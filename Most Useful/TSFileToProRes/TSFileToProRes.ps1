param(
  [string] $InputFolder,
  [string] $OutputFile,
  [string[]] $Patterns = @("*.ts", "*.mts", "*.m2ts"),
  [string] $FfmpegPath = "ffmpeg.exe",
  [string] $FfprobePath = "ffprobe.exe",
  [switch] $KeepJoinedFile
)

function Convert-TSFolderToProResProxy {
  param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string] $InputFolder,

    [Parameter(Mandatory = $true, Position = 1)]
    [string] $OutputFile,

    [string[]] $Patterns = @("*.ts", "*.mts", "*.m2ts"),

    [string] $FfmpegPath = "ffmpeg.exe",

    [string] $FfprobePath = "ffprobe.exe",

    [switch] $KeepJoinedFile
  )

  $oldErrorActionPreference = $ErrorActionPreference
  $ErrorActionPreference = "Stop"

  try {
    $ffmpegCommand = Get-Command $FfmpegPath -ErrorAction SilentlyContinue
    if (!$ffmpegCommand) {
      throw "ffmpeg was not found: $FfmpegPath"
    }

    $ffprobeCommand = Get-Command $FfprobePath -ErrorAction SilentlyContinue
    if (!$ffprobeCommand) {
      throw "ffprobe was not found: $FfprobePath"
    }

    if ([System.IO.Path]::IsPathRooted($InputFolder)) {
      $inputFolderFull = [System.IO.Path]::GetFullPath($InputFolder)
    }
    else {
      $inputFolderFull = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $InputFolder))
    }

    if ([System.IO.Path]::IsPathRooted($OutputFile)) {
      $outputFileFull = [System.IO.Path]::GetFullPath($OutputFile)
    }
    else {
      $outputFileFull = [System.IO.Path]::GetFullPath((Join-Path (Get-Location) $OutputFile))
    }

    $outputFolder = Split-Path -Parent $outputFileFull
    if ([string]::IsNullOrWhiteSpace($outputFolder)) {
      $outputFolder = Get-Location
    }

    if (!(Test-Path -LiteralPath $inputFolderFull -PathType Container)) {
      throw "Input folder does not exist: $inputFolderFull"
    }

    if (!(Test-Path -LiteralPath $outputFolder -PathType Container)) {
      New-Item -ItemType Directory -Force -Path $outputFolder | Out-Null
    }

    $files = Get-ChildItem -LiteralPath $inputFolderFull -File |
      Where-Object {
        $name = $_.Name
        $match = $false

        foreach ($pattern in $Patterns) {
          if ($name -like $pattern) {
            $match = $true
          }
        }

        $match
      } |
      Sort-Object Name

    if (!$files -or $files.Count -eq 0) {
      throw "No input files found in '$inputFolderFull' matching: $($Patterns -join ', ')"
    }

    Write-Host ""
    Write-Host "TS/MTS/M2TS to ProRes Proxy"
    Write-Host "Input:  $inputFolderFull"
    Write-Host "Output: $outputFileFull"
    Write-Host "Files:  $($files.Count)"
    Write-Host ""

    foreach ($file in $files) {
      Write-Host "  $($file.Name)"
    }

    Write-Host ""

    if (Test-Path -LiteralPath $outputFileFull) {
      Remove-Item -Force -LiteralPath $outputFileFull
    }

    $joinedFile = Join-Path $outputFolder ("{0}_JOINED_BINARY.ts" -f ([System.IO.Path]::GetFileNameWithoutExtension($outputFileFull)))

    if (Test-Path -LiteralPath $joinedFile) {
      Remove-Item -Force -LiteralPath $joinedFile
    }

    Write-Host "Step 1 of 2: binary joining files"

    $bufferSize = 64MB
    $buffer = New-Object byte[] $bufferSize
    $totalBytes = ($files | ForEach-Object { $_.Length } | Measure-Object -Sum).Sum
    $doneBytes = 0L
    $lastPrint = 0.0
    $sw = [Diagnostics.Stopwatch]::StartNew()

    $outStream = [System.IO.File]::Open(
      $joinedFile,
      [System.IO.FileMode]::CreateNew,
      [System.IO.FileAccess]::Write,
      [System.IO.FileShare]::None
    )

    try {
      foreach ($file in $files) {
        Write-Host "Joining: $($file.Name)"

        $inStream = [System.IO.File]::OpenRead($file.FullName)

        try {
          while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
            $outStream.Write($buffer, 0, $read)
            $doneBytes += $read

            if (($sw.Elapsed.TotalSeconds - $lastPrint) -ge 1) {
              $lastPrint = $sw.Elapsed.TotalSeconds
              $percent = [Math]::Round(($doneBytes / $totalBytes) * 100, 2)
              $speed = ($doneBytes / 1MB) / [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)

              Write-Host ("  {0}% | {1:N1} MiB/s" -f $percent, $speed)
            }
          }
        }
        finally {
          $inStream.Dispose()
        }
      }
    }
    finally {
      $outStream.Dispose()
      $sw.Stop()
    }

    $joinedSize = (Get-Item -LiteralPath $joinedFile).Length
    $avgSpeed = ($joinedSize / 1MB) / [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)

    Write-Host ""
    Write-Host ("Joined size: {0:N2} GiB" -f ($joinedSize / 1GB))
    Write-Host ("Join time:   {0}" -f $sw.Elapsed)
    Write-Host ("Avg speed:   {0:N1} MiB/s" -f $avgSpeed)
    Write-Host ""

    Write-Host "Step 2 of 2: converting with ffmpeg"
    Write-Host ""

    & $FfmpegPath `
      -hide_banner `
      -loglevel info `
      -stats `
      -stats_period 1 `
      -fflags +genpts+discardcorrupt `
      -err_detect ignore_err `
      -i "$joinedFile" `
      -map 0:v:0 `
      -map 0:a:0 `
      -vf "setpts=PTS-STARTPTS,bwdif=mode=send_field:parity=tff:deint=all,fps=50,format=yuv422p10le" `
      -af "aresample=async=1000:first_pts=0,asetpts=N/SR/TB" `
      -c:v prores_ks `
      -profile:v 0 `
      -vendor apl0 `
      -c:a pcm_s16le `
      -ar 48000 `
      -ac 2 `
      -f mov `
      "$outputFileFull"

    if ($LASTEXITCODE -ne 0) {
      throw "ffmpeg failed with exit code $LASTEXITCODE"
    }

    Write-Host ""
    Write-Host "ffprobe result:"
    Write-Host ""

    & $FfprobePath `
      -hide_banner `
      -show_entries format=duration,bit_rate:stream=index,codec_name,profile,width,height,pix_fmt,avg_frame_rate,r_frame_rate,field_order,bit_rate `
      -of default=noprint_wrappers=1 `
      "$outputFileFull"

    if (!$KeepJoinedFile) {
      Write-Host ""
      Write-Host "Removing temporary joined file"
      Remove-Item -Force -LiteralPath $joinedFile
    }
    else {
      Write-Host ""
      Write-Host "Temporary joined file kept:"
      Write-Host $joinedFile
    }

    Write-Host ""
    Write-Host "DONE"
    Write-Host $outputFileFull
  }
  finally {
    $ErrorActionPreference = $oldErrorActionPreference
  }
}

Set-Alias ts2prores Convert-TSFolderToProResProxy

$isDotSourced = $MyInvocation.InvocationName -eq "."

if (!$isDotSourced) {
  if ([string]::IsNullOrWhiteSpace($InputFolder) -or [string]::IsNullOrWhiteSpace($OutputFile)) {
    Write-Host ""
    Write-Host "Usage:"
    Write-Host '  .\TSFileToProRes.ps1 -InputFolder "." -OutputFile ".\output.mov" -Patterns "*.MTS"'
    Write-Host ""
    return
  }

  Convert-TSFolderToProResProxy `
    -InputFolder $InputFolder `
    -OutputFile $OutputFile `
    -Patterns $Patterns `
    -FfmpegPath $FfmpegPath `
    -FfprobePath $FfprobePath `
    -KeepJoinedFile:$KeepJoinedFile
}
