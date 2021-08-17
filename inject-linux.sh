#!/bin/bash
#
# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

basedir="$(dirname "$(readlink -f "$0")")"
for file in "$1" "$2"
do [ -f "$file" ] && {
    FILE="$(basename "$file")"
    FULLPATH="$(dirname "$(readlink -f "$file")")/$FILE"
}
done

USAGE()
{
    echo -e "Inject update.zip for Haier F17A1H

USAGE: $0 <update.zip file>

Additional arguments are maybe to know:
  -h, --help         Show help information for this script.
  -n, --non-market   Inject with install non market (root.zip).
  --readme           Show read-me (advanced help)."
    exit 1
}

README()
{
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

start-adb() {
    echo "Starting ADB services..."
    ./adb start-server
}

kill-adb() {
    echo "Killing ADB services..."
    ./adb kill-server
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
    [ -z $FILE ] && {
        echo "File not found."
        exit 1
    }

    [ -e /etc/os-release ] && . /etc/os-release || . /usr/lib/os-release

    [[ "$ID" = "debian" || "$ID_LIKE" = "debian" || "$ID_LIKE" = "ubuntu" ]] && DIST_CORE="debian"
    [[ "$ID" = "fedora" || "$ID_LIKE" = "fedora" || "$ID_LIKE" = *"rhel"* ]] && DIST_CORE="redhat"
    [[ "$ID" = *"suse"* || "$ID_LIKE" = *"suse"* ]] && DIST_CORE="suse"
    [[ "$ID" = "arch" || "$ID_LIKE" = "arch" ]] && DIST_CORE="archlinux"

    [[ -z "$DIST_CORE" ]] && {
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

    ( $DIALOG                    \
      --yesno                    \
"Anda yakin? File yang dipilih:
$FULLPATH"                       \
     9 63                        \
     $YESNO_LABEL                \
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
echo "Checking ADB program..."

## Downloading ADB programs if not exist
[ -e "$basedir/adb" ] && \
echo "ADB program was availabled on the computer or this folder." || {
    echo "Downloading Android SDK Platform Tools..."
    wget -qO "/var/tmp/platform-tools.zip" \
             https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    echo "Extracting Android SDK Platform Tools..."
    unzip -qo "/var/tmp/platform-tools.zip" platform-tools/adb \
          -d "/var/tmp/"
    mv "/var/tmp/platform-tools/adb" "$basedir/"  >/dev/null 2>&1
    rm -rf "/var/tmp/platform-tools"  >/dev/null 2>&1
    rm "/var/tmp/platform-tools.zip"  >/dev/null 2>&1
    echo "ADB program was successfully placed."
}

## Starting ADB service
start-adb

## Checking devices
echo "Connecting to device..."
sleep 1; echo "Please plug USB to your devices."
./adb wait-for-device

## Checking if your devices is F17A1H
echo "Checking if your devices is F17A1H..."
FOTA_DEVICE="$(./adb shell "getprop ro.fota.device" 2> /dev/null | grep "F17A1H")"
[ "$FOTA_DEVICE" != "Andromax F17A1H" ] && {
    [[ "$DIALOG" == "kdialog" ]] && \
    echo "Perangkat anda bukan Andromax Prime/Haier F17A1H" || \
    $DIALOG -msgbox "\nPerangkat anda bukan Andromax Prime/Haier F17A1H" 8 48
    exit 1
}

## Activating airplane mode
echo "Activating airplane mode..."
./adb shell "settings put global airplane_mode_on 1"
./adb shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

## Injecting file
echo "Preparing version file $FILE to injecting device..."
./adb push $FILE /sdcard/adupsfota/update.zip
echo "Checking file..."
echo "Verifying file..."
sleep 12

## Calling FOTA update
echo "Checking updates..."
[ "$1" == "--non-market" ] && NON_MARKET=1
[ "$2" == "--non-market" ] && NON_MARKET=1
[[ "$NON_MARKET" ]] && {
    ./adb shell "settings put global install_non_market_apps 1"
    ./adb shell "settings put secure install_non_market_apps 1"
}

echo "Cleaning FOTA updates..."
./adb shell "pm clear com.smartfren.fota"

echo "Manipulating FOTA updates..."
./adb shell "monkey -p com.smartfren.fota 1"
./adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
./adb shell "input keyevent 20"
./adb shell "input keyevent 22"
./adb shell "input keyevent 23"

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
) || {
    ./adb shell "rm /sdcard/adupsfota/update.zip" 2>&1
    kill-adb
    exit 1
}

## Start updating
echo "Updating..."
./adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for (( i=1; i<=20; i++ ))
do ./adb shell "input keyevent 20"
done
./adb shell "input keyevent 23"
sleep 1

## Complete
[[ "$DIALOG" == "kdialog" ]] && \
$DIALOG --msgbox "Proses telah selesai" || \
$DIALOG --msgbox "\n           Proses telah selesai" 8 48

kill-adb
exit 0
