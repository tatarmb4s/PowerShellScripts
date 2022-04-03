#This makes a task to run after wake up, annd automate log in

$action = New-ScheduledTaskAction -Execute PowerShell.exe -Argument "D:\_Developments\PowerShell\AutoFarm.ps1"
$trigger = New-ScheduledTaskTrigger -At 2:10pm -Once
$settings = New-ScheduledTaskSettingsSet -MultipleInstances Parallel -WakeToRun -DontStopIfGoingOnBatteries

Register-ScheduledTask -TaskName "StartG5O" `
                       -Action $action `
                       -Trigger $trigger `
                       -User "" `
                       -Password '' `
                       -Settings $settings

 
$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = ""
$DefaultPassword = ""
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "1" -type String 
Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String 