import 'package:flutter/material.dart';
import '../../data/models/paket_pengadaan.dart';

class DaftarPaketProvider with ChangeNotifier {
  List<PaketPengadaan> _originalList = [];
  List<PaketPengadaan> _filteredList = [];
  
  // Filter states
  String _searchKodeRup = "";
  String _searchNamaPaket = "";
  
  String _selectedTahunAnggaran = "";
  String _selectedInstansi = "";
  String _selectedSatuanKerja = "";
  String _selectedCaraPengadaan = "";
  String _selectedSumberDana = "";
  
  // Sort values: 0=Terbesar, 1=Terkecil, 2=Alfabet
  int _selectedSort = 0;

  int _visibleCount = 50;

  List<PaketPengadaan> get filteredList => _filteredList;
  List<PaketPengadaan> get visibleList => _filteredList.take(_visibleCount).toList();
  int get totalCount => _filteredList.length;
  bool get hasMore => _visibleCount < _filteredList.length;
  
  String get searchKodeRup => _searchKodeRup;
  String get searchNamaPaket => _searchNamaPaket;
  String get selectedTahunAnggaran => _selectedTahunAnggaran;
  String get selectedInstansi => _selectedInstansi;
  String get selectedSatuanKerja => _selectedSatuanKerja;
  String get selectedCaraPengadaan => _selectedCaraPengadaan;
  String get selectedSumberDana => _selectedSumberDana;
  int get selectedSort => _selectedSort;

  List<String> get filteredSatuanKerjaList {
    if (_selectedInstansi.isEmpty) {
      return allSatuanKerja;
    }
    final Set<String> res = {""};
    for (final p in _originalList) {
      if (p.namaSatuanKerja.trim().isNotEmpty && p.namaInstansi.trim() == _selectedInstansi) {
        res.add(p.namaSatuanKerja.trim());
      }
    }
    return res.toList()..sort();
  }

  List<String> allTahunAnggaran = [];
  List<String> allInstansi = [];
  List<String> allSatuanKerja = [];
  List<String> allCaraPengadaan = [];
  List<String> allSumberDana = [];

  void inisialisasi(List<PaketPengadaan> list) {
    _originalList = list;
    
    final Set<String> tahunSet = {""};
    final Set<String> instansiSet = {""};
    final Set<String> skpdSet = {""};
    final Set<String> caraSet = {""};
    final Set<String> sumberSet = {""};
    
    for (final p in list) {
      if (p.tahunAnggaran.trim().isNotEmpty) tahunSet.add(p.tahunAnggaran.trim());
      if (p.namaInstansi.trim().isNotEmpty) {
        instansiSet.add(p.namaInstansi.trim());
      }
      if (p.namaSatuanKerja.trim().isNotEmpty) skpdSet.add(p.namaSatuanKerja.trim());
      if (p.caraPengadaan.trim().isNotEmpty) caraSet.add(p.caraPengadaan.trim());
      if (p.sumberDana.trim().isNotEmpty) sumberSet.add(p.sumberDana.trim());
    }
    
    allTahunAnggaran = tahunSet.toList()..sort((a, b) => b.compareTo(a)); // Descending year
    allInstansi = instansiSet.toList()..sort();
    allSatuanKerja = skpdSet.toList()..sort();
    allCaraPengadaan = caraSet.toList()..sort();
    allSumberDana = sumberSet.toList()..sort();

    _visibleCount = 50;
    _filterAndSort();
  }

  void setSearchKodeRup(String val) {
    _searchKodeRup = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void setSearchNamaPaket(String val) {
    _searchNamaPaket = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void setTahunAnggaran(String val) {
    _selectedTahunAnggaran = val;
    _visibleCount = 50;
    _filterAndSort();
  }



  void setInstansi(String val) {
    _selectedInstansi = val;
    _selectedSatuanKerja = ""; // reset child
    _visibleCount = 50;
    _filterAndSort();
  }

  void setSatuanKerja(String val) {
    _selectedSatuanKerja = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void setCaraPengadaan(String val) {
    _selectedCaraPengadaan = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void setSumberDana(String val) {
    _selectedSumberDana = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void setSort(int val) {
    _selectedSort = val;
    _visibleCount = 50;
    _filterAndSort();
  }

  void resetFilters() {
    _searchKodeRup = "";
    _searchNamaPaket = "";
    _selectedTahunAnggaran = "";
    _selectedInstansi = "";
    _selectedSatuanKerja = "";
    _selectedCaraPengadaan = "";
    _selectedSumberDana = "";
    _selectedSort = 0;
    _visibleCount = 50;
    _filterAndSort();
  }

  void loadMore() {
    if (hasMore) {
      _visibleCount += 50;
      notifyListeners();
    }
  }

  void _filterAndSort() {
    List<PaketPengadaan> temp = List.from(_originalList);

    if (_searchKodeRup.trim().isNotEmpty) {
      final query = _searchKodeRup.trim().toLowerCase();
      temp = temp.where((p) => p.kodeRup.toLowerCase().contains(query)).toList();
    }

    if (_searchNamaPaket.trim().isNotEmpty) {
      final query = _searchNamaPaket.trim().toLowerCase();
      temp = temp.where((p) => p.namaPaket.toLowerCase().contains(query)).toList();
    }

    if (_selectedTahunAnggaran.isNotEmpty) {
      temp = temp.where((p) => p.tahunAnggaran.trim() == _selectedTahunAnggaran).toList();
    }

    if (_selectedInstansi.isNotEmpty) {
      temp = temp.where((p) => p.namaInstansi.trim() == _selectedInstansi).toList();
    }

    if (_selectedSatuanKerja.isNotEmpty) {
      temp = temp.where((p) => p.namaSatuanKerja.trim() == _selectedSatuanKerja).toList();
    }

    if (_selectedCaraPengadaan.isNotEmpty) {
      temp = temp.where((p) => p.caraPengadaan.trim() == _selectedCaraPengadaan).toList();
    }

    if (_selectedSumberDana.isNotEmpty) {
      temp = temp.where((p) => p.sumberDana.trim() == _selectedSumberDana).toList();
    }

    // Sort logic
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
