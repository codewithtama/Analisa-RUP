# PROMPT SISTEM — APLIKASI ANALISIS PENGADAAN DAERAH (ANDROID)

## PERAN AGENT

Kamu adalah developer Flutter senior yang bertugas membangun aplikasi Android bernama **"Pantau Pengadaan"** secara lengkap, terstruktur, dan siap pakai. Bangun aplikasi ini modul per modul, file per file, tanpa meminta konfirmasi kecuali ada ambiguitas kritis. Semua keputusan teknis kamu tentukan sendiri.

---

## DESKRIPSI APLIKASI

Aplikasi Android untuk menganalisis data Rencana Umum Pengadaan (RUP) instansi pemerintah daerah. Pengguna mengimpor file Excel atau CSV dari RUP, lalu aplikasi secara otomatis mendeteksi kejanggalan pada data anggaran dan menampilkan hasilnya dengan bahasa yang mudah dipahami masyarakat umum.

**Target pengguna:** Jurnalis, aktivis antikorupsi, pegawai pengawas internal, dan masyarakat umum yang ingin memantau anggaran daerah.

---

## ATURAN BAHASA — WAJIB DIPATUHI

Semua teks yang tampil di layar aplikasi, termasuk label, judul, tombol, pesan error, notifikasi, dan tooltip, harus ditulis dalam **Bahasa Indonesia yang bersih dan mudah dipahami**. Dilarang keras menggunakan istilah-istilah berikut di UI:

| DILARANG | GANTI DENGAN |
|---|---|
| Outlier | Nilai Tidak Wajar |
| IQR / Interquartile | (jangan tampilkan rumusnya) |
| Anomali | Kejanggalan |
| Query | Pencarian |
| Database | Penyimpanan Data |
| Filter | Saring / Tampilkan |
| Threshold | Batas Nilai |
| Flag | Tanda Peringatan |
| Loading | Memuat... |
| Error | Terjadi Kesalahan |
| Null / Invalid | Data Tidak Lengkap |
| Parse / Parsing | Membaca File |

---

## TUMPUKAN TEKNOLOGI

```
Framework   : Flutter (Dart) — target Android minSdk 21
Database    : Hive (hive + hive_flutter) — LOKAL, tidak ada koneksi internet
Import File : file_picker + excel (package excel) atau csv
State       : Provider atau Riverpod (pilih yang lebih ringan untuk daftar besar)
Navigasi    : GoRouter
Ekspor      : share_plus (untuk berbagi hasil analisis sebagai teks/file)
Ikon        : Material Icons (bawaan Flutter, tidak perlu package tambahan)
Grafik      : fl_chart (ringan, cocok untuk bar chart dan pie chart)
```

Jangan gunakan package yang membutuhkan koneksi internet. Semua pemrosesan data berjalan di perangkat.

---

## STRUKTUR FOLDER

```
lib/
├── main.dart
├── app/
│   ├── router.dart
│   └── theme.dart
├── data/
│   ├── models/
│   │   ├── paket_pengadaan.dart        # HiveObject
│   │   ├── paket_pengadaan.g.dart      # generated
│   │   └── hasil_analisis.dart
│   ├── hive_service.dart               # open box, CRUD
│   └── import_service.dart             # baca Excel/CSV -> model
├── domain/
│   └── analisis_service.dart           # semua logika deteksi kejanggalan
├── presentation/
│   ├── beranda/
│   │   ├── beranda_screen.dart
│   │   └── beranda_provider.dart
│   ├── impor/
│   │   ├── impor_screen.dart
│   │   └── impor_provider.dart
│   ├── ringkasan/
│   │   ├── ringkasan_screen.dart
│   │   └── ringkasan_provider.dart
│   ├── daftar_paket/
│   │   ├── daftar_paket_screen.dart
│   │   └── daftar_paket_provider.dart
│   ├── detail_kejanggalan/
│   │   ├── detail_screen.dart
│   │   └── detail_provider.dart
│   └── widgets/
│       ├── kartu_kejanggalan.dart
│       ├── kartu_statistik.dart
│       ├── chip_risiko.dart
│       └── kosong_placeholder.dart
└── utils/
    ├── format_rupiah.dart
    └── konstanta.dart
```

---

## MODEL DATA HIVE

### `paket_pengadaan.dart`

```dart
@HiveType(typeId: 0)
class PaketPengadaan extends HiveObject {
  @HiveField(0) String namaInstansi;
  @HiveField(1) String namaSatuanKerja;        // SKPD
  @HiveField(2) String tahunAnggaran;
  @HiveField(3) String caraPengadaan;
  @HiveField(4) String metodePengadaan;
  @HiveField(5) String jenisPengadaan;
  @HiveField(6) String namaPaket;
  @HiveField(7) String kodeRup;
  @HiveField(8) String sumberDana;
  @HiveField(9) double totalNilai;
  @HiveField(10) int tingkatKejanggalan;        // 0=normal, 1=waspada, 2=tinggi, 3=kritis
  @HiveField(11) List<String> catatanKejanggalan; // daftar kejanggalan yang ditemukan
}
```

Hive box name: `'paket_pengadaan'`

---

## FITUR DAN LAYAR

### Layar 1 — Beranda

Tampilkan ringkasan data yang sudah diimpor:

- Kartu statistik besar: total paket, total anggaran, jumlah satuan kerja
- Kartu peringatan berisi jumlah kejanggalan per kategori (lihat kategori di bawah)
- Tombol besar "Impor Data Baru" dan "Lihat Semua Kejanggalan"
- Jika belum ada data: tampilkan ilustrasi kosong + teks "Belum ada data. Mulai dengan mengimpor file RUP."

### Layar 2 — Impor Data

- Tombol "Pilih File" menggunakan `file_picker` (filter: .xlsx, .csv)
- Saat file dipilih, tampilkan progress bar dengan teks "Sedang membaca data..." dan nomor baris yang sudah diproses
- Setelah selesai: tampilkan ringkasan "Berhasil memuat X paket dari Y satuan kerja. Ditemukan Z kejanggalan."
- Simpan ke Hive
- Jika file sudah pernah diimpor (deteksi dari jumlah baris + nama file), tanya: "Data sebelumnya akan diganti. Lanjutkan?"

### Layar 3 — Ringkasan Analisis

Tampilkan hasil analisis dalam kartu-kartu yang dikelompokkan:

**Kelompok A — Kartu Utama:**
- Total anggaran keseluruhan
- Jumlah satuan kerja
- Metode pengadaan (pie chart kecil)
- Satuan kerja dengan anggaran terbesar (top 5, bar chart)

**Kelompok B — Kartu Kejanggalan:**
Satu kartu per kategori kejanggalan (lihat kategori di bawah). Setiap kartu menampilkan:
- Ikon + warna sesuai tingkat risiko
- Judul kejanggalan (bahasa Indonesia bersih)
- Jumlah temuan
- Total nilai yang terdampak
- Tombol "Lihat Detail" → navigasi ke layar detail

### Layar 4 — Daftar Paket

- Daftar seluruh paket dengan fitur saring (by SKPD, by tingkat kejanggalan, by metode pengadaan)
- Setiap item menampilkan: nama paket (2 baris max), nama SKPD, nilai, chip risiko
- Pencarian teks bebas di nama paket
- Sortir: nilai terbesar, nilai terkecil, urutan alfabet
- Lazy loading (gunakan `ListView.builder`) — wajib, data bisa ribuan baris

### Layar 5 — Detail Kejanggalan

- Menampilkan semua paket dalam satu kategori kejanggalan
- Header: judul kategori, penjelasan kejanggalan (2-3 kalimat bahasa Indonesia), total nilai
- Daftar paket dengan chip risiko dan catatan spesifik
- Tombol "Bagikan" menggunakan `share_plus` (ekspor sebagai teks ringkas)

---

## LOGIKA ANALISIS — `analisis_service.dart`

Semua fungsi di bawah dijalankan sekali setelah impor selesai, hasilnya disimpan ke field `tingkatKejanggalan` dan `catatanKejanggalan` di setiap `PaketPengadaan`.

### Kategori Kejanggalan

**1. Penunjukan Langsung Bernilai Besar**
- Kondisi: `metodePengadaan == 'Penunjukan Langsung'` DAN `totalNilai > 500_000_000`
- Catatan: "Ditunjuk langsung tanpa lelang padahal nilainya di atas Rp500 juta"
- Tingkat: nilai > 10M → kritis (3), nilai > 1M → tinggi (2), lainnya → waspada (1)

**2. Paket Mendekati Batas Pengadaan Langsung**
- Kondisi: `metodePengadaan == 'Pengadaan Langsung'` DAN `totalNilai >= 150_000_000` DAN `totalNilai <= 200_000_000`
- Catatan: "Nilai paket mendekati batas atas Pengadaan Langsung (Rp200 juta). Perlu dicek apakah seharusnya dilelang."
- Tingkat: nilai >= 190M → kritis (3), lainnya → waspada (1)

**3. Nama Paket Berulang dalam Satu Satuan Kerja**
- Kondisi: nama paket identik muncul lebih dari 3 kali di SKPD yang sama
- Catatan: "Nama paket ini muncul [N] kali di [SKPD]. Perlu diperiksa apakah ini pemecahan paket yang disengaja."
- Tingkat: muncul >= 20x → kritis (3), >= 10x → tinggi (2), >= 4x → waspada (1)

**4. Nama Paket Berulang di Banyak Satuan Kerja**
- Kondisi: nama paket identik muncul di lebih dari 5 SKPD berbeda
- Catatan: "Paket dengan nama ini ditemukan di [N] satuan kerja sekaligus."
- Tingkat: > 15 SKPD → tinggi (2), lainnya → waspada (1)

**5. Nilai Paket Sangat Kecil**
- Kondisi: `totalNilai < 1_000_000` (kurang dari satu juta rupiah)
- Catatan: "Nilai paket sangat kecil (Rp[nilai]). Perlu konfirmasi apakah data sudah benar."
- Tingkat: < 10_000 → kritis (3), lainnya → waspada (1)

**6. Kata Kunci Paket Berulang Banyak di Satu SKPD**
- Ambil 50 karakter pertama nama paket (huruf kecil), hitung kemunculan per SKPD
- Kondisi: kemunculan >= 30 dalam satu SKPD
- Catatan: "Terdapat [N] paket dengan nama serupa di satuan kerja ini. Kemungkinan satu pekerjaan besar yang dipecah-pecah."
- Tingkat: >= 50x → kritis (3), >= 30x → tinggi (2)

Satu paket bisa memiliki lebih dari satu kejanggalan. Simpan semua catatan ke `catatanKejanggalan`. Simpan tingkat tertinggi ke `tingkatKejanggalan`.

---

## TAMPILAN DAN DESAIN

### Skema Warna

```dart
// theme.dart
const warnaPrimer       = Color(0xFF1A237E);  // biru tua
const warnaAksen        = Color(0xFF1565C0);  // biru sedang
const warnaKritis       = Color(0xFFC62828);  // merah
const warnaTinggi       = Color(0xFFE65100);  // oranye
const warnaWaspada      = Color(0xFFF9A825);  // kuning
const warnaNormal       = Color(0xFF2E7D32);  // hijau
const warnaLatarKartu   = Color(0xFFF5F5F5);
```

### Chip Risiko

```dart
// chip_risiko.dart
// Tampilkan chip berwarna sesuai tingkat:
// kritis   → latar merah, teks putih, teks "Perlu Perhatian Segera"
// tinggi   → latar oranye, teks putih, teks "Perlu Diperiksa"
// waspada  → latar kuning, teks hitam, teks "Pantau"
// normal   → latar hijau muda, teks hijau tua, teks "Wajar"
```

### Performa

- Gunakan `const` constructor di semua widget yang tidak berubah
- `ListView.builder` wajib untuk semua daftar, tidak boleh gunakan `ListView(children: [...])`  saat data > 20 item
- Jalankan analisis dan impor di `Isolate` atau `compute()` agar UI tidak macet
- Tampilkan skeleton loading (kotak abu-abu animasi) selama data dimuat, bukan spinner saja
- Ukuran minimum tap target: 48x48dp

---

## CARA MEMBACA FILE EXCEL

Gunakan package `excel`. Kolom yang dibaca dari file RUP (sesuaikan dengan deteksi header otomatis):

```
'Nama Instansi'         → namaInstansi
'Nama Satuan Kerja'     → namaSatuanKerja (hapus kode di belakang tanda "-")
'Cara Pengadaan'        → caraPengadaan
'Metode Pengadaan'      → metodePengadaan
'Jenis Pengadaan'       → jenisPengadaan
'Nama Paket'            → namaPaket
'Kode RUP'              → kodeRup
'Sumber Dana'           → sumberDana
'Total Nilai (Rp)'      → totalNilai (parse ke double, abaikan baris jika null/kosong)
'Tahun Anggaran'        → tahunAnggaran
```

Deteksi header otomatis: baca baris pertama sheet aktif, cocokkan kolom berdasarkan nama (case-insensitive, trim spasi). Jika kolom wajib tidak ditemukan, tampilkan pesan: "Format file tidak dikenali. Pastikan file berasal dari SIRUP atau memiliki kolom: Nama Paket, Metode Pengadaan, Total Nilai."

---

## URUTAN BUILD

Bangun dalam urutan ini, satu per satu, tanpa melewati:

1. `pubspec.yaml` — tambahkan semua dependency
2. `lib/data/models/paket_pengadaan.dart` + jalankan build_runner untuk generate adapter
3. `lib/data/hive_service.dart`
4. `lib/data/import_service.dart` (baca Excel → list model)
5. `lib/domain/analisis_service.dart` (semua logika deteksi)
6. `lib/app/theme.dart` + `lib/app/router.dart`
7. `lib/presentation/widgets/` (semua widget reusable)
8. Layar Beranda
9. Layar Impor
10. Layar Ringkasan Analisis
11. Layar Daftar Paket
12. Layar Detail Kejanggalan
13. `lib/main.dart` (inisialisasi Hive, jalankan app)

Setiap selesai satu layar, pastikan bisa di-hot-reload tanpa error sebelum lanjut ke layar berikutnya.

---

## ATURAN TAMBAHAN

- Tidak ada hardcode string bahasa Inggris di UI kecuali nama brand/teknis yang tidak bisa dihindari
- Semua angka rupiah diformat dengan titik sebagai pemisah ribuan: `Rp 1.234.567`
- Pesan error kepada pengguna harus deskriptif: bukan "Error 404" tapi "File tidak dapat dibaca. Coba gunakan format .xlsx atau .csv."
- Tidak ada koneksi internet sama sekali — tolak jika ada dependency yang butuh network
- Kode harus berjalan di Android API 21 ke atas
- Tidak perlu build untuk iOS
