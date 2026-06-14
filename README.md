# Pantau Pengadaan

Pantau Pengadaan adalah aplikasi Android berbasis Flutter yang berfungsi untuk menganalisis data Rencana Umum Pengadaan (RUP) instansi pemerintah daerah secara lokal (tanpa koneksi internet). Aplikasi secara otomatis mendeteksi kejanggalan pada data anggaran dan menampilkan hasilnya dengan bahasa yang mudah dipahami masyarakat umum.

Aplikasi ini ditujukan untuk jurnalis, aktivis antikorupsi, pegawai pengawas internal, dan masyarakat umum yang ingin memantau transparansi anggaran daerah.

---

## Fitur Utama

- **Impor Berkas RUP**: Mendukung format Excel (.xlsx) dan CSV (.csv). Proses pembacaan berkas dijalankan di latar belakang (Isolate) sehingga antarmuka tetap responsif, lengkap dengan informasi kemajuan per baris.
- **Deteksi Kejanggalan Anggaran**: Mesin analisis lokal secara otomatis mendeteksi 6 indikator risiko kejanggalan:
  1. Penunjukan Langsung Bernilai Besar (di atas Rp500 juta)
  2. Paket Mendekati Batas Pengadaan Langsung (Rp150 juta - Rp200 juta)
  3. Nama Paket Berulang dalam Satu Satuan Kerja (SKPD)
  4. Nama Paket Berulang di Banyak Satuan Kerja (SKPD)
  5. Nilai Paket Sangat Kecil (di bawah Rp1 juta)
  6. Kata Kunci Nama Paket Berulang Banyak di Satu Satuan Kerja (SKPD)
- **Ringkasan Analisis & Visualisasi**: Dashboard grafik lingkaran (Pie Chart) untuk distribusi metode pengadaan dan grafik batang (Bar Chart) untuk 5 besar Satuan Kerja dengan anggaran terbesar.
- **Pencarian dan Penyaringan Dinamis**: Menyaring data berdasarkan Satuan Kerja, metode pengadaan, tingkat kejanggalan, dan pencarian teks bebas. Dilengkapi pengurutan berdasarkan pagu terbesar, terkecil, dan alfabet.
- **Detail & Ekspor Temuan**: Menampilkan rincian paket bermasalah per kategori risiko dan mendukung ekspor ringkasan laporan teks ke media lain.

---

## Tumpukan Teknologi

- **Framework**: Flutter (Dart) - target Android minSdk 21
- **Database**: Hive (hive + hive_flutter) - Penyimpanan offline lokal
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
