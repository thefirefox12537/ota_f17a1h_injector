#!/system/bin/sh
#
# Inject update.zip script - Andromax Prime F17A1H
#
# File update.zip dan batch script inject root dari Adi Subagja
# File bash script inject dari Faizal Hamzah

ARGS="$@"

for file in $ARGS
do if [ -f "$file" ]
then
    FILE="$file"
    FULLPATH="$(dirname "$(readlink -f "$file")")/$(basename "$file")"
    EXTENSION="$(printf "${file##*.}" | awk '{print tolower($0)}')"
    break
fi
done

ID=$(id); ID=${ID%% *}
ID=${ID%%\(*}; ID=${ID#*=}
MAGISKDIR="/data/adb"
MAGISK="$MAGISKDIR/magisk"
MAGISK_MODULE="$MAGISKDIR/modules"
ADBDIR="$MAGISK_MODULE/adb-ndk"
BASEFILE="$0"

USAGE()
{
    echo -e "Inject update.zip for Haier F17A1H

USAGE: $0 <update.zip file>

Additional arguments are maybe to know:
  -a, --download-adb   Run without check ADB and Fastboot module
                       (ADB program permanently placed. Android
                       only use).
  -h, --help           Show help information for this script.
  -n, --non-market     Inject with install non market.
  -Q, --run-temporary  Run without check ADB and Fastboot module
                       (ADB program not permanently placed).
  --readme             Show read-me (advanced help)."
    exit 1
}

README()
{
    echo -e "Untuk mengaktifkan mode USB debugging pada Haier
F17A1H sebagai berikut:

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
    echo -ne "Starting ADB services...\r"
    "$ADBDIR/adb" start-server
}

kill-adb() {
    echo "Killing ADB services..."
    "$ADBDIR/adb" kill-server
}

remove-temporary() {
    if [ ! -z "$run_temporary" ]
    then
        echo "Removing temporary program files..."
        "$ADBDIR/adb" kill-server
        for i in adb adb.bin adb.bin-armeabi
        do rm "$ADBDIR/$i" > /dev/null 2>&1
        done
    fi
}

pause() {
    echo -n "Press any key to continue . . . "
    read -srn1; echo
}


if [[ $ID -ne 0 ]]
then
    [[ "$run_temporary" ]] && \
    echo "This command only allow in root mode." || \
    exec su -c "$SHELL $BASEFILE $@"
    exit
fi

if [[ $(getprop ro.build.version.sdk) -lt 21 ]]
then
    echo "This script cannot be run in older Android version."
    exit 1
elif [[ $(uname -sr) < "Linux 3"* ]]
then
    echo "This script requires at least Linux Kernel version 3.0."
    exit 1
elif [[ $(getprop ro.product.cpu.abi) != "arm64"* ]]
then
    echo "This script requires a 64-bit Operating System."
    exit 1
elif [ ! -e "$MAGISK" ]
then
    echo "This script requires Magisk installed."
    exit 1
fi
for i in $ARGS
do case $i in
    "--run-temporary" | "--download-adb"  | "-Q" | "-a" )
        if [ -d "/data/data/com.termux" ]
        then PREFIX="/data/data/com.termux/files/usr"
        else
            echo "This script requires Termux shell installed."
            exit 1
        fi
        for split in $(printf "${PATH//:/$'\n'}")
        do [ "$split" = "$PREFIX/bin" ] && TERMUX_ENV=1
        done
        [ -z $TERMUX_ENV ] && PATH="$PREFIX/bin:$PATH"
        command -v wget > /dev/null 2>&1 || {
            pkg update -y > /dev/null 2>&1
            pkg install -y wget > /dev/null 2>&1
        }
        ;;
    * )
        ;;
esac
done

for a in '/dev' '/proc/self'
do if [[ "$0" = "$a/fd/"* ]]
then
    [[ "$run_temporary" ]] && \
    echo "Running online script mode in temporary command..." || \
    echo "Running online script mode..."
    break
fi
done

for i in $ARGS
do case $i in
    "--help" | "-h" )
        USAGE
        break
        ;;
    "--readme" )
        README
        break
        ;;
    "--non-market" | "-n" )
        NON_MARKET=1 ;;
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
done

## Main Menu
if [[ "$ARGS" ]]
then
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
else USAGE
fi

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
echo -ne "Checking ADB program...\r"

## Downloading ADB programs if not exist
for i in $ARGS
do case $i in
    "--run-temporary" | "--download-adb" | "-Q" | "-a" )
        if [ ! -e "$ADBDIR/adb" ]
        then
            echo "Downloading 'ADB and Fastboot for Android NDK' from Magisk Modules Repository..."
            for i in adb adb.bin
            do
                wget -qO \
                  "$ADBDIR/$i" \
                  https://github.com/Magisk-Modules-Repo/adb-ndk/raw/master/bin/$i 2>&1 || {
                    echo -e "Failed download 'ADB and Fastboot for Android NDK' from Magisk Modules Repository. \nPlease try again, make sure your network connected."
                    exit 1
                }
                chmod 755 "$ADBDIR/$i" > /dev/null 2>&1
            done
        else echo "ADB program was successfully placed."
        fi
        break
        ;;
    * )
        if [ -d "$ADBDIR" ]
        then
            echo "ADB program was availabled on this device."
            for d in "$ADBDIR/bin" "$ADBDIR/system/bin"
            do [ -e "$d/adb" ] && ADBDIR="$d"
            done
        else
            echo -e "ADB program cannot be found on this device. \nMake sure 'ADB and Fastboot for Android NDK' Magisk Modules already installed."
            exit 1
        fi
        break
        ;;
esac
done

## Starting ADB service
start-adb

## Checking devices
echo -ne "Connecting to device...\r"
sleep 1; echo -ne "Please plug USB to your devices.\r"
"$ADBDIR/adb" wait-for-device
echo "Connected.                      "

## Checking if your devices is F17A1H
echo -ne "Checking if your devices is F17A1H...\r"
for FOTA_DEVICE in "$("$ADBDIR/adb" shell "getprop ro.fota.device" 2> /dev/null)"
do if [ "${FOTA_DEVICE//$'\r'}" != "Andromax F17A1H" ]
then
    echo "Checking if your devices is F17A1H..."
    echo "Perangkat anda bukan Andromax Prime/Haier F17A1H"
    "$ADBDIR/adb" kill-server
    remove-temporary
    exit 1
fi
done

## Activating airplane mode
echo "Activating airplane mode..."
"$ADBDIR/adb" shell "settings put global airplane_mode_on 1"
"$ADBDIR/adb" shell "am broadcast -a android.intent.action.AIRPLANE_MODE"

## Injecting file
echo "Preparing version file $FILE to injecting device..."
"$ADBDIR/adb" push "$FILE" /sdcard/adupsfota/update.zip
echo -ne "Checking file...\r"
sleep 4
echo -ne "Verifying file...\r"
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
while [ $COUNTER -le 25 ]
do "$ADBDIR/adb" shell "input keyevent 20" > /dev/null 2>&1 && (( COUNTER+=1 ))
done
"$ADBDIR/adb" shell "input keyevent 23" > /dev/null 2>&1
sleep 10
"$ADBDIR/adb" wait-for-device > /dev/null 2>&1

if [[ "$NON_MARKET" ]]
then
    echo "Enabling install non market app..."
    "$ADBDIR/adb" shell "settings put global install_non_market_apps 1"
    "$ADBDIR/adb" shell "settings put secure install_non_market_apps 1"
fi

## Complete
echo "Proses telah selesai"
pause
kill-adb
remove-temporary

exit 0

# begin of dummy code
einECflUN24N9YwC2s85Yyaw8yw58yq8lYC5wo8aY38d8y48y48y85Y8Y5aNQ8wK53sy58Y5lejw8Y8y5g8Y58Yy5
d98Y592Y8Y37Y4wte7t4KnTwRasT278TK78tkbx78t74tk184d215y19t893tywyrweurc7XT2a3a5s87dw7TWasg
dU57t574t5k7rt7TRT6rweegr4wS4DSaataf565D6529u89288y2y9R28wngRdsvdsY9dsa4gs62dg8Y9R8yr83y7
vy3t7xy3kty8Y8yk7y7TVegadf73YKCEZWFHykDafDrsd4dD7d78DiuihaD7dgAY8DdDdDw8IydYD9yd9YDdAD4sQ
w4Ra5daqf11oOSJdiHDdUwfDGwqElw1EwEoPafw1E1d4EkQOsdbgsdbWDKnksADJaxMAafNazagbGdbsDUgf8eiqh
wjdoAJFIHetawUfwFAIe51ayq6esfdcersRdbHdAJFrwrhBhgsfdbIDagsiarfUqcfFSadhJFHiduAIgwefDY78te
ueiudjADadhBdDffHBhwdwdkjAJDHldAXannazkANXLkHwcgDUayA877a6A5FayaDewgweUA7d8ATeawgD8ada7Fg
eA6sdA7fa6caca8d8AefsdgGDs9aA9d7AgsdSCsafHA9wqctgSHC9gwegwAF0dwehfssfha9s9sdfs9Dch9HgewCa
9xiaXAvsd98sh8seg88egeH8AdweHbtyD8cewfeadaYDYdDAgeSFwcqrASGasadD8yf8YFu99F8f6sRAw5asfD7ag
ed9u9sfu9FY8yf8U9ADU9AUD9uf9A9y8g6tf7GbK4J4jkQ42OI4H1Ejndk8DY8fqJ58e3Ys8asf5YsdhtrfADgaH9
dW4vth624rhRdbdfgerKreehSKfas63gjnD7sdu8rr3hIA8Dd3rk8Y889Fyd9a8dy8AD8a3dv51sdbBDcsdUadeBD
sfaHad8Dd9DIad9DS7F7sfF77Dg9d9DG8adAVAhsA89dADaduDJbca7D87s907ad90A7D9A68f8f9Ff6AFad8AS6d
8Y9s99gge9s9797F8A7F8AC7ad8D7S7C7aza7s7fahaKAHndwDuq12w1ds2f41h8cfS6Aawbte6D5shreheAGDfwe
fH3UeinECflUgwaegN2wcet4Nbfd9YwC2s85Yyaw8yw58yq8lYC5wo8aY38d8y48y48y85Y8Y5aNQ8wK53sy58Y5l
ejw8Y8y5g8Yaweferh58Yy5gaerd98cfYweah592dhdrerY8Ywntae37Y4wte7t4KnTwRasTdg2sag7s8dfTefKe7
g8tkbx78t74tk184d215y19t893tywyrweurc7XT2a3a5s87dw7TWgweafUda5sf7t574t5k7rt7TRT6rweegr4wS
4DSaataf565D6529u89288y2y9R28RY98Y9R8yr83y7vy3t7xy3kty8Y8yk7y7TdsgsVd7f3sdYfdKsadgCEZWfwe
FfHeyfewkgDeafDrsd4dD7d78DiuihaD7dgAY8DdDdDw8IydYD9yd9YDdAD4sQw4Ra5daqf11oOSJdiHDdUDfGegE
lw1EwEoPafw1E1d4EkgsdQOW512gsdg3D21K5nksAD64JaxMA4Naza12gbG5D4Ugf8eiqhwjdoAJsFafvIwaegHcU
gFdAvIcRdweaHAasdgGDgsdgGSFAsdvJweaegFtBw4aw2eTghWfIDg1ag5s5ia4rfUF3dsf1SsdJF5HiduAIasgDY
7ewg8teueiudjADadhBdDweffgeHgBhwdwdkjAJDHldAXannazkANXLkHDUayA877a6A5FayaDUA7d8aAsdcTD8ad
a7FAsg6weAg7wfjtrja6ckaca8dsr8heAhGjDjtr9A9trhtdrh7rAScCeagHreA9hSgfHnfgC9bAbgfFn0nhfssfh
a9s99Dch9HCa9xiaXA98sh8cfsdf84argfse8agHcd8aewfcAewgHD8adaYDYdDegASgFASGasadD8yf8YFu99F8f
6sRAw5asfD7aged9u9sfu9FY8yf8U9ADU9AUD9uf9A9y8g6tf7GbK4J4jkQ42OI4H1Ejndk8DY8fqJ58e3Ys85YfA
DgaH9dwrqWRewtetKSdgsaKD7du8rr3hIA8Dd3rk8Y889Fyd9a8d91eu19b2yr39y5rv9235y35w9d2f3Yw59sfY0
Y9rYawgLe0gsd9Yre2vDedaweg9cRYgew4gny9sadYsa59gsaVLewgffsY5qwqrw28wfa5dwegw832v948Y2492c8
2Sdt59s8hrthw875A7596A8rwb6896Dfawg84y34f34ct6F89689b54tFscafAS12rvYFWGdasd3tyTC33tdfefaw
irv3u58ucq32863batvl4e8ytc2q90wcage3ewTw5eahVw2hr3thVgf5b08d2bNdfa0asVgTa2eryhAbaeThUb9sR
dbUg9OTUw3kYaVwc8tew36cegYweahK8aybe4yTYge3grLearTheYarhicer8h3ehTa8ebryieawtyve48btayu68
o34wotya38Y3cdsaTChtrsw8YT8warbvwerYT3awbt8YdTgsd8ytjtyYv8eYgaweTgI8YfsT3ty9WYawvtebTKdgs
IeTdeUefcwedgasdeWfasELrgEFSDhtrjhSAsdgfdB3dgweg8QUrwrbTL90dsg2U59UgsdRUdegwLT8YDGAEH448w
3ga96b4a6teaog3946utv304qi6by4ojqtodofteu8au38tyaiyty572yvitu3y8tiy23ty8it8wEsfsdFRy3wrv2
Baged6T3ewgwY3fd4Yga48g64regYw3ex34qrvTtr7hyeft2dsgwe1rn4h14fdbt12U6RurRsbge7ewhenhtRObdf
bvd8c6bfdb7fd6vY8ct6i8act7DTdgstaI8DThdfgreI7frefbgf4d5ybTDgthtrAdsda7fwefITfwaDGyd3ds4e2
5ewgFGgwEeDd2a45efwv3Irwavt8w23Ae4byDTDyv4cTO3edgFt56fweqvDA8ayIadggDYge8wAgrYSaify3itlq3
2tuiq238txt38y3bytseifysidry23ytkiwehfI4Tatdb5gdfsteETaUdgsB39TtrwFe52bfd36baUOsiSAFAfewG
SWEtvoFfd41gr2ASGoe64wHRa6tbRo421RddasdEHd8f7J9hT3f52g4t21H3g215Re6Te6rg5asa7ssafG8wh87RG
roFDSOdewtwvetuat8uvti38t253jk53k24t8392y754lkjger8ufoac93tuv9auw3t3owy3watv4ybkj4yiv4tkG
AeDGjrDdSAgDtWkGlREGajylGaREjHlzJkTsdgjFEiWeDrEut8eEaG32SCoR23FAfsS1sadF21E4yeB54FuHy64s2
dxa3g3e3tae4iS56tFksd312lr346GeSEagi4wub69aw4t9awuotibyiuae4o9toaweitiweht23itcoitbiewatk
dsgmkntoyij5ylhero4dfa6ga41gFoo35Kye23aetxsd35byrherage9iu9utaetFwe0239u2vSdh09tu2XoitJu2
# end of dummy code
