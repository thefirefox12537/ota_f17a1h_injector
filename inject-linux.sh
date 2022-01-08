#!/bin/bash
#
# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

for file in "$1" "$2" "$3"
do [ -f "$file" ] && {
    FILE="$file"
    FULLPATH="$(dirname "$(readlink -f "$file")")/$(basename "$file")"
    EXTENSION="$(printf "${file##*.}" | awk '{print tolower($0)}')"
    break
}
done

ADBDIR="$(dirname "$(readlink -f "$0")")"

USAGE()
{
    echo -e "Inject update.zip for Haier F17A1H

USAGE: $0 <update.zip file>

Additional arguments are maybe to know:
  -a, --download-adb   Run without check ADB and Fastboot module
                       (ADB program permanently placed. Android only use).
  -h, --help           Show help information for this script.
  -n, --non-market     Inject with install non market.
  -Q, --run-temporary  Run without check ADB and Fastboot module
                       (ADB program not permanently placed).
  --readme             Show read-me (advanced help)."
    exit 1
}

README()
{
    README="Untuk mengaktifkan mode USB debugging pada Haier F17A1H
sebagai berikut:

  *   Dial ke nomor *#*#83781#*#*
  *   Masuk ke slide 2 (DEBUG&LOG).
  *   Pilih 'Design For Test'.
  *   Pilih 'CMCC', lalu tekan OK.
  *   Pilih 'MTBF'.
  *   Lalu pilih 'MTBF Start'.
  *   Tunggu beberapa saat.
  *   Pilih 'Confirm'.
  *   Kalau sudah mulai ulang/restart HP nya.
  *   Selamat USB debugging telah aktif.


Jika masih tidak aktif, ada cara lain sebagai berikut:

  *   Dial ke nomor *#*#257384061689#*#*
  *   Aktifkan 'USB Debugging'.
  *   Izinkan aktifkan USB Debugging pada popupnya.


Tinggal jalankan skrip ini dengan membuka Command
Prompt, dan jalankan adb start-server maka akan muncul
popup izinkan sambung USB Debugging di Haier F17A1H."

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
    "$ADBDIR/adb" start-server
}

kill-adb() {
    echo "Killing ADB services..."
    "$ADBDIR/adb" kill-server
}

remove-temporary() {
    [[ "$run_temporary" ]] && {
        echo "Removing temporary program files..."
        "$ADBDIR/adb" kill-server
        rm "$ADBDIR/adb" > /dev/null 2>&1
    }
}


## Set dialog screen program
for d in dialog whiptail kdialog
do command -v $d > /dev/null 2>&1 && DIALOG="$d"
done

[ -z "$DIALOG" ] && {
    echo -e "This script requirements dialog box, one of which:

   dialog
   whiptail
   kdialog\n"
    exit 1
}

[ -e /etc/os-release ] && . /etc/os-release 2> /dev/null || . /usr/lib/os-release 2> /dev/null

[[ "$ID" = "debian" || "$ID_LIKE" = *"debian"* || "$ID_LIKE" = *"ubuntu"* ]] && DIST_CORE="debian"
[[ "$ID" = *"rhel"* || "$ID_LIKE" = *"rhel"*   || "$ID_LIKE" = "redhat"* ]] && DIST_CORE="redhat"
[[ "$ID" = "fedora" || "$ID_LIKE" = *"fedora"* ]] && DIST_CORE="redhat_fedora"
[[ "$ID" = *"suse"* || "$ID_LIKE" = *"suse"* ]] && DIST_CORE="suse"
[[ "$ID" = "arch" || "$ID_LIKE" = "arch" ]] && DIST_CORE="archlinux"

[[ -z "$DIST_CORE" ]] && {
    echo "This script cannot be run in this Linux distribution."
    exit 1
}
[[ $(uname -sr) < "Linux 4.4"* ]] && {
    echo "This script requires at least Linux Kernel version 4.4."
    exit 1
}
[[ $(uname -p) != *"64" ]] && {
    echo "This script requires a 64-bit Operating System."
    exit 1
}

case $1 in
    "--help" | "-h" )
        USAGE ;;
    "--readme" )
        README ;;
    "--run-temporary" | "-Q" )
        ADBDIR="/var/tmp"
        run_temporary=1
        ;;
    "--download-adb" | "-a" )
        echo "You cannot run this argument in Linux."
        exit 1
        ;;
    * )
        ;;
esac

## Main Menu
[[ "$1" ]] && {
    [ -z "$FILE" ] && {
        echo "File not found."
        exit 1
    }

    [ "$EXTENSION" != "zip" ] && {
        echo "File is not ZIP type."
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
" *  Harap aktifkan mode USB Debugging terlebih dahulu sebelum
    mengeksekusi inject update.zip [ Untuk mengetahui bagaimana
    cara mengaktifkan mode USB debugging, dengan mengetik ]:
       $0 --readme
 *  Apabila HP terpasang kartu SIM, skrip ini akan terotomatis
    mengaktifkan mode pesawat.

Perlu diperhatikan:
   Segala kerusakan/apapun yang terjadi itu diluar tanggung
   jawab pembuat file ini serta tidak ada kaitannya dengan
   pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
   update secara daring melalui updater resmi." 11 63

## Checking ADB programs
echo "Checking ADB program..."

## Downloading ADB programs if not exist
[ -e "$ADBDIR/adb" ] && \
echo "ADB program was availabled on the computer or this folder." || {
    echo "Downloading Android SDK Platform Tools..."
    wget \
      -qO "/var/tmp/platform-tools.zip" \
      https://dl.google.com/android/repository/platform-tools-latest-linux.zip
    echo "Extracting Android SDK Platform Tools..."
    unzip \
      -qo "/var/tmp/platform-tools.zip" platform-tools/adb \
      -d "/var/tmp/"
    mv "/var/tmp/platform-tools/adb" "$ADBDIR/" >/dev/null 2>&1
    rm -rf "/var/tmp/platform-tools" >/dev/null 2>&1
    rm "/var/tmp/platform-tools.zip" >/dev/null 2>&1
    [ ! -e "$ADBDIR/adb" ] && {
        echo "Failed getting ADB program. Please try again, make sure your network connected."
        exit 1
    } || echo "ADB program was successfully placed."
}

## Starting ADB service
start-adb

## Checking devices
echo "Connecting to device..."
sleep 1; echo "Please plug USB to your devices."
"$ADBDIR/adb" wait-for-device

## Checking if your devices is F17A1H
echo "Checking if your devices is F17A1H..."
FOTA_DEVICE="$("$ADBDIR/adb" shell "getprop ro.fota.device" 2> /dev/null | grep "F17A1H")"
[ "${FOTA_DEVICE//$'\r'}" != "Andromax F17A1H" ] && {
    [[ "$DIALOG" == "kdialog" ]] && \
    echo "Perangkat anda bukan Andromax Prime/Haier F17A1H" || \
    $DIALOG -msgbox "\nPerangkat anda bukan Andromax Prime/Haier F17A1H" 8 48
    remove-temporary
    exit 1
}

## Activating airplane mode
echo "Activating airplane mode..."
"$ADBDIR/adb" shell "settings put global airplane_mode_on 1"
"$ADBDIR/adb" shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

## Injecting file
echo "Preparing version file $FILE to injecting device..."
"$ADBDIR/adb" push "$FILE" /sdcard/adupsfota/update.zip
echo "Checking file..."
sleep 4
echo "Verifying file..."
sleep 12

## Calling FOTA update
echo "Cleaning FOTA updates..."
"$ADBDIR/adb" shell "pm clear com.smartfren.fota"

echo "Manipulating FOTA updates..."
"$ADBDIR/adb" shell "monkey -p com.smartfren.fota 1"
"$ADBDIR/adb" shell "am start -n com.smartfren.fota/com.adups.fota.FotaPopupUpateActivity"
"$ADBDIR/adb" shell "input keyevent 20" > /dev/null 2>&1
"$ADBDIR/adb" shell "input keyevent 22" > /dev/null 2>&1
"$ADBDIR/adb" shell "input keyevent 23" > /dev/null 2>&1

## Start updating
echo "Updating..."
"$ADBDIR/adb" shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
for (( i=1; i<=20; i++ ))
do "$ADBDIR/adb" shell "input keyevent 20" > /dev/null 2>&1
done
"$ADBDIR/adb" shell "input keyevent 23" > /dev/null 2>&1
sleep 10
"$ADBDIR/adb" wait-for-device > /dev/null 2>&1

for args in "$1" "$2" "$3"
do case $args in
    "--non-market" | "-n" )
        NON_MARKET=1
        break
        ;;
    * )
        ;;
esac
done
[[ "$NON_MARKET" ]] && {
    echo "Enabling install non market app..."
    "$ADBDIR/adb" shell "settings put global install_non_market_apps 1"
    "$ADBDIR/adb" shell "settings put secure install_non_market_apps 1"
}

## Complete
[[ "$DIALOG" == "kdialog" ]] && \
$DIALOG --msgbox "Proses telah selesai" || \
$DIALOG --msgbox "\n           Proses telah selesai" 8 48
kill-adb
remove-temporary

exit 0

# begin of dummy code
einECflUN24N9YwC2s85Yyaw8yw58yq8lYC5wo8aY38d8y48y48y85Y8Y5aNQ8wK53sy58Y5lejw8Y8y5g8Y58Yy5
d98Y592Y8Y37Y4wte7t4KnTwRasT278TK78tkbx78t74tk184d215y19t893tywyrweurc7XT2a3a5s87dw7TWU57
t574t5k7rt7TRT6rweegr4wS4DSaataf565D6529u89288y2y9R28RY98Y9R8yr83y7vy3t7xy3kty8Y8yk7y7TV7
3YKCEZWFHykDafDrsd4dD7d78DiuihaD7dgAY8DdDdDw8IydYD9yd9YDdAD4sQw4Ra5daqf11oOSJdiHDdUDGElw1
EwEoPafw1E1d4EkQOWDKnksADJaxMANazagbGDUgf8eiqhwjdoAJFIHUFAIRHAJFBhfIDagsiarfUFSJFHiduAIDY
78teueiudjADadhBdDffHBhwdwdkjAJDHldAXannazkANXLkHDUayA877a6A5FayaDUA7d8ATD8ada7FA6A7fa6ca
ca8d8AGD9A9d7ASCHA9SHC9AF0hfssfha9s99Dch9HCa9xiaXA98sh888H8AHD8adaYDYdDASFASGasadD8yf8YFu
99F8f6sRAw5asfD7aged9u9sfu9FY8yf8U9ADU9AUD9uf9A9y8g6tf7GbK4J4jkQ42OI4H1Ejndk8DY8fqJ58e3Ys
85YfADgaH9dWRKSKD7du8rr3hIA8Dd3rk8Y889Fyd9a8dy8AD8adBDUadeBDHad8Dd9DIad9DS7F7sfF77Dg9d9DG
8adAVAhsA89dADaduDJbca7D87s907ad90A7D9A68f8f9Ff6AFad8AS6d8Y9s99gge9s9797F8A7F8AC7ad8D7S7C
7aza7s7fahaKAHndwDuq12w1ds2f41h8S6A6D5AGDH3UeinECflUN24N9YwC2s85Yyaw8yw58yq8lYC5wo8aY38d8
y48y48y85Y8Y5aNQ8wK53sy58Y5lejw8Y8y5g8Y58Yy5d98Y592Y8Y37Y4wte7t4KnTwRasT278TK78tkbx78t74t
k184d215y19t893tywyrweurc7XT2a3a5s87dw7TWU57t574t5k7rt7TRT6rweegr4wS4DSaataf565D6529u8928
8y2y9R28RY98Y9R8yr83y7vy3t7xy3kty8Y8yk7y7TV73YKCEZWFHykDafDrsd4dD7d78DiuihaD7dgAY8DdDdDw8
IydYD9yd9YDdAD4sQw4Ra5daqf11oOSJdiHDdUDGElw1EwEoPafw1E1d4EkQOWDKnksADJaxMANazagbGDUgf8eiq
hwjdoAJFIHUFAIRHAJFBhfIDagsiarfUFSJFHiduAIDY78teueiudjADadhBdDffHBhwdwdkjAJDHldAXannazkAN
XLkHDUayA877a6A5FayaDUA7d8ATD8ada7FA6A7fa6caca8d8AGD9A9d7ASCHA9SHC9AF0hfssfha9s99Dch9HCa9
xiaXA98sh888H8AHD8adaYDYdDASFASGasadD8yf8YFu99F8f6sRAw5asfD7aged9u9sfu9FY8yf8U9ADU9AUD9uf
9A9y8g6tf7GbK4J4jkQ42OI4H1Ejndk8DY8fqJ58e3Ys85YfADgaH9dWRKSKD7du8rr3hIA8Dd3rk8Y889Fyd9a8d
91eu19b2yr39y5rv9235y35w9d2f3Yw59sfY0Y9rYL0sd9Yre2vDed9RY4ny9Y59VLY528wfa5dwegw832v948Y24
92c82Sdt59s8hrthw875A7596A8rwb6896Dfawg84y34f34ct6F89689b54tFscaAS12rvYFWGdasd3tyTC33tdfe
# end of dummy code
