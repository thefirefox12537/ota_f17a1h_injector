#!/system/bin/sh
set -e

# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

MAGISKDIR="/data/adb"
MAGISK="$MAGISKDIR/magisk"
MAGISK_MODULE="$MAGISKDIR/modules"
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
    echo -e "Untuk mengaktifkan Debugging USB pada Andromax Prime
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
di Andromax Prime.


Special thanks to:
   < Adi Subagja >
   < Ahka >
   < dan developer-developer Andromax Prime >" | more
    exit 1
}

start-adb () {
    echo "Starting ADB services..."
    adb start-server
}

kill-adb () {
    echo "Killing ADB services..."
    adb kill-server
}

pause () {
    echo -n "Press any key to continue..."
    read -srn1; echo
}


case $1 in
    "--help" | "-h" )  USAGE ;;
    "--readme" )       README ;;
    * )                ;;
esac

id="$(id)"; id="${id#*=}"; id="${id%%\(*}"; id="${id%% *}"
[ "$id" != "0" ] && {
    echo "This script only allow in root mode."
    exit 1
}

echo "+ OS Name: $(getprop ro.build.id)"
echo "+ Host: $(getprop ro.product.brand) $(getprop ro.product.model)"
echo "+ Android: $(getprop ro.build.version.release) (SDK $(getprop ro.build.version.sdk))"
echo "+ Kernel: $(uname -sr)"
echo "+ Architecture: $(uname -m)"
echo "+ Magisk installed: $([ -e "$MAGISK" ] && echo YES || echo NO)"
echo

[[ $(getprop ro.build.version.release) < "4.4"* \
|| $(getprop ro.build.version.sdk) -lt 19 ]] && {
    echo "This script cannot be run in older Android version."
    exit 1
}
[[ $(uname -sr) < "Linux 3"* ]] && {
    echo "This script requirements Linux Kernel Version 3.0 later."
    exit 1
}
[ ! -e "$MAGISK" ] && {
    echo "This script requires Magisk."
    exit 1
}
[ ! -e /system/etc/permissions/android.hardware.usb.host.xml ] && {
    echo "This script requirements your devices installed USB Host."
    exit 1
}

## Main Menu
[[ "$1" ]] && {
    [ ! -f "$1" ] && {
        echo "File not found."
        exit 1
    }

    echo -ne "File yang dipilih: \n$(dirname "$(readlink -f "$1")")/$(basename "$1") \nAnda yakin? "
    while true
    do
        read -srn1 YN
        echo
        case $YN in
            y | Y )  break ;;
            n | N )  exit 1 ;;
            * )      echo -ne "Anda yakin? " ;;
        esac
    done
} || USAGE

## NOTE
echo -ne "NOTE:  Harap baca dahulu sebelum eksekusi

 *  Harap aktifkan USB Debugging terlebih dahulu sebelum
    mengeksekusi inject update.zip [ Untuk membaca cara
    mengaktifkan USB debugging, dengan mengetik ]:
       $0 --readme
 *  Apabila HP terpasang kartu SIM, skrip akan terotomatis
    mengaktifkan mode pesawat.
"
pause

## Checking ADB programs
echo "Checking ADB program..."
[ -e "$MAGISK_MODULE/adb-ndk/system/bin/adb" ] && \
echo "ADB program was availabled on this device." || {
    echo -e "ADB program cannot be found on this device. \nMake sure ADB and Fastboot module already installed."
    exit 1
}

## Starting ADB service
start-adb

## Checking devices
echo "Connecting to device..."
sleep 1; echo "Please plug USB to your devices."
adb wait-for-device
echo "Connected."

## Checking if your devices is F17A1H
echo "Checking if your devices is F17A1H..."
for a in ro.product.device ro.build.product
do
    for device in $(adb shell "getprop $a")
    do [ "$device" != "grouper" ] && ERROR=1
    done
done
adb shell "getprop ro.build.id" > /dev/nulll 2>&1 | grep "F17A1H" || set ERROR=1
[[ $ERROR -eq 1 ]] && {
    echo "MESSAGE_ERROR=Perangkat anda bukan Andromax Prime/Haier F17A1H"
    exit 1
}

## Activating airplane mode
echo "Activating airplane mode..."
adb shell "settings put global airplane_mode_on 1"
adb shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

## Injecting file
echo "Preparing version file $1 to injecting device..."
adb push "$1" /sdcard/adupsfota/update.zip
echo "Checking file..."
echo "Verifying file..."
sleep 12

## Calling FOTA update
echo "Checking updates..."
adb shell "settings put global install_non_market_apps 1"
adb shell "settings put secure install_non_market_apps 1"

echo "Cleaning FOTA updates..."
adb shell "pm clear com.smartfren.fota"

echo "Manipulating FOTA updates..."
adb shell "monkey -p com.smartfren.fota 1"
adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
adb shell "input keyevent 20"
adb shell "input keyevent 22"
adb shell "input keyevent 23"

## Confirmation
echo -ne "Persetujuan pengguna

Segala kerusakan/apapun yang terjadi itu diluar tanggung
jawab pembuat file ini serta tidak ada kaitannya dengan
pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
update secara daring melalui updater resmi.

Lanjutkan? "
while true
do
    read -srn1 YN
    echo
    case $YN in
        y | Y )  break ;;
        n | N )  adb shell "rm /sdcard/adupsfota/update.zip"
                 kill-adb
                 exit 1
                 ;;
        * )      echo -ne "Lanjutkan? " ;;
    esac
done

## Start updating
echo "Updating..."
adb shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
COUNTER=0
while :
do
    adb shell "input keyevent 20"
    (( COUNTER+=1 ))
    [[ $COUNTER -eq 20 ]] && break
done
adb shell "input keyevent 23"
sleep 1

## Complete
echo "Proses telah selesai"
pause
kill-adb
exit 0
