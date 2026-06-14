import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/paket_pengadaan.dart';

/// Fungsi top-level untuk memproses data Excel di background Isolate (menghindari UI lag).
List<int>? _buildExcelBytes(List<Map<String, dynamic>> rawData) {
  var excel = Excel.createExcel();
  Sheet sheetObject = excel['Sheet1'];
  excel.setDefaultSheet('Sheet1');

  // Headers
  List<String> headers = [
    'Nama Instansi',
    'Nama Satuan Kerja',
    'Tahun Anggaran',
    'Cara Pengadaan',
    'Metode Pengadaan',
    'Jenis Pengadaan',
    'Nama Paket',
    'Kode RUP',
    'Sumber Dana',
    'Total Nilai (Rp)',
    'Tingkat Kejanggalan',
    'Catatan Kejanggalan',
  ];
  
  sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

  // Data
  for (var p in rawData) {
    final tingkatKejanggalan = p['tingkatKejanggalan'] as int? ?? 0;
    String tingkatStr = "Wajar";
    if (tingkatKejanggalan == 1) tingkatStr = "Pantau";
    if (tingkatKejanggalan == 2) tingkatStr = "Perlu Diperiksa";
    if (tingkatKejanggalan == 3) tingkatStr = "Kritis";

    String catatanStr = (p['catatanKejanggalan'] as List<dynamic>?)?.join("; ") ?? "";

    List<dynamic> row = [
      p['namaInstansi'] ?? "",
      p['namaSatuanKerja'] ?? "",
      p['tahunAnggaran'] ?? "",
      p['caraPengadaan'] ?? "",
      p['metodePengadaan'] ?? "",
      p['jenisPengadaan'] ?? "",
      p['namaPaket'] ?? "",
      p['kodeRup'] ?? "",
      p['sumberDana'] ?? "",
      p['totalNilai'] ?? 0.0,
      tingkatStr,
      catatanStr,
    ];
    
    sheetObject.appendRow(row.map((val) {
      if (val is double) return DoubleCellValue(val);
      if (val is int) return IntCellValue(val);
      return TextCellValue(val.toString());
    }).toList());
  }

  return excel.encode();
}

class ExportService {
  static Future<String?> exportToExcel(List<PaketPengadaan> paketList, String filename) async {
    try {
      // Ubah data objek Hive menjadi Map primitif agar aman ditransfer ke Isolate
      final rawData = paketList.map((p) => {
        'namaInstansi': p.namaInstansi,
        'namaSatuanKerja': p.namaSatuanKerja,
        'tahunAnggaran': p.tahunAnggaran,
        'caraPengadaan': p.caraPengadaan,
        'metodePengadaan': p.metodePengadaan,
        'jenisPengadaan': p.jenisPengadaan,
        'namaPaket': p.namaPaket,
        'kodeRup': p.kodeRup,
        'sumberDana': p.sumberDana,
        'totalNilai': p.totalNilai,
        'tingkatKejanggalan': p.tingkatKejanggalan,
        'catatanKejanggalan': p.catatanKejanggalan,
      }).toList();

      // Jalankan penyusunan dan encoding file Excel di background Isolate
      final fileBytes = await compute(_buildExcelBytes, rawData);
      if (fileBytes == null) return null;

      // Simpan hasil bytes ke file temporer di main thread
      final dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/$filename.xlsx');
      
      await file.writeAsBytes(fileBytes);
      
      // Bagikan file
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Hasil Ekspor Analisa RUP');
      
      return file.path;
    } catch (e) {
      debugPrint("Export error: $e");
      return null;
    }
  }
}
