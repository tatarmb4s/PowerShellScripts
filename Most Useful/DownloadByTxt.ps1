$lines = Get-Content -Path ".\ikonok.txt"
foreach ($line in $lines) {
    $fileName = Split-Path $line -Leaf
    Invoke-WebRequest -Uri $line -OutFile ".\out\$fileName"
}
