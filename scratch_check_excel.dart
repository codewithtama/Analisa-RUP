// ignore_for_file: avoid_print
import 'dart:io';
import 'package:excel/excel.dart';

void main() {
  var file = 'RUP TANGSEL.xlsx';
  try {
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      print('Table: $table');
      var rows = excel.tables[table]!.rows;
      for (int i = 0; i < 5 && i < rows.length; i++) {
        var rowStr = rows[i].map((c) => c?.value).join(' | ');
        print('Row $i: $rowStr');
      }
      break;
    }
  } catch (e) {
    print(e);
  }
}
