
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
	write-host "update in progress. exiting"
    return 1
}



$allowed = @(
"* Security Update for Windows*",
"* Security Update for x64 Client*",
"* Update for Windows*",
"* Cumulative Update for .NET Framework*",
"* Cumulative Update for Windows *",
"* Cumulative Update Preview for *"
)


$b = get-windowsupdate -MicrosoftUpdate
$kb = @()
if($b -eq $null)
{
    $status = "No Permitted updates available.."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\general_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
    return 1
}

foreach($a in $b)
{
    foreach($c in $allowed)
    {
        $title = $c.ToString();
        if($a.Title -ilike $title)
          {
              #write-host "matched $($a.kb)!"
              $kb += $a.KB
              break
          }
    }
}
$str = ''
$num = $kb.Count

if($num -eq 0)
{
    $status = "No updates to install."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\general_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
	return 1
}

if($num -eq 1)
{
    $str = $kb[0];
}
else
{
    for($d = 0; $d -lt ($num - 1); $d++)
    {
        $str += $kb[$d] + ","
    }
    $str += $kb[$d]
}
$str

[Environment]::SetEnvironmentVariable('UPDATING', '1')
$a = Get-WindowsUpdate -KBarticleID $str -MicrosoftUpdate -AcceptAll -IgnoreReboot -Silent -Install
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
    $m | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\general_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append

}


$a = Get-WURebootStatus -Silent
if($a -eq $true)
{
    $status = "Attempting to restart.."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\general_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

	Restart-Computer
}
return 0