<# :
@ ECHO OFF
@ BREAK OFF
@ SETLOCAL

for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver | find "%%v" > nul && ^
if not errorlevel 1 set OLD_WIN=1
if %OLD_WIN%? == 1? (goto winnt) ^
else (SETLOCAL ENABLEEXTENSIONS ENABLEDELAYEDEXPANSION)

for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') do ^
for %%a in (6.0 5.4 5.3 5.2 5.1 5.10 5.0 5.00) do (
    if /i "%%v.%%w" == "6.1" if /i %%x LSS 7601  (set OLD_WIN=1)
    if /i "%%v.%%w" == "%%a"  (set OLD_WIN=1)
    if /i "%%w.%%x" == "%%a"  (set OLD_WIN=1)
)

set args=%*
set basefile=%~nx0
set basedir=%~dp0
set basedir=%basedir:~0,-1%
set basestring=${%~sf0}^| Out-String
set TITLE=OTA Haier F17A1H/Andromax Prime Injector Tool

for %%x in (%args%) do ^
if exist "%%~x" (set "FILE=%%~x" && set "FULLPATH=%%~dpfx" && set "EXTENSION=%%~xx")

:: Checking your system if Windows Module Framework (PowerShell) availabled.
for %%p in ("powershell.exe") do ^
if not exist "%%~$PATH:p" (goto :nopwsh) ^
else (set psshell=%%~p)

:: Checking your system if approriate with requirements. Please wait at the moments.
:gettingrequire
if %OLD_WIN%? == 1? (
    set MESSAGE_ERROR=This script requires Windows 7 Service Pack 1 or latest
    goto :error
)

for /f usebackq %%a in (`
call %psshell% -noprofile -nologo -c ^
[Enum]::GetNames^([Net.SecurityProtocolType]^) -notcontains [Net.SecurityProtocolType]::Tls12 2^> nul
`) do if /i "%%a" == "True" (
    set MESSAGE_ERROR=This script requires at least .NET Framework version 4.5 and Windows Module Framework version 4.0
    goto :error
)

if exist "%temp%\run_online.tmp" echo Running online script mode...

if %*! == ! goto USAGE
for %%x in (%args%) do (
    if %%~x! == --readme! goto README
    for %%p in (-h --help) do ^
    if %%~x! == %%p! goto USAGE
    for %%p in (-Q --run-temporary) do ^
    if %%~x! == %%p! (set "basedir=%temp%" && set "run_temporary=1")
    for %%p in (-a --download-adb) do ^
    if %%~x! == %%p! (
    set MESSAGE_ERROR=You cannot run this argument in Windows.
    goto :error
   )
)

if not defined FILE (
    set MESSAGE_ERROR=File not found.
    goto :error
)

if /i not "%EXTENSION%" == ".zip" (
    set MESSAGE_ERROR=File is not ZIP type.
    goto :error
)

:: Main Menu
call :setnewline
set MESSAGE_QUEST=Anda yakin? File yang dipilih:%_N%%FULLPATH%
for /f usebackq %%i in (`
call %psshell% -noprofile -nologo -c "iex (%basestring%); Question-Dialog"
`) do set ret=%%i
if /i "%ret%" == "No" goto end_of_exit

:: NOTE
call %psshell% -noprofile -nologo -c "iex (%basestring%); Note-Dialog"

:: Checking ADB programs
:checkadb
set repos=https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip
echo Checking ADB program...

:: Downloading ADB programs if not exist
:adbnotexist
if not defined run_temporary ^
for %%e in (adb.exe) do ^
if exist "%%~$PATH:e" (set "FOUND_ADB_PATHENV=1" && set "ADBDIR=%%~dp$PATH:e")
if defined FOUND_ADB_PATHENV (
    echo ADB program was availabled on the computer.
    set basedir=%ADBDIR:~0,-1%
) else if not exist "%basedir%\adb.exe" (
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    echo Downloading Android SDK Platform Tools...
    call %psshell% -noprofile -nologo -c ^
    "iex (%basestring%); Download-Manager -Uri '%repos%' -Target '%temp%\platform-tools.zip'"

    echo Extracting Android SDK Platform Tools...
    call %psshell% -noprofile -nologo -c ^
    "iex (%basestring%); Extract-Zip -ZipFile '%temp%\platform-tools.zip' -DestinationPath '%temp%\'"
    for %%d in (platform-tools android-sdk\platform-tools) do if exist "%temp%\%%d" (
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do move "%temp%\%%d\%%f" "%basedir%\" > nul 2>&1
    rd /s /q "%temp%\%%d" > nul 2>&1
    )
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    set ADB_SUCCESS=1
) else (echo ADB program was availabled on the computer or this folder.)

if defined ADB_SUCCESS (
    if not exist "%basedir%\adb.exe" (
    echo Failed getting ADB program. Please try again.
    @ goto :eof
    ) else (
    echo ADB program was successfully placed.
    goto :checkadbdriver
    )
)

:checkadbdriver
set repos=https://dl.google.com/android/repository/latest_usb_driver_windows.zip
echo Checking ADB Interface driver installed...

:: Downloading ADB Interface driver
:drivernotinstalled
where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    echo Downloading ADB Interface driver...
    call %psshell% -noprofile -nologo -c ^
    "iex (%basestring%); Download-Manager -Uri '%repos%' -Target '%temp%\usb_driver.zip'"

    echo Extracting ADB Interface driver...
    call %psshell% -noprofile -nologo -c ^
    "iex (%basestring%); Extract-Zip -ZipFile '%temp%\usb_driver.zip' -DestinationPath '%temp%\'"

    echo Installing driver...
    call %psshell% -noprofile -nologo -c ^
    start -filepath pnputil.exe ^
    -argumentlist '-i -a "%temp%\usb_driver\android_winusb.inf"' ^
    -wait -windowstyle hidden -verb runas

    rd /s /q "%temp%\usb_driver" > nul 2>&1
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    set DRIVER_SUCCESS=1
) else (echo Driver already installed.)

set driverpkg='Driver package provider :\s+ Google, Inc.'
if defined DRIVER_SUCCESS (
    for /f usebackq %%a in (`
    call %psshell% -noprofile -nologo -c ^
    $(^( pnputil.exe -e ^^^| sls -Context 1 %driverpkg%^).Context.PreContext[0] -split ' : +'^)[1]
    `) do set oemdriver=%%a
    if not exist %SystemRoot%\inf\%oemdriver% (
    echo Failed installing driver. Please try again.
    @ goto :eof
    ) else (
    echo Driver successfully installed.
    goto :start_adb
    )
)

:: Starting ADB service
:start_adb
echo Starting ADB services...
call "%basedir%\adb" start-server

:: Checking devices
:checkdevice
echo Connecting to device...
call timeout /nobreak /t 1 > nul 2>&1
echo Please plug USB to your devices.
call "%basedir%\adb" wait-for-device
echo Connected.

:: Checking if your devices is F17A1H
:checkif_F17A1H
echo Checking if your devices is F17A1H...
for /f "tokens=*" %%d in ('call "%basedir%\adb" shell "getprop ro.fota.device" 2^> nul') do ^
set "FOTA_DEVICE=%%d"
if not "%FOTA_DEVICE%" == "Andromax F17A1H" (
    set MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H
    call "%basedir%\adb" kill-server
    call :remove_temporary
    goto :error
)

:: Activating airplane mode
:airplanemode
echo Activating airplane mode...
call "%basedir%\adb" shell "settings put global airplane_mode_on 1"
call "%basedir%\adb" shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

:: Injecting file
:injecting
echo Preparing version file %FILE% to injecting device...
call "%basedir%\adb" push "%FILE%" /sdcard/adupsfota/update.zip
echo Checking file...
call timeout /nobreak /t 4 > nul 2>&1
echo Verifying file...
call timeout /nobreak /t 12 > nul 2>&1

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
call timeout /nobreak /t 10 > nul 2>&1
call "%basedir%\adb" wait-for-device > nul 2>&1

for %%x in (%args%) do ^
for %%p in (-n --non-market) do ^
if %%~x! == %%p! set NON_MARKET=1
if defined NON_MARKET (
    echo Enabling install non market app...
    call "%basedir%\adb" shell "settings put global install_non_market_apps 1"
    call "%basedir%\adb" shell "settings put secure install_non_market_apps 1"
)

:: Complete
set MESSAGE_INFORM=Proses telah selesai
call %psshell% -noprofile -nologo -c "iex (%basestring%); Information-Dialog"

:kill_adb
echo Killing ADB services...
call "%basedir%\adb" kill-server
call :remove_temporary

call :end_of_exit
@ goto :eof

:remove_temporary
if defined run_temporary (
    echo Removing temporary program files...
    call "%basedir%\adb" kill-server
    for %%i in (adb.exe AdbWinApi.dll AdbWinApi.dll.dat AdbWinUsbApi.dll) do (
    attrib -s -h "%basedir%\%%i" > nul 2>&1
    del /q "%basedir%\%%i" > nul 2>&1
    )
)
@ goto :eof


:README
call %psshell% -noprofile -nologo -c "iex (%basestring%); ReadMe-Dialog"
call :end_of_exit
@ goto :eof

:USAGE
call %psshell% -noprofile -nologo -c "iex (%basestring%); Usage-Dialog"
call :end_of_exit
@ goto :eof

:error
call %psshell% -noprofile -nologo -c "iex (%basestring%); Error-Dialog"
call :end_of_exit
@ goto :eof


:setnewline
set _=^
%=Do not remove this line%

set _N=^^^%_%%_%^%_%%_%
@ goto :eof


:nopwsh
if %OLD_WIN%? == 1? goto winnt
echo This script requires Windows Module Framework (PowerShell).
@ goto :end_of_exit

:winnt
echo This script requires a newer version of Windows NT.
@ goto end_of_exit

:end_of_exit
@ ENDLOCAL
@ EXIT /B > NUL


::
:: DETAILS
::

::
:: inject.bat
:: OTA Haier F17A1H/Andromax Prime Injector Tool
::
:: Date/Time Created:          01/26/2021  1:30pm
:: Date/Time Modified:         06/12/2022  4:50pm
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Flasher
::
::
:: VersionInfo:
::
::    File version:      2,0,0
::    Product Version:   2,0,0
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   OTA Haier F17A1H/Andromax Prime Injector Tool
::    FileVersion:       2.0.0
::    InternalName:      inject
::    OriginalFileName:  inject.bat
::    ProductVersion:    2.0.0
::


::
:: COMMENTS
::

::
:: Inject update.zip script - Andromax Prime F17A1H
::
:: File update.zip dan batch script inject root dari Adi Subagja
:: Modifikasi batch script inject dari Faizal Hamzah
::
#>


[void](Add-Type -AssemblyName "System.Windows.Forms")
[void][Windows.Forms.Application]::EnableVisualStyles()
$MessageBox = New-Object Windows.Forms.Form
$MessageBox.TopMost = $True

function Download-Manager {
    param ([string]$Uri, [string]$Target)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    [void](New-Object Net.WebClient).DownloadFile($Uri, $Target)
}

function Extract-Zip {
    param ([string]$ZipFile, [string]$DestinationPath)
    [void](Add-Type -AssemblyName "System.IO.Compression.FileSystem")
    [void][IO.Compression.ZipFile]::ExtractToDirectory($ZipFile, $DestinationPath)
}

function Usage-Dialog {
    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox,
    "Inject update.zip for Haier F17A1H"  + "`n" +
    "`n" +
    "USAGE:   ${env:basefile} <update.zip file>"  + "`n" +
    "`n" +
    "Additional arguments are maybe to know:"  + "`n" +
    "   -a, --download-adb"        + "`t" +  "Run without check ADB and"  + "`n" +
                       "`t" + "`t" + "`t" +  "Fastboot module (ADB program"  + "`n" +
                       "`t" + "`t" + "`t" +  "permanently placed. Android"  + "`n" +
                       "`t" + "`t" + "`t" +  "only use)."  + "`n" +
    "   -h, --help"         + "`t" + "`t" +  "Show help information for this"  + "`n" +
                       "`t" + "`t" + "`t" +  "script."  + "`n" +
    "   -n, --non-market"   + "`t" + "`t" +  "Inject with install non market."  + "`n" +
    "   -Q, --run-temporary"       + "`t" +  "Run without check ADB and"  + "`n" +
                       "`t" + "`t" + "`t" +  "Fastboot module"  + "`n" +
                       "`t" + "`t" + "`t" +  "(ADB program not permanently"  + "`n" +
                       "`t" + "`t" + "`t" +  "placed)."  + "`n" +
    "   --readme"           + "`t" + "`t" +  "Show read-me (advanced help).",
    "${ENV:TITLE}:   Usage",
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::Information
    )
}

function ReadMe-Dialog {
    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox,
    "Untuk mengaktifkan mode USB debugging pada Haier F17A1H"  + "`n" +
    "sebagai berikut:"  + "`n" +
    "`n" +
    "  *   Dial ke nomor *#*#83781#*#*"  + "`n" +
    "  *   Masuk ke slide 2 (DEBUG&LOG)."  + "`n" +
    "  *   Pilih 'Design For Test'."  + "`n" +
    "  *   Pilih 'CMCC', lalu tekan OK."  + "`n" +
    "  *   Pilih 'MTBF'."  + "`n"  +
    "  *   Lalu pilih 'MTBF Start'."  + "`n" +
    "  *   Tunggu beberapa saat."  + "`n" +
    "  *   Pilih 'Confirm'."  + "`n" +
    "  *   Kalau sudah mulai ulang/restart HP nya."  + "`n" +
    "  *   Selamat USB debugging telah aktif."  + "`n" +
    "`n" +
    "`n" +
    "Jika masih tidak aktif, ada cara lain sebagai berikut:"  + "`n" +
    "`n" +
    "  *   Dial ke nomor *#*#257384061689#*#*"  + "`n" +
    "  *   Aktifkan 'USB Debugging'."  + "`n" +
    "  *   Izinkan aktifkan USB Debugging pada popupnya."  + "`n" +
    "`n" +
    "`n" +
    "Tinggal jalankan skrip ini dengan membuka Command"  + "`n" +
    "Prompt, dan jalankan adb start-server maka akan muncul"  + "`n" +
    "popup izinkan sambung USB Debugging di Haier F17A1H.",
    "${ENV:TITLE}:   Read-Me",
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::None
    )

    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox,
    "Special thanks to:"  + "`n" +
    "`n" +
    "    1.   Adi Subagja"  + "`n" +
    "    2.   Ahka"  + "`n" +
    "    3.   dan developer-developer Andromax Prime",
    "${ENV:TITLE}:   Read-Me",
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::None
    )
}

function Note-Dialog {
    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox,
    "  *   Harap aktifkan mode USB Debugging terlebih dahulu"  + "`n" +
    "       sebelum mengeksekusi inject update.zip [Untuk"  + "`n" +
    "       mengetahui bagaimana cara mengaktifkan mode USB"  + "`n" +
    "       debugging, dengan mengetik]:"  + "`n" +
    "`n" +
    "             ${env:basefile} --readme" + "`n" +
    "`n" +
    "  *   Apabila HP terpasang kartu SIM, skrip ini akan"  + "`n" +
    "       terotomatis mengaktifkan mode Pesawat."  + "`n" +
    "`n" +
    "NOTE:"  + "`t" +  "Harap baca dahulu sebelum eksekusi. Segala"  + "`n" +
               "`t" +  "kerusakan/apapun yang terjadi itu diluar tanggung"  + "`n" +
               "`t" +  "jawab pembuat file ini serta tidak ada kaitannya"  + "`n" +
               "`t" +  "dengan pihak manapun. Untuk lebih aman tanpa"  + "`n" +
               "`t" +  "resiko, dianjurkan update secara daring melalui"  + "`n" +
               "`t" +  "updater resmi.",
    $Null,
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::Warning
    )
}

function Error-Dialog {
    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox, ${ENV:MESSAGE_ERROR}, $Null,
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::Error
    )
}

function Information-Dialog {
    [void][Windows.Forms.MessageBox]::Show(
    $MessageBox, ${ENV:MESSAGE_INFORM}, $Null,
    [Windows.Forms.MessageBoxButtons]::OK,
    [Windows.Forms.MessageBoxIcon]::Information
    )
}

function Question-Dialog {
    [Windows.Forms.MessageBox]::Show(
    $MessageBox, ${ENV:MESSAGE_QUEST}, ${ENV:TITLE},
    [Windows.Forms.MessageBoxButtons]::YesNo,
    [Windows.Forms.MessageBoxIcon]::Question
    )
}