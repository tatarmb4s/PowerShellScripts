# A szamitogep leallitasat rogzito script
# This script is logging the Computer's shutdown

$ScripLogPath = 'D:\!SMLogs\Computer_UpTime'
$ScripLogName = 'ADomi.log'
$ScripLogFile = $ScripLogPath + '\' + $ScripLogName

$EventLogName = '!SystemManagement'
$EventLogSource = '!Computer_Down'

$EventLogMessage = 'A ' + $env:COMPUTERNAME + ' szamitogep leallitasa megkezdodott. Az leallito felhasznalo: ' + $env:USERNAME;
Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 3001 -Message $EventLogMessage;

IF (Test-Path $ScripLogPath)
    {
        $EventLogMessage = 'A ' + $ScripLogPath + ' konyvtar erheto.';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 3002 -Message $EventLogMessage;
    }
    ELSE
    {
        $EventLogMessage = 'A ' + $ScripLogPath + ' utvonal NEM erheto el!';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Error -EventId 3802 -Message $EventLogMessage;
    
    }

$ScripLogMessage = 'A szamitogep leallitasa megkezdodott.'
$ScripLogDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()
$ScripLog = $env:COMPUTERNAME + ';' + $ScripLogDate + ';' + $env:USERNAME + ';' + '3001' + ';' + $ScripLogMessage

Try {
        $ScripLog | Out-File -FilePath $ScripLogFile -Append -Encoding utf8
        $EventLogMessage = 'Megtortent a ' + $ScripLogFile + ' fajl  bejegyzese.';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 3003 -Message $EventLogMessage;
    }
    Catch
        {
            $EventLogMessage = 'A ' + $ScripLogFile + ' fajl bejegyzese nem sikerult!';
            Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Error -EventId 3803 -Message $EventLogMessage;
        }



