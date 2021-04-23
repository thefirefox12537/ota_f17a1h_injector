#!/system/bin/sh
set -e

# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

MAGISKDIR="/data/adb"
MAGISK="$MAGISKDIR/magisk"
MAGISK_MODULE="$MAGISKDIR/modules"
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
  k.)  Tinggal jalankan ADB yang sudah terinstall di
       komputer dengan membuka Terminal, kemudian ketik:

          'adb start-server'
          'adb devices'

       Maka akan muncul popup di Andromax Prime.


Jika masih tidak aktif, ada cara lain sebagai berikut:

  a.)  Dial/Tekan *#*#257384061689#*#*
  b.)  Aktifkan \"USB Debugging\".
  c.)  Izinkan aktifkan USB Debugging pada popupnya.


Special thanks to:
   < Adi Subagja >
   < dan developer-developer Andromax Prime >" | more
    exit 1
}

start-adb () {
    echo "Starting ADB services..."
    $ADB start-server
}

kill-adb () {
    echo "Killing ADB services..."
    $ADB kill-server
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
[ "$id" != "0" ] && \
[ "$id" != "root" ] && {
    echo "This script only allow in root mode."
    exit 1
}

[ -e "$MAGISK" ] || {
    echo "This script requires Magisk."
    exit 1
}

## Main Menu
[[ "$1" ]] && {
    [ ! -f "$1" ] && {
        echo "File not found."
        exit 1
    }

    echo -ne "File yang dipilih: $1 \nAnda yakin? "
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
 *  Apabila HP terpasang kartu SIM, pastikan HP dalam
    Mode Pesawat.
"
pause

## Checking ADB programs
echo "Checking ADB program..."
ADB="adb"
[ -x "$MAGISK_MODULE/adb-ndk/system/bin/adb" ] && \
ADB="$MAGISK_MODULE/adb-ndk/system/bin/adb"
sleep 1
which $ADB  >/dev/null 2>&1 && \
echo "ADB program was availabled on this device." || {
    echo -e "ADB program cannot be found on this device. \nMake sure ADB and Fastboot program already installed."
    exit 1
}

## Starting ADB service
start-adb

## Checking devices
echo "Connecting to device..."
sleep 1; echo "Please plug USB to your devices."
$ADB wait-for-device
echo "Connected."

## Injecting file
echo "Preparing version file $1 to injecting device..."
$ADB push "$1" /sdcard/adupsfota/update.zip
echo "Checking file..."
echo "Verifying file..."
sleep 12

## Calling FOTA update
echo "Checking updates..."
$ADB shell "settings put global install_non_market_apps 1"

echo "Cleaning FOTA updates..."
$ADB shell "pm clear com.smartfren.fota"

echo "Manipulating FOTA updates..."
$ADB shell "monkey -p com.smartfren.fota 1"
$ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
$ADB shell "input keyevent 20"
$ADB shell "input keyevent 22"
$ADB shell "input keyevent 23"

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
        n | N )  $ADB shell "rm /sdcard/adupsfota/update.zip"
                 kill-adb
                 exit 1
                 ;;
        * )      echo -ne "Lanjutkan? " ;;
    esac
done

## Start updating
echo "Updating..."
$ADB shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
COUNTER=0
while :
do
    $ADB shell "input keyevent 20"
    (( COUNTER+=1 ))
    [[ $COUNTER -eq 20 ]] && break
done
$ADB shell "input keyevent 23"
sleep 1

## Complete
echo "Proses telah selesai"
pause
kill-adb
exit 0
