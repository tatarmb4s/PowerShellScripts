<# 
Esememenynaplo letrehozasa
 -LogName '!SystemManagement' Naplo neve
 -Source '!Computer_Start'    Naplo forrasa, vagyis aki a bejegyzest teszi a megadott naploba

#>
<# 
This script makes an event log source
 -LogName '!SystemManagement' The log name
 -Source '!Computer_Start'    The sources name

#>

New-EventLog -LogName '!SystemManagement' -Source '!Computer_Start'
New-EventLog -LogName '!SystemManagement' -Source '!Computer_Down'
New-EventLog -LogName 'C#Loging' -Source 'C#LogingTemp' 

# Uj esemenynaplo bejegyzes.
Write-EventLog -LogName '!SystemManagement' -Source '!Computer_Start'  -EntryType Information -EventId 0 -Message 'A naplo letrahozasa sikeres.'
Write-EventLog -LogName '!SystemManagement' -Source '!Computer_Down'   -EntryType Information -EventId 0 -Message 'A naplo letrahozasa sikeres.'
Write-EventLog -LogName '!SystemManagement' -Source '!Computer_UpTime' -EntryType Information -EventId 0 -Message 'A naplo letrahozasa sikeres.'
Write-EventLog -LogName 'C#Loging' -Source 'C#LogingTemp' -EntryType Information -EventId 0 -Message 'A naplo letrahozasa sikeres.'

Write-EventLog -LogName 'Application' -Source 'Application' -EntryType Error -EventId 0 -Message 'valami'
