#!/usr/bin/env -S pwsh -nop -nol
#requires -version 3

<#PSScriptInfo
.VERSION 2.0.1
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
# Date modified:  07/03/2022 12:10am

$ErrorActionPreference = "Stop"
$ArgumentList = $args

$ReqVer = New-Object Version 4,0
$PSVersion = $PSVersionTable.PSVersion
$Protocols = [enum]::GetNames([Net.SecurityProtocolType])
$ProtTls12 = [Net.SecurityProtocolType]::Tls12
$WebClient = New-Object Net.WebClient

[string]"This script requires" | ForEach-Object {
if($IsLinux -or $IsMacOS) {throw "$_ Microsoft Windows Operating System."}
if($PSVersion -lt $ReqVer) {throw "$_ Windows Management Framework (PowerShell) version 4.0"}
if($Protocols -notcontains $ProtTls12) {throw "$_ at least .NET Framework version 4.5"}
}

Write-Verbose "Changing internet security protocol..."
[Net.ServicePointManager]::SecurityProtocol = $ProtTls12

Write-Verbose "Downloading OTA Haier F17A1H/Andromax Prime Injector Tool script code from GitHub..."
$Uri = [uri]"http://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat"
$BatFile = "${env:temp}\inject.bat"
$TmpFile = "${env:temp}\run_online.tmp"
$WebClient.DownloadFile($Uri, $BatFile) | Out-Null

& {New-Item -itemtype File -path $TmpFile | Out-Null}
& {cmd.exe /e:on /v:on /q /c $BatFile $ArgumentList}
Write-Verbose "Removing temporary script..."
$BatFile, $TmpFile | ForEach-Object {Remove-Item -literalpath $_ | Out-Null}
