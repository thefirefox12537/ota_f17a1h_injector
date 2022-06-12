#!/usr/bin/env pwsh
#requires -version 3

<#PSScriptInfo
.VERSION 1.6.0
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
OTA Haier F17A1H/Andromax Prime Injector Tool
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
# Date modified:  05/13/2022  2:22am

param([switch]$Help)

$ErrorActionPreference = 'Stop'
$Arguments = @args

if($Help) {$Arguments = "--help"}

if($IsLinux -or $IsMacOS)
{Write-Error "This script requires Microsoft Windows Operating System."}
if($PSVersionTable.PSVersion -lt (New-Object Version 4,0))
{Write-Error "This script requires Windows Module Framework (PowerShell) version 4.0"}
if([enum]::GetNames([Net.SecurityProtocolType]) -notcontains [Net.SecurityProtocolType]::Tls12)
{Write-Error "This script requires at least .NET Framework version 4.5"}

Write-Verbose "Changing internet security protocol..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Write-Verbose "Downloading OTA Haier F17A1H/Andromax Prime Injector Tool script code from GitHub repository..."
$Site = "http://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat"
$BatFile = "${env:temp}\inject.bat"
$TmpFile = "${env:temp}\run_online.tmp"
[void](New-Object Net.WebClient).DownloadFile($Site,$BatFile)

[void](New-Item -itemtype File -path $TmpFile -value "Run_Online")
& cmd.exe /c call $BatFile $Arguments
Write-Verbose "Removing temporary script..."
$BatFile,$TmpFile | ForEach-Object {[void](Remove-Item -literalpath $_)}
