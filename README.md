<h1>OTA Haier F17A1H / Andromax Prime Injector Tool</h1>
Tool ini berguna bagi pengguna Haier F17A1H (Andromax Prime) yang mau di update secara offline atau ingin di root.

<h2>Download:</h2>
<ol>
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-android.zip>Android Platform</a></li>
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-linux.sh>Linux Platform</a></li>
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat>Windows Platform</a></li><br/>
  Bila kalian ingin root Haier F17A1H (Andromax Prime), saya sudah sediakan file update_injectroot.zip dan support di segala versi firmware Haier Andromax Prime.<p>
  Klik <a href=https://mega.nz/file/ZNMEERzA#Wz7Km4PcSx0v1fG6Knuw0S2SF8oQlN4pr02NswiIMy0>disini</a> untuk mengunduh update_inject.root.zip
</ol>

<h2>Yang dibutuhkan:</h2>
<ol>
<li><b>Android</b></li>
  <ol>
  <li> Versi:  <dt>Android 5.0.0 Lollipop <b>(Minimal)</b>, Android 9 keatas <b>(Rekomendasi)</b></dt></li>
  <li> Minimal Kernel:  <dt>Linux Versi 3.0</dt></li>
  <li> Terpasang Magisk:  <dt><a href=https://github.com/topjohnwu/magisk/releases>Versi 19.00 keatas</a></dt></li>
  <li> Terpasang module Magisk ADB and Fastboot NDK</li>
  </ol><br/>
<li><b>Linux</b></li>
  <ol>
  <li> Distribusi yang didukung:  <dt>Debian/Ubuntu, RedHat Enterprise Linux, Fedora, Arch Linux, OpenSUSE/SLES</dt></li>
  <li> Minimal Kernel:  <dt>Versi 4.4</dt></li>
  <li> Arsitektur Prosesor:  <dt>64-bit (x86_64/amd64)</dt></li>
  </ol><br/>
<li><b>Windows</b></li>
  <ol>
  <li> Versi:  <dt>Windows 7 Service Pack 1 <b>(Minimal)</b>, Windows 10 <b>(Rekomendasi)</b></dt></li>
  <li> Terupdate PowerShell:  <dt><a href=http://web.archive.org/web/20181213045712/https://www.microsoft.com/en-us/download/details.aspx?id=40855>Windows Module Framework 4.0</a></dt></li>
  <li> Terpasang Microsoft .NET Framework:  <dt><a href=https://www.microsoft.com/en-us/download/details.aspx?id=30653>Versi 4.5 keatas</a></dt></li>
  </ol>
</ol>

<h2>Cara menggunakan?</h2>
<ol>
<li><b>Android:</b><p>
  Pastikan kalian memiliki aplikasi Terminal Emulator atau Termux pada perangkat ini. Jika sudah, buka Terminal Emulator lalu ketik: <pre>su</pre> Kemudian jalankan dengan ketik: <pre>inject.sh < file update.zip ></pre></li>
<li><b>Linux:</b><p>
  Buka terminal, lalu masuk ke direktori tempat skrip <b>inject-linux.sh</b> berada, jalankan dengan ketik: <pre>./inject-linux.sh < file update.zip ></pre> Jika menemukan "Permission denied." ketik terlebih dahulu: <pre>chmod 755 inject-linux.sh</pre> lalu jalankan perintahnya beserta file update.zip nya.</li><p>
<li><b>Windows:</b><p>
  Buka Command Prompt atau Powershell di menu Start. lalu masuk ke direktori tempat skrip <b>inject-win.bat</b> berada, jalankan dengan ketik: <pre>inject-win.bat < file update.zip ></pre></li>
</ol>
<p>
  
Jika kalian tidak sempat mendownload skrip, kalian bisa salin perintah dibawah ini:
  <ol>
  <li><b>Android (Termux):</b><p>
  <pre>su -c "bash <(wget -qO- http://raw.githubusercontent.com/thefirefox12537/ota_f17a1h_injector/main/inject-android/system/bin/inject.sh)" </pre>
  </li>
  <li><b>Linux:</b><p>
  <pre>bash <(wget -qO- http://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-linux.sh) </pre>
  </li>
  <li><b>Windows (Command Prompt - Wajib menggunakan Windows PowerShell versi 4.0):</b><p>
  <pre>powershell -command (New-Object System.Net.WebClient).DownloadFile('http://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat', '%tmp%\inject.bat') && "%tmp%\inject.bat" </pre>
  </li>
  <li><b>Windows (PowerShell versi 4.0 keatas):</b><p>
  <pre>(New-Object System.Net.WebClient).DownloadFile('http://github.com/thefirefox12537/ota_f17a1h_injector/releases/latest/download/inject-win.bat', "$env:tmp\inject.bat"); & "$env:tmp\inject.bat" </pre>
  </li>
  </ol>
Setelah salin, tempelkan (Paste) ke Command Prompt/Terminal dan tambahkan/ketik nama file update.zip yang akan di inject.<p>

Bila butuh panduan mengenai mengaktifkan USB debugging pada Haier F17A1H (Andromax Prime), bisa ketik sebagai berikut:
<ol>
<li><b>Android:</b><pre>inject.sh --readme</li>
<li><b>Linux:</b><pre>./inject-linux.sh --readme</li>
<li><b>Windows:</b><pre>inject-win.bat --readme</li>
</ol>

<h2>Kontak:</h2>
<li><a href=https://fb.me/thefirefoxflasher>Facebook</a></li>
<li><a href=https://www.instagram.com/thefirefoxflasher_>Instagram</a></li>
<li><a href=https://wa.me/6288228419117>WhatsApp</a></li>
<li><a href=mailto:reinmclaren33@gmail.com>E-Mail</a></li>

<h2>Changelog:</h2>
<h3>v1.3.0</h3>
<ol>
<li>Perbaikan pengunduhan program ADB (Windows)</li>
<li>Perbaikan pengunduhan dan pemasangan driver ADB (Windows)</li>
<li>Perubahan pesan dialog</li>
<li>Setelah proses inject, penambahan skrip tunggu perangkat hidup</li>
<li>Mendukung menjalankan skrip secara online <b>(Lihat README.md bagian atas, perintah wget. Sedang dikerjakan untuk update selanjutnya, untuk update saat ini masih dalam pengembangan jadi sedikit bug berjalannya perintah tersebut.)</b></li>
</ol>
<h3>v1.2.3</h3>
<ol>
<li>Pembaharuan minor ketiga</li>
<li>Perbaikan cek perangkat bahwa itu Andromax Prime</li>
<li>Penghapusan rilisan minor lama v1.2</li>
</ol>
<h3>v1.2.2</h3>
<ol>
<li>Pembaharuan minor kedua</li>
<li>Perubahan batasan versi Android di module inject-android.zip</li>
<li>Perbaikan skrip bash/shell Linux</li>
<li>Perbaikan install otomatis driver ADB pada inject-win.bat</li>
</ol>
<h3>v1.2.1</h3>
<ol>Pembaharuan minor</ol>
<h3>v1.2</h3>
<ol>
<li>Menghapus batasan Visual C++ 2015 Redist pada inject-win.bat</li>
<li>Penambahan perintah --non-market untuk inject update_injectroot.zip (File root)</li>
</ol>
<h3>v1.1.1</h3>
<ol>
<li>Pembaharuan minor</li>
<li>Menambahkan batasan versi kernel Linux, distro Linux dan sistem arsitektur prosesor pada inject-linux.sh</li>
<li>Penambahan UI dialog di inject-linux.sh (menggunakan KDialog jika berada dalam lingkungan KDE Plasma)</li>
<li>Menambahkan batasan versi Android, dan support USB Host OTG pada inject-android</li>
<li>Menambahkan batasan Visual C++ 2015 Redist pada inject-win.bat</li>
<li>Menambahkan fungsi instalasi driver ADB pada inject-win.bat</li>
<li>Perubahan fungsi pemeriksa perangkat bila perangkat itu Andromax Prime/Haier F17A1H</li>
</ol>
<h3>v1.1</h3>
<ol>
<li>Menambahkan batasan versi Windows, PowerShell, dan dotnet Framework</li>
<li>Memperbaiki Download Manager pada inject-win.bat</li>
<li>Menambahkan fungsi mengaktifkan mode pesawat secara otomatis</li>
</ol>
<h3>v1.0</h3>
<ol>Initial release</ol>
