#This simple script gets a value from a txt row, waits 3 seconds, and start typeing it. I automated it's for remote desktop connection, bc my computer dont want to remember the credentials.

C:\Windows\System32\mstsc.exe /v:#RDP IP
Start-Sleep -s 3
$content = ((Get-Content 'C:\RDP.txt')[1]) #Txt location and the 1.st row
[System.Windows.Forms.SendKeys]::SendWait('content')
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')


C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -command "& D:\_Developments\PowerShell\DayMacine.ps1"
