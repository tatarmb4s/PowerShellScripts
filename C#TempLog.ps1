# This makes a new log at C#LogingTemp source
New-EventLog -LogName 'C#Loging' -Source 'C#LogingTemp' 

Remove-EventLog -Source "C#LogingTemp"
Remove-EventLog -LogName "C#Loging"

Write-EventLog -LogName 'C#Loging' -Source 'C#LogingTemp' -EntryType Information -EventId 0 -Message 'valami'