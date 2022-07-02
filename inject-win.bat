@ echo off

REM  inject.bat
REM  OTA Haier F17A1H/Andromax Prime Injector Tool
REM
REM  Date/Time Created:          01/26/2021  1:30pm
REM  Date/Time Modified:         07/03/2022 12:10am
REM  Operating System Created:   Windows 10 Pro
REM
REM  This script created by:
REM    Faizal Hamzah
REM    The Firefox Flasher

REM  VersionInfo:
REM
REM    File version:      2,0,1
REM    Product Version:   2,0,1
REM
REM    CompanyName:       The Firefox Flasher
REM    FileDescription:   OTA Haier F17A1H/Andromax Prime Injector Tool
REM    FileVersion:       2.0.1
REM    InternalName:      inject
REM    OriginalFileName:  inject.bat
REM    ProductVersion:    2.0.1

REM
REM  Inject update.zip script - Andromax Prime F17A1H
REM
REM  File update.zip dan batch script inject root dari Adi Subagja
REM  Modifikasi batch script inject dari Faizal Hamzah
REM


if %OS%? == Windows_NT?  goto start

rem This is MS-DOS compatible and OS/2 system
ver | find "DOSBox" > nul
if not errorlevel 1  goto det_dosbox
ver | find "Operating System/2" > nul
if not errorlevel 1  goto det_windos2
if exist %windir%\..\msdos.sys  find "WinDir" %windir%\..\msdos.sys > nul
if not errorlevel 1  goto det_windos2
goto det_dos

:start
@ setlocal && set OLD_WIN=0

rem This is Windows NT
for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver | find "%%v" > nul && ^
if not errorlevel 1  set OLD_WIN=1

if %OLD_WIN%? == 1?  goto det_oldwinnt
if %OLD_WIN%? == 0?  setlocal enableextensions enabledelayedexpansion

for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') do (
    for %%a in (6.0 5.4 5.3 5.2 5.1 5.10 5.0 5.00) do (
    if /i "%%v.%%w" == "6.1" if /i %%x LSS 7601  set OLD_WIN=1
    if /i "%%v.%%w" == "%%a"  set OLD_WIN=1
    if /i "%%w.%%x" == "%%a"  set OLD_WIN=1
    )
)

set args=%*
set basefile=%~nx0
set basedir=%~dp0
set basedir=%basedir:~0,-1%
set basestring=((Get-Content "%~sf0"^|Select-String '^^^::@'^) -replace '::@'^)^|Out-String
set TITLE=OTA Haier F17A1H/Andromax Prime Injector Tool
for /f %%c in ('copy /z "%~f0" nul') do set _CR=%%c

::@
::@ Add-Type -AssemblyName "System.Windows.Forms" | Out-Null
::@ [Windows.Forms.Application]::EnableVisualStyles() | Out-Null
::@ $MessageBox = New-Object Windows.Forms.Form
::@ $MessageBox.TopMost = $True
::@
::@ function Blank-Dialog {
::@     if (-not $MessageBoxTitle) { $MessageBoxTitle = $Null }
::@     [Windows.Forms.MessageBox]::Show(
::@     $MessageBox, $MessageText, $MessageBoxTitle, $MessageBoxButton,
::@     [Windows.Forms.MessageBoxIcon]::None
::@     )
::@ }
::@
::@ function Information-Dialog {
::@     if (-not $MessageBoxTitle) { $MessageBoxTitle = $Null }
::@     [Windows.Forms.MessageBox]::Show(
::@     $MessageBox, $MessageInformation, $MessageBoxTitle, $MessageBoxButton,
::@     [Windows.Forms.MessageBoxIcon]::Information
::@     )
::@ }
::@
::@ function Question-Dialog {
::@     if (-not $MessageBoxTitle) { $MessageBoxTitle = $Null }
::@     [Windows.Forms.MessageBox]::Show(
::@     $MessageBox, $MessageQuestion, $MessageBoxTitle, $MessageBoxButton,
::@     [Windows.Forms.MessageBoxIcon]::Question
::@     )
::@ }
::@
::@ function Warning-Dialog {
::@     if (-not $MessageBoxTitle) { $MessageBoxTitle = $Null }
::@     [Windows.Forms.MessageBox]::Show(
::@     $MessageBox, $MessageWarning, $MessageBoxTitle, $MessageBoxButton,
::@     [Windows.Forms.MessageBoxIcon]::Warning
::@     )
::@ }
::@
::@ function Error-Dialog {
::@     [Windows.Forms.MessageBox]::Show(
::@     $MessageBox, $MessageError, $Null, $MessageBoxButton,
::@     [Windows.Forms.MessageBoxIcon]::Error
::@     )
::@ }
::/
::/ function Download-Manager {
::/     param ([Uri]$Uri, [string]$Target)
::/     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
::/     $WebClient = New-Object Net.WebClient
::/     $WebClient.DownloadFile($Uri, $Target) | Out-Null
::/ }
::/
::/ function Extract-Zip {
::/     param ([string]$ZipFile, [string]$DestinationPath)
::/     Add-Type -AssemblyName "System.IO.Compression.FileSystem" | Out-Null
::/     [IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $DestinationPath) | Out-Null
::/ }

for %%x in (%args%) do (
    if exist "%%~fx" (
    set FILE=%%~x
    set FULLPATH=%%~dpfx
    set EXTENSION=%%~xx
    )
)

:: Checking your system if PowerShell core version 6.0 or newer installed.
for /f "usebackq tokens=3*" %%d in (`
call reg.exe query HKLM\SOFTWARE\Microsoft\PowerShellCore /s 2^> nul ^| find /i "InstallDir"
`) do (
    for %%c in ("pwsh.exe") do (
    if exist "%%~$PATH:c" (set psshell=%%~c) ^
    else if exist "%%~d%%~c" (set psshell=%%~d%%~c)
    )
)

:: Checking your system if Windows Management Framework availabled.
if not defined psshell (
    for %%p in ("powershell.exe") do (
    if exist "%%~$PATH:p" (set psshell=%%~p) ^
    else (goto :no_powershell)
    )
)

:: Checking your system if approriate with requirements. Please wait at the moments.
:gettingrequire
if %OLD_WIN%? == 1? (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=This script requires Windows 7 Service Pack 1 or latest
    goto :error
)

for /f "usebackq tokens=*" %%a in (`
call "%psshell%" -noprofile -nologo -command ^
  "[Enum]::GetNames([Net.SecurityProtocolType]) -notcontains [Net.SecurityProtocolType]::Tls12" 2^> nul
`) do if /i "%%a" == "True" (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=This script requires at least .NET Framework version 4.5 and Windows Management Framework version 4.0
    goto :error
)

if exist "%temp%\run_online.tmp" (
    set run_temporary=1
    echo Running online script mode...
)

:: Checking a switch parameter.
if not defined args  goto USAGE
for %%x in (%args%) do (
    for %%p in (--readme) do if "%%~x" == "%%p"  goto README
    for %%p in (-h --help) do if "%%~x" == "%%p"  goto USAGE
    for %%p in (-n --non-market) do if "%%~x" == "%%p"  set NON_MARKET=1
    for %%p in (-Q --run-temporary) do if "%%~x" == "%%p"  set run_temporary=1
    for %%p in (-a --download-adb) do if "%%~x" == "%%p" (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=You cannot run this argument in Windows.
    goto :error
    )
)

:: Checking your file inserted.
if not defined FILE (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=File not found.
    goto :error
)

if /i not "%EXTENSION%" == ".zip" (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=File is not ZIP type.
    goto :error
)

:: Main Menu
:#1
:#1 $MessageBoxTitle = ${ENV:TITLE}
:#1 $MessageBoxButton = "YesNo"
:#1 $MessageQuestion = "Anda yakin? File yang dipilih:" + "`n" + ${ENV:FULLPATH}
for /f "usebackq tokens=*" %%i in (`
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#1%); " ^
  "Question-Dialog"
`) do if /i "%%i" == "No"  goto end_of_exit

:: NOTE
:#2
:#2 $MessageBoxButton = "OK"
:#2 $MessageWarning = @(
:#2 "  •   Harap aktifkan mode USB Debugging terlebih dahulu" + "`n" +
:#2 "       sebelum mengeksekusi inject update.zip [Untuk"    + "`n" +
:#2 "       mengetahui bagaimana cara mengaktifkan mode USB"  + "`n" +
:#2 "       debugging, dengan mengetik]:"                     + "`n" +
:#2 "`n" +
:#2 "             ${env:basefile} --readme" + "`n" +
:#2 "`n" +
:#2 "  •   Apabila HP terpasang kartu SIM, skrip ini akan" + "`n" +
:#2 "       terotomatis mengaktifkan mode Pesawat."        + "`n" +
:#2 "`n" +
:#2 "  NOTE:" + "`t" + "Harap baca dahulu sebelum eksekusi. Segala"        + "`n" +
:#2             "`t" + "kerusakan/apapun yang terjadi itu diluar tanggung" + "`n" +
:#2             "`t" + "jawab pembuat file ini serta tidak ada kaitannya"  + "`n" +
:#2             "`t" + "dengan pihak manapun. Untuk lebih aman tanpa"      + "`n" +
:#2             "`t" + "resiko, dianjurkan update secara daring melalui"   + "`n" +
:#2             "`t" + "updater resmi."
:#2 )
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#2%); " ^
  "Warning-Dialog | Out-Null"

:: Checking ADB programs
:checkadb
set repos=https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip
call :printf_cr "Checking ADB program..." 1

:: Downloading ADB programs if not exist
:adbnotexist
for %%a in ("A:" "B:") do (
    if /i "%basedir:~0,2%" == "%%~a" (
    set basedir=%LOCALAPPDATA%
    )
)
if defined run_temporary (
    set basedir=%temp%
) else (
    for %%e in (adb.exe) do if exist "%%~$PATH:e" (
    set FOUND_ADB_PATHENV=1
    set ADBDIR=%%~dp$PATH:e
    )
)
if defined FOUND_ADB_PATHENV (
    call :printf_lf "ADB program was availabled on the computer."
    set basedir=%ADBDIR:~0,-1%
) else if not exist "%basedir%\adb.exe" (
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    call :printf_lf "Downloading Android SDK Platform Tools..."
    call "%psshell%" -noprofile -nologo -command ^
    "Invoke-Expression (%basestring:@=/%); " ^
    "Download-Manager -Uri %repos% -Target '%temp%\platform-tools.zip'"

    echo Extracting Android SDK Platform Tools...
    call "%psshell%" -noprofile -nologo -command ^
    "Invoke-Expression (%basestring:@=/%); " ^
    "Extract-Zip -ZipFile '%temp%\platform-tools.zip' -DestinationPath '%temp%\'"
    for %%d in (platform-tools android-sdk\platform-tools) do if exist "%temp%\%%d" (
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do move "%temp%\%%d\%%f" "%basedir%\"
    rd /s /q "%temp%\%%d"
    ) > nul 2>&1
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    set ADB_SUCCESS=1
) else (
    call :printf_lf "ADB program was availabled on the computer or this folder."
)

if defined ADB_SUCCESS (
    if not exist "%basedir%\adb.exe" (
    echo Failed getting ADB program. Please try again.
    goto :eof
    ) else (
    echo ADB program was successfully placed.
    goto :checkadbdriver
    )
)

:checkadbdriver
set repos=https://dl.google.com/android/repository/latest_usb_driver_windows.zip
call :printf_cr "Checking ADB Interface driver installed..." 1

:: Downloading ADB Interface driver
:drivernotinstalled
where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    call :printf_lf "Downloading ADB Interface driver...       "
    call "%psshell%" -noprofile -nologo -command ^
    "Invoke-Expression (%basestring:@=/%); " ^
    "Download-Manager -Uri %repos% -Target '%temp%\usb_driver.zip'"

    echo Extracting ADB Interface driver...
    call "%psshell%" -noprofile -nologo -command ^
    "Invoke-Expression (%basestring:@=/%); " ^
    "Extract-Zip -ZipFile '%temp%\usb_driver.zip' -DestinationPath '%temp%\'"

    echo Installing driver...
    call "%psshell%" -noprofile -nologo -command ^
    "Start-Process -filepath pnputil.exe" ^
    "-argumentlist '-i -a "%temp%\usb_driver\android_winusb.inf"'" ^
    "-wait -windowstyle hidden -verb runas"

    rd /s /q "%temp%\usb_driver" > nul 2>&1
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    set DRIVER_SUCCESS=1
) else (
    call :printf_lf "ADB Interface driver already installed.   "
)

if defined DRIVER_SUCCESS (
    for /f usebackq %%a in (`
    call "%psshell%" -noprofile -nologo -command ^
      "$Found = pnputil.exe -e|Select-String -context 2 'Android Phone|ADB'; " ^
      "$Found.Context.PreContext -match 'Published name' -replace '.*: +'"
    `) do if exist %SystemRoot%\inf\%%a (
    echo Failed installing driver. Please try again.
    goto :eof
    ) else (
    echo ADB Interface driver successfully installed.
    goto :start_adb
    )
)

:: Starting ADB service
:start_adb
call :printf_cr "Starting ADB services...      " 1
call "%basedir%\adb" start-server

:: Checking devices
:checkdevice
call :printf_cr "Connecting to device...  " 2
call :printf_cr "Please plug USB to your devices."
call "%basedir%\adb" wait-for-device
call :printf_lf "Connected.                      " 1

:: Checking if your devices is F17A1H
:checkif_F17A1H
call :printf_cr "Checking if your devices is F17A1H..."
for /f "usebackq tokens=*" %%d in (`
call "%basedir%\adb" shell "getprop ro.fota.device" 2^> nul
`) do set "FOTA_DEVICE=%%d"
if not "%FOTA_DEVICE%" == "Andromax F17A1H" (
    set MESSAGE_BUTTON=OK
    set MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H
    call :printf_lf "Checking if your devices is F17A1H..."
    call "%basedir%\adb" kill-server
    call :remove_temporary
    goto :error
)

:: Activating airplane mode
:airplanemode
call :printf_lf "Activating airplane mode...     "
call "%basedir%\adb" shell "settings put global airplane_mode_on 1"
call "%basedir%\adb" shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

:: Injecting file
:injecting
echo Preparing version file %FILE% to injecting device...
call "%basedir%\adb" push "%FILE%" /sdcard/adupsfota/update.zip
call :printf_cr 4 "Checking file..."
call :printf_cr 12 "Verifying file..."

:: Calling FOTA update
echo Cleaning FOTA update...
call "%basedir%\adb" shell "pm clear com.smartfren.fota"

echo Manipulating FOTA update...
call "%basedir%\adb" shell "monkey -p com.smartfren.fota 1"
call "%basedir%\adb" shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
call "%basedir%\adb" shell "input keyevent 20" > nul 2>&1
call "%basedir%\adb" shell "input keyevent 22" > nul 2>&1
call "%basedir%\adb" shell "input keyevent 23" > nul 2>&1

:: Start updating
:updating
echo Updating...
call "%basedir%\adb" shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for /l %%a in (1,1,25) do ^
call "%basedir%\adb" shell "input keyevent 20" > nul 2>&1
call "%basedir%\adb" shell "input keyevent 23" > nul 2>&1
timeout /nobreak /t 10 > nul
call "%basedir%\adb" wait-for-device > nul 2>&1

if defined NON_MARKET (
    echo Enabling install non market app...
    call "%basedir%\adb" shell "settings put global install_non_market_apps 1"
    call "%basedir%\adb" shell "settings put secure install_non_market_apps 1"
)

:: Complete
:#3
:#3 $MessageBoxButton = "OK"
:#3 $MessageInformation = "Proses telah selesai."
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#3%); " ^
  "Information-Dialog | Out-Null"

:kill_adb
echo Killing ADB services...
call "%basedir%\adb" kill-server > nul 2>&1
call :remove_temporary

call :end_of_exit
goto :eof

:remove_temporary
if defined run_temporary (
    call "%basedir%\adb" kill-server > nul 2>&1
    if not exist "%temp%\run_online.tmp" echo Removing temporary program files...
    for %%i in (adb.exe AdbWinApi.dll AdbWinApi.dll.dat AdbWinUsbApi.dll) do (
    attrib -s -h -r "%basedir%\%%i"
    del /q "%basedir%\%%i"
    ) > nul 2>&1
)
goto :eof


:README
:#4
:#4 $MessageBoxTitle = "${ENV:TITLE}:   Read-Me"
:#4 $MessageBoxButton = "OK"
:#4 $TemporaryMessage = @(
:#4 "Untuk mengaktifkan mode USB debugging pada Haier F17A1H" + "`n" +
:#4 "sebagai berikut:" + "`n" +
:#4 "`n" +
:#4 "  •   Dial ke nomor *#*#83781#*#*"             + "`n" +
:#4 "  •   Masuk ke slide 2 (DEBUG&LOG)."           + "`n" +
:#4 "  •   Pilih `"Design For Test`"."              + "`n" +
:#4 "  •   Pilih `"CMCC`", lalu tekan OK."          + "`n" +
:#4 "  •   Pilih `"MTBF`"."                         + "`n" +
:#4 "  •   Lalu pilih `"MTBF Start`"."              + "`n" +
:#4 "  •   Tunggu beberapa saat."                   + "`n" +
:#4 "  •   Pilih `"Confirm`"."                      + "`n" +
:#4 "  •   Kalau sudah mulai ulang/restart HP nya." + "`n" +
:#4 "  •   Selamat USB debugging telah aktif."      + "`n" +
:#4 "`n" +
:#4 "`n" +
:#4 "Jika masih tidak aktif, ada cara lain sebagai berikut:" + "`n" +
:#4 "`n" +
:#4 "  •   Dial ke nomor *#*#257384061689#*#*"            + "`n" +
:#4 "  •   Aktifkan `"USB Debugging`"."                   + "`n" +
:#4 "  •   Izinkan aktifkan USB Debugging pada popupnya." + "`n" +
:#4 "`n" +
:#4 "`n" +
:#4 "Tinggal jalankan skrip ini dengan membuka Command"      + "`n" +
:#4 "Prompt, dan jalankan adb start-server maka akan muncul" + "`n" +
:#4 "popup izinkan sambung USB Debugging di Haier F17A1H."
:#4 ), @(
:#4 "Special thanks to:" + "`n" +
:#4 "`n" +
:#4 "  1.   Adi Subagja" + "`n" +
:#4 "  2.   Ahka"        + "`n" +
:#4 "  3.   dan developer-developer Andromax Prime"
:#4 )
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#4%); " ^
  "$TemporaryMessage.ForEach({" ^
  "$MessageText = $_; " ^
  "Blank-Dialog | Out-Null" ^
  "})"
call :end_of_exit
goto :eof

:USAGE
:#5
:#5 $MessageBoxTitle = "${ENV:TITLE}:   Usage"
:#5 $MessageBoxButton = "OK"
:#5 $MessageInformation = @(
:#5 "Inject update.zip for Haier F17A1H" + "`n" +
:#5 "`n" +
:#5 "USAGE:   ${env:basefile} <update.zip file>" + "`n" +
:#5 "`n" +
:#5 "Additional arguments are maybe to know:" + "`n" +
:#5 "   -a, --download-adb"  + "`t" + "Run without check ADB and"       + "`n" +
:#5                        "`t`t`t" + "Fastboot module (ADB program"    + "`n" +
:#5                        "`t`t`t" + "permanently placed. Android"     + "`n" +
:#5                        "`t`t`t" + "only use)."                      + "`n" +
:#5 "   -h, --help"        + "`t`t" + "Show help information for this"  + "`n" +
:#5                        "`t`t`t" + "script."                         + "`n" +
:#5 "   -n, --non-market"  + "`t`t" + "Inject with install non market." + "`n" +
:#5 "   -Q, --run-temporary" + "`t" + "Run without check ADB and"       + "`n" +
:#5                        "`t`t`t" + "Fastboot module"                 + "`n" +
:#5                        "`t`t`t" + "(ADB program not permanently"    + "`n" +
:#5                        "`t`t`t" + "placed)."                        + "`n" +
:#5 "   --readme"          + "`t`t" + "Show read-me (advanced help)."
:#5 )
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#5%); " ^
  "Information-Dialog | Out-Null"
call :end_of_exit
goto :eof

:error
:#6
:#6 $MessageBoxButton = ${ENV:MESSAGE_BUTTON}
:#6 $MessageError = ${ENV:MESSAGE_ERROR}
call "%psshell%" -noprofile -nologo -command ^
  "Invoke-Expression (%basestring%); " ^
  "Invoke-Expression (%basestring::@=#6%); " ^
  "Error-Dialog | Out-Null"
call :end_of_exit
goto :eof


:printf_cr
set STR=%1
set /p "=%STR:"=%!_CR!" < nul
if not %2?==? timeout /nobreak /t %~2 > nul
goto :eof


:printf_lf
set STR=%1
set /p "=%STR:"=%!_CR!" < nul & echo.
if not %2?==? timeout /nobreak /t %~2 > nul
goto :eof


:no_powershell
if %OLD_WIN%? == 1?  goto det_oldwinnt
echo This script requires Windows Management Framework (PowerShell).
goto end_of_exit

:det_oldwinnt
echo This script requires a newer version of Windows NT.
goto end_of_exit

:det_windos2
echo This script requires Microsoft Windows NT.
goto end_of_exit

:det_dos
:det_dosbox
echo This script cannot be run in DOS mode.
goto end_of_exit

:end_of_exit
@ if %OS%? == Windows_NT?  endlocal
@ if %OLD_WIN%? == 0?  goto :eof
@ echo on