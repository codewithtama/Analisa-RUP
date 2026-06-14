import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'ringkasan_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../widgets/kartu_kejanggalan.dart';
import '../widgets/skeleton_loader.dart';

class RingkasanScreen extends StatelessWidget {
  const RingkasanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final paketList = Provider.of<BerandaProvider>(context, listen: false).paketList;
    return ChangeNotifierProvider<RingkasanProvider>(
      create: (context) => RingkasanProvider()..hitungStatistik(paketList),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ringkasan Analisis"),
        ),
        body: Consumer2<RingkasanProvider, BerandaProvider>(
          builder: (context, ringkasanProv, berandaProv, child) {
            if (ringkasanProv.isProcessing || berandaProv.isLoading) {
              return _buildSkeleton();
            }

            if (berandaProv.paketList.isEmpty) {
              return const Center(
                child: Text("Tidak ada data. Impor file RUP terlebih dahulu."),
              );
            }

            final stats = berandaProv.hasilAnalisis;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kelompok A - Kartu Utama & Visualisasi
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Kelompok A — Visualisasi Data",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: warnaPrimer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Pie Chart Metode Pengadaan
                  _buildPieChartCard(
                    title: "Metode Pengadaan (Berdasarkan Jumlah Paket)",
                    dataList: ringkasanProv.metodeCount,
                  ),

                  // Pie Chart Sumber Dana
                  _buildPieChartCard(
                    title: "Sumber Dana (Berdasarkan Jumlah Paket)",
                    dataList: ringkasanProv.sumberDanaCount,
                  ),

                  // Pie Chart Jenis Pengadaan
                  _buildPieChartCard(
                    title: "Jenis Pengadaan (Berdasarkan Jumlah Paket)",
                    dataList: ringkasanProv.jenisPengadaanCount,
                  ),

                  // Bar Chart Top 5 SKPD
                  _buildBarChartCard(ringkasanProv),

                  const SizedBox(height: 24),

                  // Indeks Kerawanan Satuan Kerja (Leaderboard)
                  _buildLeaderboardSection(context, ringkasanProv),

                  const SizedBox(height: 24),

                  // Kelompok B - Ringkasan Kejanggalan
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      "Kelompok B — Temuan Kejanggalan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: warnaPrimer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),

                  ...stats.rincianKejanggalan.values.map((ringkasan) {
                    return KartuKejanggalan(
                      judul: ringkasan.namaKategori,
                      penjelasan: ringkasan.penjelasan,
                      jumlahTemuan: ringkasan.jumlahTemuan,
                      totalNilaiTerdampak: ringkasan.totalNilaiTerdampak,
                      tingkatRisiko: ringkasan.tingkatRisiko,
                      onTap: () {
                        context.push('/detail-kejanggalan/${ringkasan.namaKategori}');
                      },
                    );
                  }),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPieChartCard({
    required String title,
    required List<MapEntry<String, int>> dataList,
  }) {
    if (dataList.isEmpty) return const SizedBox.shrink();

    final List<MapEntry<String, int>> displayData = [];
    int otherCount = 0;
    for (int i = 0; i < dataList.length; i++) {
      if (i < 4) {
        displayData.add(dataList[i]);
      } else {
        otherCount += dataList[i].value;
      }
    }
    if (otherCount > 0) {
      displayData.add(MapEntry("Lainnya", otherCount));
    }

    final List<Color> colors = [
      warnaPrimer,
      warnaAksen,
      warnaNormal,
      warnaWaspada,
      warnaTinggi,
      Colors.purple,
      Colors.teal,
      Colors.grey,
    ];

    int total = displayData.fold(0, (sum, entry) => sum + entry.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: warnaPrimer),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 130,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 24,
                        sections: List.generate(displayData.length, (index) {
                          final entry = displayData[index];
                          final percentage = (entry.value / total) * 100;
                          return PieChartSectionData(
                            color: colors[index % colors.length],
                            value: entry.value.toDouble(),
                            title: "${percentage.toStringAsFixed(0)}%",
                            radius: 40,
                            titleStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(displayData.length, (index) {
                      final entry = displayData[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: colors[index % colors.length],
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "${entry.key} (${entry.value})",
                                style: const TextStyle(fontSize: 11, color: Colors.black87),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChartCard(RingkasanProvider provider) {
    if (provider.topSkpdBudget.isEmpty) return const SizedBox.shrink();

    double maxBudget = 1.0;
    for (final entry in provider.topSkpdBudget) {
      if (entry.totalAnggaran > maxBudget) {
        maxBudget = entry.totalAnggaran;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top 5 Satuan Kerja Anggaran Terbesar (Rasio Temuan vs Wajar)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: warnaPrimer),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: warnaNormal,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("Wajar", style: TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(width: 16),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: warnaKritis,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 6),
                const Text("Temuan Anomali", style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 20),
            ...List.generate(provider.topSkpdBudget.length, (index) {
              final entry = provider.topSkpdBudget[index];
              final ratioNormal = entry.anggaranNormal / maxBudget;
              final ratioBermasalah = entry.anggaranBermasalah / maxBudget;

              final normalPercent = entry.totalAnggaran > 0 ? (entry.anggaranNormal / entry.totalAnggaran * 100) : 0.0;
              final bermasalahPercent = entry.totalAnggaran > 0 ? (entry.anggaranBermasalah / entry.totalAnggaran * 100) : 0.0;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${index + 1}. ${entry.namaSkpd}",
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          "Total: ${formatRupiah(entry.totalAnggaran)}",
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: warnaPrimer,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final totalWidth = constraints.maxWidth;
                        final normalWidth = totalWidth * ratioNormal;
                        final bermasalahWidth = totalWidth * ratioBermasalah;

                        return Container(
                          height: 10,
                          width: totalWidth,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: Row(
                              children: [
                                if (entry.anggaranNormal > 0)
                                  Container(
                                    width: normalWidth.clamp(0.0, totalWidth),
                                    color: warnaNormal,
                                  ),
                                if (entry.anggaranBermasalah > 0)
                                  Container(
                                    width: bermasalahWidth.clamp(0.0, totalWidth),
                                    color: warnaKritis,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Wajar: ${formatRupiah(entry.anggaranNormal)} (${normalPercent.toStringAsFixed(1)}%)",
                          style: TextStyle(fontSize: 10, color: warnaNormal.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Temuan: ${formatRupiah(entry.anggaranBermasalah)} (${bermasalahPercent.toStringAsFixed(1)}%)",
                          style: TextStyle(fontSize: 10, color: warnaKritis.withValues(alpha: 0.8), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardSection(BuildContext context, RingkasanProvider provider) {
    final list = provider.skpdLeaderboard;
    if (list.isEmpty) return const SizedBox.shrink();

    // Limit display to top 10 on main ringkasan
    final limit = list.length > 10 ? 10 : list.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Indeks Kerawanan Satuan Kerja",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: warnaPrimer,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Peringkat Satuan Kerja (SKPD) paling rawan kejanggalan anggaran.",
                      style: TextStyle(fontSize: 12, color: Colors.black45),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () async {
                  final paketList = Provider.of<BerandaProvider>(context, listen: false).paketList;
                  final errorMsg = await provider.eksporLaporanTemuan(paketList);
                  if (!context.mounted) return;
                  if (errorMsg != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(errorMsg),
                        backgroundColor: errorMsg.contains("berhasil") ? warnaNormal : warnaKritis,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.download_rounded, size: 18),
                label: const Text("Ekspor CSV", style: TextStyle(fontSize: 12)),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 36),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: limit,
            separatorBuilder: (context, index) => const Divider(height: 1, thickness: 0.5),
            itemBuilder: (context, index) {
              final skpd = list[index];
              Color scoreColor = warnaNormal;
              if (skpd.skorKerawanan >= 10.0) {
                scoreColor = warnaKritis;
              } else if (skpd.skorKerawanan >= 5.0) {
                scoreColor = warnaTinggi;
              } else if (skpd.skorKerawanan >= 1.0) {
                scoreColor = warnaWaspada;
              }

              return ListTile(
                onTap: () {
                  context.push('/profil-skpd/${skpd.namaSkpd}');
                },
                leading: CircleAvatar(
                  backgroundColor: index == 0
                      ? warnaKritis
                      : (index < 3 ? warnaTinggi : warnaPrimer.withValues(alpha: 0.1)),
                  foregroundColor: index < 3 ? Colors.white : warnaPrimer,
                  radius: 16,
                  child: Text(
                    "${index + 1}",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Text(
                  skpd.namaSkpd,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: warnaPrimer),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Row(
                  children: [
                    Text(
                      "${skpd.totalPaket} paket",
                      style: const TextStyle(fontSize: 11, color: Colors.black45),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 4,
                      height: 4,
                      decoration: const BoxDecoration(color: Colors.black26, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        formatRupiah(skpd.totalAnggaran),
                        style: const TextStyle(fontSize: 11, color: Colors.black45),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "Skor: ${skpd.skorKerawanan.toStringAsFixed(0)}",
                    style: TextStyle(
                      color: scoreColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkeleton() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 12),
          const SkeletonLoader(width: double.infinity, height: 180),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 180),
          const SizedBox(height: 16),
          const SkeletonLoader(width: double.infinity, height: 220),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 12),
          ...List.generate(2, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: SkeletonLoader(width: double.infinity, height: 120),
          )),
        ],
      ),
    );
  }
}
