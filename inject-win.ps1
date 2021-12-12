#requires -version 4
if ($IsLinux -or $IsmacOS) {Write-Error "This script requires Microsoft Windows Operating System."; return 1}
if ([Environment]::OSVersion.Version -lt (New-Object Version 6,1)) {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}

$ErrorActionPreference = 'Stop'
$Repository = 'thefirefox12537/ota_f17a1h_injector'
(New-Object Net.WebClient).DownloadFile(
"http://github.com/$Repository/raw/main/inject-win.bat",
"$env:tmp\inject-win.bat"
)

& "$env:tmp\inject-win.bat" @args
Remove-Item -LiteralPath "$env:tmp\inject-win.bat"
