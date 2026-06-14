import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import '../../data/models/paket_pengadaan.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../../utils/fuzzy_match.dart';
import '../beranda/beranda_provider.dart';
import 'chip_risiko.dart';

class DialogDetailPaket extends StatefulWidget {
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

  @override
  State<DialogDetailPaket> createState() => _DialogDetailPaketState();
}

class _DialogDetailPaketState extends State<DialogDetailPaket> {
  int _currentPage = 1;
  static const int _itemsPerPage = 5;

  Future<void> _bukaTautanSirup(BuildContext context) async {
    if (widget.paket.kodeRup.trim().isEmpty) return;

    final isSwakelola = widget.paket.caraPengadaan.toLowerCase().contains('swakelola');
    final String tipeSumber = isSwakelola ? "Swakelola" : "Penyedia";
    final String tahun = widget.paket.tahunAnggaran.trim().isNotEmpty
        ? widget.paket.tahunAnggaran.trim()
        : "2026";
    final String kodeRup = widget.paket.kodeRup.trim();

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
                  ChipRisiko(tingkat: widget.paket.tingkatKejanggalan),
                ],
              ),
              const Divider(height: 24, thickness: 0.5),

              // Paket Name (Highlighted)
              const Text("Nama Pekerjaan", style: TextStyle(fontSize: 11, color: Colors.black38)),
              const SizedBox(height: 4),
              Text(
                widget.paket.namaPaket,
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
                formatRupiah(widget.paket.totalNilai),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: warnaAksen,
                ),
              ),
              const SizedBox(height: 16),

              // Metadata Grid
              _buildGridDetail([
                _DetailItem("Kode RUP", widget.paket.kodeRup.isEmpty ? "-" : widget.paket.kodeRup),
                _DetailItem("Tahun Anggaran", widget.paket.tahunAnggaran.isEmpty ? "-" : widget.paket.tahunAnggaran),
                _DetailItem("Instansi", widget.paket.namaInstansi.isEmpty ? "-" : widget.paket.namaInstansi),
                _DetailItem("Satuan Kerja (SKPD)", widget.paket.namaSatuanKerja.isEmpty ? "-" : widget.paket.namaSatuanKerja),
                _DetailItem("Cara Pengadaan", widget.paket.caraPengadaan.isEmpty ? "-" : widget.paket.caraPengadaan),
                _DetailItem("Metode Pengadaan", widget.paket.metodePengadaan.isEmpty ? "-" : widget.paket.metodePengadaan),
                _DetailItem("Jenis Pengadaan", widget.paket.jenisPengadaan.isEmpty ? "-" : widget.paket.jenisPengadaan),
                _DetailItem("Sumber Dana", widget.paket.sumberDana.isEmpty ? "-" : _jelaskanSumberDana(widget.paket.sumberDana)),
              ]),

              const SizedBox(height: 16),

              // Catatan Kejanggalan (If Any)
              if (widget.paket.catatanKejanggalan.isNotEmpty) ...[
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
                    children: widget.paket.catatanKejanggalan.map((c) {
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

              // Paket Serupa List (If Any)
              _buildPaketSerupaSection(context),
              const SizedBox(height: 24),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Tutup"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  if (widget.paket.kodeRup.trim().isNotEmpty) ...[
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

  List<PaketPengadaan> _findPaketSerupa(BuildContext context) {
    try {
      final allPaket = Provider.of<BerandaProvider>(context, listen: false).paketList;
      final skpd = widget.paket.namaSatuanKerja.trim();
      final nama = widget.paket.namaPaket.trim().toLowerCase();

      return allPaket.where((p) {
        if (p.namaSatuanKerja.trim() != skpd || p == widget.paket) {
          return false;
        }
        final otherNama = p.namaPaket.trim().toLowerCase();
        return otherNama == nama || FuzzyMatch.jaroWinkler(otherNama, nama) >= 0.85;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  Widget _buildPaketSerupaSection(BuildContext context) {
    final paketSerupa = _findPaketSerupa(context);
    if (paketSerupa.isEmpty) return const SizedBox.shrink();

    final totalPages = (paketSerupa.length / _itemsPerPage).ceil();
    // In case the list changes or pages get out of sync, clamp it safely
    final currentPage = _currentPage.clamp(1, totalPages);
    
    final paginatedList = paketSerupa
        .skip((currentPage - 1) * _itemsPerPage)
        .take(_itemsPerPage)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Paket Serupa/Sama di Satuan Kerja Ini",
          style: TextStyle(fontSize: 11, color: Colors.black38),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    const Icon(Icons.layers_outlined, size: 18, color: warnaAksen),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Ditemukan ${paketSerupa.length} paket serupa (Nama mirip >= 85% atau identik)",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: warnaPrimer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, thickness: 0.5),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: paginatedList.length,
                separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
                itemBuilder: (context, index) {
                  final item = paginatedList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.pop(context); // Close current modal
                      Future.delayed(const Duration(milliseconds: 150), () {
                        if (context.mounted) {
                          DialogDetailPaket.tampilkan(context, item);
                        }
                      });
                    },
                    borderRadius: (index == paginatedList.length - 1 && totalPages <= 1)
                        ? const BorderRadius.vertical(bottom: Radius.circular(12))
                        : null,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.namaPaket,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: warnaPrimer,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      formatRupiah(item.totalNilai),
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: warnaAksen,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "•  ${item.metodePengadaan}",
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.black45,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              if (totalPages > 1) ...[
                const Divider(height: 1, thickness: 0.5),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: warnaPrimer,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: currentPage > 1
                            ? () {
                                setState(() {
                                  _currentPage = currentPage - 1;
                                });
                              }
                            : null,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 12),
                        label: const Text("Sebelumnya", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                      Text(
                        "Halaman $currentPage dari $totalPages",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.black54,
                        ),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: warnaPrimer,
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        ),
                        onPressed: currentPage < totalPages
                            ? () {
                                setState(() {
                                  _currentPage = currentPage + 1;
                                });
                              }
                            : null,
                        icon: const Text("Berikutnya", style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                        label: const Icon(Icons.arrow_forward_ios_rounded, size: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
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
      case 'GABUNGAN APBN AND APBD':
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
