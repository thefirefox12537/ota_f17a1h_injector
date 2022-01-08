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
@ :: Date/Time Modified:         01/04/2021  6:30am
@ :: Operating System Created:   Windows 10 Pro
@ ::
@ :: This script created by:
@ ::   Faizal Hamzah
@ ::   The Firefox Flasher
@ ::
@ ::
@ :: VersionInfo:
@ ::
@ ::    File version:      1,5,0
@ ::    Product Version:   1,5,0
@ ::
@ ::    CompanyName:       The Firefox Flasher
@ ::    FileDescription:   Haier_F17A1H OTA Updater Injector
@ ::    FileVersion:       1.5.0
@ ::    InternalName:      inject
@ ::    OriginalFileName:  inject.bat
@ ::    ProductVersion:    1.5.0
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

for %%v in (Daytona Cairo Hydra Neptune NT) do ver | findstr /r /c:"%%v" > nul && if not errorlevel 1 set OLD_WINNT=1
if "%OLD_WINNT%" == "1" goto winnt
if not defined OLD_WINNT (setlocal EnableExtensions EnableDelayedExpansion)

set "_UPPERCASE=ABCDEFGHIJKLMNOPQRSTUVWXYZ"
set "_LOWERCASE=abcdefghijklmnopqrstuvwxyz"

set "basedir=%~dp0"
set "basedir=%basedir:~0,-1%"
if %1!==! goto USAGE

if %1!==--readme! goto README
for %%p in (-h --help) do ^
if %1!==%%p! goto USAGE
for %%p in (-Q --run-temporary) do ^
if %1!==%%p! (set "basedir=%temp%" && set "run_temporary=1")
for %%p in (-a --download-adb) do ^
if %1!==%%p! (set "MESSAGE_ERROR=You cannot run this argument in Windows." && goto :error)

for %%x in (%1 %2 %3) do ^
if exist %%x (set "FILE=%%x" && set "FULLPATH=%%~dpfx" && set "EXTENSION=%%~xx")
for /l %%a in (0,1,25) do ^
call set "_from=%%_UPPERCASE:~%%a,1%%" && ^
call set "_to=%%_LOWERCASE:~%%a,1%%" && ^
call set "EXTENSION=%%EXTENSION:!_from!=!_to!%%"
if not defined FILE (
    echo File not found.
    goto end_of_exit
)

if not "%EXTENSION:~1%" == "zip" (
    echo File is not ZIP type.
    goto end_of_exit
)

set "FILE=%FILE:"=%"
set "FULLPATH=%FULLPATH:"=""%"

:: Checking your system if approriate with requirements
:: Please wait at the moments.
:gettingrequire
for /f "tokens=4-7 delims=[.NT] " %%v in ('ver') do ^
if "%%v.%%w" == "6.1" if %%x LEQ 7600 (set "OLDWIN=1") && ^
if "%%v.%%w" == "6.0"  (set "OLDWIN=1") && ^
if "%%v.%%w" == "5.3"  (set "OLDWIN=1") && ^
if "%%v.%%w" == "5.2"  (set "OLDWIN=1") && ^
if "%%w.%%x" == "5.1"  (set "OLDWIN=1") && ^
if "%%w.%%x" == "5.00" (set "OLDWIN=1")
if "%OLDWIN%" == "1" (
    set "MESSAGE_ERROR=This script requires Windows 7 Service Pack 1 or latest"
    goto :error
)

for /f usebackq %%a in (`call powershell -noprofile -command ^
$PSVersionTable.PSVersion -lt ^(New-Object Version 4,0^) 2^> nul`) do ^
if "%%a" == "True" (set "errorcapt=Windows Module Framework (PowerShell) version 4.0")
for /f usebackq %%a in (`call powershell -noprofile -command ^
[System.Enum]::GetNames^([System.Net.SecurityProtocolType]^) -notcontains 'Tls12' 2^> nul`) do ^
if "%%a" == "True" (set "errorcapt=at least .NET Framework version 4.5 and Windows Module Framework version 4.0")
if defined errorcapt (
    set "MESSAGE_ERROR=This script requires %errorcapt%"
    goto :error
)


:: Main Menu
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   "Anda yakin? File yang dipilih:"  + vbCrLf + _
    echo   "%FULLPATH%", _
    echo   vbYesNo, _
    echo   "Inject Andromax Prime" _
    echo ^)
)
for /f %%i in ('call cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs" > nul 2>&1
if %ret% EQU 7 goto end_of_exit

:: NOTE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   "  *   Harap aktifkan mode USB Debugging terlebih dahulu sebelum"  + vbCrLf + _
    echo   "       mengeksekusi inject update.zip [Untuk mengetahui bagaimana cara"  + vbCrLf + _
    echo   "       mengaktifkan mode USB debugging, dengan mengetik]:"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "             %~nx0 --readme" + vbCrLf + _
    echo   vbCrLf + _
    echo   "  *   Apabila HP terpasang kartu SIM, skrip ini akan terotomatis"  + vbCrLf + _
    echo   "       mengaktifkan mode Pesawat."  + vbCrLf + _
    echo   vbCrLf + _
    echo   "NOTE:"  + vbTab +  "Harap baca dahulu sebelum eksekusi. Segala kerusakan/"  + vbCrLf + _
    echo              vbTab +  "apapun yang terjadi itu diluar tanggung jawab pembuat file"  + vbCrLf + _
    echo              vbTab +  "ini serta tidak ada kaitannya dengan pihak manapun. Untuk"  + vbCrLf + _
    echo              vbTab +  "lebih aman tanpa resiko, dianjurkan update secara"  + vbCrLf + _
    echo              vbTab +  "daring melalui updater resmi.", _
    echo   vbOKOnly _
    echo ^)
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs" > nul 2>&1

:: Checking ADB programs
:checkadb
echo Checking ADB program...

:: Downloading ADB programs if not exist
:adbnotexist
if not exist "%basedir%\adb.exe" (
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    echo Downloading Android SDK Platform Tools...
    call powershell -noprofile -command ^
    if ^([System.Environment]::OSVersion.Version -lt ^(New-Object Version 6,2^)^) ^
    {[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12}; ^
    ^(New-Object System.Net.WebClient^).DownloadFile^( ^
      'https://dl.google.com/android/repository/platform-tools_r28.0.1-windows.zip', ^
      '%temp%\platform-tools.zip' ^
    ^)

    echo Extracting Android SDK Platform Tools...
    call powershell -noprofile -command ^
    Add-Type -Assembly System.IO.Compression.FileSystem; ^
    [System.IO.Compression.ZipFile]::ExtractToDirectory^( ^
      '%temp%\platform-tools.zip', ^
      '%temp%\' ^
    ^)
    for %%d in (platform-tools android-sdk\platform-tools) do if exist "%temp%\%%d" (
    for %%f in (adb.exe AdbWinApi.dll AdbWinUsbApi.dll) do move "%temp%\%%d\%%f" "%basedir%\" > nul 2>&1
    rd /s /q "%temp%\%%d" > nul 2>&1
    )
    del /q "%temp%\platform-tools.zip" > nul 2>&1
    set ADB_SUCCESS=1
) else (echo ADB program was availabled on the computer or this folder.)

if defined ADB_SUCCESS ^
if not exist "%basedir%\adb.exe" (
    echo Failed getting ADB program. Please try again, make sure your network connected.
    @ goto :eof
) else (
    echo ADB program was successfully placed.
)

:checkadbdriver
echo Checking ADB Interface driver installed...

:: Downloading ADB Interface driver
:drivernotinstalled
where /r "%SystemRoot%\system32\DriverStore\FileRepository" android_winusb.inf > nul 2>&1
if %ERRORLEVEL% NEQ 0 (
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    echo Downloading ADB Interface driver...
    call powershell -noprofile -command ^
    if ^([System.Environment]::OSVersion.Version -lt ^(New-Object Version 6,2^)^) ^
    {[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12}; ^
    ^(New-Object System.Net.WebClient^).DownloadFile^( ^
      'https://dl.google.com/android/repository/latest_usb_driver_windows.zip', ^
      '%temp%\usb_driver.zip' ^
    ^)

    echo Extracting ADB Interface driver...
    call powershell -noprofile -command ^
    Add-Type -Assembly System.IO.Compression.FileSystem; ^
    [System.IO.Compression.ZipFile]::ExtractToDirectory^( ^
      '%temp%\usb_driver.zip', ^
      '%temp%\' ^
    ^)

    echo Installing driver...
    call powershell -noprofile -command ^
    Start-Process pnputil.exe ^
      -Wait -WindowStyle hidden -Verb runas ^
      -ArgumentList '-i -a "%temp%\usb_driver\android_winusb.inf"'

    rd /s /q "%temp%\usb_driver" > nul 2>&1
    del /q "%temp%\usb_driver.zip" > nul 2>&1
    set DRIVER_SUCCESS=1
) else (echo Driver already installed.)

set "commands=call powershell -noprofile -command "pnputil.exe -e ^| ^
Select-String -Context 1 'Driver package provider :\s+ Google, Inc.' ^| ^
foreach{^($_.Context.PreContext[0] -split ' : +'^)[1]}""
if defined DRIVER_SUCCESS for /f usebackq %%a in (`%commands%`) do ^
if not exist %SystemRoot%\inf\%%a (
    echo Failed installing driver. Please try again.
    @ goto :eof
) else (
    echo Driver successfully installed.
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
for /f "tokens=*" %%d in ('call "%basedir%\adb" shell "getprop ro.fota.device" 2^> nul ^| findstr /r /c:"F17A1H"') do ^
set "FOTA_DEVICE=%%d"
if not "%FOTA_DEVICE%" == "Andromax F17A1H" (
    set "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
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
> "%temp%\dialog.vbs" (echo Wsh.Echo MsgBox^("Proses telah selesai", vbOKOnly^))
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs" > nul 2>&1

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
    echo Wsh.Echo MsgBox^( _
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
    echo   vbOKOnly, _
    echo   "Read-Me" _
    echo ^)
    echo.
    echo Wsh.Echo MsgBox^( _
    echo   "Special thanks to:"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "    1.   Adi Subagja"  + vbCrLf + _
    echo   "    2.   Ahka"  + vbCrLf + _
    echo   "    3.   dan developer-developer Andromax Prime", _
    echo   vbOKOnly, _
    echo   "Read-Me" _
    echo ^)
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs" > nul 2>&1
call :end_of_exit
@ goto :eof


:USAGE
call :wscript dialog.vbs
>> "%temp%\dialog.vbs" (
    echo Wsh.Echo MsgBox^( _
    echo   "Inject update.zip for Haier F17A1H"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "USAGE:  %~nx0 <update.zip file>"  + vbCrLf + _
    echo   vbCrLf + _
    echo   "Additional arguments are maybe to know:"  + vbCrLf + _
    echo   "   -a, --download-adb"        + vbTab +  "Run without check ADB and Fastboot module"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "(ADB program permanently placed. Android"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "only use)."  + vbCrLf + _
    echo   "   -h, --help"        + vbTab + vbTab +  "Show help information for this script."  + vbCrLf + _
    echo   "   -n, --non-market"  + vbTab + vbTab +  "Inject with install non market."  + vbCrLf + _
    echo   "   -Q, --run-temporary"       + vbTab +  "Run without check ADB and Fastboot module"  + vbCrLf + _
    echo                    vbTab + vbTab + vbTab +  "(ADB program not permanently placed)."  + vbCrLf + _
    echo   "   --readme"          + vbTab + vbTab +  "Show read-me (advanced help).", _
    echo   vbOKOnly, _
    echo   "Usage" _
    echo ^)
)
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs" > nul 2>&1
call :end_of_exit
@ goto :eof

:error
> "%temp%\dialog.vbs" (echo Wsh.Echo MsgBox^("%MESSAGE_ERROR%", vbCritical^))
call cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs" > nul 2>&1
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