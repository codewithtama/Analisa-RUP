import 'dart:math';

/// Kelas Utilitas untuk menghitung tingkat kemiripan teks menggunakan algoritma Jaro-Winkler.
class FuzzyMatch {
  /// Menghitung kemiripan antara [s1] dan [s2] dengan rentang skor 0.0 (sangat berbeda) hingga 1.0 (identik).
  static double jaroWinkler(String s1, String s2) {
    final clean1 = s1.trim().toLowerCase();
    final clean2 = s2.trim().toLowerCase();

    if (clean1 == clean2) return 1.0;
    if (clean1.isEmpty || clean2.isEmpty) return 0.0;

    final jaroSim = jaro(clean1, clean2);
    if (jaroSim < 0.7) return jaroSim;

    // Cari panjang kecocokan prefiks (maksimal 4 karakter)
    int prefix = 0;
    for (int i = 0; i < clean1.length && i < clean2.length && i < 4; i++) {
      if (clean1[i] == clean2[i]) {
        prefix++;
      } else {
        break;
      }
    }

    // Faktor penskalaan Winkler standar adalah 0.1
    return jaroSim + prefix * 0.1 * (1.0 - jaroSim);
  }

  /// Menghitung Jaro Distance dasar.
  static double jaro(String s1, String s2) {
    final len1 = s1.length;
    final len2 = s2.length;

    // Jarak pencarian maksimal untuk pencocokan karakter
    final matchDistance = max(len1, len2) ~/ 2 - 1;

    final matches1 = List<bool>.filled(len1, false);
    final matches2 = List<bool>.filled(len2, false);

    int matches = 0;
    for (int i = 0; i < len1; i++) {
      final start = max(0, i - matchDistance);
      final end = min(len2, i + matchDistance + 1);

      for (int j = start; j < end; j++) {
        if (!matches2[j] && s1[i] == s2[j]) {
          matches1[i] = true;
          matches2[j] = true;
          matches++;
          break;
        }
      }
    }

    if (matches == 0) return 0.0;

    // Hitung transposisi
    int transpositions = 0;
    int k = 0;
    for (int i = 0; i < len1; i++) {
      if (matches1[i]) {
        while (!matches2[k]) {
          k++;
        }
        if (s1[i] != s2[k]) {
          transpositions++;
        }
        k++;
      }
    }

    final m = matches.toDouble();
    return (m / len1 + m / len2 + (m - transpositions / 2.0) / m) / 3.0;
  }
}
