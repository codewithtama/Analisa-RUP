import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../utils/format_rupiah.dart';

class DetailProvider with ChangeNotifier {
  List<PaketPengadaan> filteredPakets = [];
  double totalNilaiTerdampak = 0.0;
  String penjelasanKategori = "";
  int _visibleCount = 30;

  List<PaketPengadaan> get visibleList => filteredPakets.take(_visibleCount).toList();
  int get totalCount => filteredPakets.length;
  bool get hasMore => _visibleCount < filteredPakets.length;

  void loadMore() {
    if (hasMore) {
      _visibleCount += 30;
      notifyListeners();
    }
  }

  void inisialisasi(String kategori, List<PaketPengadaan> paketList) {
    _visibleCount = 30;
    double batasPL = 200000000.0;
    double batasPen = 500000000.0;
    try {
      if (Hive.isBoxOpen('pengaturan')) {
        final box = Hive.box('pengaturan');
        final plVal = box.get('batas_pl');
        if (plVal is num) batasPL = plVal.toDouble();
        final penVal = box.get('batas_penunjukan');
        if (penVal is num) batasPen = penVal.toDouble();
      }
    } catch (_) {}

    penjelasanKategori = _getPenjelasanKategori(kategori, batasPL, batasPen);

    filteredPakets = paketList.where((p) {
      for (final catatan in p.catatanKejanggalan) {
        if (kategori == 'Penunjukan Langsung Nilai Besar' && catatan.startsWith("Ditunjuk langsung")) {
          return true;
        }
        if (kategori == 'Mendekati Batas Pengadaan Langsung' && catatan.startsWith("Nilai paket mendekati batas atas")) {
          return true;
        }
        if (kategori == 'Nama Paket Berulang di SKPD' && catatan.startsWith("Nama paket ini muncul")) {
          return true;
        }
        if (kategori == 'Nama Paket Berulang Lintas SKPD' && catatan.startsWith("Paket dengan nama ini ditemukan")) {
          return true;
        }
        if (kategori == 'Nilai Paket Sangat Kecil' && catatan.startsWith("Nilai paket sangat kecil")) {
          return true;
        }
        if (kategori == 'Pola Paket Serupa di SKPD' && catatan.startsWith("Terdapat") && catatan.contains("serupa")) {
          return true;
        }
        if (kategori == 'Indikasi Pecah Paket Pekerjaan' && catatan.startsWith("Terindikasi pemecahan paket")) {
          return true;
        }
      }
      return false;
    }).toList();

    totalNilaiTerdampak = filteredPakets.fold(0.0, (sum, p) => sum + p.totalNilai);
    notifyListeners();
  }

  String _getPenjelasanKategori(String kategori, double batasPL, double batasPen) {
    switch (kategori) {
      case 'Penunjukan Langsung Nilai Besar':
        return 'Daftar paket pengadaan yang ditunjuk langsung oleh Satuan Kerja tanpa melalui proses lelang/tender umum, padahal nilai anggarannya melebihi batas regulasi ${formatRupiah(batasPen)}. Hal ini berpotensi menyalahi aturan lelang publik.';
      case 'Mendekati Batas Pengadaan Langsung':
        return 'Paket-paket pengadaan langsung dengan nilai mendekati batas maksimal regulasi ${formatRupiah(batasPL)}. Perlu dilakukan verifikasi independen untuk mengonfirmasi apakah paket sengaja dibuat di bawah batas lelang agar terhindar dari tender terbuka.';
      case 'Nama Paket Berulang di SKPD':
        return 'Ditemukan nama paket yang identik muncul berulang kali di satu Satuan Kerja (SKPD) yang sama. Kondisi ini sering diasosiasikan dengan pemecahan paket pekerjaan besar secara sengaja demi menghindari lelang terbuka.';
      case 'Nama Paket Berulang Lintas SKPD':
        return 'Paket pengadaan dengan nama yang persis sama ditemukan tersebar di banyak Satuan Kerja berbeda sekaligus. Pola ini patut diinvestigasi untuk mendeteksi kemungkinan duplikasi pengadaan atau monopoli vendor.';
      case 'Nilai Paket Sangat Kecil':
        return 'Daftar paket pengadaan dengan alokasi anggaran yang sangat tidak wajar atau terlalu kecil (di bawah Rp1 juta rupiah). Kemungkinan besar terdapat kesalahan penulisan data masukan atau anomali input anggaran.';
      case 'Pola Paket Serupa di SKPD':
        return 'Ditemukan kemiripan nama paket (pola karakter 50 kata pertama) yang berulang dalam jumlah tidak wajar di satu Satuan Kerja. Indikasi kuat adanya upaya memecah pekerjaan proyek besar menjadi paket-paket kecil.';
      case 'Indikasi Pecah Paket Pekerjaan':
        return 'Daftar paket pekerjaan sejenis yang nilainya dipecah-pecah di bawah batas Pengadaan Langsung (${formatRupiah(batasPL)}), namun total akumulasinya melebihi batas tersebut. Pola ini mengindikasikan taktik pemecahan paket secara sengaja untuk menghindari lelang umum.';
      default:
        return 'Daftar paket pengadaan yang masuk dalam kategori kejanggalan sistem.';
    }
  }

  Future<void> bagikanLaporan(String kategori) async {
    if (filteredPakets.isEmpty) return;

    final StringBuffer buffer = StringBuffer();
    buffer.writeln("=== LAPORAN KEJANGGALAN ANGGARAN PENGADAAN K/L/PD ===");
    buffer.writeln("Kategori: $kategori");
    buffer.writeln("Penjelasan: $penjelasanKategori");
    buffer.writeln("Jumlah Temuan: ${filteredPakets.length} paket");
    buffer.writeln("Total Nilai Terdampak: ${formatRupiah(totalNilaiTerdampak)}");
    buffer.writeln("===========================================\n");

    buffer.writeln("Daftar Paket Terkait (Menampilkan 10 Teratas):");
    int limit = filteredPakets.length > 10 ? 10 : filteredPakets.length;
    for (int i = 0; i < limit; i++) {
      final p = filteredPakets[i];
      buffer.writeln("${i + 1}. ${p.namaPaket}");
      buffer.writeln("   - SKPD: ${p.namaSatuanKerja}");
      buffer.writeln("   - Nilai: ${formatRupiah(p.totalNilai)}");
      buffer.writeln("   - Catatan: ${p.catatanKejanggalan.join('; ')}");
      buffer.writeln("");
    }

    if (filteredPakets.length > 10) {
      buffer.writeln("... dan ${filteredPakets.length - 10} paket lainnya.");
    }

    buffer.writeln("\nDipantau melalui Aplikasi Pantau RUP.");

    await Share.share(buffer.toString(), subject: "Laporan Kejanggalan - $kategori");
  }
}
