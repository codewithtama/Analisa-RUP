# Pantau RUP — Negara Kesatuan Republik Indonesia

Pantau RUP adalah aplikasi Android berbasis Flutter yang berfungsi untuk menganalisis data Rencana Umum Pengadaan (RUP) instansi pemerintah di seluruh **Negara Kesatuan Republik Indonesia** (baik Kementerian, Lembaga, maupun Pemerintah Daerah / K/L/PD) secara lokal (tanpa koneksi internet). Aplikasi secara otomatis mendeteksi kejanggalan pada data anggaran dan menampilkan hasilnya dengan bahasa formal yang mudah dipahami oleh masyarakat umum.

Aplikasi ini ditujukan untuk jurnalis, aktivis antikorupsi, pegawai pengawas internal (APIP), dan masyarakat umum yang ingin mengawal transparansi anggaran nasional maupun daerah secara mandiri.

---

## Fitur Utama

- **Impor Berkas RUP & Preset Data**: 
  - Mendukung unggah berkas Excel (.xlsx) dan CSV (.csv) secara lokal.
  - Menyediakan fitur **Preset Data RUP 2026** melalui dropdown box untuk memuat secara instan berkas RUP dari 12 Kementerian/Lembaga/Daerah (misalnya DPR, Bendahara Umum Negara, BNN, BIN, Polri, Pemkot Tangsel, dll.) yang tertanam di dalam aset aplikasi.
- **Deteksi Kejanggalan Anggaran Berbasis Regulasi**: Mesin analisis lokal otomatis mendeteksi 7 indikator risiko kejanggalan pengadaan yang dirujuk ke pasal-pasal Perpres No. 12/2021 dan UU No. 20/2001:
  1. **Penunjukan Langsung Nilai Besar**: Penunjukan langsung di atas batas regulasi Rp500 Juta (*Perpres No. 12/2021 Pasal 38*).
  2. **Mendekati Batas Pengadaan Langsung**: Paket pengadaan langsung bernilai Rp150 Juta - Rp200 Juta (*Perpres No. 12/2021 Pasal 38 Ayat (3)*).
  3. **Nama Paket Berulang di SKPD**: Nama paket identik muncul berulang kali di satu dinas (*Perpres No. 12/2021 Pasal 20 Ayat (2) Huruf d* tentang larangan memecah paket).
  4. **Nama Paket Berulang Lintas SKPD**: Paket dengan nama identik menyebar di banyak dinas (*Perpres No. 12/2021 Pasal 6* tentang prinsip efisiensi).
  5. **Nilai Paket Sangat Kecil**: Pagu di bawah Rp1 Juta (*Perpres No. 12/2021 Pasal 6* tentang prinsip efisiensi administrasi).
  6. **Pola Paket Serupa di SKPD (Fuzzy Similarity)**: Deteksi kluster nama paket dengan tingkat kemiripan kata $\ge$ 85% menggunakan algoritma Jaro-Winkler untuk mengantisipasi variasi penulisan.
  7. **Indikasi Pecah Paket Pekerjaan**: Pengelompokan paket non-tender sejenis yang jika diakumulasikan nilainya melebihi batas Pengadaan Langsung (Rp200 Juta) untuk menghindari tender umum (*Perpres No. 12/2021 Pasal 20 Ayat (2) Huruf d jo. UU No. 20/2001 Pasal 2/3*).
- **Penyelarasan Tingkat Risiko Resmi**:
  - **Perlu Perhatian Segera** (Tingkat 3 - Merah)
  - **Perlu Diperiksa** (Tingkat 2 - Oranye)
  - **Pantau** (Tingkat 1 - Kuning)
  - **Wajar** (Tingkat 0 - Hijau)
- **Visualisasi & Analisis Outlier Lanjutan**:
  - **Grafik Scatter Plot**: Memetakan Top 100 paket terbesar secara interaktif untuk mendeteksi outlier anggaran yang berisiko tinggi. Titik grafik dapat diketuk untuk melihat detail paket kerja.
  - **Grafik Stacked Bar Chart**: Membandingkan porsi anggaran wajar (normal) dan anggaran bermasalah (kejanggalan) di 5 SKPD terbesar secara berdampingan.
  - **Grafik Pie Chart**: Distribusi metode pengadaan, jenis pengadaan, dan sumber dana.
- **Penyaringan Lanjutan**: Filter berdasarkan Instansi, SKPD secara berjenjang (*cascading*), metode pengadaan, jenis pengadaan, tingkat kejanggalan, serta slider interaktif rentang anggaran (*Budget Range Slider*).
- **Ekspor Hasil Temuan Multiformat (100% Offline)**:
  - **Excel (.xlsx)**: Pemrosesan ekspor berkas dilakukan di latar belakang (Isolate `compute`) sehingga UI aplikasi terbebas dari kendala lag/freeze saat mengekspor puluhan ribu baris data.
  - **PDF Laporan Audit**: Generator laporan formal dengan visualisasi bagan, cover formal, ringkasan eksekutif, dan detail temuan.
  - **CSV**: Ekspor ringkas untuk keperluan kompilasi data audit eksternal.
- **Zero Overflowed Policy & Alur Donasi**:
  - Seluruh komponen dialog menggunakan penataan responsif (*scrollable*) agar bebas dari masalah terpotongnya UI di berbagai ukuran layar.
  - Integrasi dialog donasi QR Code DANA untuk mendukung keberlanjutan pengembangan aplikasi.

---

## Tumpukan Teknologi

- **Framework**: Flutter (Dart) - target Android minSdk 21
- **Database**: Hive (hive + hive_flutter) - Penyimpanan offline lokal biner berkinerja tinggi
- **Import/Export File**: `file_picker` + `excel` + `pdf`
- **State Management**: `provider`
- **Navigasi**: `go_router`
- **Ekspor Laporan**: `share_plus`
- **Grafik**: `fl_chart`
- **Desain**: Material 3 dengan skema warna premium (Deep Navy, Crimson Red, Amber Orange, Gold Yellow, Forest Green)

---

## Persyaratan Sistem

- Flutter SDK (versi stable terbaru)
- Android SDK & Emulator atau perangkat Android fisik (Android API 21 ke atas)

---

## Langkah Menjalankan Aplikasi

1. Unduh dependensi proyek dengan menjalankan perintah berikut di terminal:
   ```bash
   flutter pub get
   ```
2. Jalankan build_runner untuk memastikan kode adapter Hive ter-generate dengan benar:
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```
3. Hubungkan perangkat Android Anda, kemudian jalankan aplikasi:
   ```bash
   flutter run
   ```

---

## Keamanan & Kebijakan Izin

- **Aplikasi 100% Offline**: Berkas manifest produksi tidak mendeklarasikan izin internet (`android.permission.INTERNET`). Seluruh proses analisis dan data yang disimpan berada di dalam memori internal perangkat pengguna.
- **Akses Berkas Aman**: Menggunakan Storage Access Framework (SAF) bawaan Android untuk membaca berkas secara temporer tanpa membutuhkan izin baca/tulis penyimpanan penuh.
