param(
  [Parameter(Mandatory = $true)]
  [string] $InputFolder,

  [Parameter(Mandatory = $true)]
  [string] $OutputFile,

  [string[]] $Patterns = @("*.ts", "*.mts", "*.m2ts"),

  [string] $FfmpegPath = "ffmpeg.exe",

  [string] $FfprobePath = "ffprobe.exe",

  [switch] $KeepJoinedFile
)

$ErrorActionPreference = "Stop"

function Resolve-FullPath {
  param([string] $Path)

  if ([IO.Path]::IsPathRooted($Path)) {
    return [IO.Path]::GetFullPath($Path)
  }

  return [IO.Path]::GetFullPath((Join-Path (Get-Location) $Path))
}

$inputFolderFull = Resolve-FullPath $InputFolder
$outputFileFull = Resolve-FullPath $OutputFile
$outputFolder = Split-Path -Parent $outputFileFull

if (!(Test-Path -LiteralPath $inputFolderFull -PathType Container)) {
  throw "Input folder does not exist: $inputFolderFull"
}

if (!(Test-Path -LiteralPath $outputFolder -PathType Container)) {
  New-Item -ItemType Directory -Force -Verbose -Path $outputFolder | Out-Null
}

$files = Get-ChildItem -LiteralPath $inputFolderFull -File |
  Where-Object {
    $fileName = $_.Name
    $Patterns | Where-Object { $fileName -like $_ }
  } |
  Sort-Object Name

if ($files.Count -eq 0) {
  throw "No input files found in '$inputFolderFull' matching: $($Patterns -join ', ')"
}

Write-Host ""
Write-Host "Input folder: $inputFolderFull"
Write-Host "Output file:  $outputFileFull"
Write-Host "Found files:"
$files | ForEach-Object { Write-Host "  $($_.Name)" }
Write-Host ""

if (Test-Path -LiteralPath $outputFileFull) {
  Remove-Item -Force -Verbose -LiteralPath $outputFileFull
}

$joinedFile = Join-Path $outputFolder ("{0}_JOINED_BINARY.ts" -f ([IO.Path]::GetFileNameWithoutExtension($outputFileFull)))

if (Test-Path -LiteralPath $joinedFile) {
  Remove-Item -Force -Verbose -LiteralPath $joinedFile
}

Write-Host "Step 1/2: Binary joining source files..."
Write-Host "Joined temp file: $joinedFile"
Write-Host ""

$bufferSize = 64MB
$buffer = New-Object byte[] $bufferSize
$totalBytes = ($files | ForEach-Object { $_.Length } | Measure-Object -Sum).Sum
$doneBytes = 0L
$sw = [Diagnostics.Stopwatch]::StartNew()

$outStream = [IO.File]::Open($joinedFile, [IO.FileMode]::CreateNew, [IO.FileAccess]::Write, [IO.FileShare]::None)

try {
  foreach ($file in $files) {
    Write-Host "Joining $($file.FullName) ..."

    $inStream = [IO.File]::OpenRead($file.FullName)

    try {
      while (($read = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
        $outStream.Write($buffer, 0, $read)
        $doneBytes += $read

        $percent = [Math]::Round(($doneBytes / $totalBytes) * 100, 2)
        $speed = ($doneBytes / 1MB) / [Math]::Max($sw.Elapsed.TotalSeconds, 0.001)

        Write-Progress `
          -Activity "Binary joining transport-stream files" `
          -Status ("{0}% | {1:N1} MiB/s | {2}" -f $percent, $speed, $file.Name) `
          -PercentComplete $percent
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

Write-Host ""
Write-Host ("Binary join done: {0:N2} GiB in {1:c} | avg {2:N1} MiB/s" -f `
  ($joinedSize / 1GB), `
  $sw.Elapsed, `
  (($joinedSize / 1MB) / [Math]::Max($sw.Elapsed.TotalSeconds, 0.001))
)
Write-Host ""

Write-Host "Step 2/2: Converting to Premiere-friendly ProRes Proxy MOV..."
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
  throw "FFmpeg failed with exit code $LASTEXITCODE"
}

Write-Host ""
Write-Host "Conversion complete."
Write-Host "Output:"
Write-Host "  $outputFileFull"
Write-Host ""

Write-Host "Probing output..."
Write-Host ""

& $FfprobePath `
  -hide_banner `
  -show_entries format=duration,bit_rate:stream=index,codec_name,profile,width,height,pix_fmt,avg_frame_rate,r_frame_rate,field_order,bit_rate `
  -of default=noprint_wrappers=1 `
  "$outputFileFull"

if (!$KeepJoinedFile) {
  Write-Host ""
  Write-Host "Removing temporary joined file..."
  Remove-Item -Force -Verbose -LiteralPath $joinedFile
} else {
  Write-Host ""
  Write-Host "Kept temporary joined file:"
  Write-Host "  $joinedFile"
}

Write-Host ""
Write-Host "DONE"