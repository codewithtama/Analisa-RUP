import 'package:flutter/material.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../data/models/skpd_model.dart';

class ProfilSkpdProvider with ChangeNotifier {
  late SkpdModel selectedSkpdModel;
  int peringkat = 0;
  int totalSkpd = 0;
  
  List<PaketPengadaan> _originalList = [];
  List<PaketPengadaan> _filteredList = [];
  String _searchQuery = "";

  List<PaketPengadaan> get filteredList => _filteredList;
  String get searchQuery => _searchQuery;

  void inisialisasi(String skpdName, List<PaketPengadaan> allPakets) {
    _searchQuery = "";
    
    final Map<String, List<PaketPengadaan>> groups = {};
    for (final p in allPakets) {
      final skpd = p.namaSatuanKerja.trim();
      groups.putIfAbsent(skpd, () => []).add(p);
    }
    
    final List<SkpdModel> skpdModels = [];
    groups.forEach((name, list) {
      skpdModels.add(SkpdModel.hitung(name, list));
    });
    
    skpdModels.sort((a, b) => b.skorKerawanan.compareTo(a.skorKerawanan));
    totalSkpd = skpdModels.length;

    final cleanSkpdName = skpdName.trim();
    selectedSkpdModel = skpdModels.firstWhere(
      (m) => m.namaSkpd == cleanSkpdName,
      orElse: () => SkpdModel(
        namaSkpd: skpdName,
        totalPaket: 0,
        totalAnggaran: 0.0,
        jumlahKritis: 0,
        jumlahTinggi: 0,
        jumlahWaspada: 0,
        skorKerawanan: 0.0,
        paketList: [],
      ),
    );

    final idx = skpdModels.indexWhere((m) => m.namaSkpd == cleanSkpdName);
    peringkat = idx != -1 ? (idx + 1) : 0;

    _originalList = selectedSkpdModel.paketList;
    _filteredList = List.from(_originalList);
    _filter();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _filter();
  }

  void _filter() {
    if (_searchQuery.trim().isEmpty) {
      _filteredList = List.from(_originalList);
    } else {
      final q = _searchQuery.trim().toLowerCase();
      _filteredList = _originalList
          .where((p) => p.namaPaket.toLowerCase().contains(q))
          .toList();
    }
    notifyListeners();
  }
}
