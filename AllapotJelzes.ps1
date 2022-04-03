$TimeBack = 5
  
  for ($i=1; $i -le $TimeBack; $i++)
    {
     Start-Sleep -s 1
     Write-Host $i
    }


For(;;) 
{
    $wsh = New-Object -ComObject WScript.Shell
      $wsh.SendKeys('{E}')

    Start-Sleep -s 1

    $wsh = New-Object -ComObject WScript.Shell
      $wsh.SendKeys('{Enter}')

    Start-Sleep -s 600
}