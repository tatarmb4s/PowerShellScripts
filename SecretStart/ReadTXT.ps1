try 
{
    
    $sourceLabel = "TOPHONE"
    $sourceLetter = Get-WmiObject -Class Win32_Volume | Where-Object {$_.Label -eq $sourceLabel} | select -expand name
    #$cango = Get-Content -Path $sourceLetter\cango2021.txt
    $cango

    try {
        $cango = Get-Content -Path $sourceLetter\cango2021.txt
        Write-Host "Eredeti forma: $gotype"
    }
    catch {
        $cango = "Error"
    }

    $gotype = $cango.GetType();
    
    if ($cango -eq "true") {
        Write-Host "A gép megy" -ForegroundColor Cyan
        [console]::beep(500,300)
    }elseif ($cango -eq "update") {
        Write-Host "Csak az update lesz" -ForegroundColor Green

        [console]::beep(500,300)
        [console]::beep(500,300)
        [console]::beep(500,300)
    }elseif ($cango -eq $null) {
        Write-Host "Elérési úthiba" -ForegroundColor Red

        [console]::beep(500,900)
        [console]::beep(500,300)
        [console]::beep(500,900)
    }else {
        try {

            $int = [int]$cango
            Write-Host ("Új forma: " + $int.GetType())

            Write-Host "A gép $int másodperc mulva áll le" -ForegroundColor Red
            [console]::beep(500,300)
            [console]::beep(500,900)
            [console]::beep(500,300)

        } 
        catch {
            Write-Host "    Rossz fromátum    " -BackgroundColor Red
            [console]::beep(500,300)
            [console]::beep(500,900)
            [console]::beep(500,900)
        }
    }

} 
catch {
    Write-Host "Elérési hiba vagy egyéb" -BackgroundColor Red -ForegroundColor Black
    [console]::beep(500,900)
    [console]::beep(500,900)
    [console]::beep(500,900)
    
}
