import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/import_service.dart';
import '../../data/hive_service.dart';
import '../../data/models/paket_pengadaan.dart';

class ImporProvider with ChangeNotifier {
  final ImportService _importService = ImportService();
  final HiveService _hiveService = HiveService();

  bool _isImporting = false;
  double _progress = 0.0;
  String _statusText = "";
  ImportResult? _importResult;

  bool get isImporting => _isImporting;
  double get progress => _progress;
  String get statusText => _statusText;
  ImportResult? get importResult => _importResult;

  Future<void> pilihDanImporBerkas({
    required BuildContext context,
    required bool forceOverwrite,
    required void Function(List<PaketPengadaan>) onImportCompleted,
    required List<PaketPengadaan> currentPaketList,
  }) async {
    _importResult = null;
    notifyListeners();

    try {
      final FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'csv'],
      );

      if (!context.mounted) return;

      if (pickerResult == null || pickerResult.files.isEmpty) {
        return; // User cancelled
      }

      final file = pickerResult.files.first;
      final path = file.path;

      if (path == null) {
        _statusText = "Berkas tidak valid.";
        notifyListeners();
        return;
      }

      if (!forceOverwrite && currentPaketList.isNotEmpty) {
        final proceed = await _tanyaKonfirmasi(context, file.name);
        if (!proceed) return;
      }

      _isImporting = true;
      _progress = 0.0;
      _statusText = "Membaca berkas...";
      notifyListeners();

      final double batasPL = await _hiveService.getBatasPL();
      final double batasPenunjukan = await _hiveService.getBatasPenunjukan();

      final result = await _importService.importFile(
        path,
        batasPL,
        batasPenunjukan,
        (progressUpdate) {
          _progress = progressUpdate.total > 0 ? (progressUpdate.current / progressUpdate.total) : 0.0;
          _statusText = "${progressUpdate.status} (${progressUpdate.current}/${progressUpdate.total} baris)";
          notifyListeners();
        },
      );

      _importResult = result;
      if (result.isSuccess && result.paketList.isNotEmpty) {
        onImportCompleted(result.paketList);
      }
    } catch (e) {
      _importResult = ImportResult(
        paketList: [],
        jumlahSatuanKerja: 0,
        jumlahKejanggalan: 0,
        errorMessage: "Terjadi kesalahan saat mengimpor berkas: $e",
        isSuccess: false,
      );
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<void> muatDariPreset({
    required BuildContext context,
    required String assetPath,
    required bool forceOverwrite,
    required void Function(List<PaketPengadaan>) onImportCompleted,
    required List<PaketPengadaan> currentPaketList,
  }) async {
    _importResult = null;
    notifyListeners();

    try {
      if (!forceOverwrite && currentPaketList.isNotEmpty) {
        final proceed = await _tanyaKonfirmasi(context, assetPath.split('/').last);
        if (!proceed) return;
      }

      _isImporting = true;
      _progress = 0.0;
      _statusText = "Membaca berkas sampel...";
      notifyListeners();

      final byteData = await rootBundle.load(assetPath);
      final dir = await getTemporaryDirectory();
      final tempFile = File('${dir.path}/${assetPath.split('/').last}');
      await tempFile.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

      final double batasPL = await _hiveService.getBatasPL();
      final double batasPenunjukan = await _hiveService.getBatasPenunjukan();

      final result = await _importService.importFile(
        tempFile.path,
        batasPL,
        batasPenunjukan,
        (progressUpdate) {
          _progress = progressUpdate.total > 0 ? (progressUpdate.current / progressUpdate.total) : 0.0;
          _statusText = "${progressUpdate.status} (${progressUpdate.current}/${progressUpdate.total} baris)";
          notifyListeners();
        },
      );

      _importResult = result;
      if (result.isSuccess && result.paketList.isNotEmpty) {
        onImportCompleted(result.paketList);
      }
    } catch (e) {
      _importResult = ImportResult(
        paketList: [],
        jumlahSatuanKerja: 0,
        jumlahKejanggalan: 0,
        errorMessage: "Terjadi kesalahan saat memuat sampel: $e",
        isSuccess: false,
      );
    } finally {
      _isImporting = false;
      notifyListeners();
    }
  }

  Future<bool> _tanyaKonfirmasi(BuildContext context, String filename) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Ganti Data Sebelumnya?"),
        content: Text(
          "Anda memilih berkas '$filename'. Mengimpor data baru akan mengganti seluruh data pengadaan yang tersimpan sebelumnya. Lanjutkan?",
        ),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.black54)),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: const Text("Lanjutkan"),
            onPressed: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
