class RingkasanKejanggalan {
  final String namaKategori;
  final String penjelasan;
  final int jumlahTemuan;
  final double totalNilaiTerdampak;
  final int tingkatRisiko; // 1=waspada, 2=tinggi, 3=kritis

  RingkasanKejanggalan({
    required this.namaKategori,
    required this.penjelasan,
    required this.jumlahTemuan,
    required this.totalNilaiTerdampak,
    required this.tingkatRisiko,
  });
}

class HasilAnalisis {
  final int totalPaket;
  final double totalAnggaran;
  final int totalSatuanKerja;

  final int totalKritis;
  final int totalTinggi;
  final int totalWaspada;
  final int totalNormal;

  final Map<String, RingkasanKejanggalan> rincianKejanggalan;

  HasilAnalisis({
    required this.totalPaket,
    required this.totalAnggaran,
    required this.totalSatuanKerja,
    required this.totalKritis,
    required this.totalTinggi,
    required this.totalWaspada,
    required this.totalNormal,
    required this.rincianKejanggalan,
  });

  factory HasilAnalisis.kosong() {
    return HasilAnalisis(
      totalPaket: 0,
      totalAnggaran: 0.0,
      totalSatuanKerja: 0,
      totalKritis: 0,
      totalTinggi: 0,
      totalWaspada: 0,
      totalNormal: 0,
      rincianKejanggalan: {},
    );
  }
}
