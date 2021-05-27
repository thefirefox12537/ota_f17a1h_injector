#!/bin/bash
set -e

# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

dir_0="$(dirname "$(readlink -f "$0")")"

USAGE () {
    echo -e "Inject update.zip for Haier F17A1H

USAGE: $0 <update.zip file>

Additional arguments are maybe to know:
  -h, --help    Show help information for this script.
  --readme      Show read-me (advanced help)."
    exit 1
}

README () {
    echo -e "Untuk mengaktifkan Debugging USB pada Andromax Prime
sebagai berikut:

  a.)  Dial/Tekan *#*#83781#*#*
  b.)  Slide 2 (debug & log).
  c.)  Design For Test.
  d.)  CMCC lalu tekan OK.
  e.)  MTBF.
  f.)  Lalu Tekan MTBF.
  g.)  Please Wait.
  h.)  Pilih dan tekan Confirm.
  i.)  Kalau Sudah Lalu Mulai Ulang (restart HP).
  j.)  Selamat USB Debug Telah Aktif.

  
Jika masih tidak aktif, ada cara lain sebagai berikut:

  a.)  Dial/Tekan *#*#257384061689#*#*
  b.)  Aktifkan \"USB Debugging\".
  c.)  Izinkan aktifkan USB Debugging pada popupnya.


Tinggal jalankan skrip ini dengan membuka Terminal,
maka akan muncul popup izinkan sambung USB Debugging di
Andromax Prime.


Special thanks to:
   < Adi Subagja >
   < dan developer-developer Andromax Prime >" | more
    exit 1
}

start-adb () {
    { $ADB start-server 2>&1
    } | $DIALOG --gauge "Starting ADB services..." 6 63 0
}

kill-adb () {
    { echo 0; sleep 1
      $ADB kill-server 2>&1
      echo 100
    } | $DIALOG --clear --gauge "Killing ADB services..." 6 63 0
}


## Set dialog screen program
[ ! -x "$(which dialog)" ] && DIALOG="dialog" || \
[ ! -x "$(which whiptail)" ] && DIALOG="whiptail" || {
    id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
    [ "$id" != "0" ] && \
    [ "$id" != "root" ] && {
        which su  >/dev/null 2>&1    &&  SUDO_COMMAND="su -c "
        which sudo  >/dev/null 2>&1  &&  SUDO_COMMAND="sudo "
    }
    [ -e /etc/os-release ] && . /etc/os-release || . /usr/lib/os-release

    ## Debian and Ubuntu based distro
    [ "$ID" == "debian" ] || [ "$ID_LIKE" == "debian" ] || [ "$ID_LIKE" == "ubuntu" ] \
    && REPO_COMMANDS="apt-get install"

    ## Fedora and RedHat based distro
    [ "$ID" == "fedora" ] || [ "$ID_LIKE" == "fedora" ] || [[ "$ID_LIKE" == *"rhel"* ]] \
    && REPO_COMMANDS="dnf install"

    ## Arch Linux based distro
    [ "$ID" == "arch" ] || [ "$ID_LIKE" == "arch" ] \
    && REPO_COMMANDS="pacman -S"

    ## SUSE based distro
    [[ "$ID" == *"suse"* ]] || [[ "$ID_LIKE" == *"suse"* ]] \
    && REPO_COMMANDS="zypper in"

    echo -e "This script requirements dialog box, one of which:

   dialog\n   whiptail\n"
    [[ $REPO_COMMANDS ]] && \
    echo -e "Please install that with type:

   $SUDO_COMMAND$REPO_COMMANDS dialog
       or
   $SUDO_COMMAND$REPO_COMMANDS whiptail\n"
    exit 1
}

case $1 in
    "--help" | "-h" )  USAGE;;
    "--readme" )       README;;
    * )                ;;
esac

## Main Menu
[[ "$1" ]] && {
    [ ! -f "$1" ] && {
        echo "File not found."
        exit 1
    }

    ( $DIALOG                                 \
      --yesno                                 \
"Anda yakin? File yang dipilih:

$(dirname $(readlink -f $1))/$(basename $1)"  \
     11 63                                    \
      --yes-button 'Ya'                       \
      --no-button 'Tidak'                     \
      3>&1 1>&2 2>&3
    ) || exit 1
} || USAGE

## NOTE
$DIALOG                                                      \
--title "NOTE:  Harap baca dahulu sebelum eksekusi"          \
--msgbox                                                     \
" *  Harap aktifkan USB Debugging terlebih dahulu sebelum
    mengeksekusi inject update.zip [ Untuk membaca cara
    mengaktifkan USB debugging, dengan mengetik ]:
      $0 --readme
 *  Apabila HP terpasang kartu SIM, skrip akan terotomatis
    mengaktifkan mode pesawat." 11 63

## Checking ADB programs
ADB="adb"
{ sleep 0.2; echo 10
  for a in "$dir_0" "$dir_0/bin"
  do
      [ -x "$a/adb" ] && \
      ADB="$a/adb"
  done
  sleep 0.5; echo 50
  which $ADB >/dev/null 2>&1 || ERROR=1
  sleep 0.7; echo 90
  sleep 0.1; echo 100
} | $DIALOG --gauge "Checking ADB program..." 6 63 0

## Downloading ADB programs if not exist
while true
do
    [[ $ERROR -eq 1 ]] && \
    { echo 0; sleep 2
      echo 20; sleep 1
      wget -qO "/var/tmp/android-platform-tools.zip" \
               https://dl.google.com/android/repository/platform-tools-latest-linux.zip
      echo 60; sleep 0.5
      unzip -qo "$ZIP" platform-tools/adb \
            -d "/var/tmp/"
      echo 75; sleep 1
      mv "/var/tmp/platform-tools/adb" "$dir_0/"  >/dev/null 2>&1
      echo 80; sleep 1
      rm -rf "/var/tmp/platform-tools"  >/dev/null 2>&1
      rm "$ZIP"  >/dev/null 2>&1
      echo 100; sleep 2
      ADB="$dir_0/adb"
    } | $DIALOG --gauge "Downloading ADB program..." 8 63
    which $ADB >/dev/null 2>&1 && break
done

## Starting ADB service
start-adb

## Checking devices
{ sleep 1; echo 50
} | $DIALOG --gauge "Connecting to device..." 6 63 0
{ $ADB wait-for-device 2>&1
  echo 100
} | $DIALOG --gauge "Please plug USB to your devices." 6 63 50

## Activating airplane mode
{ $ADB shell "settings put global airplane_mode_on 1" 2>&1
  echo 50
  $ADB shell "am broadcast -a android.intent.action.AIRPLANE_MODE" 2>&1
  echo 100
} | $DIALOG --gauge "Activating airplane mode..." 6 63 0

## Injecting file
{ sleep 2; echo 100
} | $DIALOG --gauge "Preparing version file $1 to injecting device..." 6 63 0
{ COUNTER=0
  while :
  do
      cat << eof
XXX
$COUNTER
Injecting...
XXX
eof
      (( COUNTER+=10 ))
      [[ $COUNTER -eq 80 ]] && break
      sleep 0.5
  done
  echo 81
  $ADB push "$1" /sdcard/adupsfota/update.zip 2>&1
  echo 95; sleep 0.5
  echo 99; sleep 0.1
  echo 100
} | $DIALOG --gauge "Injecting..." 6 63 0
{ sleep 2; echo 100
} | $DIALOG --gauge "Checking file..." 6 63 0
{ COUNTER=0
  while :
  do
      cat << eof
XXX
$COUNTER
Verifying file...
XXX
eof
      sleep 1
      (( COUNTER+=10 ))
      [[ $COUNTER -eq 100 ]] && break
  done
} | $DIALOG --gauge "Verifying file..." 6 63 0

## Calling FOTA update
{ $ADB shell "settings put global install_non_market_apps 1" 2>&1
} | $DIALOG --gauge "Checking updates..." 6 63 0

{ $ADB shell "pm clear com.smartfren.fota" 2>&1
} | $DIALOG --gauge "Cleaning FOTA updates..." 6 63 0
{ $ADB shell "monkey -p com.smartfren.fota 1" 2>&1
  echo 27
  $ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity" 2>&1
  echo 66
  $ADB shell "input keyevent 20" 2>&1
  echo 78
  $ADB shell "input keyevent 22" 2>&1
  echo 92
  $ADB shell "input keyevent 23" 2>&1
  echo 100
} | $DIALOG --gauge "Manipulating FOTA updates..." 6 63 0

## Confirmation
( $DIALOG                                                    \
  --title "Persetujuan pengguna"                             \
  --yesno                                                    \
"Segala kerusakan/apapun yang terjadi itu diluar tanggung
jawab pembuat file ini serta tidak ada kaitannya dengan
pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
update secara daring melalui updater resmi." 10 63           \
  --yes-button 'Lanjutkan'                                   \
  --no-button 'Batal'                                        \
  3>&1 1>&2 2>&3
) || \
{
    $ADB shell "rm /sdcard/adupsfota/update.zip" 2>&1
    kill-adb
    exit 1
}

## Start updating
{ $ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity" 2>&1
  COUNTER=0
  while :
  do
      cat << eof
XXX
$COUNTER
Updating...
XXX
eof
      $ADB shell "input keyevent 20" 2>&1
      (( COUNTER+=4 ))
      [[ $COUNTER -eq 80 ]] && break
  done
  sleep 0.5; echo 93
  $ADB shell "input keyevent 23" 2>&1
  sleep 1; echo 100
} | $DIALOG --gauge "Updating..." 6 63 0

## Complete
$DIALOG --msgbox "\n           Proses telah selesai" 8 48
kill-adb
exit 0
