Write-Output $Env:PATH
[Environment]::SetEnvironmentVariable("PATH", $Env:PATH+";C:\Program Files\BraveSoftware\Brave-Browser\Application", [EnvironmentVariableTarget]::Machine)