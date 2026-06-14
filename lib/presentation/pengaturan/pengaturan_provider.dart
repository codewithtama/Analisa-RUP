import 'package:flutter/material.dart';
import '../../data/hive_service.dart';
import '../../domain/analisis_service.dart';
import '../beranda/beranda_provider.dart';

class PengaturanProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final AnalisisService _analisisService = AnalisisService();

  double _batasPL = 200000000.0;
  double _batasPenunjukan = 500000000.0;
  bool _isLoading = false;
  bool _isSaving = false;

  double get batasPL => _batasPL;
  double get batasPenunjukan => _batasPenunjukan;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  final TextEditingController controllerPL = TextEditingController();
  final TextEditingController controllerPenunjukan = TextEditingController();

  PengaturanProvider() {
    loadSettings();
  }

  Future<void> loadSettings() async {
    _isLoading = true;
    notifyListeners();

    try {
      _batasPL = await _hiveService.getBatasPL();
      _batasPenunjukan = await _hiveService.getBatasPenunjukan();
      
      controllerPL.text = _batasPL.toStringAsFixed(0);
      controllerPenunjukan.text = _batasPenunjukan.toStringAsFixed(0);
    } catch (e) {
      debugPrint("Gagal memuat pengaturan: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> simpanPengaturan(BerandaProvider berandaProvider) async {
    final double? plParsed = double.tryParse(controllerPL.text.replaceAll(RegExp(r'[^0-9.-]'), ''));
    final double? penunjukanParsed = double.tryParse(controllerPenunjukan.text.replaceAll(RegExp(r'[^0-9.-]'), ''));

    if (plParsed == null || penunjukanParsed == null) {
      return false;
    }

    _isSaving = true;
    notifyListeners();

    try {
      _batasPL = plParsed;
      _batasPenunjukan = penunjukanParsed;

      await _hiveService.setBatasPL(_batasPL);
      await _hiveService.setBatasPenunjukan(_batasPenunjukan);

      // Re-run analysis on all existing packages
      final paketList = await _hiveService.getSemuaPaket();
      if (paketList.isNotEmpty) {
        _analisisService.analisisSemua(
          paketList,
          batasPL: _batasPL,
          batasPenunjukan: _batasPenunjukan,
        );
        await _hiveService.simpanSemuaPaket(paketList);
      }

      // Update Beranda state
      await berandaProvider.loadData();
      _isSaving = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint("Gagal menyimpan pengaturan: $e");
      _isSaving = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    controllerPL.dispose();
    controllerPenunjukan.dispose();
    super.dispose();
  }
}
