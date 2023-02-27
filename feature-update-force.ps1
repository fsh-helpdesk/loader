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


$a = get-computerinfo
if(( $a.OsVersion -eq "10.0.19045") -or ($a.OsVersion -eq "10.0.22621") )
{
    $status = "Preferred Feature update already installed"
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\Feature_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
}

    $status = "Forcing Feature Update"
    $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\Feature_updates-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

#if($a.WindowsProductName -ne 'Windows 10 Pro')
#{
#    return 1
#}

$dir = "c:\temp"
$c = Test-Path -path $dir

if($c -eq $false)
{
    New-Item -Path "c:\" -Name "temp" -ItemType "directory"
}

$webClient = New-Object System.Net.WebClient
$url = 'https://go.microsoft.com/fwlink/?LinkID=799445'
$file = "$($dir)\Win10Upgrade.exe"
$webClient.DownloadFile($url,$file)
Start-Process -FilePath $file -ArgumentList '/quietinstall /skipeula /auto upgrade /DynamicUpdate Disable /showoobe none /copylogs $dir'