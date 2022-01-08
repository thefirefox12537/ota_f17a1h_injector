#!/system/bin/sh
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

ID="$(id)"; ID="${ID%% *}"
ID="${ID%%\(*}"; ID="${ID#*=}"
MAGISKDIR="/data/adb"
MAGISK="$MAGISKDIR/magisk"
MAGISK_MODULE="$MAGISKDIR/modules"
ADBDIR="$MAGISK_MODULE/adb-ndk/bin"

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
    echo -e "Untuk mengaktifkan mode USB debugging pada Haier F17A1H
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
popup izinkan sambung USB Debugging di Haier F17A1H.


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
        for i in adb adb.bin adb.bin-armeabi
        do rm "$ADBDIR/$i" > /dev/null 2>&1
        done
    }
}

pause() {
    echo -n "Press any key to continue..."
    read -srn1; echo
}


case $1 in
    "--help" | "-h" )
        USAGE ;;
    "--readme" )
        README ;;
    "--run-temporary" | "-Q" )
        [ ! -d "/data/local/tmp" ] && \
        mkdir "/data/local/tmp" > /dev/null 2>&1
        ADBDIR="/data/local/tmp"
        run_temporary=1
        ;;
    "--download-adb" | "-a" )
        [ ! -d "/data/local/bin" ] && \
        mkdir "/data/local/bin" > /dev/null 2>&1
        ADBDIR="/data/local/bin"
        ;;
    * )
        ;;
esac

[[ $ID -ne 0 ]] && {
    echo "This script only allow in root mode."
    exit 1
}

[[ $(getprop ro.build.version.sdk) -lt 21 ]] && {
    echo "This script cannot be run in older Android version."
    exit 1
}
[[ $(uname -sr) < "Linux 3"* ]] && {
    echo "This script requires at least Linux Kernel version 3.0."
    exit 1
}
[ ! -e "$MAGISK" ] && {
    echo "This script requires Magisk installed."
    exit 1
}
case $1 in
    "--run-temporary" | "--download-adb"  | "-Q" | "-a" )
        [ ! -d "/data/data/com.termux" ] && \
        PREFIX="/data/data/com.termux/files/usr" || {
            echo "This script requires Termux shell installed."
            exit 1
        }
        for split in $(printf "${PATH//:/$'\n'}")
        do [ "$split" == "$PREFIX/bin" ] && TERMUX_ENV=1
        done
        [ -z $TERMUX_ENV ] && PATH="$PREFIX/bin:$PATH"
        command -v wget > /dev/null 2>&1 || pkg install -y wget > /dev/null 2>&1
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

    echo -ne "File yang dipilih: \n$FULLPATH \nAnda yakin? "
    while true
    do
        read -srn1 YN
        echo
        case $YN in
            [Yy]* )
                break ;;
            [Nn]* )
                exit 1 ;;
            * )
                echo -ne "Anda yakin? " ;;
        esac
    done
} || USAGE

## NOTE
echo -ne "NOTE:  Harap baca dahulu sebelum eksekusi

 *  Harap aktifkan mode USB Debugging terlebih dahulu sebelum
    mengeksekusi inject update.zip [ Untuk mengetahui bagaimana
    cara mengaktifkan mode USB debugging, dengan mengetik ]:
       $0 --readme
 *  Apabila HP terpasang kartu SIM, skrip ini akan terotomatis
    mengaktifkan mode pesawat.

Perlu diperhatikan:
   Segala kerusakan/apapun yang terjadi itu diluar tanggung
   jawab pembuat file ini serta tidak ada kaitannya dengan
   pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
   update secara daring melalui updater resmi.
"
pause

## Checking ADB programs
echo "Checking ADB program..."
case $1 in
    "--run-temporary" | "--download-adb" | "-Q" | "-a" )
        echo "Downloading 'ADB and Fastboot for Android NDK' from Magisk Modules Repository..."
        for i in adb adb.bin adb.bin-armeabi
        do [ -e "$ADBDIR/$i" ] && \
        ADB_EXIST=1 || {
            wget \
              -qO "$ADBDIR/$i" \
              https://github.com/Magisk-Modules-Repo/adb-ndk/raw/master/bin/$i
            chmod 755 "$ADBDIR/$i" > /dev/null 2>&1
            ADB_SUCCESS=1
        }
        done
        ;;
    * )
        [ -d "$ADBDIR" ] && \
        ADB_EXIST=1 || {
            echo -e "ADB program cannot be found on this device. \nMake sure 'ADB and Fastboot for Android NDK' Magisk Modules already installed."
            exit 1
        }
        ;;
esac

[ ! -z $ADB_EXIST ] && echo "ADB program was availabled on this device."
[ ! -z $ADB_SUCCESS ] && \
[ ! -e "$ADBDIR/adb" ] && {
    echo "Failed getting ADB program. Please try again, make sure your network connected."
    exit 1
} || echo "ADB program was successfully placed."

## Starting ADB service
start-adb

## Checking devices
echo "Connecting to device..."
sleep 1; echo "Please plug USB to your devices."
"$ADBDIR/adb" wait-for-device
echo "Connected."

## Checking if your devices is F17A1H
echo "Checking if your devices is F17A1H..."
FOTA_DEVICE="$("$ADBDIR/adb" shell "getprop ro.fota.device" 2> /dev/null | grep "F17A1H")"
[ "${FOTA_DEVICE//$'\r'}" != "Andromax F17A1H" ] && {
    echo "Perangkat anda bukan Andromax Prime/Haier F17A1H"
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
COUNTER=1
echo "Updating..."
"$ADBDIR/adb" shell "am start -n com.smartfren.fota/com.adups.fota.FotaInstallDialogActivity"
while [ $COUNTER -le 20 ]
do "$ADBDIR/adb" shell "input keyevent 20" > /dev/null 2>&1 && (( COUNTER+=1 ))
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
echo "Proses telah selesai"
pause
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
# end of dummy code
