import '../data/models/paket_pengadaan.dart';
import '../data/models/hasil_analisis.dart';
import '../utils/format_rupiah.dart';

class AnalisisService {
  void analisisSemua(List<PaketPengadaan> list) {
    // Maps for frequency checks
    // 3. Nama Paket Berulang dalam Satu Satuan Kerja: SKPD -> PaketNama -> count
    final Map<String, Map<String, int>> skpdPaketCount = {};
    // 4. Nama Paket Berulang di Banyak Satuan Kerja: PaketNama -> set of SKPDs
    final Map<String, Set<String>> paketSkpdSet = {};
    // 6. Kata Kunci Paket Berulang Banyak di Satu SKPD: SKPD -> Keyword (50 chars) -> count
    final Map<String, Map<String, int>> skpdKeywordCount = {};

    // First pass to compute counts
    for (final paket in list) {
      final skpd = paket.namaSatuanKerja.trim();
      final nama = paket.namaPaket.trim().toLowerCase();
      
      // For 3
      skpdPaketCount.putIfAbsent(skpd, () => {})[nama] = 
          (skpdPaketCount[skpd]![nama] ?? 0) + 1;

      // For 4
      paketSkpdSet.putIfAbsent(nama, () => {}).add(skpd);

      // For 6
      final keyword = nama.length > 50 ? nama.substring(0, 50) : nama;
      skpdKeywordCount.putIfAbsent(skpd, () => {})[keyword] = 
          (skpdKeywordCount[skpd]![keyword] ?? 0) + 1;
    }

    // Second pass to evaluate anomalies
    for (final paket in list) {
      final catatans = <String>[];
      int maxTingkat = 0;

      final skpd = paket.namaSatuanKerja.trim();
      final nama = paket.namaPaket.trim().toLowerCase();
      final keyword = nama.length > 50 ? nama.substring(0, 50) : nama;

      // Helper to update maxTingkat
      void updateTingkat(int tingkat) {
        if (tingkat > maxTingkat) {
          maxTingkat = tingkat;
        }
      }

      // 1. Penunjukan Langsung Bernilai Besar
      if (paket.metodePengadaan.trim().toLowerCase() == 'penunjukan langsung' &&
          paket.totalNilai > 500000000) {
        int tingkat = 1; // default waspada
        if (paket.totalNilai > 10000000000) {
          tingkat = 3; // kritis
        } else if (paket.totalNilai > 1000000000) {
          tingkat = 2; // tinggi
        }
        updateTingkat(tingkat);
        catatans.add("Ditunjuk langsung tanpa lelang padahal nilainya di atas Rp500 juta");
      }

      // 2. Paket Mendekati Batas Pengadaan Langsung
      if (paket.metodePengadaan.trim().toLowerCase() == 'pengadaan langsung' &&
          paket.totalNilai >= 150000000 &&
          paket.totalNilai <= 200000000) {
        int tingkat = 1;
        if (paket.totalNilai >= 190000000) {
          tingkat = 3;
        }
        updateTingkat(tingkat);
        catatans.add("Nilai paket mendekati batas atas Pengadaan Langsung (Rp200 juta). Perlu dicek apakah seharusnya dilelang.");
      }

      // 3. Nama Paket Berulang dalam Satu Satuan Kerja
      final countInSkpd = skpdPaketCount[skpd]?[nama] ?? 0;
      if (countInSkpd > 3) {
        int tingkat = 1;
        if (countInSkpd >= 20) {
          tingkat = 3;
        } else if (countInSkpd >= 10) {
          tingkat = 2;
        }
        updateTingkat(tingkat);
        catatans.add("Nama paket ini muncul $countInSkpd kali di $skpd. Perlu diperiksa apakah ini pemecahan paket yang disengaja.");
      }

      // 4. Nama Paket Berulang di Banyak Satuan Kerja
      final skpdsForPaket = paketSkpdSet[nama] ?? {};
      final countAcrossSkpd = skpdsForPaket.length;
      if (countAcrossSkpd > 5) {
        int tingkat = 1;
        if (countAcrossSkpd > 15) {
          tingkat = 2;
        }
        updateTingkat(tingkat);
        catatans.add("Paket dengan nama ini ditemukan di $countAcrossSkpd satuan kerja sekaligus.");
      }

      // 5. Nilai Paket Sangat Kecil
      if (paket.totalNilai < 1000000) {
        int tingkat = 1;
        if (paket.totalNilai < 10000) {
          tingkat = 3;
        }
        updateTingkat(tingkat);
        catatans.add("Nilai paket sangat kecil (${formatRupiah(paket.totalNilai)}). Perlu konfirmasi apakah data sudah benar.");
      }

      // 6. Kata Kunci Paket Berulang Banyak di Satu SKPD
      final countKeyword = skpdKeywordCount[skpd]?[keyword] ?? 0;
      if (countKeyword >= 30) {
        int tingkat = 2;
        if (countKeyword >= 50) {
          tingkat = 3;
        }
        updateTingkat(tingkat);
        catatans.add("Terdapat $countKeyword paket dengan nama serupa di satuan kerja ini. Kemungkinan satu pekerjaan besar yang dipecah-cepah.");
      }

      // Save results to paket object
      paket.tingkatKejanggalan = maxTingkat;
      paket.catatanKejanggalan = catatans;
    }
  }

  HasilAnalisis hitungHasilAnalisis(List<PaketPengadaan> list) {
    if (list.isEmpty) return HasilAnalisis.kosong();

    int totalPaket = list.length;
    double totalAnggaran = 0;
    final Set<String> skpdSet = {};

    int totalKritis = 0;
    int totalTinggi = 0;
    int totalWaspada = 0;
    int totalNormal = 0;

    int c1 = 0, c2 = 0, c3 = 0, c4 = 0, c5 = 0, c6 = 0;
    double v1 = 0, v2 = 0, v3 = 0, v4 = 0, v5 = 0, v6 = 0;

    for (final p in list) {
      totalAnggaran += p.totalNilai;
      skpdSet.add(p.namaSatuanKerja);

      switch (p.tingkatKejanggalan) {
        case 3:
          totalKritis++;
          break;
        case 2:
          totalTinggi++;
          break;
        case 1:
          totalWaspada++;
          break;
        case 0:
        default:
          totalNormal++;
          break;
      }

      for (final catatan in p.catatanKejanggalan) {
        if (catatan.startsWith("Ditunjuk langsung")) {
          c1++;
          v1 += p.totalNilai;
        } else if (catatan.startsWith("Nilai paket mendekati batas atas")) {
          c2++;
          v2 += p.totalNilai;
        } else if (catatan.startsWith("Nama paket ini muncul")) {
          c3++;
          v3 += p.totalNilai;
        } else if (catatan.startsWith("Paket dengan nama ini ditemukan")) {
          c4++;
          v4 += p.totalNilai;
        } else if (catatan.startsWith("Nilai paket sangat kecil")) {
          c5++;
          v5 += p.totalNilai;
        } else if (catatan.startsWith("Terdapat") && catatan.contains("serupa")) {
          c6++;
          v6 += p.totalNilai;
        }
      }
    }

    final rincian = {
      'Penunjukan Langsung Nilai Besar': RingkasanKejanggalan(
        namaKategori: 'Penunjukan Langsung Nilai Besar',
        penjelasan: 'Paket ditunjuk langsung tanpa lelang padahal nilainya di atas Rp500 juta.',
        jumlahTemuan: c1,
        totalNilaiTerdampak: v1,
        tingkatRisiko: 3,
      ),
      'Mendekati Batas Pengadaan Langsung': RingkasanKejanggalan(
        namaKategori: 'Mendekati Batas Pengadaan Langsung',
        penjelasan: 'Nilai paket mendekati batas atas Pengadaan Langsung (Rp200 juta). Perlu dicek apakah seharusnya dilelang.',
        jumlahTemuan: c2,
        totalNilaiTerdampak: v2,
        tingkatRisiko: 3,
      ),
      'Nama Paket Berulang di SKPD': RingkasanKejanggalan(
        namaKategori: 'Nama Paket Berulang di SKPD',
        penjelasan: 'Nama paket identik muncul berulang kali di satu Satuan Kerja yang sama. Kemungkinan pemecahan paket sengaja.',
        jumlahTemuan: c3,
        totalNilaiTerdampak: v3,
        tingkatRisiko: 3,
      ),
      'Nama Paket Berulang Lintas SKPD': RingkasanKejanggalan(
        namaKategori: 'Nama Paket Berulang Lintas SKPD',
        penjelasan: 'Paket dengan nama identik ditemukan di banyak Satuan Kerja berbeda sekaligus.',
        jumlahTemuan: c4,
        totalNilaiTerdampak: v4,
        tingkatRisiko: 2,
      ),
      'Nilai Paket Sangat Kecil': RingkasanKejanggalan(
        namaKategori: 'Nilai Paket Sangat Kecil',
        penjelasan: 'Nilai paket sangat kecil (di bawah Rp1 juta), perlu dipastikan kebenaran datanya.',
        jumlahTemuan: c5,
        totalNilaiTerdampak: v5,
        tingkatRisiko: 3,
      ),
      'Pola Paket Serupa di SKPD': RingkasanKejanggalan(
        namaKategori: 'Pola Paket Serupa di SKPD',
        penjelasan: 'Ditemukan banyak paket dengan nama mirip di satu Satuan Kerja yang sama. Indikasi pemecahan pekerjaan.',
        jumlahTemuan: c6,
        totalNilaiTerdampak: v6,
        tingkatRisiko: 3,
      ),
    };

    return HasilAnalisis(
      totalPaket: totalPaket,
      totalAnggaran: totalAnggaran,
      totalSatuanKerja: skpdSet.length,
      totalKritis: totalKritis,
      totalTinggi: totalTinggi,
      totalWaspada: totalWaspada,
      totalNormal: totalNormal,
      rincianKejanggalan: rincian,
    );
  }
}
