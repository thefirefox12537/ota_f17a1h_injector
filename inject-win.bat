@ ECHO OFF
@ GOTO STARTSCRIPT

@ ::
@ :: Microsoft Windows(R) Command Script
@ :: Copyright (c) 1990-2020 Microsoft Corp. All rights reserved.
@ ::

@ ::
@ :: DETAILS
@ ::

@ ::
@ :: inject.bat
@ :: OTA Haier F17A1H/Andromax Prime Injector Tool
@ ::
@ :: Date/Time Created:          01/26/2021  1:30pm
@ :: Date/Time Modified:         04/17/2022  4:10am
@ :: Operating System Created:   Windows 10 Pro
@ ::
@ :: This script created by:
@ ::   Faizal Hamzah
@ ::   The Firefox Flasher
@ ::
@ ::
@ :: VersionInfo:
@ ::
@ ::    File version:      1,5,3
@ ::    Product Version:   1,5,3
@ ::
@ ::    CompanyName:       The Firefox Flasher
@ ::    FileDescription:   OTA Haier F17A1H/Andromax Prime Injector Tool
@ ::    FileVersion:       1.5.3
@ ::    InternalName:      inject
@ ::    OriginalFileName:  inject.bat
@ ::    ProductVersion:    1.5.3
@ ::



::BEGIN

:STARTSCRIPT
if "%OS%" == "Windows_NT" goto runwinnt

:runos2
ver | find "Operating System/2" > nul
if not errorlevel 1 goto win9xos2

:rundoswin
if exist %windir%\..\msdos.sys find "WinDir" %windir%\..\msdos.sys > nul
if not errorlevel 1 goto win9xos2
goto dos

:runwinnt
@ SETLOCAL
@ BREAK OFF

for %%v in (Daytona Cairo Hydra Neptune NT) do ^
ver | find "%%v" > nul && ^
if not errorlevel 1 (set "OLD_WINNT=1")
if "%OLD_WINNT%" == "1" (goto winnt) ^
else (setlocal EnableExtensions EnableDelayedExpansion)

set "basedir=%~dp0"
set "basedir=%basedir:~0,-1%"
set "TITLE=OTA Haier F17A1H/Andromax Prime Injector Tool"

for %%x in (%1 %2 %3) do ^
if exist %%x (set "FILE=%%x" && set "FULLPATH=%%~dpfx" && set "EXTENSION=%%~xx")
set "_UPPERCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "_LOWERCASE=abcdefghijklmnopqrstuvwxyz"
for /l %%a in (0,1,25) do ^
call set "_from=%%_UPPERCASE:~%%a,1%%" && ^
call set "_to=%%_LOWERCASE:~%%a,1%%" && ^
call set "EXTENSION=%%EXTENSION:!_from!=!_to!%%"

:: Checking your system if approriate with requirements
:: Please wait at the moments.
:gettingrequire
for %%a in (6.0 5.3 5.2 5.1 5.10 5.0 5.00) do ^
for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') do ^
if "%%v.%%w" == "6.1" (if %%x LEQ 7600 (set "OLD_WIN=1")) else ^
if "%%v.%%w" == "%%a"  (set "OLD_WIN=1") else ^
if "%%w.%%x" == "%%a"  (set "OLD_WIN=1")
if "%OLD_WIN%" == "1" (
    set "MESSAGE_ERROR=This script requires Windows 7 Service Pack 1 or latest"
    goto :error
)

set "ProtocolType=Net.SecurityProtocolType"
for /f usebackq %%a in (`
call powershell.exe -noprofile -c ^
[Enum]::GetNames^([%ProtocolType%]^) -notcontains [%ProtocolType%]::Tls12 2^> nul
`) do if "%%a" == "True" (
    set "MESSAGE_ERROR=This script requires at least .NET Framework version 4.5 and Windows Module Framework version 4.0"
    goto :error
)

if exist "%temp%\run_online.tmp" echo Running online script mode...

if %1!==! goto USAGE
if %1!==--readme! goto README
for %%p in (-h --help) do ^
if %1!==%%p! goto USAGE
for %%p in (-Q --run-temporary) do ^
if %1!==%%p! (set "basedir=%temp%" && set "run_temporary=1")
for %%p in (-a --download-adb) do ^
if %1!==%%p! (set "MESSAGE_ERROR=You cannot run this argument in Windows." && goto :error)

if not defined FILE (
    set "MESSAGE_ERROR=File not found."
    goto :error
)

if not "%EXTENSION:~1%" == "zip" (
    set "MESSAGE_ERROR=File is not ZIP type."
    goto :error
)

:: Main Menu
set "FILE=%FILE:"=%"
set "FULLPATH=%FULLPATH:"=""%"
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo WScript.Echo MsgBox^( _
    echo   "Anda yakin? File yang dipilih:"  + vbCrLf + _
    echo   "%FULLPATH%", _
    echo   4+32, _
    echo   "%TITLE%" _
    echo ^)
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
for /f %%i in ('call cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
if %ret% EQU 7 goto end_of_exit

:: NOTE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo MsgBox _
    echo   "  *   Harap aktifkan mode USB Debugging terlebih dahulu"  + vbCrLf + _
    echo   "       sebelum mengeksekusi inject update.zip [Untuk"  + vbCrLf + _
    echo   "       mengetahui bagaimana cara mengaktifkan mode USB"  + vbCrLf + _
    echo   "       debugging, dengan mengetik]:" + vbCrLf + _
    echo   vbCrLf + _
    echo   "             %~nx0 --readme" + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Apabila HP terpasang kartu SIM, skrip ini akan"  + vbCrLf + _
    echo   "       terotomatis mengaktifkan mode Pesawat."  + vbCrLf + _
    echo   vbCrLf + _
    echo   "NOTE:"  + vbTab +  "Harap baca dahulu sebelum eksekusi. Segala"  + vbCrLf + _
    echo              vbTab +  "kerusakan/apapun yang terjadi itu diluar tanggung"  + vbCrLf + _
    echo              vbTab +  "jawab pembuat file ini serta tidak ada kaitannya"  + vbCrLf + _
    echo              vbTab +  "dengan pihak manapun. Untuk lebih aman tanpa"  + vbCrLf + _
    echo              vbTab +  "resiko, dianjurkan update secara daring melalui"  + vbCrLf + _
    echo              vbTab +  "updater resmi.", _
    echo   0+0+48
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript

:: Checking ADB programs
:checkadb
set "repos=https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip"
echo Checking ADB program...

:: Downloading ADB programs if not exist
:adbnotexist
if not defined run_temporary ^
for %%e in (adb.exe) do ^
if exist "%%~$PATH:e" (set "FOUND_ADB_PATHENV=1" && set "ADBDIR=%%~dp$PATH:e")
if defined FOUND_ADB_PATHENV (
    echo ADB program was availabled on the computer.
    set "basedir=%ADBDIR:~0,-1%"
) else if not exist "%basedir%\adb.exe" (
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    call powershell.exe -noprofile -c ^
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
    [void]^(Add-Type -AssemblyName 'System.IO.Compression.FileSystem'^); ^
    ^
    echo 'Downloading Android SDK Platform Tools...'; ^
    [void]^(New-Object Net.WebClient^).DownloadFile^('%repos%','%temp%\platform-tools.zip'^); ^
    ^
    echo 'Extracting Android SDK Platform Tools...'; ^
    [void][IO.Compression.ZipFile]::ExtractToDirectory^('%temp%\platform-tools.zip','%temp%\'^)
    for %%d in (platform-tools android-sdk\platform-tools) do if exist "%temp%\%%d" (
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do move "%temp%\%%d\%%f" "%basedir%\" > nul 2>&1
    rd /s /q "%temp%\%%d" > nul 2>&1
    )
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    set ADB_SUCCESS=1
) else (echo ADB program was availabled on the computer or this folder.)

if defined ADB_SUCCESS (
    if not exist "%basedir%\adb.exe" (echo Failed getting ADB program. Please try again. && @ goto :eof) ^
    else (echo ADB program was successfully placed. && goto :checkadbdriver)
)

:checkadbdriver
set "repos=https://dl.google.com/android/repository/latest_usb_driver_windows.zip"
echo Checking ADB Interface driver installed...

:: Downloading ADB Interface driver
:drivernotinstalled
where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    call powershell.exe -noprofile -c ^
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
    [void]^(Add-Type -AssemblyName 'System.IO.Compression.FileSystem'^); ^
    ^
    echo 'Downloading ADB Interface driver...'; ^
    [void]^(New-Object Net.WebClient^).DownloadFile^('%repos%','%temp%\usb_driver.zip'^); ^
    ^
    echo 'Extracting ADB Interface driver...'; ^
    [void][IO.Compression.ZipFile]::ExtractToDirectory^('%temp%\usb_driver.zip','%temp%\'^); ^
    ^
    echo 'Installing driver...'; ^
    start pnputil.exe ^
      -wait -windowstyle hidden -verb runas ^
      -argumentList '-i -a "%temp%\usb_driver\android_winusb.inf"'

    rd /s /q "%temp%\usb_driver" > nul 2>&1
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    set DRIVER_SUCCESS=1
) else (echo Driver already installed.)

set "driverpkg='Driver package provider :\s+ Google, Inc.'"
if defined DRIVER_SUCCESS (
    for /f usebackq %%a in (`
    call powershell.exe -noprofile -c ^
    $^(^( pnputil.exe -e ^| sls -Context 1 %driverpkg%^).Context.PreContext[0] -split ' : +'^)[1]
    `) do set "oemdriver=%%a"
    if not exist %SystemRoot%\inf\%oemdriver% (echo Failed installing driver. Please try again. && @ goto :eof) ^
    else (echo Driver successfully installed. && goto :start_adb)
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
    set "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
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
for /l %%a in (1,1,20) do ^
call "%basedir%\adb" shell "input keyevent 20" > nul 2>&1
call "%basedir%\adb" shell "input keyevent 23" > nul 2>&1
call timeout /nobreak /t 10 > nul 2>&1
call "%basedir%\adb" wait-for-device > nul 2>&1

for %%x in (%1 %2 %3) do ^
for %%p in (-n --non-market) do ^
if %%x!==%%p! set "NON_MARKET=1"
if defined NON_MARKET (
    echo Enabling install non market app...
    call "%basedir%\adb" shell "settings put global install_non_market_apps 1"
    call "%basedir%\adb" shell "settings put secure install_non_market_apps 1"
)

:: Complete
> "%temp%\dialog.vbs" (
    echo MsgBox "Proses telah selesai", vbOKOnly
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript

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

:wscript
> "%temp%\%1" (
    echo '
    echo ' Copyright ^(c^) Microsoft Corporation.  All rights reserved.
    echo '
    echo ' VBScript Source File
    echo '
    echo ' Script Name: %1
    echo '
    echo.
)
@ goto :eof

:README
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo MsgBox _
    echo   "Untuk mengaktifkan mode USB debugging pada Haier F17A1H"  + vbCrLf + _
    echo   "sebagai berikut:"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Dial ke nomor *#*#83781#*#*"  + vbCrLf + _
    echo   "  *   Masuk ke slide 2 (DEBUG&LOG)."  + vbCrLf + _
    echo   "  *   Pilih 'Design For Test'."  + vbCrLf + _
    echo   "  *   Pilih 'CMCC', lalu tekan OK."  + vbCrLf + _
    echo   "  *   Pilih 'MTBF'." + vbCrLf  + _
    echo   "  *   Lalu pilih 'MTBF Start'."  + vbCrLf + _
    echo   "  *   Tunggu beberapa saat."  + vbCrLf + _
    echo   "  *   Pilih 'Confirm'."  + vbCrLf + _
    echo   "  *   Kalau sudah mulai ulang/restart HP nya."  + vbCrLf + _
    echo   "  *   Selamat USB debugging telah aktif."  + vbCrLf + _
    echo   vbCrLf + _
    echo   vbCrLf + _
    echo   "Jika masih tidak aktif, ada cara lain sebagai berikut:"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Dial ke nomor *#*#257384061689#*#*"  + vbCrLf + _
    echo   "  *   Aktifkan 'USB Debugging'."  + vbCrLf + _
    echo   "  *   Izinkan aktifkan USB Debugging pada popupnya."  + vbCrLf + _
    echo   vbCrLf + _
    echo   vbCrLf + _
    echo   "Tinggal jalankan skrip ini dengan membuka Command"  + vbCrLf + _
    echo   "Prompt, dan jalankan adb start-server maka akan muncul"  + vbCrLf + _
    echo   "popup izinkan sambung USB Debugging di Haier F17A1H.", _
    echo   0+0+0, _
    echo   "%TITLE%:   Read-Me"
    echo MsgBox _
    echo   "Special thanks to:"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "    1.   Adi Subagja"  + vbCrLf + _
    echo   "    2.   Ahka"  + vbCrLf + _
    echo   "    3.   dan developer-developer Andromax Prime", _
    echo   0+0+0, _
    echo   "%TITLE%:   Read-Me"
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript
call :end_of_exit
@ goto :eof


:USAGE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo MsgBox _
    echo   "Inject update.zip for Haier F17A1H"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "USAGE:  %~nx0 <update.zip file>"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "Additional arguments are maybe to know:"  + vbCrLf + _
    echo   "   -a, --download-adb"        + vbTab +  "Run without check ADB and"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "Fastboot module (ADB program"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "permanently placed. Android"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "only use)."  + vbCrLf + _
    echo   "   -h, --help"        + vbTab + vbTab +  "Show help information for this"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "script."  + vbCrLf + _
    echo   "   -n, --non-market"  + vbTab + vbTab +  "Inject with install non market."  + vbCrLf + _
    echo   "   -Q, --run-temporary"       + vbTab +  "Run without check ADB and"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "Fastboot module"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "(ADB program not permanently"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "placed)."  + vbCrLf + _
    echo   "   --readme"          + vbTab + vbTab +  "Show read-me (advanced help).", _
    echo   0+0+64, _
    echo   "%TITLE%:   Usage"
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript
call :end_of_exit
@ goto :eof

:error
> "%temp%\dialog.vbs" (
    echo MsgBox "%MESSAGE_ERROR%", 0+0+16
    echo CreateObject^("Scripting.FileSystemObject"^).DeleteFile "%temp%\dialog.vbs"
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript
call :end_of_exit
@ goto :eof


:dos
echo This program cannot be run in DOS mode.
@ GOTO ENDSCRIPT

:win9xos2
echo This script requires Microsoft Windows NT.
@ GOTO ENDSCRIPT

:winnt
echo This script requires a newer version of Windows NT.

:end_of_exit
@ ENDLOCAL
@ GOTO ENDSCRIPT

:: END



@ ::
@ :: COMMENTS
@ ::
@ :: Inject update.zip script - Andromax Prime F17A1H
@ ::
@ :: File update.zip dan batch script inject root dari Adi Subagja
@ :: Modifikasi batch script inject dari Faizal Hamzah
@ ::

:ENDSCRIPT
@ ECHO ON