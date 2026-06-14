// ignore_for_file: avoid_print
import 'dart:io';
import 'package:excel/excel.dart';
import 'lib/utils/fuzzy_match.dart';

void main() {
  final file = 'assets/dataRUP/RUP TANGSEL.xlsx';
  if (!File(file).existsSync()) {
    print('File not found: $file');
    return;
  }
  
  final bytes = File(file).readAsBytesSync();
  final excel = Excel.decodeBytes(bytes);
  final sheet = excel.tables.values.first;
  
  final rows = sheet.rows;
  print('Total rows: ${rows.length}');
  
  // Find column indices
  final headerRow = rows.first;
  int idxNamaPaket = -1;
  int idxNamaSatuanKerja = -1;
  
  for (int i = 0; i < headerRow.length; i++) {
    final val = headerRow[i]?.value?.toString().toLowerCase().trim() ?? '';
    if (val == 'nama paket') {
      idxNamaPaket = i;
    } else if (val == 'nama satuan kerja') {
      idxNamaSatuanKerja = i;
    }
  }
  
  print('idxNamaPaket: $idxNamaPaket, idxNamaSatuanKerja: $idxNamaSatuanKerja');
  if (idxNamaPaket == -1 || idxNamaSatuanKerja == -1) {
    return;
  }
  
  final Map<String, List<String>> skpdPakets = {};
  for (int i = 1; i < rows.length; i++) {
    final row = rows[i];
    if (row.length <= idxNamaPaket || row.length <= idxNamaSatuanKerja) continue;
    final name = row[idxNamaPaket]?.value?.toString().trim() ?? '';
    final skpd = row[idxNamaSatuanKerja]?.value?.toString().trim() ?? '';
    if (name.isNotEmpty && skpd.isNotEmpty) {
      skpdPakets.putIfAbsent(skpd, () => []).add(name);
    }
  }
  
  // Let's analyze clustering for SKPDs
  skpdPakets.forEach((skpd, pakets) {
    final List<List<String>> clusters = [];
    for (final name in pakets) {
      final cleanName = name.toLowerCase().trim();
      bool matched = false;
      for (final cluster in clusters) {
        final repName = cluster.first.toLowerCase().trim();
        if (FuzzyMatch.jaroWinkler(repName, cleanName) >= 0.85) {
          cluster.add(name);
          matched = true;
          break;
        }
      }
      if (!matched) {
        clusters.add([name]);
      }
    }
    
    // Print stats of clusters for SKPDs that have clusters > 5
    int maxClusterSize = 0;
    for (final cluster in clusters) {
      if (cluster.length > maxClusterSize) {
        maxClusterSize = cluster.length;
      }
    }
    
    if (maxClusterSize >= 3) {
      print('SKPD: $skpd | Total pakets: ${pakets.length} | Clusters count: ${clusters.length} | Max cluster size: $maxClusterSize');
      // Print the large clusters
      for (final cluster in clusters) {
        if (cluster.length >= 3) {
          print('  - Large cluster (size ${cluster.length}):');
          for (int i = 0; i < 5 && i < cluster.length; i++) {
            print('    * ${cluster[i]}');
          }
        }
      }
    }
  });
}
