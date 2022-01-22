#!/usr/bin/env pwsh
#requires -version 3

<#PSScriptInfo
.VERSION 1.5.1
.GUID 702d7de5-2805-4d25-92fa-4aa08148b894
.AUTHOR Faizal Hamzah
.PROJECTURI http://github.com/thefirefox12537/ota_f17a1h_injector.git
.LICENSEURI http://github.com/thefirefox12537/ota_f17a1h_injector#readme
.COMPANYNAME The Firefox Flasher
.TAGS inject.bat inject inject-win.bat inject-win
.REQUIREDSCRIPTS pnputil cscript adb
.RELEASENOTES
#>

<#
.SYNOPSIS
Haier_F17A1H OTA Updater Injector
.DESCRIPTION
Tool ini berguna bagi pengguna Haier F17A1H (Andromax Prime) yang mau di update offline atau ingin di root.
.INPUTS
System.String
.OUTPUTS
System.String[]
.NOTES
Run inject-win.ps1 without arguments to view help usage.
#>

# Date created:   12/08/2021  4:11pm
# Date modified:  01/22/2021  7:40pm

$ErrorActionPreference = 'Stop'
if ($IsLinux -or $IsMacOS)
{Write-Error "This script requires Microsoft Windows Operating System."}
if ($PSVersionTable.PSVersion -lt (New-Object Version 4,0))
{Write-Error "This script requires Windows Module Framework (PowerShell) version 4.0"}
if ([System.Enum]::GetNames([System.Net.SecurityProtocolType]) -notcontains 'Tls12')
{Write-Error "This script requires at least .NET Framework version 4.5"}

if ([System.Environment]::OSVersion.Version -lt (New-Object Version 6,2)) {
Write-Verbose "Changing internet security protocol..."
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
}

Write-Verbose "Downloading Haier_F17A1H OTA Updater Injector script code from GitHub repository..."
$Repository = 'thefirefox12537/ota_f17a1h_injector'
$Releases_and_files = 'releases/latest/download/inject-win.bat'
(New-Object System.Net.WebClient).DownloadFile(
"http://github.com/$Repository/$Releases_and_files",
"${env:temp}\inject.bat"
)

[void](New-Item -itemtype File -path "${env:temp}\run_online.tmp" -value "Run_Online")
cmd.exe /c call "${env:temp}\inject.bat" @args
Write-Verbose "Removing temporary script..."
foreach ($FileRemove in @("inject.bat", "run_online.tmp")) {
[void](Remove-Item -literalpath "${env:temp}\$FileRemove")
}
