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
@ :: Haier_F17A1H OTA Updater Injector
@ ::
@ :: Date/Time Created:          01/26/2021  1:30pm
@ :: Date/Time Modified:         09/22/2021  2:48am
@ :: Operating System Created:   Windows 10 Pro
@ ::
@ :: This script created by:
@ ::   Faizal Hamzah
@ ::   The Firefox Flasher
@ ::
@ ::
@ :: VersionInfo:
@ ::
@ ::    File version:      1,3,0
@ ::    Product Version:   1,3,0
@ ::
@ ::    CompanyName:       The Firefox Flasher
@ ::    FileDescription:   Haier_F17A1H OTA Updater Injector
@ ::    FileVersion:       1.3.0
@ ::    InternalName:      inject
@ ::    OriginalFileName:  inject.bat
@ ::    ProductVersion:    1.3.0
@ ::



::BEGIN

:STARTSCRIPT
if "%OS%" == "Windows_NT"  goto runwinnt

:runos2
ver | find "Operating System/2"  > nul
if not errorlevel 1  goto win9xos2

:rundoswin
if exist %windir%\..\msdos.sys  find "WinVer" %windir%\..\msdos.sys | find "WinVer=4"  > nul
if not errorlevel 1  goto win9xos2
goto dos

:runwinnt
@ SETLOCAL
@ BREAK OFF

for %%v in (Daytona  Cairo  Hydra  Neptune  NT) do ver | findstr /r /c:"%%v"  > nul  && ^
if not errorlevel 1  set LOWERNT=1
if "%LOWERNT%" == "1" goto winnt

if not defined LOWERNT  setlocal EnableExtensions EnableDelayedExpansion

set "basedir=%~dp0"
set "basedir=%basedir:~0,-1%"
if %1!==!  goto USAGE

for %%p in (-h  --help) do if %1!==%%p!  goto USAGE
if %1!==--readme!  goto README

if exist %1  set "FILE=%1" & set "FULLPATH=%~dpnx1"
if exist %2  set "FILE=%2" & set "FULLPATH=%~dpnx2"
if not defined FILE  (
    echo File not found.
    goto end_of_exit
)

set "FILE=%FILE:"=%"
set "FULLPATH=%FULLPATH:"=""%"

:: Checking your system if approriate with requirements
:: Please wait at the moments.
:gettingrequire
for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') ^
do if "%%w" == "5"  ( set "WINVER=%%w.%%x.%%y" ) ^
else  ( set "WINVER=%%v.%%w.%%x" )
for %%v in (6.1.7600  6.0  5.2  5.1  5.00) ^
do if "%WINVER%" == "%%v"  (
    set "MESSAGE_ERROR=This script requirements Windows 7 Service Pack 1 or later"
    goto :error
)

for /f %%v in ('powershell -NoProfile -Command "(Get-Host).Version.Major"  2^> nul') ^
do set "PSVER_MAJOR=%%v"
if %PSVER_MAJOR% LSS 4  (
    set "MESSAGE_ERROR=This script requirements Windows Module Framework (PowerShell) version 4.0"
    goto :error
)

for /f "skip=2 tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Net Framework Setup\NDP\v4\Full" /v Version  2^> nul') ^
do set "DOTNETFX_VER=%%v"
if "%DOTNETFX_VER%" LSS "4.5"  (
    set "MESSAGE_ERROR=This script requirements Microsoft .NET Framework version 4.5 or later"
    goto :error
)


:: Main Menu
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   "Anda yakin? File yang dipilih:" + vbCrLf + _
    echo   "%FULLPATH%", _
    echo   vbYesNo, _
    echo   "Inject Andromax Prime" _
    echo ^)
)
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto end_of_exit

:: NOTE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   " *  Harap aktifkan USB Debugging terlebih dahulu sebelum mengeksekusi" + vbCrLf + _
    echo   "     inject update.zip [Untuk membaca cara mengaktifkan USB debugging," + vbCrLf + _
    echo   "     dengan mengetik]:" + vbCrLf + _
    echo   vbCrLf + _
    echo   "           %~nx0 --readme" + vbCrLf + _
    echo   vbCrLf + _
    echo   " *  Apabila HP terpasang kartu SIM, skrip akan terotomatis mengaktifkan" + vbCrLf + _
    echo   "     Mode Pesawat." + vbCrLf + _
    echo   vbCrLf + _
    echo   "NOTE:" + vbTab + "Harap baca dahulu sebelum eksekusi. Segala kerusakan/" + vbCrLf + _
    echo   vbTab + "apapun yang terjadi itu diluar tanggung jawab pembuat file ini" + vbCrLf + _
    echo   vbTab + "serta tidak ada kaitannya dengan pihak manapun. Untuk lebih" + vbCrLf + _
    echo   vbTab + "aman tanpa resiko, dianjurkan update secara daring melalui" + vbCrLf + _
    echo   vbTab + "updater resmi.", _
    echo   vbOKOnly _
    echo ^)
)
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:: Checking ADB programs
:checkadb
echo Checking ADB program...

:: Downloading ADB programs if not exist
:adbnotexist
if not exist "%basedir%\adb.exe"  (
    del /q "%temp%\platform-tools.zip"  > nul 2>&1
    echo Downloading Android SDK Platform Tools...
    powershell -NoProfile -Command ^
    $ProgressPreference = 'SilentlyContinue'; ^
    Invoke-WebRequest ^
      -uri https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip ^
      -OutFile '%temp%\platform-tools.zip'

    echo Extracting Android SDK Platform Tools...
    powershell -NoProfile -Command ^
    Add-Type -Assembly System.IO.Compression.FileSystem; ^
    [void][System.IO.Compression.ZipFile]::ExtractToDirectory^('%temp%\platform-tools.zip', '%temp%\'^)
    for %%d in (platform-tools android-sdk\platform-tools) do if exist "%temp%\%%d"  (
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do move "%temp%\%%d\%%f" "%basedir%\"  > nul 2>&1
    rd /s /q "%temp%\%%d"  > nul 2>&1
    )
    del /q "%temp%\platform-tools.zip"  > nul 2>&1
    if not exist "%basedir%\adb.exe"  (
        echo Failed getting ADB program. Please try again, make sure your network connected.
        @ goto :eof
    ) else  (
        echo ADB program was successfully placed.
    )
) else  ( echo ADB program was availabled on the computer or this folder. )

echo Checking ADB Interface driver installed...

:: Downloading ADB Interface driver
:drivernotinstalled
where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf  > nul 2>&1
if %ERRORLEVEL% NEQ 0  (
    del /q "%temp%\usb_driver.zip"  > nul 2>&1
    echo Downloading ADB Interface driver...
    powershell -NoProfile -Command ^
    $ProgressPreference = 'SilentlyContinue'; ^
    Invoke-WebRequest ^
      -uri https://dl.google.com/android/repository/latest_usb_driver_windows.zip ^
      -OutFile '%temp%\usb_driver.zip'

    echo Extracting ADB Interface driver...
    powershell -NoProfile -Command ^
    Add-Type -Assembly System.IO.Compression.FileSystem; ^
    [void][System.IO.Compression.ZipFile]::ExtractToDirectory^('%temp%\usb_driver.zip', '%temp%\'^)
    powershell -NoProfile -Command ^
    Start-Process PnPUtil.exe ^
      -Wait -WindowStyle hidden -Verb runas ^
      -ArgumentList '-i -a "%temp%\usb_driver\android_winusb.inf"'

    rd /s /q "%temp%\usb_driver"  > nul 2>&1
    del /q "%temp%\usb_driver.zip"  > nul 2>&1
    where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf  > nul 2>&1
    if %ERRORLEVEL% NEQ 0  (
        echo Failed installing driver. Please try again.
        @ goto :eof
    ) else  (
        echo Driver successfully installed.
    )
) else  ( echo Driver already installed. )

:: Starting ADB service
:start_adb
echo Starting ADB services...
.\adb start-server

:: Checking devices
:checkdevice
echo Connecting to device...
timeout /NOBREAK /T 1  > nul 2>&1
echo Please plug USB to your devices.
.\adb wait-for-device
echo Connected.

:: Checking if your devices is F17A1H
:checkif_F17A1H
echo Checking if your devices is F17A1H...
for /f "tokens=*" %%d in ('.\adb shell "getprop ro.fota.device"  2^> nul ^| findstr /r /c:"F17A1H"') do ^
set "FOTA_DEVICE=%%d"
if not "%FOTA_DEVICE%" == "Andromax F17A1H"  (
    set "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
    goto :error
)

:: Activating airplane mode
:airplanemode
echo Activating airplane mode...
.\adb shell "settings put global airplane_mode_on 1"
.\adb shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

:: Injecting file
:injecting
echo Preparing version file %FILE% to injecting device...
.\adb push "%FILE%" /sdcard/adupsfota/update.zip
echo Checking file...
echo Verifying file...
timeout /NOBREAK /T 12  > nul 2>&1

:: Calling FOTA update
echo Checking updates...
if %1!==--non-market!  set "NON_MARKET=1"
if %2!==--non-market!  set "NON_MARKET=1"
if defined NON_MARKET  (
    .\adb shell "settings put global install_non_market_apps 1"
    .\adb shell "settings put secure install_non_market_apps 1"
)

echo Cleaning FOTA update...
.\adb shell "pm clear com.smartfren.fota"

echo Manipulating FOTA update...
.\adb shell "monkey -p com.smartfren.fota 1"
.\adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
.\adb shell "input keyevent 20"
.\adb shell "input keyevent 22"
.\adb shell "input keyevent 23"

:: Start updating
:updating
echo Updating...
.\adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for /l %%a in (0, 1, 20) do .\adb shell "input keyevent 20"
.\adb shell "input keyevent 23"
timeout /nobreak /t 10  > nul 2>&1
.\adb wait-for-device  > nul 2>&1

:: Complete
> "%temp%\dialog.vbs" ( echo Wsh.Echo MsgBox^("Proses telah selesai", vbOKOnly^) )
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:kill_adb
echo Killing ADB services...
.\adb kill-server
call :end_of_exit
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
    echo Wsh.Echo MsgBox^( _
    echo   "Untuk mengaktifkan Debugging USB pada Andromax Prime" + vbCrLf + _
    echo   "sebagai berikut:" + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Dial/Tekan *#*#83781#*#*" + vbCrLf + _
    echo   "  *   Slide 2 (debug & log)." + vbCrLf + _
    echo   "  *   Design For Test." + vbCrLf + _
    echo   "  *   CMCC lalu tekan OK." + vbCrLf + _
    echo   "  *   MTBF." + vbCrLf + _
    echo   "  *   Lalu tekan MTBF." + vbCrLf + _
    echo   "  *   Please Wait." + vbCrLf + _
    echo   "  *   Pilih dan tekan Confirm." + vbCrLf + _
    echo   "  *   Kalau sudah lalu Mulai Ulang (restart HP)." + vbCrLf + _
    echo   "  *   Selamat USB Debug telah aktif." + vbCrLf + _
    echo   vbCrLf + _
    echo   vbCrLf + _
    echo   "Jika masih tidak aktif, ada cara lain sebagai berikut:" + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Dial/Tekan *#*#257384061689#*#*" + vbCrLf + _
    echo   "  *   Aktifkan 'USB Debugging'." + vbCrLf + _
    echo   "  *   Izinkan aktifkan USB Debugging pada popupnya." + vbCrLf + _
    echo   vbCrLf + _
    echo   vbCrLf + _
    echo   "Tinggal jalankan skrip ini dengan membuka Command" + vbCrLf + _
    echo   "Prompt, maka akan muncul popup izinkan sambung USB" + vbCrLf + _
    echo   "Debugging di Andromax Prime.", _
    echo   vbOKOnly, _
    echo   "Read-Me" _
    echo ^)
    echo.
    echo Wsh.Echo MsgBox^( _
    echo   "Special thanks to:" + vbCrLf + _
    echo   vbCrLf + _
    echo   "    1.   Adi Subagja" + vbCrLf + _
    echo   "    2.   Ahka" + vbCrLf + _
    echo   "    3.   dan developer-developer Andromax Prime", _
    echo   vbOKOnly, _
    echo   "Read-Me" _
    echo ^)
)
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof


:USAGE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   "Inject update.zip for Haier F17A1H" + vbCrLf + _
    echo   vbCrLf + _
    echo   "USAGE:  %~nx0 <update.zip file>" + vbCrLf + _
    echo   vbCrLf + _
    echo   "Additional arguments are maybe to know:" + vbCrLf + _
    echo   "    -h, --help" + vbTab + "    Show help information for this script." + vbCrLf + _
    echo   "    -n, --non-market    Inject with install non market (root.zip)." + vbCrLf + _
    echo   "    --readme" + vbTab + "    Show read-me (advanced help).", _
    echo   vbOKOnly, _
    echo   "Usage" _
    echo ^)
)
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof

:error
> "%temp%\dialog.vbs" ( echo Wsh.Echo MsgBox^("%MESSAGE_ERROR%", vbCritical^) )
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
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