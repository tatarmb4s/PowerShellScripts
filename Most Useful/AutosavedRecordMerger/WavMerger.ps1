function Join-CapturedAudioByInput {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Folder,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$DeviceName,

        [Parameter(Mandatory = $false)]
        [string]$OutputFolder,

        [Parameter(Mandatory = $false)]
        [string]$FfmpegPath = "ffmpeg",

        [Parameter(Mandatory = $false)]
        [string]$FfprobePath = "ffprobe",

        [Parameter(Mandatory = $false)]
        [switch]$Recurse,

        [Parameter(Mandatory = $false)]
        [switch]$Overwrite,

        [Parameter(Mandatory = $false)]
        [switch]$SkipDecodeCheck,

        [Parameter(Mandatory = $false)]
        [switch]$KeepTemp,

        [Parameter(Mandatory = $false)]
        [int]$ExpectedChunkSeconds = 30,

        [Parameter(Mandatory = $false)]
        [double]$GapToleranceSeconds = 3.0
    )

    function Resolve-ExternalTool {
        param(
            [Parameter(Mandatory = $true)]
            [string]$ToolName
        )

        $cmd = Get-Command -Name $ToolName -CommandType Application -ErrorAction SilentlyContinue
        if ($null -eq $cmd) {
            throw "Cannot find '$ToolName'. Install FFmpeg, add it to PATH, or pass -FfmpegPath and -FfprobePath."
        }

        return $cmd.Source
    }

    function ConvertTo-FfconcatFileLine {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path
        )

        $fullPath = [System.IO.Path]::GetFullPath($Path)
        $portablePath = $fullPath.Replace('\', '/')
        $escapedPath = $portablePath.Replace("'", "'\''")
        return "file '$escapedPath'"
    }

    function Test-AudioFileForJoin {
        param(
            [Parameter(Mandatory = $true)]
            [string]$Path,

            [Parameter(Mandatory = $true)]
            [string]$FfprobeExe,

            [Parameter(Mandatory = $true)]
            [string]$FfmpegExe,

            [Parameter(Mandatory = $true)]
            [bool]$DoDecodeCheck
        )

        $probeArgs = @(
            "-v", "error",
            "-select_streams", "a:0",
            "-show_entries", "stream=codec_name,sample_fmt,sample_rate,channels,bits_per_sample,bits_per_raw_sample,channel_layout:format=duration",
            "-of", "json",
            $Path
        )

        $probeOutput = & $FfprobeExe @probeArgs 2>&1
        $probeExit = $LASTEXITCODE
        $probeText = ($probeOutput | Out-String).Trim()

        if ($probeExit -ne 0) {
            return [PSCustomObject]@{
                IsValid   = $false
                Signature = ""
                Duration  = $null
                Error     = "ffprobe failed: $probeText"
            }
        }

        if ([string]::IsNullOrWhiteSpace($probeText)) {
            return [PSCustomObject]@{
                IsValid   = $false
                Signature = ""
                Duration  = $null
                Error     = "ffprobe returned empty output"
            }
        }

        try {
            $probeJson = $probeText | ConvertFrom-Json -ErrorAction Stop
        }
        catch {
            return [PSCustomObject]@{
                IsValid   = $false
                Signature = ""
                Duration  = $null
                Error     = "ffprobe JSON parse failed: $($_.Exception.Message)"
            }
        }

        $streams = @($probeJson.streams)
        if ($streams.Count -lt 1) {
            return [PSCustomObject]@{
                IsValid   = $false
                Signature = ""
                Duration  = $null
                Error     = "no audio stream found"
            }
        }

        $stream = $streams[0]

        $bits = ""
        if ($null -ne $stream.bits_per_sample -and [string]$stream.bits_per_sample -ne "0") {
            $bits = [string]$stream.bits_per_sample
        }
        elseif ($null -ne $stream.bits_per_raw_sample -and [string]$stream.bits_per_raw_sample -ne "0") {
            $bits = [string]$stream.bits_per_raw_sample
        }

        $signature = @(
            "codec=$($stream.codec_name)",
            "sample_fmt=$($stream.sample_fmt)",
            "sample_rate=$($stream.sample_rate)",
            "channels=$($stream.channels)",
            "bits=$bits"
        ) -join ";"

        $duration = $null
        if ($null -ne $probeJson.format -and $null -ne $probeJson.format.duration) {
            $durationValue = 0.0
            $durationText = [string]$probeJson.format.duration
            $numberStyle = [System.Globalization.NumberStyles]::Float
            $culture = [System.Globalization.CultureInfo]::InvariantCulture

            if ([double]::TryParse($durationText, $numberStyle, $culture, [ref]$durationValue)) {
                $duration = $durationValue
            }
        }

        if ($DoDecodeCheck) {
            $decodeArgs = @(
                "-v", "error",
                "-xerror",
                "-i", $Path,
                "-map", "0:a:0",
                "-f", "null",
                "-"
            )

            $decodeOutput = & $FfmpegExe @decodeArgs 2>&1
            $decodeExit = $LASTEXITCODE
            $decodeText = ($decodeOutput | Out-String).Trim()

            if ($decodeExit -ne 0) {
                return [PSCustomObject]@{
                    IsValid   = $false
                    Signature = $signature
                    Duration  = $duration
                    Error     = "decode check failed: $decodeText"
                }
            }
        }

        return [PSCustomObject]@{
            IsValid   = $true
            Signature = $signature
            Duration  = $duration
            Error     = ""
        }
    }

    $ffmpegExe = Resolve-ExternalTool -ToolName $FfmpegPath
    $ffprobeExe = Resolve-ExternalTool -ToolName $FfprobePath

    $resolvedFolder = (Resolve-Path -LiteralPath $Folder -ErrorAction Stop).ProviderPath

    if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
        $resolvedOutputFolder = $resolvedFolder
    }
    else {
        if (-not (Test-Path -LiteralPath $OutputFolder)) {
            [void](New-Item -ItemType Directory -Path $OutputFolder -Force)
        }

        $resolvedOutputFolder = (Resolve-Path -LiteralPath $OutputFolder -ErrorAction Stop).ProviderPath
    }

    $safeDeviceName = $DeviceName -replace '[\\/:*?"<>|]', '_'
    $runStamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $reportPath = Join-Path $resolvedOutputFolder ("combine_report_{0}_{1}.txt" -f $safeDeviceName, $runStamp)

    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) ("join_audio_{0}_{1}" -f $safeDeviceName, [guid]::NewGuid().ToString("N"))
    [void](New-Item -ItemType Directory -Path $tempDir -Force)

    $reportLines = New-Object System.Collections.ArrayList
    $resultRows = New-Object System.Collections.ArrayList
    $badRows = New-Object System.Collections.ArrayList

    [void]$reportLines.Add("Combine captured audio report")
    [void]$reportLines.Add("Started: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
    [void]$reportLines.Add("Folder: $resolvedFolder")
    [void]$reportLines.Add("OutputFolder: $resolvedOutputFolder")
    [void]$reportLines.Add("DeviceName: $DeviceName")
    [void]$reportLines.Add("Recurse: $Recurse")
    [void]$reportLines.Add("Overwrite: $Overwrite")
    [void]$reportLines.Add("SkipDecodeCheck: $SkipDecodeCheck")
    [void]$reportLines.Add("")

    try {
        $rxOptions = [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
        $pattern = '^(?<stamp>\d{8}_\d{6})_' + [regex]::Escape($DeviceName) + '_In_(?<input>\d+)\.wav$'
        $rx = New-Object -TypeName System.Text.RegularExpressions.Regex -ArgumentList $pattern, $rxOptions

        $allFiles = @(Get-ChildItem -LiteralPath $resolvedFolder -Filter "*.wav" -File -Recurse:$Recurse -ErrorAction Stop)
        $items = New-Object System.Collections.ArrayList

        foreach ($file in $allFiles) {
            $match = $rx.Match($file.Name)
            if ($match.Success) {
                $stampText = $match.Groups["stamp"].Value
                $inputNumber = [int]($match.Groups["input"].Value)
                $stamp = [datetime]::ParseExact(
                    $stampText,
                    "yyyyMMdd_HHmmss",
                    [System.Globalization.CultureInfo]::InvariantCulture
                )

                [void]$items.Add([PSCustomObject]@{
                    File      = $file
                    StampText = $stampText
                    Stamp     = $stamp
                    Input     = $inputNumber
                    Signature = ""
                    Duration  = $null
                })
            }
        }

        if ($items.Count -eq 0) {
            $message = "No matching files found for device '$DeviceName' in '$resolvedFolder'."
            Write-Warning $message
            [void]$reportLines.Add($message)

            $utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false
            [System.IO.File]::WriteAllLines($reportPath, [string[]]$reportLines.ToArray(), $utf8NoBom)

            return [PSCustomObject]@{
                Status     = "NoMatchingFiles"
                ReportPath = $reportPath
            }
        }

        Write-Host ("Found {0} matching file(s) for device {1}." -f $items.Count, $DeviceName)

        $groups = $items | Sort-Object -Property Input | Group-Object -Property Input
        $doDecodeCheck = -not [bool]$SkipDecodeCheck
        $utf8NoBom = New-Object -TypeName System.Text.UTF8Encoding -ArgumentList $false

        foreach ($group in $groups) {
            $inputNumber = [int]$group.Name
            $ordered = @($group.Group | Sort-Object -Property Stamp, StampText)
            $good = New-Object System.Collections.ArrayList
            $referenceSignature = $null
            $checkedCount = 0

            Write-Host ("Checking input {0}: {1} file(s)" -f $inputNumber, $ordered.Count)

            foreach ($item in $ordered) {
                $checkedCount++
                $percent = [int](($checkedCount / [double]$ordered.Count) * 100)

                Write-Progress `
                    -Activity ("Checking input {0}" -f $inputNumber) `
                    -Status $item.File.Name `
                    -PercentComplete $percent

                $probe = Test-AudioFileForJoin `
                    -Path $item.File.FullName `
                    -FfprobeExe $ffprobeExe `
                    -FfmpegExe $ffmpegExe `
                    -DoDecodeCheck $doDecodeCheck

                if (-not $probe.IsValid) {
                    $reason = $probe.Error
                    Write-Warning ("Skipping bad file: {0} -- {1}" -f $item.File.FullName, $reason)

                    [void]$badRows.Add([PSCustomObject]@{
                        Input   = $inputNumber
                        File    = $item.File.FullName
                        Reason  = "BadFile"
                        Details = $reason
                    })

                    continue
                }

                if ($null -eq $referenceSignature) {
                    $referenceSignature = $probe.Signature
                }
                elseif ($probe.Signature -ne $referenceSignature) {
                    $reason = "audio format differs from first good file. Expected '$referenceSignature', got '$($probe.Signature)'"
                    Write-Warning ("Skipping incompatible file: {0} -- {1}" -f $item.File.FullName, $reason)

                    [void]$badRows.Add([PSCustomObject]@{
                        Input   = $inputNumber
                        File    = $item.File.FullName
                        Reason  = "FormatMismatch"
                        Details = $reason
                    })

                    continue
                }

                $item.Signature = $probe.Signature
                $item.Duration = $probe.Duration
                [void]$good.Add($item)
            }

            Write-Progress -Activity ("Checking input {0}" -f $inputNumber) -Completed

            if ($good.Count -eq 0) {
                [void]$resultRows.Add([PSCustomObject]@{
                    Input                = $inputNumber
                    Status               = "NoGoodFiles"
                    OutputPath           = ""
                    GoodFiles            = 0
                    SkippedFiles         = $ordered.Count
                    TotalDurationSeconds = $null
                })

                continue
            }

            if ($ExpectedChunkSeconds -gt 0 -and $good.Count -gt 1) {
                for ($i = 1; $i -lt $good.Count; $i++) {
                    $previous = $good[$i - 1]
                    $current = $good[$i]
                    $deltaSeconds = ($current.Stamp - $previous.Stamp).TotalSeconds

                    if ([math]::Abs($deltaSeconds - $ExpectedChunkSeconds) -gt $GapToleranceSeconds) {
                        $gapMessage = "Input $inputNumber timestamp jump: $($previous.File.Name) -> $($current.File.Name), delta $deltaSeconds seconds, expected about $ExpectedChunkSeconds seconds."
                        Write-Warning $gapMessage

                        [void]$badRows.Add([PSCustomObject]@{
                            Input   = $inputNumber
                            File    = $current.File.FullName
                            Reason  = "TimestampGap"
                            Details = $gapMessage
                        })
                    }
                }
            }

            $listPath = Join-Path $tempDir ("concat_{0}_in_{1}.ffconcat" -f $safeDeviceName, $inputNumber)
            $listLines = @("ffconcat version 1.0")

            foreach ($goodItem in $good) {
                $listLines += ConvertTo-FfconcatFileLine -Path $goodItem.File.FullName
            }

            [System.IO.File]::WriteAllLines($listPath, [string[]]$listLines, $utf8NoBom)

            $outputPath = Join-Path $resolvedOutputFolder ("combined_{0}_In_{1}.wav" -f $safeDeviceName, $inputNumber)

            if ((Test-Path -LiteralPath $outputPath) -and -not $Overwrite) {
                $reason = "Output already exists. Use -Overwrite to replace it: $outputPath"
                Write-Warning $reason

                [void]$resultRows.Add([PSCustomObject]@{
                    Input                = $inputNumber
                    Status               = "SkippedOutputExists"
                    OutputPath           = $outputPath
                    GoodFiles            = $good.Count
                    SkippedFiles         = $ordered.Count - $good.Count
                    TotalDurationSeconds = $null
                })

                continue
            }

            $ffmpegArgs = @("-hide_banner", "-stats")

            if ($Overwrite) {
                $ffmpegArgs += "-y"
            }
            else {
                $ffmpegArgs += "-n"
            }

            $ffmpegArgs += @(
                "-f", "concat",
                "-safe", "0",
                "-i", $listPath,
                "-map", "0:a:0",
                "-c", "copy",
                $outputPath
            )

            Write-Host ("Creating: {0}" -f $outputPath)
            & $ffmpegExe @ffmpegArgs
            $ffmpegExit = $LASTEXITCODE

            $totalDuration = 0.0
            $hasDuration = $false

            foreach ($goodItem in $good) {
                if ($null -ne $goodItem.Duration) {
                    $totalDuration += [double]$goodItem.Duration
                    $hasDuration = $true
                }
            }

            $durationForResult = $null
            if ($hasDuration) {
                $durationForResult = $totalDuration
            }

            if ($ffmpegExit -ne 0) {
                Write-Warning ("FFmpeg failed for input {0} with exit code {1}." -f $inputNumber, $ffmpegExit)

                [void]$resultRows.Add([PSCustomObject]@{
                    Input                = $inputNumber
                    Status               = "FfmpegFailed"
                    OutputPath           = $outputPath
                    GoodFiles            = $good.Count
                    SkippedFiles         = $ordered.Count - $good.Count
                    TotalDurationSeconds = $durationForResult
                })
            }
            else {
                [void]$resultRows.Add([PSCustomObject]@{
                    Input                = $inputNumber
                    Status               = "Created"
                    OutputPath           = $outputPath
                    GoodFiles            = $good.Count
                    SkippedFiles         = $ordered.Count - $good.Count
                    TotalDurationSeconds = $durationForResult
                })
            }
        }

        [void]$reportLines.Add("Outputs")
        [void]$reportLines.Add("-------")

        foreach ($row in $resultRows) {
            $durationText = ""
            if ($null -ne $row.TotalDurationSeconds) {
                $durationText = "{0:n2}" -f [double]$row.TotalDurationSeconds
            }

            [void]$reportLines.Add(("Input {0}: {1}; good={2}; skipped={3}; duration_seconds={4}; output={5}" -f `
                $row.Input, $row.Status, $row.GoodFiles, $row.SkippedFiles, $durationText, $row.OutputPath))
        }

        [void]$reportLines.Add("")
        [void]$reportLines.Add("Skipped, bad, or suspicious files")
        [void]$reportLines.Add("----------------------------------")

        if ($badRows.Count -eq 0) {
            [void]$reportLines.Add("None")
        }
        else {
            foreach ($bad in $badRows) {
                [void]$reportLines.Add(("Input {0}: {1}; file={2}; details={3}" -f `
                    $bad.Input, $bad.Reason, $bad.File, $bad.Details))
            }
        }

        [void]$reportLines.Add("")
        [void]$reportLines.Add("Finished: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")

        [System.IO.File]::WriteAllLines($reportPath, [string[]]$reportLines.ToArray(), $utf8NoBom)

        Write-Host ("Report: {0}" -f $reportPath)

        return [PSCustomObject]@{
            Status       = "Done"
            DeviceName   = $DeviceName
            Folder       = $resolvedFolder
            OutputFolder = $resolvedOutputFolder
            ReportPath   = $reportPath
            Outputs      = @($resultRows)
            Skipped      = @($badRows)
        }
    }
    finally {
        if ((Test-Path -LiteralPath $tempDir) -and -not $KeepTemp) {
            Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
        }
        elseif ($KeepTemp) {
            Write-Host ("Temp kept: {0}" -f $tempDir)
        }
    }
}