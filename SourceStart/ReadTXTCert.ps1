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
            Stop-Computer -Force
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
# MIIR2wYJKoZIhvcNAQcCoIIRzDCCEcgCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUxPP0B6Iqklt1ZXwYBOsZ3sIf
# DLGggg1BMIIDBjCCAe6gAwIBAgIQLBeC3Al8KbBEX3W/VIO5nzANBgkqhkiG9w0B
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
# mXflsWdNY4eQ8oATLHDdIjCCBP4wggPmoAMCAQICEA1CSuC+Ooj/YEAhzhQA8N0w
# DQYJKoZIhvcNAQELBQAwcjELMAkGA1UEBhMCVVMxFTATBgNVBAoTDERpZ2lDZXJ0
# IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTExMC8GA1UEAxMoRGlnaUNl
# cnQgU0hBMiBBc3N1cmVkIElEIFRpbWVzdGFtcGluZyBDQTAeFw0yMTAxMDEwMDAw
# MDBaFw0zMTAxMDYwMDAwMDBaMEgxCzAJBgNVBAYTAlVTMRcwFQYDVQQKEw5EaWdp
# Q2VydCwgSW5jLjEgMB4GA1UEAxMXRGlnaUNlcnQgVGltZXN0YW1wIDIwMjEwggEi
# MA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDC5mGEZ8WK9Q0IpEXKY2tR1zoR
# Qr0KdXVNlLQMULUmEP4dyG+RawyW5xpcSO9E5b+bYc0VkWJauP9nC5xj/TZqgfop
# +N0rcIXeAhjzeG28ffnHbQk9vmp2h+mKvfiEXR52yeTGdnY6U9HR01o2j8aj4S8b
# Ordh1nPsTm0zinxdRS1LsVDmQTo3VobckyON91Al6GTm3dOPL1e1hyDrDo4s1SPa
# 9E14RuMDgzEpSlwMMYpKjIjF9zBa+RSvFV9sQ0kJ/SYjU/aNY+gaq1uxHTDCm2mC
# tNv8VlS8H6GHq756WwogL0sJyZWnjbL61mOLTqVyHO6fegFz+BnW/g1JhL0BAgMB
# AAGjggG4MIIBtDAOBgNVHQ8BAf8EBAMCB4AwDAYDVR0TAQH/BAIwADAWBgNVHSUB
# Af8EDDAKBggrBgEFBQcDCDBBBgNVHSAEOjA4MDYGCWCGSAGG/WwHATApMCcGCCsG
# AQUFBwIBFhtodHRwOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwHwYDVR0jBBgwFoAU
# 9LbhIB3+Ka7S5GGlsqIlssgXNW4wHQYDVR0OBBYEFDZEho6kurBmvrwoLR1ENt3j
# anq8MHEGA1UdHwRqMGgwMqAwoC6GLGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9z
# aGEyLWFzc3VyZWQtdHMuY3JsMDKgMKAuhixodHRwOi8vY3JsNC5kaWdpY2VydC5j
# b20vc2hhMi1hc3N1cmVkLXRzLmNybDCBhQYIKwYBBQUHAQEEeTB3MCQGCCsGAQUF
# BzABhhhodHRwOi8vb2NzcC5kaWdpY2VydC5jb20wTwYIKwYBBQUHMAKGQ2h0dHA6
# Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydFNIQTJBc3N1cmVkSURUaW1l
# c3RhbXBpbmdDQS5jcnQwDQYJKoZIhvcNAQELBQADggEBAEgc3LXpmiO85xrnIA6O
# Z0b9QnJRdAojR6OrktIlxHBZvhSg5SeBpU0UFRkHefDRBMOG2Tu9/kQCZk3taaQP
# 9rhwz2Lo9VFKeHk2eie38+dSn5On7UOee+e03UEiifuHokYDTvz0/rdkd2NfI1Jp
# g4L6GlPtkMyNoRdzDfTzZTlwS/Oc1np72gy8PTLQG8v1Yfx1CAB2vIEO+MDhXM/E
# EXLnG2RJ2CKadRVC9S0yOIHa9GCiurRS+1zgYSQlT7LfySmoc0NR2r1j1h9bm/cu
# G08THfdKDXF+l7f0P4TrweOjSaH6zqe/Vs+6WXZhiV9+p7SOZ3j5NpjhyyjaW4em
# ii8wggUxMIIEGaADAgECAhAKoSXW1jIbfkHkBdo2l8IVMA0GCSqGSIb3DQEBCwUA
# MGUxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsT
# EHd3dy5kaWdpY2VydC5jb20xJDAiBgNVBAMTG0RpZ2lDZXJ0IEFzc3VyZWQgSUQg
# Um9vdCBDQTAeFw0xNjAxMDcxMjAwMDBaFw0zMTAxMDcxMjAwMDBaMHIxCzAJBgNV
# BAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdp
# Y2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0IFNIQTIgQXNzdXJlZCBJRCBUaW1l
# c3RhbXBpbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC90DLu
# S82Pf92puoKZxTlUKFe2I0rEDgdFM1EQfdD5fU1ofue2oPSNs4jkl79jIZCYvxO8
# V9PD4X4I1moUADj3Lh477sym9jJZ/l9lP+Cb6+NGRwYaVX4LJ37AovWg4N4iPw7/
# fpX786O6Ij4YrBHk8JkDbTuFfAnT7l3ImgtU46gJcWvgzyIQD3XPcXJOCq3fQDpc
# t1HhoXkUxk0kIzBdvOw8YGqsLwfM/fDqR9mIUF79Zm5WYScpiYRR5oLnRlD9lCos
# p+R1PrqYD4R/nzEU1q3V8mTLex4F0IQZchfxFwbvPc3WTe8GQv2iUypPhR3EHTyv
# z9qsEPXdrKzpVv+TAgMBAAGjggHOMIIByjAdBgNVHQ4EFgQU9LbhIB3+Ka7S5GGl
# sqIlssgXNW4wHwYDVR0jBBgwFoAUReuir/SSy4IxLVGLp6chnfNtyA8wEgYDVR0T
# AQH/BAgwBgEB/wIBADAOBgNVHQ8BAf8EBAMCAYYwEwYDVR0lBAwwCgYIKwYBBQUH
# AwgweQYIKwYBBQUHAQEEbTBrMCQGCCsGAQUFBzABhhhodHRwOi8vb2NzcC5kaWdp
# Y2VydC5jb20wQwYIKwYBBQUHMAKGN2h0dHA6Ly9jYWNlcnRzLmRpZ2ljZXJ0LmNv
# bS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RDQS5jcnQwgYEGA1UdHwR6MHgwOqA4oDaG
# NGh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFzc3VyZWRJRFJvb3RD
# QS5jcmwwOqA4oDaGNGh0dHA6Ly9jcmwzLmRpZ2ljZXJ0LmNvbS9EaWdpQ2VydEFz
# c3VyZWRJRFJvb3RDQS5jcmwwUAYDVR0gBEkwRzA4BgpghkgBhv1sAAIEMCowKAYI
# KwYBBQUHAgEWHGh0dHBzOi8vd3d3LmRpZ2ljZXJ0LmNvbS9DUFMwCwYJYIZIAYb9
# bAcBMA0GCSqGSIb3DQEBCwUAA4IBAQBxlRLpUYdWac3v3dp8qmN6s3jPBjdAhO9L
# hL/KzwMC/cWnww4gQiyvd/MrHwwhWiq3BTQdaq6Z+CeiZr8JqmDfdqQ6kw/4stHY
# fBli6F6CJR7Euhx7LCHi1lssFDVDBGiy23UC4HLHmNY8ZOUfSBAYX4k4YU1iRiSH
# Y4yRUiyvKYnleB/WCxSlgNcSR3CzddWThZN+tpJn+1Nhiaj1a5bA9FhpDXzIAbG5
# KHW3mWOFIoxhynmUfln8jA/jb7UBJrZspe6HUSHkWGCbugwtK22ixH67xCUrRwII
# fEmuE7bhfEJCKMYYVs9BNLZmXbZ0e/VWMyIvIjayS6JKldj1po5SMYIEBDCCBAAC
# AQEwLzAbMRkwFwYDVQQDDBBBVEEgQXV0aGVudGljb2RlAhAsF4LcCXwpsERfdb9U
# g7mfMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkGCSqG
# SIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEEAYI3
# AgEVMCMGCSqGSIb3DQEJBDEWBBR1ML/5+n7Gm3I/ouXF9QfSQ2OBazANBgkqhkiG
# 9w0BAQEFAASCAQArZuWZhoZOwatV29JbfQIfjZpdNcKCn81rnvW5QWk8G9fJ2iFU
# OjOkVw6dSjR/JmAaY2BOjwXVKsq5ebXy4gVtrNZ02uG9XJBgaNecoe+eWH60MtOc
# YerINvQLM2kruQD3AU0E8NPBaOos36/NwCMWISUheZbmPxkaeadEw96l9gUf6HFT
# RhvAbTg2bhK+z2RBhukbSYwjRYq4avxQ3lcLomCn0XNGtxzZRVj0/O8jo64yRBxu
# 7tBmP779m29VHnSV3y9nWcexYUpEHADfDMwUwWhZ3+XjxTX547Hs6SSrlUic7BxT
# b7g6tYj3pSArU6XOnrZI5TX1ulF2xCcBCym8oYICMDCCAiwGCSqGSIb3DQEJBjGC
# Ah0wggIZAgEBMIGGMHIxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxEaWdpQ2VydCBJ
# bmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xMTAvBgNVBAMTKERpZ2lDZXJ0
# IFNIQTIgQXNzdXJlZCBJRCBUaW1lc3RhbXBpbmcgQ0ECEA1CSuC+Ooj/YEAhzhQA
# 8N0wDQYJYIZIAWUDBAIBBQCgaTAYBgkqhkiG9w0BCQMxCwYJKoZIhvcNAQcBMBwG
# CSqGSIb3DQEJBTEPFw0yMTA3MTUxNjAxNTJaMC8GCSqGSIb3DQEJBDEiBCBswMmU
# aD085YcfsOOvmgmuV/kn7MgdbbG6v9OGapWEwTANBgkqhkiG9w0BAQEFAASCAQAH
# E4ZqQTCPV4xljF/63X4qyu0EDMfNbHVlG0MqfPNDfYwMspeZEXTNPDyOh3GkGoE9
# nifrEH0Tt8PbS8x/tQoyrrC6rj4EbxgDhe6BTcBZje5y7ZZfAajvXn+40pGRvqvy
# A6Pc5456Wlt8N/9354zQG8SjyFgTh6bOQH1Wd5Dq6wYDvhwR+g/K5krUK/92zvRa
# Em8EOXNj4B+Pyhrnx+8FQOsUxjct1ORvFBjpSONfVTMlp2tYaScTtRFNhoX94TxM
# WoK8TG/Eh/czj6rR82BC5xswDF7i2PFlOe6hycc2eUf7YdWc3G6tgYYIAexLB3K5
# vd9bWkjQF4rz/wCZEd5x
# SIG # End signature block
