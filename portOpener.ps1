$displayName = "GitEA3000Proxy";
$portvalue = 3000;
$everithing = $false;
$tcpin = $true;
$udpin = $true;
$tcpout = $true;
$udpout = $true;

if ($everithing -eq $true) 
{

    New-NetFirewallRule -DisplayName $displayName"TCPIn" -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $portvalue 
    New-NetFirewallRule -DisplayName $displayName"UDPIn" -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $portvalue
    New-NetFirewallRule -DisplayName $displayName"TCPOut" -Profile 'Public' -Direction Outbound -Action Allow -Protocol TCP -LocalPort $portvalue 
    New-NetFirewallRule -DisplayName $displayName"UDPOut" -Profile 'Public' -Direction Outbound -Action Allow -Protocol UDP -LocalPort $portvalue
    Write-Host("Sikerült! Minden bekapcsolva$")

}
else 
{
    if ($tcpin -eq $true)
    {
        New-NetFirewallRule -DisplayName $displayName"TCPIn" -Profile 'Public' -Direction Inbound -Action Allow -Protocol TCP -LocalPort $portvalue    
    }

    if ($udpin -eq $true)
    {
        New-NetFirewallRule -DisplayName $displayName"UDPIn" -Profile 'Public' -Direction Inbound -Action Allow -Protocol UDP -LocalPort $portvalue    
    }

    if ($tcpout -eq $true)
    {
        New-NetFirewallRule -DisplayName $displayName"TCPOut" -Profile 'Public' -Direction Outbound -Action Allow -Protocol TCP -LocalPort $portvalue    
    }

    if ($udpout -eq $true)
    {
        New-NetFirewallRule -DisplayName $displayName"UDPOut" -Profile 'Public' -Direction Outbound -Action Allow -Protocol UDP -LocalPort $portvalue   
    }
    Write-Host("Sikerült! 
    Bekapcsolva:
    Inbound: 
        TCP: "+$tcpin+"
        UDP: "+$udpin+"
    Outbound:
        TCP: "+$tcpout+"
        UDP: "+$udpout+"
    ")
}
