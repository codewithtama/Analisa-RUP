// ignore_for_file: avoid_print, unused_element, unused_local_variable
import 'dart:io';
import 'package:excel/excel.dart';

// Copy parser logic from import_service.dart to see if any file has headers issues
String _getCellValueString(CellValue? value) {
  if (value == null) return '';
  return value.toString().trim();
}

double? _parseDouble(CellValue? value) {
  if (value == null) return null;
  if (value is DoubleCellValue) return value.value;
  if (value is IntCellValue) return value.value.toDouble();
  final String s = value.toString().trim();
  if (s.isEmpty) return null;

  String cleaned = s.replaceAll(RegExp(r'[Rr]p\.?'), '').trim();
  // Remove non-breaking spaces
  cleaned = cleaned.replaceAll(RegExp(r'\u00A0'), '').replaceAll(' ', '');

  final hasComma = cleaned.contains(',');
  final hasDot = cleaned.contains('.');

  if (hasComma && hasDot) {
    final commaIndex = cleaned.lastIndexOf(',');
    final dotIndex = cleaned.lastIndexOf('.');
    if (commaIndex > dotIndex) {
      cleaned = cleaned.replaceAll('.', '').replaceAll(',', '.');
    } else {
      cleaned = cleaned.replaceAll(',', '');
    }
  } else if (hasComma) {
    final parts = cleaned.split(',');
    if (parts.last.length == 3) {
      cleaned = cleaned.replaceAll(',', '');
    } else {
      cleaned = cleaned.replaceAll(',', '.');
    }
  } else if (hasDot) {
    final dotCount = '.'.allMatches(cleaned).length;
    if (dotCount > 1) {
      cleaned = cleaned.replaceAll('.', '');
    } else {
      final parts = cleaned.split('.');
      if (parts.last.length == 3) {
        cleaned = cleaned.replaceAll('.', '');
      }
    }
  }

  cleaned = cleaned.replaceAll(RegExp(r'[^0-9.-]'), '');
  return double.tryParse(cleaned);
}

String _getInstansiFromFilename(String filePath) {
  final name = filePath.split('/').last.split('\\').last;
  String clean = name.replaceAll('.xlsx', '').replaceAll('.csv', '');
  if (clean.startsWith('RUP ')) {
    clean = clean.substring(4);
  }
  return clean.trim();
}

void testFile(String filepath) {
  final file = File(filepath);
  if (!file.existsSync()) {
    print('File $filepath NOT FOUND');
    return;
  }
  
  try {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    if (excel.tables.isEmpty) {
      print('File $filepath: Empty tables');
      return;
    }
    final sheet = excel.tables.values.first;
    final rows = sheet.rows;
    if (rows.isEmpty) {
      print('File $filepath: Empty rows');
      return;
    }
    
    final headerRow = rows.first;
    final headers = headerRow.map((c) => _getCellValueString(c?.value)).toList();
    
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
      final headerStr = _getCellValueString(headerRow[i]?.value).toLowerCase();
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
    
    // Check if CSS headers are used
    final bool isCssHeader = headers.contains('w-full') || headers.contains('font-mono');
    if (isCssHeader && (idxNamaPaket == -1 || idxMetodePengadaan == -1 || idxTotalNilai == -1)) {
      if (headers.length >= 10) {
        idxNamaSatuanKerja = 1;
        idxCaraPengadaan = 2;
        idxMetodePengadaan = 3;
        idxJenisPengadaan = 4;
        idxNamaPaket = 5;
        idxKodeRup = 6;
        idxTotalNilai = 9;
      } else if (headers.length == 9) {
        idxCaraPengadaan = 1;
        idxMetodePengadaan = 2;
        idxJenisPengadaan = 3;
        idxNamaPaket = 4;
        idxKodeRup = 5;
        idxTotalNilai = 8;
      }
    }
    
    if (idxNamaPaket == -1 || idxMetodePengadaan == -1 || idxTotalNilai == -1) {
      print('File ${filepath.split("/").last} => FAIL (missing indices: namaPaket=$idxNamaPaket, metode=$idxMetodePengadaan, pagu=$idxTotalNilai)');
      return;
    }
    
    // Test parsing first row
    final firstDataRow = rows[1];
    final namaPaket = _getCellValueString(firstDataRow[idxNamaPaket]?.value);
    final totalNilai = _parseDouble(firstDataRow[idxTotalNilai]?.value);
    final instansi = idxNamaInstansi != -1 ? _getCellValueString(firstDataRow[idxNamaInstansi]?.value) : _getInstansiFromFilename(filepath);
    
    print('File: ${filepath.split("/").last} => SUCCESS: Instansi="$instansi", parsed ${rows.length - 1} rows, sample packet="$namaPaket", pagu=$totalNilai');
  } catch (e) {
    print('File $filepath: ERROR $e');
  }
}

void main() {
  final dir = Directory('assets/dataRUP');
  if (!dir.existsSync()) {
    print('assets/dataRUP directory not found');
    return;
  }
  
  final files = dir.listSync().whereType<File>().toList();
  for (var f in files) {
    testFile(f.path.replaceAll('\\', '/'));
  }
}
