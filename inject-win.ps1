#!/usr/bin/env pwsh
#requires -version 4
<#PSScriptInfo
.VERSION 1.4.2
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
<#
Date created:   12/08/2021  4:11pm
Date modified:  12/25/2021  5:40am
#>

if ($IsLinux -or $IsmacOS)
{Write-Error "This script requires Microsoft Windows Operating System."; return 1}

if ([System.Enum]::GetNames([System.Net.SecurityProtocolType]) -notcontains 'Tls12')
{Write-Error "This script requires .NET Framework version 4.5"; return 1}
if ([System.Environment]::OSVersion.Version -lt (New-Object Version 6,2))
{[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12}

$ErrorActionPreference = 'Stop'
$WebClient = New-Object Net.WebClient
$GitHub = 'http://github.com'
$Repository = 'thefirefox12537/ota_f17a1h_injector'
$Releases = 'releases/latest/download'
$File = 'inject-win.bat'
$WebClient.DownloadFile("$GitHub/$Repository/$Releases/$File", "$env:tmp\inject.bat")

& "$env:tmp\inject.bat" @args
Remove-Item -LiteralPath "$env:tmp\inject.bat"
