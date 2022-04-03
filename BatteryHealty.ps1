#This script tells you you'r battery-s details
powercfg /batteryreport
$FileLocation = "file:///C:/Users/THrown%20Creeper/battery-report.html"
Start-Process chrome $FileLocation