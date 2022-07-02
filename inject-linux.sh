#!/usr/bin/bash
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

ADBDIR="$(dirname "$(readlink -f "$0")")"
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
    README="Untuk mengaktifkan mode USB debugging pada Haier
F17A1H sebagai berikut:

  •   Dial ke nomor *#*#83781#*#*
  •   Masuk ke slide 2 (DEBUG&LOG).
  •   Pilih \"Design For Test\".
  •   Pilih \"CMCC\", lalu tekan OK.
  •   Pilih \"MTBF\".
  •   Lalu pilih \"MTBF Start\".
  •   Tunggu beberapa saat.
  •   Pilih \"Confirm\".
  •   Kalau sudah mulai ulang/restart HP nya.
  •   Selamat USB debugging telah aktif.


Jika masih tidak aktif, ada cara lain sebagai berikut:

  •   Dial ke nomor *#*#257384061689#*#*
  •   Aktifkan \"USB Debugging\".
  •   Izinkan aktifkan USB Debugging pada popupnya.


Tinggal jalankan skrip ini dengan membuka Command
Prompt, dan jalankan adb start-server maka akan muncul
popup izinkan sambung USB Debugging di Haier F17A1H.
"
    THANKS="Special thanks to:
  1.  Adi Subagja
  2.  Ahka
  3.  dan developer-developer Andromax Prime"

    if [ "$DIALOG" = "kdialog" ]
    then
        echo -e "$README" > /var/tmp/readme.txt
        $DIALOG --title "Read-Me" --textbox /var/tmp/readme.txt 392 360
        $DIALOG --title "Read-Me" --msgbox "$THANKS"
        rm /var/tmp/readme.txt > /dev/null 2>&1
    else echo -e "$README\n\n$THANKS" | more
    fi
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
        rm "$ADBDIR/adb" > /dev/null 2>&1
    fi
}

pause() {
    echo -n "Press any key to continue . . . "
    read -srn1; echo
}


[ -e /etc/os-release ] && \
. /etc/os-release 2> /dev/null || \
. /usr/lib/os-release 2> /dev/null

[[ "$ID" =~ "debian" || "$ID_LIKE" =~ "debian" || "$ID_LIKE" =~ "ubuntu" ]] && DIST_CORE="debian"
[[ "$ID" =~ "rhel"   || "$ID_LIKE" =~ "rhel"   || "$ID_LIKE" =~ "redhat" ]] && DIST_CORE="redhat"
[[ "$ID" =~ "fedora" || "$ID_LIKE" =~ "fedora" ]] && DIST_CORE="redhat_fedora"
[[ "$ID" =~ "suse"   || "$ID_LIKE" =~ "suse"   ]] && DIST_CORE="suse"
[[ "$ID" =~ "arch"   || "$ID_LIKE" =~ "arch"   ]] && DIST_CORE="archlinux"

if [[ -z "$DIST_CORE" ]]
then
    echo "This script cannot be run in this Linux distribution."
    exit 1
elif [[ $(uname -sr) < "Linux 4.4"* ]]
then
    echo "This script requires at least Linux Kernel version 4.4."
    exit 1
elif [[ $(uname -p) != *"64" ]]
then
    echo "This script requires a 64-bit Operating System."
    exit 1
fi

## Set dialog screen program
for d in dialog whiptail
do command -v $d > /dev/null 2>&1 && DIALOG="$d"
done
[ ! -z "$DISPLAY" ] && \
command -v kdialog > /dev/null 2>&1 && DIALOG="kdialog"

for a in '/dev' '/proc/self'
do if [[ "$0" = "$a/fd/"* ]]
then
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
done

## Main Menu
if [[ "$ARGS" ]]
then
    [ -z "$FILE" ] && {
        [ "$DIALOG" = "kdialog" ] && \
        $DIALOG --error "File not found." || \
        echo "File not found."
        exit 1
    }

    [ "$EXTENSION" != "zip" ] && {
        [ "$DIALOG" = "kdialog" ] && \
        $DIALOG --error "File is not ZIP type." || \
        echo "File is not ZIP type."
        exit 1
    }

    [ "$DIALOG" = "kdialog" ] && \
    YESNO_LABEL="--yes-label Ya --no-label Tidak" || \
    YESNO_LABEL="--yes-button Ya --no-button Tidak"

    if [ ! -z "$DIALOG" ]
    then
        ( $DIALOG                    \
          --yesno                    \
"Anda yakin? File yang dipilih:
$FULLPATH"                           \
         9 63                        \
         $YESNO_LABEL                \
          3>&1 1>&2 2>&3
        ) || exit 1
    else
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
    fi
else USAGE
fi

## NOTE
TITLE_NOTE="NOTE:  Harap baca dahulu sebelum eksekusi"
NOTE=" •  Harap aktifkan mode USB Debugging terlebih dahulu sebelum
    mengeksekusi inject update.zip [ Untuk mengetahui bagaimana
    cara mengaktifkan mode USB debugging, dengan mengetik ]:
       $0 --readme
 •  Apabila HP terpasang kartu SIM, skrip ini akan terotomatis
    mengaktifkan mode pesawat.

Perlu diperhatikan:
   Segala kerusakan/apapun yang terjadi itu diluar tanggung
   jawab pembuat file ini serta tidak ada kaitannya dengan
   pihak manapun. Untuk lebih aman tanpa resiko, dianjurkan
   update secara daring melalui updater resmi.
"
if [ ! -z "$DIALOG" ]
then
    [ "$DIALOG" = "kdialog" ] && \
    SIZE="11 63" || SIZE="18 68"

    $DIALOG                 \
    --title "$TITLE_NOTE"   \
    --msgbox "$NOTE" $SIZE
else
    echo -ne "$TITLE_NOTE\n\n$NOTE"
    pause
fi

## Checking ADB programs
echo -ne "Checking ADB program...\r"

## Downloading ADB programs if not exist
while true
do
    if [[ ! $run_temporary && -e $(command -v adb) ]]
    then
        echo "ADB program was availabled on the computer."
        ADBDIR="$(dirname "$(command -v adb)")"
        break
    elif [ ! -e "$ADBDIR/adb" ]
    then
        echo "Downloading Android SDK Platform Tools..."
        wget -qO \
          "/var/tmp/platform-tools.zip" \
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
    else echo "ADB program was availabled on the computer or this folder."
    fi
    break
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
    if [ ! -z "$DIALOG" ]
    then
        [ "$DIALOG" = "kdialog" ] && \
        $DIALOG --error "Perangkat anda bukan Andromax Prime/Haier F17A1H" || \
        $DIALOG --msgbox "\nPerangkat anda bukan Andromax Prime/Haier F17A1H" 8 52
    else echo "Perangkat anda bukan Andromax Prime/Haier F17A1H"
    fi
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
if [ ! -z "$DIALOG" ]
then
    [ "$DIALOG" = "kdialog" ] && \
    $DIALOG --msgbox "Proses telah selesai" || \
    $DIALOG --msgbox "\nProses telah selesai" 8 24
else
    echo "Proses telah selesai."
    pause
fi
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
j2592sF10tGuijegdDsFASfn4lyhregret9gseg4ef96y34tUeg7DauGeiy34t5uN5UvdgDag54u8658mi7jtq4vy
wetvi9wuatoautl92u3609u36byul4ot8eaytily4386yw8yietgurhn5n4l7kqj4596u235p2p305u396yblwaeh
giaeh85y385uy9a2u5oy2yvt5ow3tekenf8aweht8385vy385o326awtBU3hsryhWrfweUet44ThrehtOReeghyEj
yjtIAdsgsGOwebagt9IEaegFaeD63afed4s25aytbgRGref9reYtwetGgseO8egoVEhaeD8rhgaeorgh8h56lib3j
4o69uo34TU9dasg3UgeTgeO9dBwUfTeagUeOYasTfaoseHg8fGe8gHrhEhGtOhEA9gRrgOseEfIsGg9sdgsGdHOEg
dsRggha99dgHsdfGeOhArFhrGgH9dAsg9dGhrAhOrIhFrhdfG9hAfhdfERJhdfGhOdgfhhao9gaohn4eyjbaio4y4
getb3q49yb43olyq94lerihkera8ruaey8bu4eyo9a469t3utolejtbiauwby694u43u5towejgkfdn4fdg36t5rf
euStVCawHvuGtiFewaDtuo9u3t69EFCWbu29ylo4eaCre351g4D36Db2E372b6G2v6tadg496bF340q96u3ayo3uy
VDhSVaDuGyerl9tauvelyu4b6lya3ufewg54bw54gB4HltS9oD43RtHyS3aCtyV34Da9FytaE4389yt98a3Gyt8re
yt843y6f8F34yitkae4FSDtkyADeg8wefTewgO3reQga5re9veSDFra8yvArehYTrhDSFea8rheYrch8rehTeryr8
eheTgYe8egcTeryg8rhTsrthYtrh8rYregcTre8rhYrtvThrts8hrhYta8iyFDtS8yFa8tFEya438ytayitceHJyt
TeKvkI4tb8yaJebtNGyO8iyb4ePt84Ifsg359grH2895v8F3wytk8a3y6tey4katewoFirDuoqGuRrHoiwztrmFob
GwtRvwHoBetJNvweZtyDeFbib4r2c59uFb93EtGu2H94uFyDtSreHgdDeFtbEGeryrtBmCuDi87GoEuDiyFEtj4G5
ukJolSkmD7jA6uE56Fy5y643Ctv3Vtd4G3StD43R6h6y4Gby54tf348y5t3D2S9FuGrvCowudRgesrhIrLeCDtvGa
rEeCfaFeDgJWaDeyeErhRergcLFSDreCaKhrJybEtrWhshCDvrthIgfhTfhOtrIhuttlhtr9hUthTtL9hrthUW9Yu
9YrCthrDthfgtjytkUAjytEjyt9bdgrYsgUr9gEhtUhylaDCDeuEylu457ul45wtilFerDjgeSrnkGimVuyngHnrE
sAthvStCbnmu7i7jn7mDSu7um7i78ur5tgaeDrt43hqby4t3TEfdgdrsWTrgCREf351sd6h4rhtfdysdg46ru7Fef
etvy4y894tvu4itkycuFSreiu9ub5yk4w59yCuvlfhyu95ub79759y84oyv9bturst9uby54o8w4oyu4oywu54boy
4wu5ECvRyEYTRuHSTw45yof9yhu4ub5y9ruoBhRTsdgrthHStTRHyRTHbwu5y34ut34uy4uby7q4t7er7ybe7yr97
rt98v7rt8y458byo4wuy745uygw48oy5r9by74w75yr7tgre7g76fdhfd86dfhGRE6VRbRTrHeRThCRGybrty754y
4by5y865t43otuv487tb47t64b46tu3693yb4toiyoeaorti3w0riwv3t83vt8cwa3t3vo437674yb54uy95153rr
sh92hvtrh06rgcre20brecg22dg8ub43yb5uytnkiyhjui87i76u5y540t4ti0w0eifc0iwer3u9ruvt9u58yrige
r9gaGAEReGEGrn658u658yf48tv94e5tu4e5t923u5238DrehfFvSegrer5DFgdsg23FE6R8Hb4684b8tv9486yv4
568egtcegr4r5h6rhy8tr4y5f8er6gtrbger54vy8o45y954tv4t834t34t4u65in7kythtaergeargtbeyrrty5n
765b7u56hy4yb45win6549it4oy9v4uitvlreabu0yu4uy0ve4yusl50yubr0yusltrhy509yu34qoyub4ly954tg
ijet98u34otc9u43oy9baetuavul463o6ub9u6u419c430btu6491u90u54l3iyulryjb4u65qu4y0g954y0guy95
t3q4tqb39yuo3q4tc9u43yb93qu4tx094iut0943ubyoeagjle46y439y6up34iy03iyvblaeydfkjgkefje5byfe
# end of dummy code
