
#
# CONFIDENTIAL - INTERNAL USE ONLY
#
# (C) Copyright 2023 PSYCHO-SOCIAL REHABILITATION CENTER INC d/b/a FELLOWSHIP HOUSE
#
# PERMISSION TO COPY, USE OR MODIFY BY ANY 3RD PARTY INDIVIDUAL OR VENDOR INCLUDING THEIR ASSOCIATES
# IS STRICTLY PROHIBITED.
#

#c:\windows\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\dcc\NETLOGON\test.ps1

if([Environment]::GetEnvironmentVariable('UPDATING') -eq 1)
{
    return 1
}



$b = get-windowsupdate -Category "Drivers" -MicrosoftUpdate
$kb = @()

if($b -eq $null)
{
    $status = "No driver updates available"
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\driver_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
    #no updates available
    return 1
}


[Environment]::SetEnvironmentVariable('UPDATING', '1') 
$a = Install-WindowsUpdate -Category "Drivers" -MicrosoftUpdate -AcceptAll -IgnoreReboot -ForceInstall
[Environment]::SetEnvironmentVariable('UPDATING', '0')


foreach($b in $a)
{
$downloaded = $b.status[1]
$installed = $b.status[2]

 if($downloaded -eq 'F')
{
    $status = "DownloadFailed"
}
elseif($installed -eq 'I')
{
    $status = "Installed"
}
elseif($installed -eq 'F')
{
    $status = "InstallFailed"
}


    $m = "[$($b.ComputerName)] [$($status)] $($b.Title)" 
    $m | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\driver_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append

}


$a = Get-WURebootStatus -Silent
if($a -eq $true)
{
    $status = "Attempting to restart.."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\driver_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

	Restart-Computer -Force
}


return 0