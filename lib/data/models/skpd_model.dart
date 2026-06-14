import 'paket_pengadaan.dart';

class SkpdModel {
  final String namaSkpd;
  final int totalPaket;
  final double totalAnggaran;
  final int jumlahKritis; // Perlu Perhatian Segera
  final int jumlahTinggi; // Perlu Diperiksa
  final int jumlahWaspada; // Pantau
  final double skorKerawanan;
  final List<PaketPengadaan> paketList;

  SkpdModel({
    required this.namaSkpd,
    required this.totalPaket,
    required this.totalAnggaran,
    required this.jumlahKritis,
    required this.jumlahTinggi,
    required this.jumlahWaspada,
    required this.skorKerawanan,
    required this.paketList,
  });

  factory SkpdModel.hitung(String namaSkpd, List<PaketPengadaan> paketList) {
    final int totalPaket = paketList.length;
    double totalAnggaran = 0.0;
    int kritis = 0;
    int tinggi = 0;
    int waspada = 0;

    for (final p in paketList) {
      totalAnggaran += p.totalNilai;
      switch (p.tingkatKejanggalan) {
        case 3:
          kritis++;
          break;
        case 2:
          tinggi++;
          break;
        case 1:
          waspada++;
          break;
      }
    }

    final double skor = (kritis * 3.0) + (tinggi * 2.0) + (waspada * 1.0);

    return SkpdModel(
      namaSkpd: namaSkpd,
      totalPaket: totalPaket,
      totalAnggaran: totalAnggaran,
      jumlahKritis: kritis,
      jumlahTinggi: tinggi,
      jumlahWaspada: waspada,
      skorKerawanan: skor,
      paketList: paketList,
    );
  }
}
