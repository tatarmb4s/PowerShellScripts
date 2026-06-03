function Join-CapturedAudioTimeline {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$Folder,

        [Parameter(Mandatory = $true)]
        [string]$DeviceName,

        [string]$OutputFolder,

        [string]$FfmpegPath = "ffmpeg",

        [string]$FfprobePath = "ffprobe",

        [switch]$Recurse,

        [switch]$Overwrite,

        [int]$SampleRate = 48000,

        [double]$GapThresholdSeconds = 0.25,

        [double]$DefaultBadChunkSeconds = 30.0
    )

    if ([string]::IsNullOrWhiteSpace($OutputFolder)) {
        $OutputFolder = $Folder
    }

    if (-not (Test-Path -LiteralPath $OutputFolder)) {
        New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null
    }

    $resolvedFolder = (Resolve-Path -LiteralPath $Folder).ProviderPath
    $resolvedOutputFolder = (Resolve-Path -LiteralPath $OutputFolder).ProviderPath

    $safeDeviceName = $DeviceName -replace '[\\/:*?"<>|]', '_'
    $runStamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $tempDir = Join-Path ([System.IO.Path]::GetTempPath()) "timeline_audio_$safeDeviceName`_$runStamp"

    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null

    function Get-WavDurationSeconds {
        param([string]$Path)

        $args = @(
            "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            $Path
        )

        $text = (& $FfprobePath @args 2>$null | Out-String).Trim()

        $value = 0.0
        if ([double]::TryParse(
            $text,
            [System.Globalization.NumberStyles]::Float,
            [System.Globalization.CultureInfo]::InvariantCulture,
            [ref]$value
        )) {
            return $value
        }

        return $null
    }

    function Test-WavDecodable {
        param([string]$Path)

        $args = @(
            "-v", "error",
            "-xerror",
            "-i", $Path,
            "-map", "0:a:0",
            "-f", "null",
            "-"
        )

        & $FfmpegPath @args 2>$null
        return ($LASTEXITCODE -eq 0)
    }

    function New-SilenceWav {
        param(
            [string]$Path,
            [double]$Seconds
        )

        if ($Seconds -le 0) {
            return
        }

        & $FfmpegPath `
            -hide_banner `
            -stats `
            -y `
            -f lavfi `
            -i "anullsrc=r=$SampleRate:cl=mono" `
            -t ("{0:0.000000}" -f $Seconds) `
            -c:a pcm_s24le `
            $Path
    }

    function ConvertTo-FfconcatLine {
        param([string]$Path)

        $full = [System.IO.Path]::GetFullPath($Path).Replace('\', '/')
        $escaped = $full.Replace("'", "'\''")
        return "file '$escaped'"
    }

    $rx = [regex]::new(
        '^(?<stamp>\d{8}_\d{6})_' + [regex]::Escape($DeviceName) + '_In_(?<input>\d+)\.wav$',
        [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    )

    $files = Get-ChildItem -LiteralPath $resolvedFolder -Filter "*.wav" -File -Recurse:$Recurse

    $items = foreach ($file in $files) {
        $m = $rx.Match($file.Name)
        if ($m.Success) {
            [PSCustomObject]@{
                File = $file
                Input = [int]$m.Groups["input"].Value
                StampText = $m.Groups["stamp"].Value
                Stamp = [datetime]::ParseExact(
                    $m.Groups["stamp"].Value,
                    "yyyyMMdd_HHmmss",
                    [System.Globalization.CultureInfo]::InvariantCulture
                )
            }
        }
    }

    if (-not $items) {
        throw "No matching files found for device '$DeviceName' in '$resolvedFolder'."
    }

    $groups = $items | Sort-Object Input | Group-Object Input

    foreach ($group in $groups) {
        $inputNumber = [int]$group.Name
        $ordered = @($group.Group | Sort-Object Stamp, StampText)

        $listPath = Join-Path $tempDir "timeline_$safeDeviceName`_In_$inputNumber.ffconcat"
        $list = New-Object System.Collections.ArrayList
        [void]$list.Add("ffconcat version 1.0")

        $report = New-Object System.Collections.ArrayList
        [void]$report.Add("Timeline rebuild report")
        [void]$report.Add("Input: $inputNumber")
        [void]$report.Add("Device: $DeviceName")
        [void]$report.Add("")

        for ($i = 0; $i -lt $ordered.Count; $i++) {
            $current = $ordered[$i]
            $next = $null

            if ($i + 1 -lt $ordered.Count) {
                $next = $ordered[$i + 1]
            }

            $duration = Get-WavDurationSeconds -Path $current.File.FullName
            $decodable = Test-WavDecodable -Path $current.File.FullName

            if ($null -eq $duration) {
                if ($null -ne $next) {
                    $duration = ($next.Stamp - $current.Stamp).TotalSeconds
                }
                else {
                    $duration = $DefaultBadChunkSeconds
                }
            }

            if ($decodable) {
                [void]$list.Add((ConvertTo-FfconcatLine -Path $current.File.FullName))
                [void]$report.Add("USE  $($current.File.Name) duration=$duration")
            }
            else {
                $repairedPath = Join-Path $tempDir ("repaired_$($current.File.BaseName).wav")

                & $FfmpegPath `
                    -hide_banner `
                    -stats `
                    -y `
                    -err_detect ignore_err `
                    -i $current.File.FullName `
                    -map 0:a:0 `
                    -c:a pcm_s24le `
                    $repairedPath

                if ($LASTEXITCODE -eq 0 -and (Test-Path -LiteralPath $repairedPath)) {
                    [void]$list.Add((ConvertTo-FfconcatLine -Path $repairedPath))
                    $duration = Get-WavDurationSeconds -Path $repairedPath
                    [void]$report.Add("REPAIR $($current.File.Name) -> $repairedPath duration=$duration")
                }
                else {
                    $silenceBadPath = Join-Path $tempDir ("silence_bad_$($current.File.BaseName).wav")
                    New-SilenceWav -Path $silenceBadPath -Seconds $duration
                    [void]$list.Add((ConvertTo-FfconcatLine -Path $silenceBadPath))
                    [void]$report.Add("SILENCE_FOR_BAD $($current.File.Name) seconds=$duration")
                }
            }

            if ($null -ne $next) {
                $expectedNextStart = $current.Stamp.AddSeconds($duration)
                $gap = ($next.Stamp - $expectedNextStart).TotalSeconds

                if ($gap -gt $GapThresholdSeconds) {
                    $silenceGapPath = Join-Path $tempDir ("silence_gap_$($current.StampText)_to_$($next.StampText)_In_$inputNumber.wav")
                    New-SilenceWav -Path $silenceGapPath -Seconds $gap
                    [void]$list.Add((ConvertTo-FfconcatLine -Path $silenceGapPath))
                    [void]$report.Add("GAP $($current.File.Name) -> $($next.File.Name) seconds=$gap")
                }
                elseif ($gap -lt (-1 * $GapThresholdSeconds)) {
                    [void]$report.Add("OVERLAP_OR_SHORT_CHUNK $($current.File.Name) -> $($next.File.Name) seconds=$gap")
                }
            }
        }

        [System.IO.File]::WriteAllLines($listPath, [string[]]$list.ToArray(), [System.Text.UTF8Encoding]::new($false))

        $outPath = Join-Path $resolvedOutputFolder "timeline_${safeDeviceName}_In_${inputNumber}.wav"

        $overwriteArg = "-n"
        if ($Overwrite) {
            $overwriteArg = "-y"
        }

        & $FfmpegPath `
            -hide_banner `
            -stats `
            $overwriteArg `
            -f concat `
            -safe 0 `
            -i $listPath `
            -map 0:a:0 `
            -c:a pcm_s24le `
            $outPath

        $reportPath = Join-Path $resolvedOutputFolder "timeline_report_${safeDeviceName}_In_${inputNumber}_$runStamp.txt"
        [void]$report.Add("")
        [void]$report.Add("Output: $outPath")
        [void]$report.Add("Concat list: $listPath")
        [System.IO.File]::WriteAllLines($reportPath, [string[]]$report.ToArray(), [System.Text.UTF8Encoding]::new($false))

        Write-Host "Created: $outPath"
        Write-Host "Report:  $reportPath"
    }

    Write-Host "Temp kept here for inspection: $tempDir"
}