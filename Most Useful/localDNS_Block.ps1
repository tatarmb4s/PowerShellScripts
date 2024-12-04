param([int]$action)

# URL to block/unblock
$url = "api.ipregistry.co"

# Path to hosts file
$hostsPath = "$env:windir\System32\drivers\etc\hosts"

# Check if URL is already in hosts file
$urlInHosts = (Get-Content -Path $hostsPath) -match $url

if ($action -eq 1) {
    # Block URL
    if (-not $urlInHosts) {
        Add-Content -Path $hostsPath -Value "127.0.0.1 $url"
        Write-Host "Blocked $url"
    } else {
        Write-Host "$url is already blocked"
    }
} elseif ($action -eq 0) {
    # Unblock URL
    if ($urlInHosts) {
        (Get-Content -Path $hostsPath) | Where-Object { $_ -notmatch $url } | Set-Content -Path $hostsPath
        Write-Host "Unblocked $url"
    } else {
        Write-Host "$url is not blocked"
    }
} else {
    Write-Host "Invalid parameter. Use 1 to block, 0 to unblock."
}