#$a = get-computerinfo

$serverInstance = Read-Host "Enter the name of your instance"
$credential = Get-Credential

# Connect to the Server and return a few properties
Get-SqlInstance -ServerInstance FILESHARE\LDRHISTORY
# done



#componentcleanup through task scheduler
schtasks.exe /Run /TN "\Microsoft\Windows\Servicing\StartComponentCleanup"