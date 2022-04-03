#This script gets out the most comonn informations from the computer

# $ComputerInfo = Get-ComputerInfo | Select-Object CsName, WindowsProductName, WindowsCurrentVersion, CsManufacturer, CsModel, BiosSeralNumber;

# Alaphelyzetbe allitas
$ActualDateTime = $null;
$win32bios = $null;
$Win32ComputerSystem = $null;
$Win32OperatingSystem = $null;
$LogFile = $null;
$LogfileData = $null;
$Counter = $null;


# Adatok lekerdezese
Try {
        $ActualDateTime = Get-Date -Format ("yyyy-MM-dd HH:mm:ss");
        $win32bios = Get-WmiObject -Class win32_bios | Select-Object PSComputerName, SerialNumber;
        $Win32ComputerSystem = Get-WMIObject -class Win32_ComputerSystem | Select-Object Manufacturer, Model, UserName;
        $Win32OperatingSystem = Get-WMIObject -class Win32_OperatingSystem | Select-Object BuildNumber, Caption; 
        $LogFile = 'G:\PowerShell\GetComputerDatas.csv';
    }
    Catch
        {
            Write-Host 'Az adatok lekerdezese nem sikerult.';
        }

# Adatok atadasa
Try {
        # Naplo fejlec
        $LogHeader = 'DateTime;UserName;PSComputerName;SerialNumber;Manufacturer;Model;Caption;BuildNumber';
        # Lekert adatok atadasa
        $Log = $ActualDateTime+';'+$Win32ComputerSystem.UserName+';'+$win32bios.PSComputerName+';'+$win32bios.SerialNumber+';'+$Win32ComputerSystem.Manufacturer+';'+$Win32ComputerSystem.Model+';'+$Win32OperatingSystem.Caption+';'+$Win32OperatingSystem.BuildNumber;
    }
    Catch
        {
            Write-Host 'Az adatok atadasa nem sikerult.';
        }

# Log fajl megletenek ellenorzese
Try {
        If ((Test-Path ($LogFile)) -eq $True)
            {
                Write-Host 'van';
                Try {
                        $LogfileDatas = Import-Csv -Path $LogFile -Delimiter ';';
                        $LogfileDatas.GetType()
                        Foreach ($LogfileData in $LogfileDatas)
                            {
                                $Counter = $Counter + 1;
                                If($LogfileData.UserName -eq $Win32ComputerSystem.UserName)
                                    {
                                        'OK'
                                        $LogfileData.UserName = 'Csak';
                                        $LogfileData.UserName
                                    }
                                Write-Host $Counter;
                            }

                        $Log | Out-File $LogFile -Force -Encoding default -Append;
                    }
                    Catch
                        {
                            Write-Host 'HIBA! Log fajl beolvasasakor.' -ForegroundColor Red;
                        }
            }
            Else
                {
                    Try {
                            $LogHeader | Out-File $LogFile -Force -Encoding default;
                            $Log       | Out-File $LogFile -Force -Encoding default -Append;
                        }
                        Catch
                            {
                                Write-Host 'HIBA! Log fajl letrehozasakor.' -ForegroundColor Red;
                            }
                }
    }
    Catch
        {
            Write-Host 'Az fajl ellenorzese nem sikerult.';
        }
    