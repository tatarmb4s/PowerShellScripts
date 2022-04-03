#Changes the acollated virtual memory of the system

wmic pagefileset where NAME = "g:\ 'pagefile.sys'" set INITIALSIZE = 512, MAXIMUMSIZE = 16384
try {
$result = wmic computersystem set AutomaticManagedPageFile = FALSE
$result = wmic pagefileset where NAME = "C: \\ pagefile.sys" set INITIALSIZE = 4096, MAXIMUMSIZE = 4096
# Restart-Computer
} catch {
exit 1
}