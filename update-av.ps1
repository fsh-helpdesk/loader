
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


$allowed = @(
"Windows Malicious*",
"Security Intelligence*",
"Update for Windows Defender*",
"Update for Microsoft Defender*"

)

#$allowed

$b = get-windowsupdate
$kb = @()

if($b -eq $null)
{
    $status = "No AV updates available.."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\av_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
    #no updates available
    return 1
}

foreach($a in $b)
{
    foreach($c in $allowed)
    {
        $title = $c.ToString();
        if($a.Title -ilike $title)
          {
              #write-host "matched!"
              $kb += $a.KB
              break
          }
    }
}
$str = ""

$num = $Kb.Count
if($num -eq 0)
{
    $status = "No AV updates available.."
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\av_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
	return 1
}

if($num -eq 1)
{
    $str = $kb[0];
}
else
{
    for($d = 0; $d -lt ( $num -1 ); $d++)
    {
        $str += $kb[$d] + ","
    }
    $str += $kb[$d]
}

[Environment]::SetEnvironmentVariable('UPDATING', '1')
$a = Install-WindowsUpdate -KBarticleID $str -MicrosoftUpdate -AcceptAll -IgnoreReboot -Silent #no pipeline support
[Environment]::SetEnvironmentVariable('UPDATING', '0')

$state = ''




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
    $m = "[$($b.ComputerName)] [$($b.Status)] [$($status)] $($b.Title)" 
    $m | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\av_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
}


return 0