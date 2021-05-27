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
:: Date/Time Modified:         05/27/2021 11:10am
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Flasher
::
::
:: VersionInfo:
::
::    File version:      1,1,0
::    Product Version:   1,1,0
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Haier_F17A1H OTA Updater Injector
::    FileVersion:       1.1.0
::    InternalName:      inject
::    OriginalFileName:  inject.bat
::    ProductVersion:    1.1
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

if not defined LOWERNT  setlocal EnableExtensions
for %%p in (-h --help) do if "%1" == "%%p" goto USAGE
if "%1" == "--readme" goto README

set "dir_0=%~dp0"
set "dir_0=%dir_0:~0,-1%"
if [%1] == [] goto USAGE
if not exist %1 (
    echo File not found.
    goto end_of_exit
)

echo Getting any requirements...
echo.
for /f "tokens=* delims=ProductName*REG_SZ* " %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" 2^> nul ^| findstr /r /c:"\<ProductName"') do ( set "OSVER=%%v" )

for /f "tokens=3-5" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion" 2^> nul ^| findstr /r /c:"\<CSDVersion"') do ( set "SPCHK=[%%v %%w %%x]" )

for /f "tokens=4-7 delims=[.NT] " %%a in ('ver') do (
    if "%%b" == "5" ( set "WINVER=%%b.%%c.%%d" ) ^
    else ( set "WINVER=%%a.%%b.%%c" )
)
for %%v in (6.1.7600 6.0 5.2 5.1 5.00) do if "%WINVER%" == "%%v"  ( set "NO_WIN7SP1=1" )

for /f "tokens=2 delims=: " %%v in ('powershell -Command Get-Host 2^> nul ^| findstr /r /c:"Version"') do ( set "POWERSHELLVER=%%v" )
if "%POWERSHELLVER%" LSS "4.0"  ( set "OLD_PWSH=1" )
if not defined POWERSHELLVER  ( set "POWERSHELLVER=N/A" )

for /f "tokens=3" %%v in ('reg query "HKLM\SOFTWARE\Microsoft\Net Framework Setup\NDP\v4\Full" 2^> nul ^| findstr /r /c:"\<Version"') do ( set DOTNETFX_VER=%%v )
if "%DOTNETFX_VER%" LSS "4.5"  ( set "OLD_DOTNETFX=1" )
if not defined DOTNETFX_VER  ( set "DOTNETFX_VER=N/A" )

echo  + OS Name: %OSVER% %SPCHK%
echo  + Kernel: %OS% %WINVER%
echo  + Architecture: %PROCESSOR_ARCHITECTURE%
echo  + PowerShell version: %POWERSHELLVER%
echo  + .NET Framework: %DOTNETFX_VER%
echo.

if defined NO_WIN7SP1  (
    set "MESSAGE_ERROR=This script requirements Windows 7 Service Pack 1 or later"
    goto :error
)
if defined OLD_PWSH  (
    set "MESSAGE_ERROR=This script requirements Windows PowerShell version 4.0"
    goto :error
)
if defined OLD_DOTNETFX  (
    set "MESSAGE_ERROR=This script requirements .NET Framework 4.5 or later"
    goto :error
)

:: Main Menu
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^("File yang dipilih:  %~dpnx1" + vbCrLf + "Anda yakin?", vbYesNo, "Inject Andromax Prime"^)
) >> "%temp%\dialog.vbs"
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto end_of_exit

:: NOTE
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^(" *  Harap aktifkan USB Debugging terlebih dahulu sebelum" + vbCrLf + "     mengeksekusi inject update.zip [ Untuk membaca cara" + vbCrLf + "     mengaktifkan USB debugging, dengan mengetik ]:" + vbCrLf + vbCrLf + vbTab + "%~nx0 --readme" + vbCrLf + vbCrLf + " *  Apabila HP terpasang kartu SIM, skrip akan terotomatis" + vbCrLf + "     mengaktifkan Mode Pesawat.", vbOKOnly, "NOTE:  Harap baca dahulu sebelum eksekusi"^)
) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:: Checking ADB programs
:checkadb
echo Checking ADB program...
set "ADB=adb"
set "ADB_which=adb"
set "ADB_DIR=%dir_0%"
for %%a in (%dir_0% %dir_0%\bin) do if exist "%%a\adb.exe"  (
    set "ADB=%%a\adb.exe"
    set "ADB_which=%%a:adb.exe"
    set "ADB_DIR=%%a"
)

:: Downloading ADB programs if not exist
:adbnotexist
if "%SUCCESS%" EQU "1"  (
    echo ADB program was successfully downloaded.
    goto :eof
)
where "%ADB_which%"  > nul 2>&1
if %ERRORLEVEL% EQU 0  ( echo ADB program was availabled on the computer or this folder. ) ^
else (
    echo Downloading Android Platform Tools...
    call :download_script "%temp%\platform-tools.zip" https://dl.google.com/android/repository/platform-tools-latest-windows.zip 

    echo Extracting Android Platform Tools...
    call :unzip_script "%temp%\platform-tools.zip" "%temp%\"
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do (
        move "%temp%\android-sdk\platform-tools\%%f" "%dir_0%\"  > nul 2>&1
        move "%temp%\platform-tools\%%f" "%dir_0%\"  > nul 2>&1
    )
    rd /s /q "%temp%\android-sdk"  > nul 2>&1
    rd /s /q "%temp%\platform-tools"  > nul 2>&1
    del /q "%temp%\platform-tools.zip"  > nul 2>&1

    set "ADB=%dir_0%\adb.exe"
    set "ADB_DIR=%dir_0%"
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
    echo Downloading ADB Interface driver...
    call :download_script "%temp%\usb_driver.zip" https://dl.google.com/android/repository/latest_usb_driver_windows.zip
    call :download_script "%temp%\DPInst.zip" https://drive.google.com/u/0/uc?id=16Qo6VVz63lyStSeGDa6g58HodR7ac_Uz

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
"%ADB%" start-server

:: Checking devices
:checkdevice
echo Connecting to device...
timeout /NOBREAK /T 1  > nul 2>&1
echo Please plug USB to your devices.
"%ADB%" wait-for-device
echo Connected.

:: Activating airplane mode
:airplanemode
echo Activating airplane mode...
"%ADB%" shell "settings put global airplane_mode_on 1"
"%ADB%" shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

:: Injecting file
:injecting
echo Preparing version file %1 to injecting device...
"%ADB%" push "%1" /sdcard/adupsfota/update.zip
echo Checking file...
echo Verifying file...
timeout /NOBREAK /T 12  > nul 2>&1

:: Calling FOTA update
echo Checking updates...
"%ADB%" shell "settings put global install_non_market_apps 1"

echo Cleaning FOTA update...
"%ADB%" shell "pm clear com.smartfren.fota"

echo Manipulating FOTA update...
"%ADB%" shell "monkey -p com.smartfren.fota 1"
"%ADB%" shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
"%ADB%" shell "input keyevent 20"
"%ADB%" shell "input keyevent 22"
"%ADB%" shell "input keyevent 23"

:: Confirmation
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^("Segala kerusakan/apapun yang terjadi itu diluar tanggung jawab pembuat file ini serta tidak ada kaitannya dengan pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan update secara daring melalui updater resmi.", vbYesNo, "Persetujuan pengguna"^)
) >> "%temp%\dialog.vbs"
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto kill_adb

:: Start updating
:updating
echo Updating...
"%ADB%" shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for /l %%a in (0,1,20) do "%ADB%" shell "input keyevent 20"
"%ADB%" shell "input keyevent 23"

:: Complete
echo Wsh.Echo MsgBox("Proses telah selesai", vbOKOnly) > "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:kill_adb
echo Killing ADB services...
"%ADB%" kill-server
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
( echo Wsh.Echo MsgBox^("Untuk mengaktifkan Debugging USB pada Andromax Prime" + vbCrLf + "sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#83781#*#*" + vbCrLf + "  *   Slide 2 (debug & log)." + vbCrLf + "  *   Design For Test." + vbCrLf + "  *   CMCC lalu tekan OK." + vbCrLf + "  *   MTBF." + vbCrLf + "  *   Lalu Tekan MTBF." + vbCrLf + "  *   Please Wait." + vbCrLf + "  *   Pilih dan tekan Confirm." + vbCrLf + "  *   Kalau Sudah Lalu Mulai Ulang (restart HP)." + vbCrLf + "  *   Selamat USB Debug Telah Aktif." + vbCrLf + vbCrLf + vbCrLf + "Jika masih tidak aktif, ada cara lain sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#257384061689#*#*" + vbCrLf + "  *   Aktifkan 'USB Debugging'." + vbCrLf + "  *   Izinkan aktifkan USB Debugging pada popupnya." + vbCrLf +vbCrLf + vbCrLf + "Tinggal jalankan skrip ini dengan membuka Command" + vbCrLf + "Prompt, maka akan muncul popup izinkan sambung USB" + vbCrLf + "Debugging di Andromax Prime.", vbOKOnly, "Read-Me"^)
  echo.
  echo Wsh.Echo MsgBox^("Special thanks to:" + vbCrLf + vbCrLf + "    1.   Adi Subagja" + vbCrLf + "    2.   dan developer-developer Andromax Prime", vbOKOnly, "Read-Me"^)
) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
call :end_of_exit
@ goto :eof


:USAGE
echo Inject update.zip for Haier F17A1H
echo.
echo USAGE: %~nx0 ^<update.zip file^>
echo.
echo Additional arguments are maybe to know:
echo  -h, --help    Show help information for this script.
echo  --readme      Show read-me (advanced help).
call :end_of_exit
@ goto :eof

:error
echo %MESSAGE_ERROR%
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