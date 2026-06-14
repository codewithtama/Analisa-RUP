import 'package:flutter/material.dart';
import '../../data/hive_service.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../data/models/hasil_analisis.dart';
import '../../domain/analisis_service.dart';

class BerandaProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final AnalisisService _analisisService = AnalisisService();

  List<PaketPengadaan> _paketList = [];
  HasilAnalisis _hasilAnalisis = HasilAnalisis.kosong();
  bool _isLoading = true;

  List<PaketPengadaan> get paketList => _paketList;
  HasilAnalisis get hasilAnalisis => _hasilAnalisis;
  bool get isLoading => _isLoading;

  BerandaProvider() {
    loadData();
  }

  Future<void> loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      _paketList = await _hiveService.getSemuaPaket();
      _hasilAnalisis = _analisisService.hitungHasilAnalisis(_paketList);
    } catch (e) {
      debugPrint("Error loading data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePaketList(List<PaketPengadaan> newList) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _hiveService.simpanSemuaPaket(newList);
      _paketList = newList;
      _hasilAnalisis = _analisisService.hitungHasilAnalisis(_paketList);
    } catch (e) {
      debugPrint("Error saving data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> hapusSemuaData() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _hiveService.hapusSemua();
      _paketList = [];
      _hasilAnalisis = HasilAnalisis.kosong();
    } catch (e) {
      debugPrint("Error clearing data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
