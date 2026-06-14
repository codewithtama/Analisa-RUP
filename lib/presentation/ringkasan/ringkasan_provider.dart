import 'package:flutter/material.dart';
import '../../data/models/paket_pengadaan.dart';

class RingkasanProvider with ChangeNotifier {
  List<MapEntry<String, int>> metodeCount = [];
  List<MapEntry<String, double>> topSkpdBudget = [];
  bool isProcessing = true;

  void hitungStatistik(List<PaketPengadaan> paketList) {
    if (paketList.isEmpty) {
      metodeCount = [];
      topSkpdBudget = [];
      isProcessing = false;
      notifyListeners();
      return;
    }

    isProcessing = true;

    final Map<String, int> metCountMap = {};
    final Map<String, double> skpdBudMap = {};

    for (final p in paketList) {
      final method = p.metodePengadaan.trim().isEmpty ? "Lainnya" : p.metodePengadaan.trim();
      metCountMap[method] = (metCountMap[method] ?? 0) + 1;

      final skpd = p.namaSatuanKerja.trim().isEmpty ? "Lainnya" : p.namaSatuanKerja.trim();
      skpdBudMap[skpd] = (skpdBudMap[skpd] ?? 0) + p.totalNilai;
    }

    metodeCount = metCountMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    topSkpdBudget = skpdBudMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    if (topSkpdBudget.length > 5) {
      topSkpdBudget = topSkpdBudget.sublist(0, 5);
    }

    isProcessing = false;
    notifyListeners();
  }
}
