#This script gets the uptime
$upTime = (get-date) - (gcim Win32_OperatingSystem).LastBootUpTime
"A szerver online {0:dd} napja, {0:hh} órája, {0:mm} perce, {0:ss} másodperce" -f $upTime
