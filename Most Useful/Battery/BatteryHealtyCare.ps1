# This script checks the battery level always, and if its reach the miunimum or the maximum, the script gives a mesage box. If you choose yes, the script will run again.

$minlevel = '20';
$maxlevel = '90';

while($true) 
{
    $Perc = (Get-WmiObject win32_battery).estimatedChargeRemaining;
    Write-Host($Perc);
    if ($Perc -gt $maxlevel -OR $Perc -lt $minlevel) 
    {
        $msg = [System.Windows.MessageBox]::Show('The battery reached the '+$Perc+'%.','Do you want to display another message?','YesNo','Information');
        if ($msg -eq 'Yes') 
        {
            Start-Sleep(3600);        
        }
        if ($msg -eq 'No') 
        {
            break;        
        }
    }
    Start-Sleep(1);
}
Write-Host('Ended');