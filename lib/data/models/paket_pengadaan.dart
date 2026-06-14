import 'package:hive/hive.dart';

part 'paket_pengadaan.g.dart';

@HiveType(typeId: 0)
class PaketPengadaan extends HiveObject {
  @HiveField(0)
  final String namaInstansi;

  @HiveField(1)
  final String namaSatuanKerja; // SKPD

  @HiveField(2)
  final String tahunAnggaran;

  @HiveField(3)
  final String caraPengadaan;

  @HiveField(4)
  final String metodePengadaan;

  @HiveField(5)
  final String jenisPengadaan;

  @HiveField(6)
  final String namaPaket;

  @HiveField(7)
  final String kodeRup;

  @HiveField(8)
  final String sumberDana;

  @HiveField(9)
  final double totalNilai;

  @HiveField(10)
  int tingkatKejanggalan; // 0=normal, 1=waspada, 2=tinggi, 3=kritis

  @HiveField(11)
  List<String> catatanKejanggalan; // daftar kejanggalan yang ditemukan

  PaketPengadaan({
    required this.namaInstansi,
    required this.namaSatuanKerja,
    required this.tahunAnggaran,
    required this.caraPengadaan,
    required this.metodePengadaan,
    required this.jenisPengadaan,
    required this.namaPaket,
    required this.kodeRup,
    required this.sumberDana,
    required this.totalNilai,
    this.tingkatKejanggalan = 0,
    this.catatanKejanggalan = const [],
  });
}
