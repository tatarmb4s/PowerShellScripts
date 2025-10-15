Get-Service -Name ssh-agent
Set-Service -Name ssh-agent -StartupType Automatic -Verbose
Start-Service -Name ssh-agent -Verbose
