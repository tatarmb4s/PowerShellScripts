<#$RegPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
$DefaultUsername = ""
$DefaultPassword = ""
Set-ItemProperty $RegPath "AutoAdminLogon" -Value "0" -type String 
Set-ItemProperty $RegPath "DefaultUsername" -Value "$DefaultUsername" -type String 
Set-ItemProperty $RegPath "DefaultPassword" -Value "$DefaultPassword" -type String #>

D:\_Developments\CMD\GTARun.bat

Start-Sleep -s 100 

$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Right}')
 Start-Sleep -s 1 
$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Right}')
Start-Sleep -s 1
$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Right}')
Start-Sleep -s 1
$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Right}')
Start-Sleep -s 1
$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Right}')
Start-Sleep -s 1
$wsh = New-Object -ComObject WScript.Shell
  $wsh.SendKeys('{Enter}')

For(;;) 
{ $TimeUp = 5000
  
  for ($i=1; $i -le $TimeUp; $i++)
    {
     $wsh = New-Object -ComObject WScript.Shell
     $wsh.SendKeys('{Up}')
    }
  
  $TimeBack = 5000
  
  for ($i=1; $i -le $TimeBack; $i++)
    {
     $wsh = New-Object -ComObject WScript.Shell
     $wsh.SendKeys('{Down}')
    }
}





# Stop-Computer -ComputerName localhost -Force
