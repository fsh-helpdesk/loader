
#
# CONFIDENTIAL - INTERNAL USE ONLY
#
# (C) Copyright 2023 PSYCHO-SOCIAL REHABILITATION CENTER INC d/b/a FELLOWSHIP HOUSE
#
# PERMISSION TO COPY, USE OR MODIFY BY ANY 3RD PARTY INDIVIDUAL OR VENDOR INCLUDING THEIR ASSOCIATES
# IS STRICTLY PROHIBITED.
#

#%SystemRoot%\system32\WindowsPowerShell\v1.0\powershell.exe -ExecutionPolicy ByPass -File \\dcc\NETLOGON\setup.ps1
#Add-WUServiceManager -ServiceID "7971f918-a847-4430-9279-4a52d1efe18d" -AddServiceFlag 7
#Get-WUlist -MicrosoftUpdate

[Environment]::SetEnvironmentVariable('UPDATING', '0')
[Environment]::SetEnvironmentVariable('LDRSTATUS', '')
   
if([Environment]::GetEnvironmentVariable('LDRSTATUS') -eq $null)
{
    $res =  invoke-expression -Command \\dcc.fellowship.org\NETLOGON\pswu-install.ps1
        if($res -eq 1)
    {
        $a = "LDR status 0: error"
        $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
    }

    $a = Get-WURebootStatus -Silent
    if($a -eq $true)
    {
        $status = "Attempting to restart.."
        $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
        write-host $status

    	Restart-Computer -Force
        exit
    }
        $status = "No pending restarts.. Continuing"
        $status | Out-File "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
        write-host $status


    [Environment]::SetEnvironmentVariable('LDRSTATUS', 'LDR_INITIAL_UPDATE')
    #phase 1 setup install PSWindowsUpdate module
}

if([Environment]::GetEnvironmentVariable('LDRSTATUS') -eq 'LDR_INITIAL_UPDATE')
{
    $a = "LDR_INITIAL_UPDATE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
    $res = invoke-expression -Command \\dcc.fellowship.org\NETLOGON\feature-update.ps1
    if($res -eq 2)
    {
        $res = invoke-expression -Command \\dcc.fellowship.org\NETLOGON\feature-update-force.ps1
        if($res -eq 1)
        {
        $a = "LDR_INITIAL_UPDATE: error on forced update"
        $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
        }

        exit; 
   }
    $a = "LDR_INITIAL_UPDATE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    [Environment]::SetEnvironmentVariable('LDRSTATUS', 'LDR_POST_INSTALL_UPDATE')
    #phase 2 setup
}

if([Environment]::GetEnvironmentVariable('LDRSTATUS') -eq 'LDR_POST_INSTALL_UPDATE')
{
    $a = "LDR_POST_INSTALL_UPDATE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    $res = invoke-expression -Command \\dcc.fellowship.org\NETLOGON\update.ps1 #if no feature update is present
    if($res -eq 1)
    {
        $a = "LDR_POST_INSTALL_UPDATE: error"
        $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append
    }
    [Environment]::SetEnvironmentVariable('LDRSTATUS', 'LDR_POST_INSTALL_UPDATE2')
    $a = "LDR_POST_INSTALL_UPDATE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    #phase 3a setup
}

if([Environment]::GetEnvironmentVariable('LDRSTATUS') -eq 'LDR_POST_INSTALL_UPDATE2')
{
    $a = "LDR_POST_INSTALL_UPDATE2"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    $res = invoke-expression -Command \\dcc.fellowship.org\NETLOGON\update-drivers.ps1 #if no feature update is present
    [Environment]::SetEnvironmentVariable('LDRSTATUS', 'LDR_COMPLETE')
    $a = "LDR_POST_INSTALL_UPDATE2"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    #phase 3b setup
}



if([Environment]::GetEnvironmentVariable('LDRSTATUS') -eq 'LDR_COMPLETE')
{
    $a = "LDR_COMPLETE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    $res = invoke-expression -Command \\dcc.fellowship.org\NETLOGON\update-av.ps1

    $a = "LDR_COMPLETE"
    $a | Out-File "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)\test.log" -Append

    [Environment]::SetEnvironmentVariable('LDRSTATUS', '')

    #update on load.
}


#phase 4 LDR_COMPLETE - run sanity checks on boot