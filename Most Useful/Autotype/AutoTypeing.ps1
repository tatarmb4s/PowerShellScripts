#This simple script gets a value from a txt row, waits 3 seconds, and start typeing it. I automated it's for remote desktop connection, bc my computer dont want to remember the credentials.


Start-Sleep -s 3
$content = ((Get-Content 'G:\_Developments\PowerShell\PowerShellScripts\Most Useful\Autotype\ad.txt')[1]) #Txt location and the 1.st row
[System.Windows.Forms.SendKeys]::SendWait($content)
[System.Windows.Forms.SendKeys]::SendWait('{ENTER}')


