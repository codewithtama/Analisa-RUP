import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/paket_pengadaan.dart';

class ExportService {
  static Future<String?> exportToExcel(List<PaketPengadaan> paketList, String filename) async {
    try {
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
      for (var p in paketList) {
        String tingkatStr = "Wajar";
        if (p.tingkatKejanggalan == 1) tingkatStr = "Pantau";
        if (p.tingkatKejanggalan == 2) tingkatStr = "Perlu Diperiksa";
        if (p.tingkatKejanggalan == 3) tingkatStr = "Kritis";

        String catatanStr = p.catatanKejanggalan.join("; ");

        List<dynamic> row = [
          p.namaInstansi,
          p.namaSatuanKerja,
          p.tahunAnggaran,
          p.caraPengadaan,
          p.metodePengadaan,
          p.jenisPengadaan,
          p.namaPaket,
          p.kodeRup,
          p.sumberDana,
          p.totalNilai,
          tingkatStr,
          catatanStr,
        ];
        
        sheetObject.appendRow(row.map((val) {
          if (val is double) return DoubleCellValue(val);
          if (val is int) return IntCellValue(val);
          return TextCellValue(val.toString());
        }).toList());
      }

      var fileBytes = excel.encode();
      if (fileBytes == null) return null;

      // Save to temporary directory
      final dir = await getTemporaryDirectory();
      final File file = File('${dir.path}/$filename.xlsx');
      
      await file.writeAsBytes(fileBytes);
      
      // Share file
      final xFile = XFile(file.path);
      await Share.shareXFiles([xFile], text: 'Hasil Ekspor Analisa RUP');
      
      return file.path;
    } catch (e) {
      debugPrint("Export error: $e");
      return null;
    }
  }
}
