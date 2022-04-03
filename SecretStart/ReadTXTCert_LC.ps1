try 
{
    #ffff
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
        Start-Process -FilePath notepad.exe
        Start-Sleep -Seconds 3

        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{t}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{r}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{u}')


        [console]::beep(500,300)
    }elseif ($cango -eq "update") {
        Write-Host "Csak az update lesz" -ForegroundColor Green

        Start-Process -FilePath notepad.exe
        Start-Sleep -Seconds 3

        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{u}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{p}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{d}')

        [console]::beep(500,300)
        [console]::beep(500,300)
        [console]::beep(500,300)
    }elseif ($cango -eq $null) {
        Write-Host "Elérési úthiba" -ForegroundColor Red

        Start-Process -FilePath notepad.exe
        Start-Sleep -Seconds 3

        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{e}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{h}')
        $wsh = New-Object -ComObject WScript.Shell
        $wsh.SendKeys('{b}')

        [console]::beep(500,900)
        [console]::beep(500,300)
        [console]::beep(500,900)
    }else {
        try {

            $int = [int]$cango
            Write-Host ("Új forma: " + $int.GetType())

            Start-Process -FilePath notepad.exe
            Start-Sleep -Seconds 3
    
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{s}')
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{h}')
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{t}')

            Write-Host "A gép $int másodperc mulva áll le" -ForegroundColor Red
            [console]::beep(500,300)
            [console]::beep(500,900)
            [console]::beep(500,300)

            $TimeBack = $int
  
            for ($i=1; $i -le $TimeBack; $TimeBack--)
              {
               Start-Sleep -s 1 
               Write-Host $TimeBack -ForegroundColor Red
              }
            #Stop-Computer -Force
            Write-Host Leallva


        } 
        catch {
            Write-Host "    Rossz fromátum    " -BackgroundColor Red

            Start-Process -FilePath notepad.exe
            Start-Sleep -Seconds 3
    
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{b}')
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{f}')
            $wsh = New-Object -ComObject WScript.Shell
            $wsh.SendKeys('{d}')

            [console]::beep(500,300)
            [console]::beep(500,900)
            [console]::beep(500,900)
        }
    }

} 
catch {
    Write-Host "Elérési hiba vagy egyéb" -BackgroundColor Red -ForegroundColor Black

    Start-Process -FilePath notepad.exe
    Start-Sleep -Seconds 3

    $wsh = New-Object -ComObject WScript.Shell
    $wsh.SendKeys('{*}')
    $wsh = New-Object -ComObject WScript.Shell
    $wsh.SendKeys('{*}')
    $wsh = New-Object -ComObject WScript.Shell
    $wsh.SendKeys('{*}')

    [console]::beep(500,900)
    [console]::beep(500,900)
    [console]::beep(500,900)
    
}
# SIG # Begin signature block
# MIIFcAYJKoZIhvcNAQcCoIIFYTCCBV0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUbQLqMldJDYIRUqlI/UsYkkgA
# 0JCgggMKMIIDBjCCAe6gAwIBAgIQLBeC3Al8KbBEX3W/VIO5nzANBgkqhkiG9w0B
# AQsFADAbMRkwFwYDVQQDDBBBVEEgQXV0aGVudGljb2RlMB4XDTIxMDcxNTE1MDEw
# NVoXDTIyMDcxNTE1MjEwNVowGzEZMBcGA1UEAwwQQVRBIEF1dGhlbnRpY29kZTCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMLWbCqwQ6nyd5hMIWq/8l2R
# 31oR7mj6J4Cl2TPvPBWSeRGpFaykEfE/g8d7KupN+BuM0OFIk7G0oJHo6KGaJjrz
# gt+U2aNi1RDJsHFL6Qk1I+/G/N7FftYl4IcIk2n7Kwo3Rl/Tfg+gFZv/6UXyfSOW
# XYzF7+fj1zTnwhaCreItNMmuNO3Jv2T6Yfb0czNWwPwzHzatmr167eIZ4mhr6FzJ
# 0Pjh/F5oN4MhkIVRAbXpgrkBXdmll2XSpVm+FIIgzui3rlNSItsK+1s3rIOpTuZx
# EbSorFyHWZrzWjZwbrlC3NEuPZ63EQ0Jsq/sIW0x0cspi+9we8qbIHJRPMUMKRkC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBQfWMdTWTtCwI6NY2c7x8DTX0wbaDANBgkqhkiG9w0BAQsFAAOCAQEA
# MIy6Ynwixyn4sJTaeHOGihTls45wNkLUeDYJWuK69tNT7X1k+vSlfKOnchnWHebu
# lW4DRlLDsVJjb631hIFXAXXuoGDdpPc7I9MupXy3NbcW2FovSLBDGmwdt+KNnH79
# S19Rlqj7QGVhHOvFNsRzErv3OxkEIkIfc9WXEfsoUIpMqyky9V+YnkzQkawCUBJC
# MvHxMFiqt+Q3TUTOlv3X2bPhnC/cY4zszo4zHVhfZgZibkJlbgqGGBWkJGlc8kSh
# lZPLy2WBunMLMO1ZHXiBzEGnUIjZkS3tFHa613d7DKLoi+uqoQF1wPdjhv8g5Xvf
# mXflsWdNY4eQ8oATLHDdIjGCAdAwggHMAgEBMC8wGzEZMBcGA1UEAwwQQVRBIEF1
# dGhlbnRpY29kZQIQLBeC3Al8KbBEX3W/VIO5nzAJBgUrDgMCGgUAoHgwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQULnuf
# TtP0DM84HMTpQnQNLceQXpgwDQYJKoZIhvcNAQEBBQAEggEAr6hjhZf8ZbfaAsv4
# XvkUauxeJFVoAfvy1fFTLQ+6VJW3mAVeCCtq0SQlJzPnPytZfajWd2yENIYiM9Ij
# T42o+c3h0kOGmGr4Hbob0qpnPvtwi4Kc9tSNLKE/LtK0xomoAINb3ozlNNjcP9DM
# QhZmmV6LmOsZn50DkWIcIGY6snGk+QzpjVCT+rFGH/8/pQ+SA8e4gjY67M4dPXw/
# ykCkAVdS8doXJj7Jy8fDiGRGhg3+6BU9laWEgnR4HKEu1B4iXxHs54KJ3ERr4OxE
# OUhvrfSMfFW13TQgZpba8r4aHF+eI3+kfBttURB85zGnMaz6saHuscOsnjIKmvqj
# wAsQFg==
# SIG # End signature block
