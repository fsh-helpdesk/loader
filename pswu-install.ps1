

$uncpath = "filesystem::\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)"
$path = "\\fileshare.fellowship.org\repository\$($env:COMPUTERNAME)"


$c = Test-Path -path $uncpath
if($c -eq $false)
{
    New-Item -Path "\\fileshare.fellowship.org\repository\" -Name "$($env:COMPUTERNAME)" -ItemType "directory"
    $status = "Created Repository location."
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

}
$a = Get-PackageProvider -Name NuGet -Force
if ($a.Name -ne "NuGet")
{
    $b = install-packageprovider -name NuGet -Force
    $status = "Installed NuGet"
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status
}

$a = Get-InstalledModule -name PSWindowsUpdate  -ErrorAction SilentlyContinue
if ($a.Name -ne "PSWindowsUpdate")
{
    $a = install-module -name PSWindowsUpdate -Force
    $status = "Installed PSWU"
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status


    $a = Import-Module PSWindowsUpdate
    $status = "Imported PSWU"
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

}

$a = Get-InstalledModule -name SqlServer -ErrorAction SilentlyContinue
if ($a.Name -ne "SqlServer")
{
 
    $a = Install-Module -Name SqlServer -Force
     $status = "Installed SqlServer"
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status


    $a = Import-Module SqlServer
    $status = "Imported SqlServer"
    $status | Out-File "$($path)\module-install-$(Get-Date -f yyyy-MM-dd).log" -Force -Append
    write-host $status

}
