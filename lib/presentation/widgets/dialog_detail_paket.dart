import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import 'chip_risiko.dart';

class DialogDetailPaket extends StatelessWidget {
  final PaketPengadaan paket;

  const DialogDetailPaket({super.key, required this.paket});

  static void tampilkan(BuildContext context, PaketPengadaan paket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DialogDetailPaket(paket: paket),
    );
  }

  Future<void> _bukaTautanSirup(BuildContext context) async {
    if (paket.kodeRup.trim().isEmpty) return;

    final isSwakelola = paket.caraPengadaan.toLowerCase().contains('swakelola');
    final String tipeSumber = isSwakelola ? "Swakelola" : "Penyedia";
    final String tahun = paket.tahunAnggaran.trim().isNotEmpty
        ? paket.tahunAnggaran.trim()
        : "2026";
    final String kodeRup = paket.kodeRup.trim();

    final String url =
        "https://data.inaproc.id/rup?tahun=$tahun&offset=0&limit=20&search_rup=$kodeRup&kode=$kodeRup&detail_sumber=$tipeSumber&sumber=$tipeSumber";

    try {
      final uri = Uri.parse(url);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal membuka tautan INAPROC: $e"),
            backgroundColor: warnaKritis,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Expanded(
                    child: Text(
                      "Detail Paket Kerja",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: warnaPrimer,
                      ),
                    ),
                  ),
                  ChipRisiko(tingkat: paket.tingkatKejanggalan),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),

              // Paket Name (Highlighted)
              const Text("Nama Pekerjaan", style: TextStyle(fontSize: 11, color: Colors.black38)),
              const SizedBox(height: 4),
              Text(
                paket.namaPaket,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: warnaPrimer,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Pagu Anggaran (Highlighted)
              const Text("Pagu Anggaran", style: TextStyle(fontSize: 11, color: Colors.black38)),
              const SizedBox(height: 4),
              Text(
                formatRupiah(paket.totalNilai),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: warnaAksen,
                ),
              ),
              const SizedBox(height: 16),

              // Metadata Grid
              _buildGridDetail([
                _DetailItem("Kode RUP", paket.kodeRup.isEmpty ? "-" : paket.kodeRup),
                _DetailItem("Tahun Anggaran", paket.tahunAnggaran.isEmpty ? "-" : paket.tahunAnggaran),
                _DetailItem("Instansi", paket.namaInstansi.isEmpty ? "-" : paket.namaInstansi),
                _DetailItem("Satuan Kerja (SKPD)", paket.namaSatuanKerja.isEmpty ? "-" : paket.namaSatuanKerja),
                _DetailItem("Cara Pengadaan", paket.caraPengadaan.isEmpty ? "-" : paket.caraPengadaan),
                _DetailItem("Metode Pengadaan", paket.metodePengadaan.isEmpty ? "-" : paket.metodePengadaan),
                _DetailItem("Jenis Pengadaan", paket.jenisPengadaan.isEmpty ? "-" : paket.jenisPengadaan),
                _DetailItem("Sumber Dana", paket.sumberDana.isEmpty ? "-" : _jelaskanSumberDana(paket.sumberDana)),
              ]),

              const SizedBox(height: 16),

              // Catatan Kejanggalan (If Any)
              if (paket.catatanKejanggalan.isNotEmpty) ...[
                const Text("Temuan Analisis Risiko", style: TextStyle(fontSize: 11, color: Colors.black38)),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: warnaKritis.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: warnaKritis.withValues(alpha: 0.15)),
                  ),
                  child: Column(
                    children: paket.catatanKejanggalan.map((c) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.warning_amber_rounded, size: 16, color: warnaKritis),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: warnaKritis,
                                  fontWeight: FontWeight.w600,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Tutup"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  if (paket.kodeRup.trim().isNotEmpty) ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new_rounded, size: 18),
                        label: const Text("Tautan INAPROC"),
                        onPressed: () => _bukaTautanSirup(context),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridDetail(List<_DetailItem> items) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(4),
        1: FlexColumnWidth(6),
      },
      children: items.map((item) {
        return TableRow(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.black45,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Text(
                item.value,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  String _jelaskanSumberDana(String sd) {
    final clean = sd.trim().toUpperCase();
    switch (clean) {
      case 'APBD':
        return 'APBD (Anggaran Pendapatan dan Belanja Daerah)';
      case 'APBDP':
        return 'APBDP (APBD Perubahan)';
      case 'APBN':
        return 'APBN (Anggaran Pendapatan dan Belanja Negara)';
      case 'APBNP':
        return 'APBNP (APBN Perubahan)';
      case 'GABUNGAN_APBN_DAN_APBD':
      case 'GABUNGAN APBN DAN APBD':
        return 'Gabungan APBN dan APBD (Patungan Pusat & Daerah)';
      case 'PHLN':
        return 'PHLN (Pinjaman/Hibah Luar Negeri)';
      case 'PNBP':
        return 'PNBP (Penerimaan Negara Bukan Pajak)';
      case 'BLUD':
        return 'BLUD (Badan Layanan Umum Daerah)';
      case 'BLU':
        return 'BLU (Badan Layanan Umum Pusat)';
      case 'BUMD':
        return 'BUMD (Badan Usaha Milik Daerah)';
      case 'BUMN':
        return 'BUMN (Badan Usaha Milik Negara)';
      case 'LAINNYA':
        return 'Lainnya (Hibah/Dana Khusus)';
      default:
        return sd;
    }
  }
}

class _DetailItem {
  final String label;
  final String value;

  _DetailItem(this.label, this.value);
}
