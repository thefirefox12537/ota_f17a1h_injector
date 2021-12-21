# OTA Haier F17A1H / Andromax Prime Injector Tool
Tool ini berguna bagi pengguna Haier F17A1H (Andromax Prime) yang mau di update OTA offline atau ingin di root.


## Download:
  <ol>
  <li>[Android Platform](https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-android.zip)</li>
  <li>[Linux Platform](https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-linux.sh)</li>
  <li>[Windows Platform](https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat)</li>
  <ol>

Bila kalian ingin root Haier F17A1H (Andromax Prime), saya sudah sediakan file update_injectroot.zip dan support di segala versi firmware Haier Andromax Prime. Klik [disini](https://mega.nz/file/ZNMEERzA#Wz7Km4PcSx0v1fG6Knuw0S2SF8oQlN4pr02NswiIMy0).

**Disclaimer**:  update_injectroot.zip file from AdiRoot tool by [Adi Subagja](https://www.facebook.com/adisubagja.mint).


## Yang dibutuhkan:
### Android
  *  Versi:  <dt>Android 5.0.0 Lollipop <b>(Minimal)</b>, Android 9 keatas <b>(Rekomendasi)</b></dt>
  *  Minimal Kernel:  <dt>Linux Versi 3.0</dt>
  *  Terpasang Magisk:  <dt>[Versi 19.00 keatas](https://github.com/topjohnwu/magisk/releases)<dt>
  *  Terpasang module Magisk ADB and Fastboot NDK
  *  Mendukung USB OTG pada smartphone

### Linux
  *  Distribusi yang didukung:  <dt>Debian/Ubuntu, RedHat Enterprise Linux, Fedora, Arch Linux, OpenSUSE/SLES</dt>
  *  Minimal Kernel:  <dt>Versi 4.4</dt>
  *  Arsitektur Prosesor:  <dt>64-bit (x86_64/amd64)</dt>

### Windows
  *  Versi:  <dt>Windows 7 Service Pack 1 <b>(Minimal)</b>, Windows 10 <b>(Rekomendasi)</b></dt>
  *  Terupdate PowerShell:  <dt>[Windows Module Framework 4.0](http://web.archive.org/web/20181213045712/https://www.microsoft.com/en-us/download/details.aspx?id=40855)</dt>
  *  Terpasang .NET Framework:  <dt>[Versi 4.5 keatas](https://www.microsoft.com/en-us/download/details.aspx?id=30653)</dt>


## Cara menggunakan?
### Anda perlu mengunduh skripnya [diatas](https://github.com/thefirefox12537/ota_f17a1h_injector#download) dan ikuti tatacaranya sesuai platform yang anda gunakan:

**Android**

Pastikan kalian memiliki aplikasi Terminal Emulator atau Termux pada perangkat ini. Jika sudah, buka Terminal Emulator lalu ketik:
```sh
su
```
Kemudian jalankan dengan ketik:
```sh
inject.sh < path file update.zip >
```

**Linux**

Buka terminal, lalu masuk ke direktori tempat skrip **inject-linux.sh** berada, jalankan dengan ketik:
```bash
./inject-linux.sh < path file update.zip >
```
Jika menemukan "Permission denied." ketik terlebih dahulu:
```bash
chmod 755 inject-linux.sh
```
lalu jalankan perintahnya beserta file update.zip nya.

**Windows**

Buka Command Prompt atau Powershell di menu Start. lalu masuk ke direktori tempat skrip **inject-win.bat** berada, jalankan dengan ketik:
```
inject-win.bat < path file update.zip >
```


### Jika kalian tidak sempat mendownload skrip, kalian bisa salin perintah dibawah ini dan tempelkan ke Command Prompt/Terminal dan tambahkan/ketik nama file update.zip yang akan di inject:

**Android (Termux. Sebelum jalankan, masuk su dulu)**
```bash
bash <(wget -qO- https://bit.ly/injectscript_android) -Q 
```

**Linux**
```bash
bash <(wget -qO- https://bit.ly/injectscript_linux) -Q 
```

**Windows (Command Prompt - Wajib terupdate Windows PowerShell versi 4.0 keatas)**
```
powershell -command ^& ([Scriptblock]::Create((New-Object Net.WebClient).DownloadString('https://bit.ly/injectscript_windows'))) -Q 
```

**Windows (PowerShell versi 4.0 keatas)**
```
& ([Scriptblock]::Create((New-Object Net.WebClient).DownloadString('https://bit.ly/injectscript_windows'))) -Q 
```


### Bila butuh panduan mengenai mengaktifkan USB debugging pada Haier F17A1H (Andromax Prime), bisa ketik sebagai berikut:

**Android**
```sh
inject.sh --readme
```
```bash
bash <(wget -qO- https://bit.ly/injectscript_android) --readme
```

**Linux**
```bash
./inject-linux.sh --readme
```
```bash
bash <(wget -qO- https://bit.ly/injectscript_linux) --readme
```

**Windows**
```
inject-win.bat --readme
```
```
powershell -command ^& ([Scriptblock]::Create((New-Object Net.WebClient).DownloadString('https://bit.ly/injectscript_windows'))) --readme
```
```
& ([Scriptblock]::Create((New-Object Net.WebClient).DownloadString('https://bit.ly/injectscript_windows'))) --readme
```


## Kontak:
  *  [Facebook](https://fb.me/thefirefoxflasher)
  *  [Instagram](https://www.instagram.com/thefirefoxflasher_)
  *  [WhatsApp](https://bit.ly/wa_thefirefoxflasher)
  *  [E-mail](mailto:reinmclaren33@gmail.com)


## Changelog:
### v1.4.1
Pembaharuan minor
### v1.4.0: Revision #1 (Tidak ada sertaan ke paket releases)
Penambahan skrip baru di platform Windows PowerShell **(Lihat di [README.md](https://github.com/thefirefox12537/ota_f17a1h_injector#jika-kalian-tidak-sempat-mendownload-skrip-kalian-bisa-salin-perintah-dibawah-ini-dan-tempelkan-ke-command-promptterminal-dan-tambahkanketik-nama-file-updatezip-yang-akan-di-inject).)**
### v1.4.0
  *  Perubahan menjalankan skrip secara online **(Lihat README.md [bagian atas](https://github.com/thefirefox12537/ota_f17a1h_injector#jika-kalian-tidak-sempat-mendownload-skrip-kalian-bisa-salin-perintah-dibawah-ini-dan-tempelkan-ke-command-promptterminal-dan-tambahkanketik-nama-file-updatezip-yang-akan-di-inject), perintah wget. Sedang dikerjakan untuk update selanjutnya, untuk update saat ini masih dalam pengembangan jadi sedikit bug berjalannya perintah tersebut.)**
  *  Kini di platform Android sudah dapat menjalankan secara online tanpa membutuhkan syarat memasang module ADB terlebih dahulu
  *  Pesan dialog mengaktifkan mode pesawat dan resiko sudah disatukan pada bagian awal
### v1.3.0
  *  Perbaikan pengunduhan program ADB (Windows)
  *  Perbaikan pengunduhan dan pemasangan driver ADB (Windows)
  *  Perubahan pesan dialog
  *  Setelah proses inject, penambahan skrip tunggu perangkat hidup
  *  Mendukung menjalankan skrip secara online **(Lihat README.md [bagian atas](https://github.com/thefirefox12537/ota_f17a1h_injector#jika-kalian-tidak-sempat-mendownload-skrip-kalian-bisa-salin-perintah-dibawah-ini-dan-tempelkan-ke-command-promptterminal-dan-tambahkanketik-nama-file-updatezip-yang-akan-di-inject), perintah wget. Sedang dikerjakan untuk update selanjutnya, untuk update saat ini masih dalam pengembangan jadi sedikit bug berjalannya perintah tersebut.)**
### v1.2.3
  *  Pembaharuan minor ketiga
  *  Perbaikan cek perangkat bahwa itu Andromax Prime
  *  Penghapusan rilisan minor lama v1.2
### v1.2.2
  *  Pembaharuan minor kedua
  *  Perubahan batasan versi Android di module inject-android.zip
  *  Perbaikan skrip bash/shell Linux
  *  Perbaikan install otomatis driver ADB pada inject-win.bat
### v1.2.1
Pembaharuan minor
### v1.2
  *  Menghapus batasan Visual C++ 2015 Redist pada inject-win.bat
  *  Penambahan perintah --non-market untuk inject update_injectroot.zip (File root)
### v1.1.1
  *  Pembaharuan minor
  *  Menambahkan batasan versi kernel Linux, distro Linux dan sistem arsitektur prosesor pada inject-linux.sh
  *  Penambahan UI dialog di inject-linux.sh (menggunakan KDialog jika berada dalam lingkungan KDE Plasma)
  *  Menambahkan batasan versi Android, dan support USB Host OTG pada inject-android
  *  Menambahkan batasan Visual C++ 2015 Redist pada inject-win.bat
  *  Menambahkan fungsi instalasi driver ADB pada inject-win.bat
  *  Perubahan fungsi pemeriksa perangkat bila perangkat itu Andromax Prime/Haier F17A1H
### v1.1
  *  Menambahkan batasan versi Windows, PowerShell, dan dotnet Framework
  *  Memperbaiki Download Manager pada inject-win.bat
  *  Menambahkan fungsi mengaktifkan mode pesawat secara otomatis
### v1.0
Initial release
