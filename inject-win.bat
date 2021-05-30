@ ECHO OFF
@ GOTO STARTSCRIPT

::
:: Microsoft Windows(R) Command Script
:: Copyright (c) 1990-2020 Microsoft Corp. All rights reserved.
::

::
:: DETAILS
::

::
:: inject.bat
:: Haier_F17A1H OTA Updater Injector
::
:: Date/Time Created:          01/26/2021  1:30pm
:: Date/Time Modified:         05/30/2021  4:44pm
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Flasher
::
::
:: VersionInfo:
::
::    File version:      1,1,1
::    Product Version:   1,1,1
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Haier_F17A1H OTA Updater Injector
::    FileVersion:       1.1.1
::    InternalName:      inject
::    OriginalFileName:  inject.bat
::    ProductVersion:    1.1.1
::



::BEGIN

:STARTSCRIPT
if "%OS%" == "Windows_NT" goto runwinnt

:runos2
ver | find "Operating System/2" > nul
if not errorlevel 1 goto win9xos2

:rundoswin
if exist %windir%\..\msdos.sys find "WinVer" %windir%\..\msdos.sys | find "WinVer=4" > nul
if not errorlevel 1 goto win9xos2
goto dos

:runwinnt
@ SETLOCAL
@ BREAK OFF

for %%v in (Daytona Cairo Hydra Neptune NT) do ver | findstr /r /c:"%%v" > nul && if not errorlevel 1 set LOWERNT=1
if "%LOWERNT%" == "1" goto winnt

if not defined LOWERNT  setlocal EnableExtensions EnableDelayedExpansion
for %%p in (-h --help) do if "%1" == "%%p" goto USAGE
if "%1" == "--readme" goto README

set "basedir=%~dp0"
set "basedir=%basedir:~0,-1%"
if [%1] == [] goto USAGE
if not exist %1 (
    echo File not found.
    goto end_of_exit
)

:: Getting any requirements
:gettingrequire
set "dlm=ProductName*REG_SZ*"
for /f "tokens=* delims=%dlm% " %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" 2^> nul ^| findstr /r /c:"\<ProductName"') do ( set "OSVER=%%v" )

for /f "tokens=3-5" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" 2^> nul ^| findstr /r /c:"\<CSDVersion"') do ( set "SPCHK=[%%v %%w %%x]" )

for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') do ( if "%%w" == "5" ( set "WINVER=%%w.%%x.%%y" ) else ( set "WINVER=%%v.%%w.%%x" ) )
for %%v in (6.1.7600 6.0 5.2 5.1 5.00) do if "%WINVER%" == "%%v"  ( set "NO_WIN7SP1=1" )

set "dlm1=System Manufacturer"  &&  set "dlm2=System Model"
for /f "tokens=* delims=%dlm1: =*%: " %%v in ('systeminfo 2^> nul ^| findstr /r /c:"%dlm1%"') do ^
for /f "tokens=* delims=%dlm2: =*%: " %%w in ('systeminfo 2^> nul ^| findstr /r /c:"%dlm2%"') do ( set "HOST=%%v %%w" )

for /f "tokens=2 delims=: " %%v in ('powershell -Command Get-Host 2^> nul ^| findstr /r /c:"Version"') do ( set "POWERSHELLVER=%%v" )
if "%POWERSHELLVER%" LSS "4.0"  ( set "OLD_PWSH=1" )
if not defined POWERSHELLVER  ( set "POWERSHELLVER=N/A" )

for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Net Framework Setup\NDP\v4\Full" 2^> nul ^| findstr /r /c:"\<Version"') do ( set "DOTNETFX_VER=%%v" )
if "%DOTNETFX_VER%" LSS "4.5"  ( set "OLD_DOTNETFX=1" )
if not defined DOTNETFX_VER  ( set "DOTNETFX_VER=N/A" )

if "%PROCESSOR_ARCHITECTURE%" == "X86" ( set "SOFTWAREHIVE=HKLM\SOFTWARE" ) ^
else ( set "SOFTWAREHIVE=HKLM\SOFTWARE\Wow6432Node" )
for /f "tokens=3" %%v in ('reg query "%SOFTWAREHIVE%\Microsoft\VisualStudio\14.0\VC\Runtimes\X86" 2^> nul ^| findstr /r /c:"\<Version"') do ( set "MSVCR_VER=%%v" )
if not defined MSVCR_VER  ( set "NO_MSVCR=1"  &&  set "MSVCR_INST=N/A" ) ^
else ( set "MSVCR_INST=YES" )

:: Your system
echo + OS Name: %OSVER% %SPCHK%
echo + Host: %HOST%
echo + Kernel: %OS% %WINVER%
echo + Architecture: %PROCESSOR_ARCHITECTURE%
echo + PowerShell version: %POWERSHELLVER%
echo + .NET Framework: %DOTNETFX_VER%
echo + Visual C++ Redist 2015: %MSVCR_INST%
echo.

:: Not allowed from requirements
if defined NO_WIN7SP1  (
    set "MESSAGE_ERROR=This script requirements Windows 7 Service Pack 1 or later"
    goto :error
) else if defined OLD_PWSH  (
    set "MESSAGE_ERROR=This script requirements Windows PowerShell version 4.0"
    goto :error
) else if defined OLD_DOTNETFX  (
    set "MESSAGE_ERROR=This script requirements .NET Framework 4.5 or later"
    goto :error
) else if defined NO_MSVCR  (
    set "MESSAGE_ERROR=This script requirements Visual C++ 2015 Redistribution or later"
    goto :error
)

:: Main Menu
call :wscript dialog.vbs
echo Wsh.Echo MsgBox^("Anda yakin? File yang dipilih:" + vbCrLf + "%~dpnx1", vbYesNo, "Inject Andromax Prime"^) >> "%temp%\dialog.vbs"
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto end_of_exit

:: NOTE
call :wscript dialog.vbs
echo Wsh.Echo MsgBox^(" *  Harap aktifkan USB Debugging terlebih dahulu sebelum" + vbCrLf + "     mengeksekusi inject update.zip [ Untuk membaca cara" + vbCrLf + "     mengaktifkan USB debugging, dengan mengetik ]:" + vbCrLf + vbCrLf + vbTab + "%~nx0 --readme" + vbCrLf + vbCrLf + " *  Apabila HP terpasang kartu SIM, skrip akan terotomatis" + vbCrLf + "     mengaktifkan Mode Pesawat.", vbOKOnly, "NOTE:  Harap baca dahulu sebelum eksekusi"^) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:: Checking ADB programs
:checkadb
echo Checking ADB program...

:: Downloading ADB programs if not exist
:adbnotexist
if "%SUCCESS%" EQU "1"  (
    echo ADB program was successfully placed.
    goto :eof
)
if exist "%basedir%\adb.exe"  ( echo ADB program was availabled on the computer or this folder. ) ^
else (
    if not exist "%temp%\platform-tools.zip" (
        echo Downloading Android SDK Platform Tools...
        call :download_script "%temp%\platform-tools.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip
    )

    echo Extracting Android SDK Platform Tools...
    call :unzip_script "%temp%\platform-tools.zip" "%temp%\"
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do (
        move "%temp%\android-sdk\platform-tools\%%f" "%basedir%\"  > nul 2>&1
        move "%temp%\platform-tools\%%f" "%basedir%\"  > nul 2>&1
    )
    rd /s /q "%temp%\android-sdk"  > nul 2>&1
    rd /s /q "%temp%\platform-tools"  > nul 2>&1
    del /q "%temp%\platform-tools.zip"  > nul 2>&1

    set "SUCCESS=1"
    call :adbnotexist
)

echo Checking ADB Interface driver installed...

:: Downloading ADB Interface driver
:drivernotinstalled
if "%SUCCESS%" EQU "2"  (
    echo Driver successfully installed.
    goto :eof
)
where /r "%SystemRoot%\System32\DriverStore\FileRepository" android_winusb.inf  > nul 2>&1
if %ERRORLEVEL% EQU 0  ( echo Driver already installed. ) ^
else (
    if not exist "%temp%\usb_driver.zip" (
        echo Downloading ADB Interface driver...
        call :download_script "%temp%\usb_driver.zip" https://dl.google.com/android/repository/latest_usb_driver_windows.zip
        call :download_script "%temp%\DPInst.zip" https://drive.google.com/u/0/uc?id=16Qo6VVz63lyStSeGDa6g58HodR7ac_Uz
    )

    echo Extracting ADB Interface driver...
    call :unzip_script "%temp%\usb_driver.zip" "%temp%\"
    call :unzip_script "%temp%\DPInst.zip" "%temp%\usb_driver\"
    if "%PROCESSOR_ARCHITECTURE%" == "X86" ( "%temp%\usb_driver\DPInst_x86.exe" /f /lm /sw /a ) ^
    else ( "%temp%\usb_driver\DPInst_x64.exe" /f /lm /sw /a )

    rd /s /q "%temp%\usb_driver"  > nul 2>&1
    del /q "%temp%\usb_driver.zip"
    del /q "%temp%\DPInst.zip"

    set "SUCCESS=2"
    call :drivernotinstalled
)

:: Starting ADB service
:start_adb
echo Starting ADB services...
adb start-server

:: Checking devices
:checkdevice
echo Connecting to device...
timeout /NOBREAK /T 1  > nul 2>&1
echo Please plug USB to your devices.
adb wait-for-device
echo Connected.

:: Checking if your devices is F17A1H
:checkif_F17A1H
echo Checking if your devices is F17A1H...
for %%a in (ro.product.device ro.build.product) do ^
for /f usebackq %%d in (`adb shell "getprop %%a"`) do if not "%%d" == "grouper" set ERROR=1
adb shell "getprop ro.build.id" > nul 2>&1 | findstr /r /c:"F17A1H" || set ERROR=1
if defined ERROR  (
    set "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
    goto :error
)

:: Activating airplane mode
:airplanemode
echo Activating airplane mode...
adb shell "settings put global airplane_mode_on 1"
adb shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

:: Injecting file
:injecting
echo Preparing version file %1 to injecting device...
adb push "%1" /sdcard/adupsfota/update.zip
echo Checking file...
echo Verifying file...
timeout /NOBREAK /T 12  > nul 2>&1

:: Calling FOTA update
echo Checking updates...
adb shell "settings put global install_non_market_apps 1"
adb shell "settings put secure install_non_market_apps 1"

echo Cleaning FOTA update...
adb shell "pm clear com.smartfren.fota"

echo Manipulating FOTA update...
adb shell "monkey -p com.smartfren.fota 1"
adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
adb shell "input keyevent 20"
adb shell "input keyevent 22"
adb shell "input keyevent 23"

:: Confirmation
call :wscript dialog.vbs
echo Wsh.Echo MsgBox^("Segala kerusakan/apapun yang terjadi itu diluar tanggung jawab pembuat file ini serta tidak ada kaitannya dengan pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan update secara daring melalui updater resmi.", vbYesNo, "Persetujuan pengguna"^) >> "%temp%\dialog.vbs"
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto kill_adb

:: Start updating
:updating
echo Updating...
adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for /l %%a in (0,1,20) do adb shell "input keyevent 20"
adb shell "input keyevent 23"

:: Complete
echo Wsh.Echo MsgBox("Proses telah selesai", vbOKOnly) > "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:kill_adb
echo Killing ADB services...
adb kill-server
if defined ADB  for %%v in (ADB ADB_which) do set %%v=
call :end_of_exit
@ goto :eof

:wscript
( echo ' Copyright ^(c^) Microsoft Corporation.  All rights reserved.
  echo ' VBScript Source File
  echo ' Script Name: %1
  echo ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
) > "%temp%\%1"
@ goto :eof

:README
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^("Untuk mengaktifkan Debugging USB pada Andromax Prime" + vbCrLf + "sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#83781#*#*" + vbCrLf + "  *   Slide 2 (debug & log)." + vbCrLf + "  *   Design For Test." + vbCrLf + "  *   CMCC lalu tekan OK." + vbCrLf + "  *   MTBF." + vbCrLf + "  *   Lalu tekan MTBF." + vbCrLf + "  *   Please Wait." + vbCrLf + "  *   Pilih dan tekan Confirm." + vbCrLf + "  *   Kalau sudah lalu Mulai Ulang (restart HP)." + vbCrLf + "  *   Selamat USB Debug telah aktif." + vbCrLf + vbCrLf + vbCrLf + "Jika masih tidak aktif, ada cara lain sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#257384061689#*#*" + vbCrLf + "  *   Aktifkan 'USB Debugging'." + vbCrLf + "  *   Izinkan aktifkan USB Debugging pada popupnya." + vbCrLf +vbCrLf + vbCrLf + "Tinggal jalankan skrip ini dengan membuka Command" + vbCrLf + "Prompt, maka akan muncul popup izinkan sambung USB" + vbCrLf + "Debugging di Andromax Prime.", vbOKOnly, "Read-Me"^)
  echo.
  echo Wsh.Echo MsgBox^("Special thanks to:" + vbCrLf + vbCrLf + "    1.   Adi Subagja" + vbCrLf + "    2.   Ahka" + vbCrLf + "    3.   dan developer-developer Andromax Prime", vbOKOnly, "Read-Me"^)
) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof


:USAGE
call :wscript dialog.vbs
echo Wsh.Echo MsgBox^("Inject update.zip for Haier F17A1H" + vbCrLf + vbCrLf + "USAGE:  %~nx0 <update.zip file>" + vbCrLf + vbCrLf + "Additional arguments are maybe to know:" + vbCrLf + "     -h, --help" + vbTab + "Show help information for this script." + vbCrLf + "     --readme" + vbTab + "Show read-me (advanced help).", vbOKOnly, "Usage"^) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof

:error
call :wscript dialog.vbs
echo Wsh.Echo MsgBox^("%MESSAGE_ERROR%", vbCritical^) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof

:unzip_script
call :wscript unzip.vbs
( echo set objShell = CreateObject^("Shell.Application"^)
  echo objShell.NameSpace^(%2^).CopyHere^(objShell.NameSpace^(%1^).items^)
) >> "%temp%\unzip.vbs"
cscript "%temp%\unzip.vbs" //nologo //e:vbscript > nul
del /q "%temp%\unzip.vbs"  > nul 2>&1
@ goto :eof

:download_script
powershell -Command Invoke-WebRequest -uri %2 -OutFile %1
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



::
:: COMMENTS
::
:: Inject update.zip script - Andromax Prime F17A1H
::
:: File update.zip dan batch script inject root dari Adi Subagja
:: Modifikasi batch script inject dari Faizal Hamzah
::

:ENDSCRIPT
@ ECHO ON