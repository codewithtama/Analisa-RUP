import 'package:flutter/material.dart';
import '../../data/models/paket_pengadaan.dart';

class DaftarPaketProvider with ChangeNotifier {
  List<PaketPengadaan> _originalList = [];
  List<PaketPengadaan> _filteredList = [];
  
  String _searchQuery = "";
  String _selectedSkpd = "";
  int _selectedTingkat = -1; // -1 means All
  String _selectedMetode = "";
  String _selectedJenis = "";
  
  // Sort values: 0=Terbesar, 1=Terkecil, 2=Alfabet
  int _selectedSort = 0;

  List<PaketPengadaan> get filteredList => _filteredList;
  
  String get searchQuery => _searchQuery;
  String get selectedSkpd => _selectedSkpd;
  int get selectedTingkat => _selectedTingkat;
  String get selectedMetode => _selectedMetode;
  String get selectedJenis => _selectedJenis;
  int get selectedSort => _selectedSort;

  List<String> allSkpd = [];
  List<String> allMetode = [];
  List<String> allJenis = [];

  void inisialisasi(List<PaketPengadaan> list) {
    _originalList = list;
    
    final Set<String> skpds = {""};
    final Set<String> metodes = {""};
    final Set<String> jeniss = {""};
    for (final p in list) {
      if (p.namaSatuanKerja.trim().isNotEmpty) {
        skpds.add(p.namaSatuanKerja.trim());
      }
      if (p.metodePengadaan.trim().isNotEmpty) {
        metodes.add(p.metodePengadaan.trim());
      }
      if (p.jenisPengadaan.trim().isNotEmpty) {
        jeniss.add(p.jenisPengadaan.trim());
      }
    }
    
    allSkpd = skpds.toList()..sort();
    allMetode = metodes.toList()..sort();
    allJenis = jeniss.toList()..sort();

    _filterAndSort();
  }

  void setSearchQuery(String val) {
    _searchQuery = val;
    _filterAndSort();
  }

  void setSkpd(String val) {
    _selectedSkpd = val;
    _filterAndSort();
  }

  void setTingkat(int val) {
    _selectedTingkat = val;
    _filterAndSort();
  }

  void setMetode(String val) {
    _selectedMetode = val;
    _filterAndSort();
  }

  void setJenis(String val) {
    _selectedJenis = val;
    _filterAndSort();
  }

  void setSort(int val) {
    _selectedSort = val;
    _filterAndSort();
  }

  void resetFilters() {
    _searchQuery = "";
    _selectedSkpd = "";
    _selectedTingkat = -1;
    _selectedMetode = "";
    _selectedJenis = "";
    _selectedSort = 0;
    _filterAndSort();
  }

  void _filterAndSort() {
    List<PaketPengadaan> temp = List.from(_originalList);

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      temp = temp.where((p) =>
          p.namaPaket.toLowerCase().contains(query) ||
          p.kodeRup.toLowerCase().contains(query)).toList();
    }

    if (_selectedSkpd.isNotEmpty) {
      temp = temp.where((p) => p.namaSatuanKerja.trim() == _selectedSkpd).toList();
    }

    if (_selectedTingkat != -1) {
      temp = temp.where((p) => p.tingkatKejanggalan == _selectedTingkat).toList();
    }

    if (_selectedMetode.isNotEmpty) {
      temp = temp.where((p) => p.metodePengadaan.trim() == _selectedMetode).toList();
    }

    if (_selectedJenis.isNotEmpty) {
      temp = temp.where((p) => p.jenisPengadaan.trim() == _selectedJenis).toList();
    }

    if (_selectedSort == 0) {
      temp.sort((a, b) => b.totalNilai.compareTo(a.totalNilai));
    } else if (_selectedSort == 1) {
      temp.sort((a, b) => a.totalNilai.compareTo(b.totalNilai));
    } else if (_selectedSort == 2) {
      temp.sort((a, b) => a.namaPaket.toLowerCase().compareTo(b.namaPaket.toLowerCase()));
    }

    _filteredList = temp;
    notifyListeners();
  }
}
