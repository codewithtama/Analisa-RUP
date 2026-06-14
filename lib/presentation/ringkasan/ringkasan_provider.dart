import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/hive_service.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../data/models/skpd_model.dart';

class SkpdBudgetBreakdown {
  final String namaSkpd;
  final double anggaranNormal;
  final double anggaranBermasalah;
  final double totalAnggaran;

  SkpdBudgetBreakdown({
    required this.namaSkpd,
    required this.anggaranNormal,
    required this.anggaranBermasalah,
    required this.totalAnggaran,
  });
}

class RingkasanProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();

  List<MapEntry<String, int>> metodeCount = [];
  List<SkpdBudgetBreakdown> topSkpdBudget = [];
  List<MapEntry<String, int>> sumberDanaCount = [];
  List<MapEntry<String, int>> jenisPengadaanCount = [];
  List<SkpdModel> skpdLeaderboard = [];
  bool isProcessing = true;

  double batasPL = 200000000.0;
  double batasPenunjukan = 500000000.0;

  Future<void> hitungStatistik(List<PaketPengadaan> paketList) async {
    isProcessing = true;
    notifyListeners();

    try {
      batasPL = await _hiveService.getBatasPL();
      batasPenunjukan = await _hiveService.getBatasPenunjukan();
    } catch (_) {}

    if (paketList.isEmpty) {
      metodeCount = [];
      topSkpdBudget = [];
      sumberDanaCount = [];
      jenisPengadaanCount = [];
      skpdLeaderboard = [];
      isProcessing = false;
      notifyListeners();
      return;
    }

    final Map<String, int> metCountMap = {};
    final Map<String, double> skpdTotalMap = {};
    final Map<String, double> skpdNormalMap = {};
    final Map<String, double> skpdBermasalahMap = {};
    final Map<String, int> sdCountMap = {};
    final Map<String, int> jpCountMap = {};
    final Map<String, List<PaketPengadaan>> skpdGroup = {};

    for (final p in paketList) {
      final method = p.metodePengadaan.trim().isEmpty ? "Lainnya" : p.metodePengadaan.trim();
      metCountMap[method] = (metCountMap[method] ?? 0) + 1;

      final skpd = p.namaSatuanKerja.trim().isEmpty ? "Lainnya" : p.namaSatuanKerja.trim();
      skpdTotalMap[skpd] = (skpdTotalMap[skpd] ?? 0) + p.totalNilai;
      
      if (p.tingkatKejanggalan > 0) {
        skpdBermasalahMap[skpd] = (skpdBermasalahMap[skpd] ?? 0) + p.totalNilai;
      } else {
        skpdNormalMap[skpd] = (skpdNormalMap[skpd] ?? 0) + p.totalNilai;
      }

      final sd = p.sumberDana.trim().isEmpty ? "Lainnya" : p.sumberDana.trim();
      sdCountMap[sd] = (sdCountMap[sd] ?? 0) + 1;

      final jp = p.jenisPengadaan.trim().isEmpty ? "Lainnya" : p.jenisPengadaan.trim();
      jpCountMap[jp] = (jpCountMap[jp] ?? 0) + 1;

      skpdGroup.putIfAbsent(skpd, () => []).add(p);
    }

    metodeCount = metCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Calculate Top 5 SKPD by Total Budget
    final sortedTotalEntries = skpdTotalMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    final top5 = sortedTotalEntries.length > 5 ? sortedTotalEntries.sublist(0, 5) : sortedTotalEntries;

    topSkpdBudget = top5.map((entry) {
      final skpd = entry.key;
      return SkpdBudgetBreakdown(
        namaSkpd: skpd,
        anggaranNormal: skpdNormalMap[skpd] ?? 0.0,
        anggaranBermasalah: skpdBermasalahMap[skpd] ?? 0.0,
        totalAnggaran: entry.value,
      );
    }).toList();

    sumberDanaCount = sdCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    jenisPengadaanCount = jpCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final List<SkpdModel> skpdModels = [];
    skpdGroup.forEach((skpdName, list) {
      skpdModels.add(SkpdModel.hitung(skpdName, list));
    });

    // Sort SKPD by score descending
    skpdModels.sort((a, b) => b.skorKerawanan.compareTo(a.skorKerawanan));
    skpdLeaderboard = skpdModels;

    isProcessing = false;
    notifyListeners();
  }

  Future<String?> eksporLaporanTemuan(List<PaketPengadaan> list) async {
    final findings = list.where((p) => p.tingkatKejanggalan > 0).toList();
    if (findings.isEmpty) {
      return "Tidak ada temuan kejanggalan untuk diekspor.";
    }

    final csvBuffer = StringBuffer();
    // Headers
    csvBuffer.writeln("Kode RUP,Satuan Kerja (SKPD),Nama Paket,Metode Pengadaan,Pagu (Rp),Tingkat Kejanggalan,Temuan/Catatan,Sumber Dana,Jenis Pengadaan,Tahun");

    for (final p in findings) {
      final kodeRup = '"${p.kodeRup.replaceAll('"', '""')}"';
      final skpd = '"${p.namaSatuanKerja.replaceAll('"', '""')}"';
      final nama = '"${p.namaPaket.replaceAll('"', '""')}"';
      final metode = '"${p.metodePengadaan.replaceAll('"', '""')}"';
      final pagu = p.totalNilai;
      
      String tingkat = "Waspada";
      if (p.tingkatKejanggalan == 2) {
        tingkat = "Tinggi";
      } else if (p.tingkatKejanggalan == 3) {
        tingkat = "Kritis";
      }
      final tingkatStr = '"$tingkat"';

      final catatan = '"${p.catatanKejanggalan.join('; ').replaceAll('"', '""')}"';
      final sumber = '"${p.sumberDana.replaceAll('"', '""')}"';
      final jenis = '"${p.jenisPengadaan.replaceAll('"', '""')}"';
      final tahun = '"${p.tahunAnggaran.replaceAll('"', '""')}"';

      csvBuffer.writeln("$kodeRup,$skpd,$nama,$metode,$pagu,$tingkatStr,$catatan,$sumber,$jenis,$tahun");
    }

    try {
      String? savedPath;
      if (Platform.isWindows) {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final file = File('${downloadsDir.path}/laporan_temuan_pengadaan.csv');
          await file.writeAsString(csvBuffer.toString());
          savedPath = file.path;
        }
      }

      // Share sheet fallback/alternative
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/laporan_temuan_pengadaan.csv');
      await tempFile.writeAsString(csvBuffer.toString());
      final xFile = XFile(tempFile.path);
      await Share.shareXFiles([xFile], subject: 'Laporan Temuan Kejanggalan RUP');

      if (savedPath != null) {
        return "Laporan berhasil diekspor ke folder Unduhan:\n$savedPath";
      }
      return null; // Success (shared)
    } catch (e) {
      return "Gagal mengekspor laporan: $e";
    }
  }
}
