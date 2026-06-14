# Panduan Penggunaan Aplikasi — "Pantau RUP"

Aplikasi **Pantau RUP** adalah aplikasi Android berbasis Flutter yang dirancang untuk menganalisis data Rencana Umum Pengadaan (RUP) instansi pemerintah daerah secara lokal (offline). Aplikasi ini mendeteksi 7 jenis kejanggalan anggaran secara otomatis untuk membantu jurnalis, aktivis, dan masyarakat umum memantau alokasi dana daerah.

---

## 📋 Persyaratan Sistem

Sebelum menjalankan aplikasi, pastikan sistem Anda telah memiliki:
1. **Flutter SDK** (versi stable terbaru)
2. **Android SDK & Emulator/Perangkat Android Fisik** (Android API 21 ke atas)
3. **Koneksi USB Debugging** aktif jika menggunakan perangkat fisik

---

## 🚀 Cara Menjalankan Aplikasi

Ikuti langkah-langkah berikut untuk mengompilasi dan menjalankan aplikasi pada perangkat Anda:

1. **Buka Terminal / Command Prompt** pada direktori utama proyek (`C:\Users\tamav\Desktop\PROYEK\Analisa RUP`).
2. **Unduh Dependensi**:
   Unduh semua pustaka yang digunakan oleh aplikasi dengan menjalankan perintah:
   ```bash
   flutter pub get
   ```
3. **Jalankan Aplikasi**:
   Pastikan emulator atau perangkat Android fisik Anda sudah terhubung dan terdeteksi (`flutter devices`), kemudian ketik:
   ```bash
   flutter run
   ```

---

## 🛠️ Panduan Fitur Aplikasi

### 1. Mengimpor Data RUP Baru
Saat pertama kali membuka aplikasi, layar Beranda akan menampilkan status kosong karena belum ada data yang dimuat.
* Ketuk tombol **"Mulai"** pada halaman Beranda (atau buka menu Impor).
* Ketuk tombol **"Pilih Berkas"** untuk membuka pemilih berkas sistem Anda.
* Pilih berkas RUP Anda. Anda dapat mencoba menggunakan file contoh yang berada di folder proyek: `RUP TANGSEL.xlsx`.
* Sistem akan menampilkan bilah kemajuan (*progress bar*) beserta nomor baris data yang sedang dibaca secara asinkron.
* Setelah proses membaca selesai, sistem akan menampilkan statistik jumlah paket kerja yang berhasil dimuat dan jumlah kejanggalan anggaran yang terdeteksi.

> [!NOTE]
> **Deteksi File Duplikat**: Jika Anda mencoba mengimpor data saat database lokal tidak kosong, sistem akan memunculkan dialog konfirmasi: *"Data sebelumnya akan diganti. Lanjutkan?"*.

---

### 2. Membaca Hasil Analisis & Grafik (Dashboard)
Setelah berhasil mengimpor data, Anda dapat menavigasi ke halaman **Hasil Analisis**:
* **Kelompok A (Visualisasi Utama)**:
  * **Metode Pengadaan**: Menampilkan grafik lingkaran (*Pie Chart*) interaktif yang menunjukkan persentase distribusi metode pengadaan (misal: E-Purchasing, Pengadaan Langsung, Tender).
  * **Top 5 SKPD Anggaran Terbesar**: Menampilkan grafik batang (*Bar Chart*) horizontal berisi daftar 5 dinas/Satuan Kerja dengan akumulasi pagu anggaran tertinggi.
* **Kelompok B (Kategori Kejanggalan)**:
  Menampilkan kartu ringkasan untuk ke-6 jenis deteksi risiko kejanggalan, lengkap dengan jumlah paket terdampak dan total nilai anggarannya.

---

### 3. Eksplorasi & Pencarian Daftar Paket
Gunakan halaman **Daftar Paket Kerja** untuk menelusuri seluruh data secara fleksibel:
* **Pencarian Bebas**: Ketik nama paket pada kolom pencarian untuk memfilter teks secara cepat.
* **Penyaringan (Saring)**: Ketuk ikon filter di pojok kanan atas untuk membatasi tampilan berdasarkan:
  * Dinas/Satuan Kerja (SKPD) tertentu.
  * Metode pengadaan tertentu.
  * Tingkat risiko kejanggalan (Perlu Perhatian Segera, Tinggi, Waspada, Wajar).
* **Pengurutan (Sortir)**: Pilih chip pengurutan di bawah bilah pencarian untuk menyusun paket berdasarkan:
  * Nilai Terbesar (Pagu tertinggi ke terendah)
  * Nilai Terkecil (Pagu terendah ke tertinggi)
  * Nama A-Z (Urutan alfabet)

---

### 4. Detail Kejanggalan & Berbagi Laporan
Jika Anda mengetuk salah satu kategori kejanggalan pada halaman Ringkasan (misalnya, *"Penunjukan Langsung Nilai Besar"*):
* Aplikasi akan membuka halaman detail yang berisi penjelasan hukum/konteks mengenai kejanggalan tersebut dan akumulasi total anggaran terdampak.
* Daftar di bawahnya akan memuat seluruh paket kerja yang melanggar aturan tersebut beserta indikator tingkat risikonya.
* Ketuk tombol **"Bagikan Laporan"** (atau ikon share di pojok kanan atas) untuk menyalin ringkasan temuan analisis ke clipboard atau membagikannya langsung ke aplikasi lain (seperti WhatsApp, Email, Catatan, dll.) sebagai teks laporan yang siap dipublikasikan.

---

## 📂 Format Dokumen RUP yang Didukung

Untuk memastikan file Excel atau CSV Anda dapat dibaca dengan benar oleh sistem, berkas tersebut harus memiliki baris pertama sebagai header dengan nama kolom yang cocok secara otomatis (tidak sensitif huruf besar/kecil) terhadap kolom wajib berikut:
1. **Nama Paket** (Wajib)
2. **Metode Pengadaan** (Wajib)
3. **Total Nilai (Rp)** atau **Total Nilai** (Wajib)
4. *Nama Instansi* (Opsional)
5. *Nama Satuan Kerja* (Opsional)
6. *Cara Pengadaan* (Opsional)
7. *Jenis Pengadaan* (Opsional)
8. *Kode RUP* (Opsional)
9. *Sumber Dana* (Opsional)
10. *Tahun Anggaran* (Opsional)
