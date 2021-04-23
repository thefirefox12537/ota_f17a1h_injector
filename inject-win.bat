@ ECHO OFF
:STARTSCRIPT

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
:: Date/Time Modified:         04/22/2021  2:36am
:: Operating System Created:   Windows 10 Pro
::
:: This script created by:
::   Faizal Hamzah
::   The Firefox Flasher
::
::
:: VersionInfo:
::
::    File version:      1,0,0
::    Product Version:   1,0,0
::
::    CompanyName:       The Firefox Flasher
::    FileDescription:   Haier_F17A1H OTA Updater Injector
::    FileVersion:       1.0.0
::    InternalName:      inject
::    OriginalFileName:  inject.bat
::    ProductVersion:    1.0
::



::BEGIN
break off

if "%OS%" == "Windows_NT" goto runwinnt

:runos2
ver | find "Operating System/2" > nul
if not errorlevel 1 goto win9xos2

:rundoswin
find "WinVer" %HostWinBootDrv%\msdos.sys | find "WinVer=4" > nul
if not errorlevel 1 if not "%windir%" == "" goto win9xos2
goto dos

:runwinnt
setlocal
for %%v in (Cairo Hydra Neptune Whistler NT) do ver | findstr /r /c:"%%v" > nul
if not errorlevel 1 set LOWERNT=1
if "%LOWERNT%" == "1" goto winnt

if not defined LOWERNT  setlocal EnableExtensions EnableDelayedExpansion
for /f "tokens=4,5,6 delims=[.NT " %%a in ('ver') do (
    if %%a.%%b LEQ "6.0"  goto winnt
    if %%b.%%c LEQ "5.1"  goto winnt
)


for %%p in (-h --help) do if [%1] == [%%p] goto USAGE
if [%1] == [--readme] goto README

set "dir_0=%~dp0"
set "dir_0=%dir_0:~0,-1%"
if [%1] == [] goto USAGE
if not exist %1 (
    echo File not found.
    goto end_of_exit
)

:: Main Menu
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^("Versi yang dipilih:  %~dpnx1" + vbCrLf + "Anda yakin?", vbYesNo, "Inject Andromax Prime"^)
) >> "%temp%\dialog.vbs"
for /f %%i in ('cscript "%temp%\dialog.vbs" //nologo //e:vbscript') do set ret=%%i
del /q "%temp%\dialog.vbs"  > nul 2>&1
if %ret% EQU 7  goto end_of_exit

:: NOTE
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^(" *  Harap aktifkan USB Debugging terlebih dahulu sebelum" + vbCrLf + "     mengeksekusi inject update.zip [ Untuk membaca cara" + vbCrLf + "     mengaktifkan USB debugging, dengan mengetik ]:" + vbCrLf + vbCrLf + vbTab + "%~nx0 --readme" + vbCrLf + vbCrLf + " *  Apabila HP terpasang kartu SIM, pastikan HP dalam" + vbCrLf + "     Mode Pesawat.", vbOKOnly, "NOTE:  Harap baca dahulu sebelum eksekusi"^)
) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:: Checking ADB programs
:checkadb
echo Checking ADB program...
set ADB=adb
set ADB_which=adb
for %%a in ("%dir_0%" "%dir_0%\bin") do if exist "%%a\adb.exe"  (
    set "ADB=%%a\adb.exe"
    set "ADB_which=%ADB:\adb.exe=^:adb.exe%"
)

:: Downloading ADB programs if not exist
:adbnotexist
if defined ADB  (
    where "%ADB_which%"  > nul 2>&1
    if %errorlevel% EQU 1  (
        echo Downloading ADB program...
        set "ZIP=%temp%\android-platform-tools.zip"
        set "ADB_LINK=https://dl.google.com/android/repository/platform-tools-latest-windows.zip"
        bitsadmin /transfer adb /download /priority normal %ADB_LINK% %ZIP%
        if %errorlevel% EQU 1  goto :adbnotexist
        echo Extracting...
        call :unzip_script %ZIP% "%temp%\"
        move "%temp%\platform-tools\adb.exe" "%dir_0%\"  > nul 2>&1
        move "%temp%\platform-tools\adbWinAPI.dll" "%dir_0%\"  > nul 2>&1
        move "%temp%\platform-tools\adbWinUSBAPI.dll" "%dir_0%\"  > nul 2>&1
        del /s /q "%temp%\platform-tools"  > nul 2>&1
        del /q %ZIP%  > nul 2>&1
        set "ADB=%dir_0%\adb.exe"
        set "ADB_which=%ADB:\adb.exe=^:adb.exe%"
        set SUCCESS=1
        goto :adbnotexist
    ) else ( echo ADB program was availabled on the computer or this folder. )
    if defined SUCCESS  (
        echo ADB program was successfully downloaded.
        set SUCCESS=
    )
)

:: Starting ADB service
:start_adb
echo Starting ADB services...
%ADB% start-server

:: Checking devices
:checkdevice
echo Connecting to device...
timeout /NOBREAK /T 1  > nul 2>&1
echo Please plug USB to your devices.
%ADB% wait-for-device
echo Connected.

:: Injecting file
:injecting
echo Preparing version file %1 to injecting device...
%ADB% push "%1" /sdcard/adupsfota/update.zip
echo Checking file...
echo Verifying file...
timeout /NOBREAK /T 12  > nul 2>&1

:: Calling FOTA update
echo Checking updates...
%ADB% shell "settings put global install_non_market_apps 1"

echo Cleaning FOTA update...
%ADB% shell "pm clear com.smartfren.fota"

echo Manipulating FOTA update...
%ADB% shell "monkey -p com.smartfren.fota 1"
%ADB% shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
%ADB% shell "input keyevent 20"
%ADB% shell "input keyevent 22"
%ADB% shell "input keyevent 23"

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
%ADB% shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for /l %%a in (0,1,20) do %ADB% shell "input keyevent 20"
%ADB% shell "input keyevent 23"

:: Complete
echo Wsh.Echo MsgBox("Proses telah selesai", vbOKOnly) > "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1

:kill_adb
echo Killing ADB services...
%ADB% kill-server
if defined ADB  for %%v in (ADB ADB_which) do set %%v=
goto :end_of_exit

:wscript
( echo ' Copyright ^(c^) Microsoft Corporation.  All rights reserved.
  echo ' VBScript Source File
  echo ' Script Name: %1
  echo ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' ' '
) > "%temp%\%1"
goto :eof

:README
call :wscript dialog.vbs
( echo Wsh.Echo MsgBox^("Untuk mengaktifkan Debugging USB pada Andromax Prime sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#83781#*#*" + vbCrLf + "  *   Slide 2 (debug & log)." + vbCrLf + "  *   Design For Test." + vbCrLf + "  *   CMCC lalu tekan OK." + vbCrLf + "  *   MTBF." + vbCrLf + "  *   Lalu Tekan MTBF." + vbCrLf + "  *   Please Wait." + vbCrLf + "  *   Pilih dan tekan Confirm." + vbCrLf + "  *   Kalau Sudah Lalu Mulai Ulang (restart HP)." + vbCrLf + "  *   Selamat USB Debug Telah Aktif." + vbCrLf + "  *   Tinggal jalankan ADB yang sudah terinstall di" + vbCrLf + "       komputer dengan membuka Terminal, kemudian ketik:" + vbCrLf + vbCrLF + vbTab + "'adb start-server'" + vbCrLf + vbTab + "'adb devices'" + vbCrLf + vbCrLF + "       Maka akan muncul popup di Andromax Prime." + vbCrLf + vbCrLf + "Jika masih tidak aktif, ada cara lain sebagai berikut:" + vbCrLf + vbCrLf + "  *   Dial/Tekan *#*#257384061689#*#*" + vbCrLf + "  *   Aktifkan 'USB Debugging'." + vbCrLf + "  *   Izinkan aktifkan USB Debugging pada popupnya.", vbOKOnly, "Read-Me"^)
  echo.
  echo Wsh.Echo MsgBox^("Special thanks to:" + vbCrLf + vbCrLf + "    1.   Adi Subagja" + vbCrLf + "    2.   dan developer-developer Andromax Prime", vbOKOnly, "Read-Me"^)
) >> "%temp%\dialog.vbs"
cscript "%temp%\dialog.vbs" //nologo //e:vbscript > nul
del /q "%temp%\dialog.vbs"  > nul 2>&1
goto :end_of_exit

:USAGE
echo Inject update.zip for Haier F17A1H
echo.
echo USAGE: %~nx0 ^<update.zip file^>
echo.
echo Additional arguments are maybe to know:
echo  -h, --help    Show help information for this script.
echo  --readme      Show read-me (advanced help).
goto :end_of_exit

:unzip_script
call :wscript unzip.vbs
( echo set Fso = CreateObject^("Scripting.FileSystemObject"^)
  echo.
  echo if not Fso.FolderExists^(%2^) Then
  echo Fso.CreateFolder^(%2^)
  echo end if
  echo.
  echo set objShell = CreateObject^("Shell.Application"^)
  echo set FilesInZip=objShell.NameSpace^(%1^).items
  echo.
  echo objShell.NameSpace^(%2^).CopyHere^(FilesInZip^)
  echo set Fso = Nothing
  echo set objShell = Nothing
) >> "%temp%\unzip.vbs"
cscript "%temp%\unzip.vbs" //nologo //e:vbscript > nul
del /q "%temp%\unzip.vbs"  > nul 2>&1
goto :eof

:end_of_exit
endlocal
exit /b
goto :eof


:dos
echo This program cannot be run in DOS mode.
goto ENDSCRIPT

:win9xos2
echo This script requires Microsoft Windows NT.
goto ENDSCRIPT

:winnt
echo This script requires a newer version of Windows NT.
endlocal
goto ENDSCRIPT
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