# Pantau Pengadaan

Pantau Pengadaan adalah aplikasi Android berbasis Flutter yang berfungsi untuk menganalisis data Rencana Umum Pengadaan (RUP) instansi pemerintah daerah secara lokal (tanpa koneksi internet). Aplikasi secara otomatis mendeteksi kejanggalan pada data anggaran dan menampilkan hasilnya dengan bahasa formal yang mudah dipahami masyarakat umum.

Aplikasi ini ditujukan untuk jurnalis, aktivis antikorupsi, pegawai pengawas internal, dan masyarakat umum yang ingin memantau transparansi anggaran daerah.

---

## Fitur Utama

- **Impor Berkas RUP**: Mendukung format Excel (.xlsx) dan CSV (.csv). Proses pembacaan berkas dijalankan di latar belakang (Isolate) sehingga antarmuka tetap responsif, lengkap dengan informasi kemajuan baris.
- **Kalkulator Regulasi (Pengaturan Batas Kustom)**: Pengguna dapat mengubah batas nominal Pengadaan Langsung (PL) dan Penunjukan Langsung (PenL) secara persisten di dalam aplikasi. Sistem secara otomatis memicu analisis ulang instan pada seluruh data paket kerja jika batas diubah.
- **Deteksi Kejanggalan Anggaran**: Mesin analisis lokal secara otomatis mendeteksi 7 indikator risiko kejanggalan:
  1. Penunjukan Langsung Bernilai Besar (di atas batas Penunjukan Langsung kustom)
  2. Paket Mendekati Batas Pengadaan Langsung (75% hingga 100% dari batas PL kustom)
  3. Nama Paket Berulang dalam Satu Satuan Kerja (SKPD)
  4. Nama Paket Berulang di Banyak Satuan Kerja (SKPD)
  5. Nilai Paket Sangat Kecil (di bawah Rp1 juta)
  6. Kata Kunci Nama Paket Berulang Banyak di Satu Satuan Kerja (SKPD)
  7. Pola Pecah Paket Menghindari Tender (Tender Avoidance Split): Beberapa paket non-tender sejenis di satu dinas yang jika diakumulasikan melebihi batas PL kustom akan ditandai dengan tingkat risiko tertinggi (Perlu Perhatian Segera).
- **Grafik Stacked Bar Chart & Visualisasi**: 
  - Grafik lingkaran (Pie Chart) untuk sebaran metode pengadaan, jenis pengadaan, dan sumber dana.
  - Stacked Bar Chart komparatif untuk 5 besar SKPD beranggaran terbesar yang membandingkan porsi anggaran wajar (normal) dan anggaran bermasalah (anomali) secara berdampingan lengkap dengan persentase rasionya.
- **Indeks Kerawanan Satuan Kerja (Leaderboard)**: Pemeringkatan SKPD paling rawan berdasarkan bobot akumulasi tingkat kejanggalan internal dinas (Perlu Perhatian Segera = 3, Tinggi = 2, Waspada = 1).
- **Profil Satuan Kerja Terperinci**: Halaman detail SKPD untuk melihat rekapitulasi pagu, volume paket, sebaran status risiko, serta kolom pencarian lokal instan lintas nama dan kode RUP di dinas tersebut.
- **Pencarian dan Penyaringan Dinamis**: Menyaring data berdasarkan Satuan Kerja, metode pengadaan, jenis pengadaan (Barang/Konstruksi/Jasa), tingkat kejanggalan, dan pencarian teks bebas (Nama Paket dan Kode RUP secara bersamaan). Dilengkapi pengurutan berdasarkan pagu terbesar, terkecil, dan alfabet.
- **Ekspor Hasil Temuan (CSV Offline)**: Tombol ekspor laporan di halaman Ringkasan yang menyaring seluruh paket terindikasi bermasalah, memformatnya secara standar, menyimpan langsung ke folder Downloads di Windows, serta memicu share sheet lintas platform untuk kemudahan berbagi.

---

## Tumpukan Teknologi

- **Framework**: Flutter (Dart) - target Android minSdk 21
- **Database**: Hive (hive + hive_flutter) - Penyimpanan offline lokal biner berkinerja tinggi
- **Import File**: file_picker + excel
- **State Management**: Provider
- **Navigasi**: GoRouter
- **Ekspor Laporan**: share_plus
- **Grafik**: fl_chart
- **Desain**: Material 3 dengan skema warna terstandardisasi (Biru Tua, Biru Sedang, Merah Kritis, Oranye Tinggi, Kuning Waspada, Hijau Wajar)

---

## Persyaratan Sistem

- Flutter SDK (versi stable)
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
- **Akses Berkas Aman**: Menggunakan Storage Access Framework (SAF) bawaan Android untuk membaca berkas secara temporer tanpa membutuhkan izin baca/tulis penyimpanan penuh (`READ_EXTERNAL_STORAGE` / `WRITE_EXTERNAL_STORAGE`).
