$sourceLabel = "TOPHONE"
# Get Source Drive
$sourceLetter = Get-WmiObject -Class Win32_Volume | Where-Object {$_.Label -eq $sourceLabel} | select -expand name
Write-Host -NoNewline "Source: "
if ($sourceLetter) {
    Write-Host -NoNewline "found " -ForegroundColor Green
    Write-Host -NoNewline "`"$sourceLabel`"" -ForegroundColor Cyan
    Write-Host -NoNewline " at "
    Write-Host "$sourceLetter" -ForegroundColor Cyan
} else { 
    Write-Host "NOT FOUND. :(" -ForegroundColor Red 
}