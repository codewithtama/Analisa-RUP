import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'profil_skpd_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../widgets/chip_risiko.dart';
import '../widgets/dialog_detail_paket.dart';

class ProfilSkpdScreen extends StatelessWidget {
  final String namaSkpd;

  const ProfilSkpdScreen({super.key, required this.namaSkpd});

  @override
  Widget build(BuildContext context) {
    final allPakets = Provider.of<BerandaProvider>(context, listen: false).paketList;
    final TextEditingController searchController = TextEditingController();

    return ChangeNotifierProvider<ProfilSkpdProvider>(
      create: (context) => ProfilSkpdProvider()..inisialisasi(namaSkpd, allPakets),
      builder: (context, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Profil Satuan Kerja"),
          ),
          body: Consumer<ProfilSkpdProvider>(
            builder: (context, provider, child) {
              final model = provider.selectedSkpdModel;
              final list = provider.filteredList;

              Color rankColor = warnaNormal;
              if (model.skorKerawanan >= 10.0) {
                rankColor = warnaKritis;
              } else if (model.skorKerawanan >= 5.0) {
                rankColor = warnaTinggi;
              } else if (model.skorKerawanan >= 1.0) {
                rankColor = warnaWaspada;
              }

              return Column(
                children: [
                  // SKPD Header Card
                  _buildHeaderCard(model, provider.peringkat, provider.totalSkpd, rankColor),

                  // Risk counts summary row
                  _buildRiskCountsRow(model),

                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Cari paket kerja dinas ini...",
                        prefixIcon: const Icon(Icons.search_rounded, size: 20),
                        suffixIcon: searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  searchController.clear();
                                  provider.setSearchQuery("");
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onChanged: (val) {
                        provider.setSearchQuery(val);
                      },
                    ),
                  ),

                  // Packets List
                  Expanded(
                    child: list.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            itemCount: list.length,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemBuilder: (context, index) {
                              final paket = list[index];
                              return _buildPaketCard(context, paket);
                            },
                          ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildHeaderCard(model, int peringkat, int totalSkpd, Color rankColor) {
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: rankColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Peringkat $peringkat dari $totalSkpd",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: warnaPrimer.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "Skor: ${model.skorKerawanan.toStringAsFixed(0)}",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: warnaPrimer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              model.namaSkpd,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: warnaPrimer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Divider(height: 24, thickness: 0.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Total Anggaran SKPD",
                      style: TextStyle(fontSize: 11, color: Colors.black38),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(model.totalAnggaran),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: warnaAksen,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      "Jumlah Paket Kerja",
                      style: TextStyle(fontSize: 11, color: Colors.black38),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${model.totalPaket} Paket",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskCountsRow(model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          _buildCountBadge(warnaKritis, "Kritis", model.jumlahKritis),
          const SizedBox(width: 8),
          _buildCountBadge(warnaTinggi, "Tinggi", model.jumlahTinggi),
          const SizedBox(width: 8),
          _buildCountBadge(warnaWaspada, "Waspada", model.jumlahWaspada),
        ],
      ),
    );
  }

  Widget _buildCountBadge(Color color, String label, int count) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(
          children: [
            Text(
              "$count",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.black45, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaketCard(BuildContext context, dynamic paket) {
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
                        fontSize: 13,
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
              const SizedBox(height: 8),
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
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: warnaAksen,
                    ),
                  ),
                ],
              ),
              if (paket.catatanKejanggalan.isNotEmpty) ...[
                const Divider(height: 16, thickness: 0.5),
                ...paket.catatanKejanggalan.map((c) => Padding(
                      padding: const EdgeInsets.only(bottom: 2.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: warnaKritis),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              c,
                              style: const TextStyle(fontSize: 11, color: warnaKritis, height: 1.3),
                            ),
                          ),
                        ],
                      ),
                    )),
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
          Icon(Icons.search_off_rounded, size: 48, color: Colors.black26),
          SizedBox(height: 12),
          Text(
            "Tidak Ada Paket Yang Sesuai",
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          SizedBox(height: 4),
          Text(
            "Coba ketik kata kunci pencarian lainnya.",
            style: TextStyle(fontSize: 12, color: Colors.black38),
          ),
        ],
      ),
    );
  }
}
