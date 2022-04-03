# A szamitogep leallitasat rogzito script
# This script is logging the Computer's startup

$ScripLogPath = 'D:\!SMLogs\Computer_UpTime'
$ScripLogName = 'ADomi.log'
$ScripLogFile = $ScripLogPath + '\' + $ScripLogName

$EventLogName = '!SystemManagement'
$EventLogSource = '!Computer_Down'

$EventLogMessage = 'A ' + $env:COMPUTERNAME + ' szamitogep indítasa megtortent. Az indító felhasznalo: ' + $env:USERNAME;
Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 1001 -Message $EventLogMessage;

IF (Test-Path $ScripLogPath)
    {
        $EventLogMessage = 'A ' + $ScripLogPath + ' konyvtar erheto.';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 1002 -Message $EventLogMessage;
    }
    ELSE
    {
        $EventLogMessage = 'A ' + $ScripLogPath + ' utvonal NEM erheto el!';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Error -EventId 1802 -Message $EventLogMessage;
    
    }

$ScripLogMessage = 'A szamitogep inditasa megtortent.'
$ScripLogDate = (Get-Date -Format "yyyy-MM-dd HH:mm:ss").ToString()
$ScripLog = $env:COMPUTERNAME + ';' + $ScripLogDate + ';' + $env:USERNAME + ';' + '1001' + ';' + $ScripLogMessage

Try {
        $ScripLog | Out-File -FilePath $ScripLogFile -Append -Encoding utf8
        $EventLogMessage = 'Megtortent a ' + $ScripLogFile + ' fajl  bejegyzese.';
        Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Information -EventId 1003 -Message $EventLogMessage;
    }
    Catch
        {
            $EventLogMessage = 'A ' + $ScripLogFile + ' fajl bejegyzese nem sikerult!';
            Write-EventLog -LogName $EventLogName -Source $EventLogSource -EntryType Error -EventId 1803 -Message $EventLogMessage;
        }



