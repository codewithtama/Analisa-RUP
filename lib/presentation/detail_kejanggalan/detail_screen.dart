import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'detail_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../../utils/kejanggalan_helper.dart';
import '../widgets/chip_risiko.dart';
import '../widgets/dialog_detail_paket.dart';

class DetailScreen extends StatelessWidget {
  final String kategori;

  const DetailScreen({super.key, required this.kategori});

  @override
  Widget build(BuildContext context) {
    final list = Provider.of<BerandaProvider>(context, listen: false).paketList;
    return ChangeNotifierProvider<DetailProvider>(
      create: (context) => DetailProvider()..inisialisasi(kategori, list),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Detail Kejanggalan"),
            actions: [
              Consumer<DetailProvider>(
                builder: (context, provider, child) {
                  return IconButton(
                    icon: const Icon(Icons.share_rounded),
                    tooltip: "Bagikan Laporan",
                    onPressed: provider.filteredPakets.isEmpty
                        ? null
                        : () => provider.bagikanLaporan(kategori),
                  );
                },
              ),
            ],
          ),
          body: Consumer<DetailProvider>(
            builder: (context, provider, child) {
              final list = provider.visibleList;

              return Column(
                children: [
                  // Premium Header Card
                  _buildHeaderCard(provider),

                  // List title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Daftar Temuan (${provider.totalCount} Paket)",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: warnaPrimer,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Packets List
                  Expanded(
                    child: list.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: list.length + (provider.hasMore ? 1 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemBuilder: (context, index) {
                              if (index < list.length) {
                                final paket = list[index];
                                return _buildPaketCard(context, paket);
                              } else {
                                return _buildLoadMoreWidget(provider);
                              }
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          // Share floating action button
          floatingActionButton: Consumer<DetailProvider>(
            builder: (context, provider, child) {
              if (provider.filteredPakets.isEmpty) return const SizedBox.shrink();
              return FloatingActionButton.extended(
                onPressed: () => provider.bagikanLaporan(kategori),
                backgroundColor: warnaPrimer,
                foregroundColor: Colors.white,
                icon: const Icon(Icons.share_rounded),
                label: const Text("Bagikan Laporan"),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(DetailProvider provider) {
    final catId = KejanggalanHelper.mapKategoriToId(kategori);
    final url = catId != null ? KejanggalanHelper.regulasiUrls[catId] : null;

    return Card(
      margin: const EdgeInsets.all(16.0),
      color: Colors.white,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: warnaPrimer.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              kategori,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: warnaPrimer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.penjelasanKategori,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.black54,
                height: 1.4,
              ),
            ),
            if (url != null) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () async {
                  try {
                    final uri = Uri.parse(url);
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  } catch (e) {
                    debugPrint("Gagal membuka tautan regulasi: $e");
                  }
                },
                borderRadius: BorderRadius.circular(4),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.gavel_rounded, size: 14, color: warnaAksen),
                      SizedBox(width: 6),
                      Text(
                        "Baca Regulasi Resmi di JDIH BPK",
                        style: TextStyle(
                          fontSize: 12,
                          color: warnaAksen,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total Nilai Terdampak:",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black45,
                  ),
                ),
                Text(
                  formatRupiah(provider.totalNilaiTerdampak),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: warnaKritis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaketCard(BuildContext context, dynamic paket) {
    // Extract specific warning for this category
    String warningNote = "";
    final catId = KejanggalanHelper.mapKategoriToId(kategori);
    if (catId != null) {
      for (final note in paket.catatanKejanggalan) {
        if (KejanggalanHelper.matches(note, catId)) {
          warningNote = KejanggalanHelper.clean(note);
          break;
        }
      }
    }

    if (warningNote.isEmpty && paket.catatanKejanggalan.isNotEmpty) {
      warningNote = KejanggalanHelper.clean(paket.catatanKejanggalan.first);
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => DialogDetailPaket.tampilkan(context, paket),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      paket.namaPaket,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: warnaPrimer,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ChipRisiko(tingkat: paket.tingkatKejanggalan),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                "Kode RUP: ${paket.kodeRup.isEmpty ? '-' : paket.kodeRup}",
                style: const TextStyle(fontSize: 11, color: warnaAksen, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "SKPD: ${paket.namaSatuanKerja}",
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Metode: ${paket.metodePengadaan}",
                    style: const TextStyle(fontSize: 11, color: Colors.black38),
                  ),
                  Text(
                    formatRupiah(paket.totalNilai),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: warnaAksen,
                    ),
                  ),
                ],
              ),
              if (warningNote.isNotEmpty) ...[
                const Divider(height: 16, thickness: 0.5),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 16, color: warnaKritis),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        warningNote,
                        style: const TextStyle(
                          fontSize: 12,
                          color: warnaKritis,
                          fontWeight: FontWeight.w600,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline_rounded, size: 48, color: warnaNormal),
          SizedBox(height: 12),
          Text(
            "Tidak Ada Temuan",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          SizedBox(height: 4),
          Text(
            "Seluruh paket kerja wajar dalam kategori ini.",
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMoreWidget(DetailProvider provider) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "Menampilkan ${provider.visibleList.length} dari ${provider.totalCount} paket",
            style: const TextStyle(fontSize: 12, color: Colors.black45),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () {
              provider.loadMore();
            },
            child: const Text("Muat Lebih Banyak"),
          ),
        ],
      ),
    );
  }
}
