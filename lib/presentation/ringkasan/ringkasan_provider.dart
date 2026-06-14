import 'package:flutter/material.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../data/models/skpd_model.dart';

class RingkasanProvider with ChangeNotifier {
  List<MapEntry<String, int>> metodeCount = [];
  List<MapEntry<String, double>> topSkpdBudget = [];
  List<MapEntry<String, int>> sumberDanaCount = [];
  List<MapEntry<String, int>> jenisPengadaanCount = [];
  List<SkpdModel> skpdLeaderboard = [];
  bool isProcessing = true;

  void hitungStatistik(List<PaketPengadaan> paketList) {
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

    isProcessing = true;

    final Map<String, int> metCountMap = {};
    final Map<String, double> skpdBudMap = {};
    final Map<String, int> sdCountMap = {};
    final Map<String, int> jpCountMap = {};
    final Map<String, List<PaketPengadaan>> skpdGroup = {};

    for (final p in paketList) {
      final method = p.metodePengadaan.trim().isEmpty ? "Lainnya" : p.metodePengadaan.trim();
      metCountMap[method] = (metCountMap[method] ?? 0) + 1;

      final skpd = p.namaSatuanKerja.trim().isEmpty ? "Lainnya" : p.namaSatuanKerja.trim();
      skpdBudMap[skpd] = (skpdBudMap[skpd] ?? 0) + p.totalNilai;

      final sd = p.sumberDana.trim().isEmpty ? "Lainnya" : p.sumberDana.trim();
      sdCountMap[sd] = (sdCountMap[sd] ?? 0) + 1;

      final jp = p.jenisPengadaan.trim().isEmpty ? "Lainnya" : p.jenisPengadaan.trim();
      jpCountMap[jp] = (jpCountMap[jp] ?? 0) + 1;

      skpdGroup.putIfAbsent(skpd, () => []).add(p);
    }

    metodeCount = metCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topSkpdBudget = skpdBudMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (topSkpdBudget.length > 5) {
      topSkpdBudget = topSkpdBudget.sublist(0, 5);
    }

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
}
