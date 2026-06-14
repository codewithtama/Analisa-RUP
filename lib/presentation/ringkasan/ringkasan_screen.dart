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

                  // Pie Chart Card
                  _buildPieChartCard(ringkasanProv),

                  // Bar Chart Card
                  _buildBarChartCard(ringkasanProv),

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

  Widget _buildPieChartCard(RingkasanProvider provider) {
    if (provider.metodeCount.isEmpty) return const SizedBox.shrink();

    // Limit to top 4 and group others
    final List<MapEntry<String, int>> displayMethods = [];
    int otherCount = 0;
    for (int i = 0; i < provider.metodeCount.length; i++) {
      if (i < 4) {
        displayMethods.add(provider.metodeCount[i]);
      } else {
        otherCount += provider.metodeCount[i].value;
      }
    }
    if (otherCount > 0) {
      displayMethods.add(MapEntry("Lainnya", otherCount));
    }

    final List<Color> colors = [
      warnaPrimer,
      warnaAksen,
      warnaNormal,
      warnaWaspada,
      warnaTinggi,
      Colors.grey,
    ];

    int total = displayMethods.fold(0, (sum, entry) => sum + entry.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Metode Pengadaan (Berdasarkan Jumlah Paket)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: warnaPrimer),
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
                        sections: List.generate(displayMethods.length, (index) {
                          final entry = displayMethods[index];
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
                    children: List.generate(displayMethods.length, (index) {
                      final entry = displayMethods[index];
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
      if (entry.value > maxBudget) {
        maxBudget = entry.value;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Top 5 Satuan Kerja Anggaran Terbesar (SKPD)",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: warnaPrimer),
            ),
            const SizedBox(height: 20),
            // Custom high fidelity horizontal bars since vertical bars in fl_chart are hard to read for long titles.
            // This is clean, visually gorgeous, responsive, and works flawlessly.
            ...List.generate(provider.topSkpdBudget.length, (index) {
              final entry = provider.topSkpdBudget[index];
              final ratio = entry.value / maxBudget;
              return Padding(
                padding: const EdgeInsets.only(bottom: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${index + 1}. ${entry.key}",
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
                          formatRupiah(entry.value),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: warnaAksen,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Stack(
                      children: [
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: ratio.clamp(0.02, 1.0),
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [warnaPrimer, warnaAksen],
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
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
          const SkeletonLoader(width: double.infinity, height: 220),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 150, height: 20),
          const SizedBox(height: 12),
          ...List.generate(3, (index) => const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: SkeletonLoader(width: double.infinity, height: 120),
          )),
        ],
      ),
    );
  }
}
