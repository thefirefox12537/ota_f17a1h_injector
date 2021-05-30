#!/bin/bash
set -e

# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

basedir="$(dirname "$(readlink -f "$0")")"

USAGE () {
    echo -e "Inject update.zip for Haier F17A1H

USAGE: $0 <update.zip file>

Additional arguments are maybe to know:
  -h, --help    Show help information for this script.
  --readme      Show read-me (advanced help)."
    exit 1
}

README () {
    README="Untuk mengaktifkan Debugging USB pada Andromax Prime
sebagai berikut:

  *  Dial/Tekan *#*#83781#*#*
  *  Slide 2 (debug & log).
  *  Design For Test.
  *  CMCC lalu tekan OK.
  *  MTBF.
  *  Lalu tekan MTBF.
  *  Please Wait.
  *  Pilih dan tekan Confirm.
  *  Kalau sudah lalu Mulai Ulang (restart HP).
  *  Selamat USB Debug telah aktif.


Jika masih tidak aktif, ada cara lain sebagai berikut:

  *  Dial/Tekan *#*#257384061689#*#*
  *  Aktifkan 'USB Debugging'.
  *  Izinkan aktifkan USB Debugging pada popupnya.


Tinggal jalankan skrip ini dengan membuka Terminal,
maka akan muncul popup izinkan sambung USB Debugging
di Andromax Prime."

    [ "$DIALOG" == "kdialog" ] && {
        $DIALOG --title "Read-Me" --msgbox "$README"
        $DIALOG --title "Read-Me" --msgbox "Special thanks to:
   1.  Adi Subagja
   2.  Ahka
   3.  dan developer-developer Andromax Prime"
    } || \
    echo -e "$README\n\n
Special thanks to:
   < Adi Subagja >
   < Ahka >
   < dan developer-developer Andromax Prime >" | more
    exit 1
}

start-adb () {
    [ "$DIALOG" == "kdialog" ] && \
    { echo "Starting ADB services..."
      $ADB start-server
    } || \
    { $ADB start-server 2>&1
    } | $DIALOG --gauge "Starting ADB services..." 6 63 0
}

kill-adb () {
    [ "$DIALOG" == "kdialog" ] && \
    { echo "Killing ADB services..."
      $ADB kill-server
    } || \
    { echo 0; sleep 1
      $ADB kill-server 2>&1
      echo 100
    } | $DIALOG --clear --gauge "Killing ADB services..." 6 63 0
}


## Set dialog screen program
for d in dialog whiptail kdialog
do which $d  > /dev/null 2>&1 && DIALOG="$d"
done

[ -z "$DIALOG" ] && {
    echo -e "This script requirements dialog box, one of which:

   dialog
   whiptail
   kdialog\n"
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

    [ -e /etc/os-release ] && . /etc/os-release || . /usr/lib/os-release

    [[ "$ID" = "debian" || "$ID_LIKE" = "debian" || "$ID_LIKE" = "ubuntu" ]] && DIST_CORE="debian"
    [[ "$ID" = "fedora" || "$ID_LIKE" = "fedora" || "$ID_LIKE" = *"rhel"* ]] && DIST_CORE="redhat"
    [[ "$ID" = *"suse"* || "$ID_LIKE" = *"suse"* ]] && DIST_CORE="suse"
    [[ "$ID" = "arch" || "$ID_LIKE" = "arch" ]] && DIST_CORE="archlinux"

    [[ -f /sys/devices/virtual/dmi/id/product_name ]] && \
        HOST=$(< /sys/devices/virtual/dmi/id/product_name)
    [[ -f /sys/firmware/devicetree/base/model ]] && \
        HOST=$(< /sys/firmware/devicetree/base/model)
    [[ -f /tmp/sysinfo/model ]] && \
        HOST=$(< /tmp/sysinfo/model)
    [[ "$HOST" ]] && HOST="Undefined"

    echo "+ OS Name: $NAME $VERSION"
    echo "+ Host: $HOST"
    echo "+ Kernel: $(uname -sr)"
    echo "+ Architecture: $(uname -p)"
    echo

    [[ ! "$DIST_CORE" ]] && {
        echo "This script cannot be run in this Linux distribution"
        exit 1
    }
    [[ $(uname -sr) < "Linux 4.4"* ]] && {
        echo "This script requirements Linux Kernel Version 4.4 later"
        exit 1
    }
    [[ $(uname -p) != *"64" ]] && {
        echo "This script requirements a 64-bit Operating System"
        exit 1
    }

    for d in dialog whiptail
    do [ "$DIALOG" == "$d" ] && YESNO_LABEL="--yes-button Ya --no-button Tidak"
    done

    [ "$DIALOG" == "kdialog" ] && YESNO_LABEL="--yes-label Ya --no-label Tidak"

    ( $DIALOG                                       \
      --yesno                                       \
"Anda yakin? File yang dipilih:
$(dirname "$(readlink -f "$1")")/$(basename "$1")"  \
     9 63                                           \
     $YESNO_LABEL                                   \
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
ADB=adb
[ "$DIALOG" == "kdialog" ] && \
{ echo "Checking ADB program..."
  [ -e "$basedir/adb" ] && ADB="./adb"
  which $ADB  >/dev/null 2>&1 || ERROR=1
} || \
{ sleep 0.2; echo 10
  [ -e "$basedir/adb" ] && ADB="./adb"
  sleep 0.5; echo 50
  which $ADB  >/dev/null 2>&1 || ERROR=1
  sleep 0.7; echo 90
  sleep 0.1; echo 100
} | $DIALOG --gauge "Checking ADB program..." 6 63 0

## Downloading ADB programs if not exist
while true
do
    [ "$DIALOG" == "kdialog" ] && \
    { [[ $ERROR -eq 1 ]] && \
      { echo "Downloading Android SDK Platform Tools..."
        wget -qO "/var/tmp/android-platform-tools.zip" \
                 https://dl.google.com/android/repository/platform-tools-latest-linux.zip
        echo "Extracting Android SDK Platform Tools..."
        unzip -qo "/var/tmp/android-platform-tools.zip" platform-tools/adb \
              -d "/var/tmp/"
        mv "/var/tmp/platform-tools/adb" "$basedir/"  >/dev/null 2>&1
        rm -rf "/var/tmp/platform-tools"  >/dev/null 2>&1
        rm "/var/tmp/android-platform-tools.zip"  >/dev/null 2>&1
        ADB="./adb"
        SUCCESS="1"
      } || echo "ADB program was availabled on the computer or this folder."
      [[ "$SUCCESS" ]] && echo "ADB program was successfully placed."
    } || \
    { [[ $ERROR -eq 1 ]] && \
      { echo 0; sleep 2
        echo 20; sleep 1
        wget -qO "/var/tmp/android-platform-tools.zip" \
                 https://dl.google.com/android/repository/platform-tools-latest-linux.zip
        echo 60; sleep 0.5
      } | $DIALOG --gauge "Downloading Android SDK Platform Tools..." 8 63 0
      { unzip -qo "/var/tmp/android-platform-tools.zip" platform-tools/adb \
              -d "/var/tmp/"
        echo 75; sleep 1
        mv "/var/tmp/platform-tools/adb" "$basedir/"  >/dev/null 2>&1
        echo 80; sleep 1
        rm -rf "/var/tmp/platform-tools"  >/dev/null 2>&1
        rm "/var/tmp/android-platform-tools.zip"  >/dev/null 2>&1
        ADB="./adb"
        echo 100; sleep 2
      } | $DIALOG --gauge "Extracting Android SDK Platform Tools..." 8 63 60
    }
    which $ADB  >/dev/null 2>&1 && break
done

## Starting ADB service
start-adb

## Checking devices
[ "$DIALOG" == "kdialog" ] && echo "Connecting to device..." || \
{ sleep 1; echo 50
} | $DIALOG --gauge "Connecting to device..." 6 63 0

[ "$DIALOG" == "kdialog" ] && \
{ sleep 1
  echo "Please plug USB to your devices."
  $ADB wait-for-device
} || \
{ $ADB wait-for-device 2>&1
  echo 100
} | $DIALOG --gauge "Please plug USB to your devices." 6 63 50

## Checking if your devices is F17A1H
[ "$DIALOG" == "kdialog" ] && \
{ echo "Checking if your devices is F17A1H..."
  for a in ro.product.device ro.build.product
  do
      for device in $($ADB shell "getprop $a")
      do [ "$device" != "grouper" ] && ERROR=2
      done
  done
  $ADB shell "getprop ro.build.id" > /dev/nulll 2>&1 | grep "F17A1H" || set ERROR=2
  [[ $ERROR -eq 2 ]] && {
      echo "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
      exit 1
  }
} || {
    { for a in ro.product.device ro.build.product
      do
          for device in $($ADB shell "getprop $a")
          do [ "$device" != "grouper" ] && ERROR=2
          done
      done
      echo 50; sleep 0.3
      $ADB shell "getprop ro.build.id" 2>&1 | grep "F17A1H" || set ERROR=2
      echo 100
    } | $DIALOG --gauge "Checking if your devices is F17A1H..." 6 63 0
    [[ $ERROR -eq 2 ]] && {
        $DIALOG --msgbox "\n     Perangkat anda bukan Andromax Prime/Haier F17A1H" 8 63
        exit 1
    }
}

## Activating airplane mode
[ "$DIALOG" == "kdialog" ] && \
{ echo "Activating airplane mode..."
  $ADB shell "settings put global airplane_mode_on 1"
  $ADB shell "am broadcast -a android.intent.action.AIRPLANE_MODE"
} || \
{ $ADB shell "settings put global airplane_mode_on 1" 2>&1
  echo 50
  $ADB shell "am broadcast -a android.intent.action.AIRPLANE_MODE" 2>&1
  echo 100
} | $DIALOG --gauge "Activating airplane mode..." 6 63 0

## Injecting file
[ "$DIALOG" == "kdialog" ] || \
{ sleep 2; echo 100
} | $DIALOG --gauge "Preparing version file $1 to injecting device..." 6 63 0

[ "$DIALOG" == "kdialog" ] && \
{ echo "Preparing version file $1 to injecting device..."
  $ADB push "$1" /sdcard/adupsfota/update.zip
} || \
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

[ "$DIALOG" == "kdialog" ] && echo "Checking file..." || \
{ sleep 2; echo 100
} | $DIALOG --gauge "Checking file..." 6 63 0

[ "$DIALOG" == "kdialog" ] && \
{ echo "Verifying file..."
  sleep 12
} || \
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
[ "$DIALOG" == "kdialog" ] && \
{ echo "Checking updates..."
  $ADB shell "settings put global install_non_market_apps 1"
  $ADB shell "settings put secure install_non_market_apps 1"
} || \
{ $ADB shell "settings put global install_non_market_apps 1" 2>&1
  $ADB shell "settings put secure install_non_market_apps 1" 2>&1
} | $DIALOG --gauge "Checking updates..." 6 63 0

[ "$DIALOG" == "kdialog" ] && \
{ echo "Cleaning FOTA updates..."
  $ADB shell "pm clear com.smartfren.fota"
} || \
{ $ADB shell "pm clear com.smartfren.fota" 2>&1
} | $DIALOG --gauge "Cleaning FOTA updates..." 6 63 0

[ "$DIALOG" == "kdialog" ] && \
{ echo "Manipulating FOTA updates..."
  $ADB shell "monkey -p com.smartfren.fota 1"
  $ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
  $ADB shell "input keyevent 20"
  $ADB shell "input keyevent 22"
  $ADB shell "input keyevent 23"
} || \
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

for d in dialog whiptail
do [ "$DIALOG" == "$d" ] && YESNO_LABEL="--yes-button Lanjutkan --no-button Batal"
done

[ "$DIALOG" == "kdialog" ] && YESNO_LABEL="--yes-label Lanjutkan --no-label Batal"

## Confirmation
( $DIALOG                                                    \
  --title "Persetujuan pengguna"                             \
  --yesno                                                    \
"Segala kerusakan/apapun yang terjadi itu diluar tanggung
jawab pembuat file ini serta tidak ada kaitannya dengan
pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
update secara daring melalui updater resmi." 10 63           \
  $YESNO_LABEL                                               \
  3>&1 1>&2 2>&3
) || \
{
    $ADB shell "rm /sdcard/adupsfota/update.zip" 2>&1
    kill-adb
    exit 1
}

## Start updating
[ "$DIALOG" == "kdialog" ] && \
{ echo "Updating..."
  $ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
  COUNTER=0
  while :
  do
      $ADB shell "input keyevent 20" 2>&1
      (( COUNTER+=1 ))
      [[ $COUNTER -eq 20 ]] && break
  done
  $ADB shell "input keyevent 23"
  sleep 1
} || \
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
[[ "$DIALOG" == "kdialog" ]] && \
$DIALOG --msgbox "Proses telah selesai" || \
$DIALOG --msgbox "\n           Proses telah selesai" 8 48

kill-adb
exit 0
