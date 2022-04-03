#This script geted out the logs from windows.old forlder, to save it for the future

$MainFolder = 'D:\WindwsOld_files\';


$FolderName = Get-Item -Path 'D:\WindwsOld_files\lastOS.txt' | Get-Content
New-Item -Path 'D:\WindwsOld_files\' -Name $FolderName -ItemType "directory"
$Path = $MainFolder+$FolderName
Copy-Item -Path 'C:\Windows.old\WINDOWS\System32\winevt\Logs' -Destination $Path -Force
#New-Item -Path $Path -Name 'Logs' -ItemType "directory"
$Path2 = $Path+'\Logs'
Copy-Item -Path 'C:\Windows.old\WINDOWS\System32\winevt\Logs\*.*' -Destination $Path2 -Force


$BuildNum   = [System.Environment]::OSVersion.Version.Build;
$OSName     = (Get-WmiObject Win32_OperatingSystem).Caption;
$LastOS = $OSName+" "+$BuildNum;
$LastOS;

New-Item -Path 'D:\WindwsOld_files\lastOS.txt' -Value $LastOS -Force

Remove-Item 'C:\Windows.old\' -Force

takeown /F C:\Windows.old* /R /A /D Y
cacls C:\Windows.old\*.* /T /grant administrators:F
rmdir /S /Q C:\Windows.old