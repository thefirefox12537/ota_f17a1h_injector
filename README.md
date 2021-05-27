<h1>OTA Haier F17A1H / Andromax Prime Injector Tool</h1>
Tool ini berguna bagi pengguna Haier F17A1H (Andromax Prime) yang mau di update secara offline atau ingin di root.

<h2>Download:</h2>
<ol>
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/download/v1.0/inject-android.zip>Android Platform</a></li> (harus dalam kondisi root Magisk dan terpasang module ADB)
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/download/v1.0/inject-linux.sh>Linux Platform</a></li>
<li><a href=https://github.com/thefirefox12537/ota_f17a1h_injector/releases/download/v1.0/inject-win.bat>Windows Platform</a></li>
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
<h3>v1.1</h3>
<ol>
<li>Menambahkan batasan versi Windows, PowerShell, dan dotnet Framework</li>
<li>Memperbaiki Download Manager pada inject-win.bat</li>
<li>Menambahkan fungsi mengaktifkan mode pesawat secara otomatis</li>
</ol>
<h3>v1.0</h3>
<ol>Initial release</ol>
