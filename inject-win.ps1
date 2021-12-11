#requires -version 4
param([switch][alias('R')]$Readme,
      [switch][alias('H')]$Help,
      [switch][alias('N')]$NonMarket,
      [switch][alias('Q')]$RunTemporary,
      [string]$UpdateFile)

if ($IsLinux -or $IsmacOS) {Write-Error "This script requires Microsoft Windows Operating System."; return 1}
if ([Environment]::OSVersion.Version -lt (New-Object Version 6,1)) {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12}

if ($Readme) {$ReadmeStr = '--readme'}
if ($Help) {$HelpStr = '--help'}
if ($NonMarket) {$NonMarketStr = '--non-market'}
if ($RunTemporary) {$RunTemporaryStr = '--run-temporary'}

$ErrorActionPreference = 'Stop'
$RunScript = (Split-Path -Leaf $MyInvocation.MyCommand.Definition).Replace('.ps1','.bat')
$Repository = 'thefirefox12537/ota_f17a1h_injector'
(New-Object Net.WebClient).DownloadFile(
"http://github.com/$Repository/raw/main/inject-win.bat",
"$env:tmp\$RunScript"
)

& "$env:tmp\$RunScript" $ReadmeStr $HelpStr $NonMarketStr $RunTemporaryStr $UpdateFile
Remove-Item -LiteralPath "$env:tmp\$RunScript"
