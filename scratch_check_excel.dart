// ignore_for_file: avoid_print, unused_element
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
  final s = value.toString().replaceAll(RegExp(r'[^0-9.-]'), '');
  return double.tryParse(s);
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
    int idxInstansi = -1;
    for (int i = 0; i < headers.length; i++) {
      if (headers[i].toLowerCase() == 'nama instansi') {
        idxInstansi = i;
        break;
      }
    }
    
    String instansiVal = 'UNKNOWN';
    if (idxInstansi != -1 && rows.length > 1) {
      instansiVal = _getCellValueString(rows[1][idxInstansi]?.value);
    }
    print('File: ${filepath.split("/").last} => Instansi in file: "$instansiVal"');
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
