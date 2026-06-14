import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'package:excel/excel.dart';
import 'models/paket_pengadaan.dart';
import '../domain/analisis_service.dart';

class ImportProgress {
  final int current;
  final int total;
  final String status;

  ImportProgress(this.current, this.total, this.status);
}

class ImportResult {
  final List<PaketPengadaan> paketList;
  final int jumlahSatuanKerja;
  final int jumlahKejanggalan;
  final String errorMessage;
  final bool isSuccess;

  ImportResult({
    required this.paketList,
    required this.jumlahSatuanKerja,
    required this.jumlahKejanggalan,
    this.errorMessage = '',
    this.isSuccess = true,
  });
}

class ImportParams {
  final String filePath;
  final SendPort sendPort;

  ImportParams(this.filePath, this.sendPort);
}

class ImportService {
  Future<ImportResult> importFile(
    String filePath,
    void Function(ImportProgress) onProgress,
  ) async {
    final receivePort = ReceivePort();
    
    final params = ImportParams(filePath, receivePort.sendPort);
    final isolate = await Isolate.spawn(parseFileIsolate, params);
    
    ImportResult? result;
    
    await for (final message in receivePort) {
      if (message is ImportProgress) {
        onProgress(message);
      } else if (message is ImportResult) {
        result = message;
        break;
      }
    }
    
    receivePort.close();
    isolate.kill(priority: Isolate.beforeNextEvent);
    
    return result ??
        ImportResult(
          paketList: [],
          jumlahSatuanKerja: 0,
          jumlahKejanggalan: 0,
          errorMessage: "Terjadi kesalahan yang tidak diketahui saat membaca berkas.",
          isSuccess: false,
        );
  }
}

// Top-level or static function for Isolate
void parseFileIsolate(ImportParams params) {
  final file = File(params.filePath);
  if (!file.existsSync()) {
    params.sendPort.send(ImportResult(
      paketList: [],
      jumlahSatuanKerja: 0,
      jumlahKejanggalan: 0,
      errorMessage: "Berkas tidak ditemukan.",
      isSuccess: false,
    ));
    return;
  }

  try {
    final bytes = file.readAsBytesSync();
    final isCsv = params.filePath.toLowerCase().endsWith('.csv');

    List<List<dynamic>> rows = [];

    if (isCsv) {
      String csvString;
      try {
        csvString = utf8.decode(bytes);
      } catch (_) {
        csvString = latin1.decode(bytes);
      }
      rows = _parseCsv(csvString);
    } else {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        params.sendPort.send(ImportResult(
          paketList: [],
          jumlahSatuanKerja: 0,
          jumlahKejanggalan: 0,
          errorMessage: "Berkas Excel tidak memiliki tabel/sheet.",
          isSuccess: false,
        ));
        return;
      }
      final sheet = excel.tables.values.first;
      for (final row in sheet.rows) {
        rows.add(row.map((cell) => cell?.value).toList());
      }
    }

    if (rows.isEmpty) {
      params.sendPort.send(ImportResult(
        paketList: [],
        jumlahSatuanKerja: 0,
        jumlahKejanggalan: 0,
        errorMessage: "Berkas kosong.",
        isSuccess: false,
      ));
      return;
    }

    final headerRow = rows.first;
    int idxNamaInstansi = -1;
    int idxNamaSatuanKerja = -1;
    int idxCaraPengadaan = -1;
    int idxMetodePengadaan = -1;
    int idxJenisPengadaan = -1;
    int idxNamaPaket = -1;
    int idxKodeRup = -1;
    int idxSumberDana = -1;
    int idxTotalNilai = -1;
    int idxTahunAnggaran = -1;

    for (int i = 0; i < headerRow.length; i++) {
      final headerStr = _getCellValueString(headerRow[i]).toLowerCase();
      if (headerStr == 'nama instansi') {
        idxNamaInstansi = i;
      } else if (headerStr == 'nama satuan kerja') {
        idxNamaSatuanKerja = i;
      } else if (headerStr == 'cara pengadaan') {
        idxCaraPengadaan = i;
      } else if (headerStr == 'metode pengadaan') {
        idxMetodePengadaan = i;
      } else if (headerStr == 'jenis pengadaan') {
        idxJenisPengadaan = i;
      } else if (headerStr == 'nama paket') {
        idxNamaPaket = i;
      } else if (headerStr == 'kode rup') {
        idxKodeRup = i;
      } else if (headerStr == 'sumber dana') {
        idxSumberDana = i;
      } else if (headerStr.startsWith('total nilai') ||
                 headerStr == 'total nilai (rp)' ||
                 headerStr == 'pagu') {
        idxTotalNilai = i;
      } else if (headerStr == 'tahun anggaran') {
        idxTahunAnggaran = i;
      }
    }

    // Check mandatory headers
    if (idxNamaPaket == -1 || idxMetodePengadaan == -1 || idxTotalNilai == -1) {
      params.sendPort.send(ImportResult(
        paketList: [],
        jumlahSatuanKerja: 0,
        jumlahKejanggalan: 0,
        errorMessage: "Format file tidak dikenali. Pastikan file berasal dari SIRUP atau memiliki kolom: Nama Paket, Metode Pengadaan, Total Nilai.",
        isSuccess: false,
      ));
      return;
    }

    final List<PaketPengadaan> paketList = [];
    final Set<String> satuanKerjaSet = {};

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length <= idxNamaPaket ||
          row.length <= idxMetodePengadaan ||
          row.length <= idxTotalNilai) {
        continue;
      }

      final String namaPaketVal = _getCellValueString(row[idxNamaPaket]);
      final String metodePengadaanVal = _getCellValueString(row[idxMetodePengadaan]);
      final double? totalNilaiVal = _parseDouble(row[idxTotalNilai]);

      if (namaPaketVal.isEmpty || metodePengadaanVal.isEmpty || totalNilaiVal == null) {
        continue;
      }

      final String namaInstansiVal = idxNamaInstansi != -1 && idxNamaInstansi < row.length
          ? _getCellValueString(row[idxNamaInstansi])
          : '';
      final String rawSatuanKerja = idxNamaSatuanKerja != -1 && idxNamaSatuanKerja < row.length
          ? _getCellValueString(row[idxNamaSatuanKerja])
          : '';
      final String namaSatuanKerjaVal = _cleanSatuanKerja(rawSatuanKerja);

      final String tahunAnggaranVal = idxTahunAnggaran != -1 && idxTahunAnggaran < row.length
          ? _getCellValueString(row[idxTahunAnggaran])
          : '';
      final String caraPengadaanVal = idxCaraPengadaan != -1 && idxCaraPengadaan < row.length
          ? _getCellValueString(row[idxCaraPengadaan])
          : '';
      final String jenisPengadaanVal = idxJenisPengadaan != -1 && idxJenisPengadaan < row.length
          ? _getCellValueString(row[idxJenisPengadaan])
          : '';
      final String kodeRupVal = idxKodeRup != -1 && idxKodeRup < row.length
          ? _getCellValueString(row[idxKodeRup])
          : '';
      final String sumberDanaVal = idxSumberDana != -1 && idxSumberDana < row.length
          ? _getCellValueString(row[idxSumberDana])
          : '';

      satuanKerjaSet.add(namaSatuanKerjaVal);

      paketList.add(PaketPengadaan(
        namaInstansi: namaInstansiVal,
        namaSatuanKerja: namaSatuanKerjaVal,
        tahunAnggaran: tahunAnggaranVal,
        caraPengadaan: caraPengadaanVal,
        metodePengadaan: metodePengadaanVal,
        jenisPengadaan: jenisPengadaanVal,
        namaPaket: namaPaketVal,
        kodeRup: kodeRupVal,
        sumberDana: sumberDanaVal,
        totalNilai: totalNilaiVal,
      ));

      if (i % 100 == 0 || i == rows.length - 1) {
        params.sendPort.send(ImportProgress(i, rows.length - 1, "Sedang membaca data..."));
      }
    }

    // Run analysis after importing
    final analisisService = AnalisisService();
    analisisService.analisisSemua(paketList);

    int jumlahKejanggalan = 0;
    for (final p in paketList) {
      if (p.tingkatKejanggalan > 0) {
        jumlahKejanggalan += p.catatanKejanggalan.length;
      }
    }

    params.sendPort.send(ImportResult(
      paketList: paketList,
      jumlahSatuanKerja: satuanKerjaSet.length,
      jumlahKejanggalan: jumlahKejanggalan,
    ));
  } catch (e) {
    params.sendPort.send(ImportResult(
      paketList: [],
      jumlahSatuanKerja: 0,
      jumlahKejanggalan: 0,
      errorMessage: "Terjadi kesalahan saat membaca berkas: $e",
      isSuccess: false,
    ));
  }
}

String _getCellValueString(dynamic value) {
  if (value == null) return '';
  return value.toString().trim();
}

double? _parseDouble(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toDouble();
  final String cleaned = val.toString().replaceAll(RegExp(r'[^0-9.-]'), '');
  return double.tryParse(cleaned);
}

String _cleanSatuanKerja(String raw) {
  if (raw.contains(' - ')) {
    return raw.split(' - ').first.trim();
  } else if (raw.contains('-')) {
    final parts = raw.split('-');
    final last = parts.last.trim();
    if (RegExp(r'^[0-9.]+$').hasMatch(last) || last.contains('.')) {
      return parts.sublist(0, parts.length - 1).join('-').trim();
    }
  }
  return raw.trim();
}

List<List<String>> _parseCsv(String content) {
  final List<List<String>> rows = [];
  List<String> currentRow = [];
  final StringBuffer currentCell = StringBuffer();
  bool inQuotes = false;

  for (int i = 0; i < content.length; i++) {
    final char = content[i];
    if (char == '"') {
      inQuotes = !inQuotes;
    } else if (char == ',' && !inQuotes) {
      currentRow.add(currentCell.toString().trim());
      currentCell.clear();
    } else if ((char == '\n' || char == '\r') && !inQuotes) {
      if (char == '\r' && i + 1 < content.length && content[i + 1] == '\n') {
        i++; // skip \n
      }
      currentRow.add(currentCell.toString().trim());
      currentCell.clear();
      if (currentRow.isNotEmpty) {
        rows.add(currentRow);
        currentRow = [];
      }
    } else {
      currentCell.write(char);
    }
  }
  if (currentCell.isNotEmpty || currentRow.isNotEmpty) {
    currentRow.add(currentCell.toString().trim());
    rows.add(currentRow);
  }
  return rows;
}
