import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'beranda_provider.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';
import '../widgets/kartu_statistik.dart';
import '../widgets/kosong_placeholder.dart';
import '../widgets/skeleton_loader.dart';

class BerandaScreen extends StatefulWidget {
  const BerandaScreen({super.key});

  @override
  State<BerandaScreen> createState() => _BerandaScreenState();
}

class _BerandaScreenState extends State<BerandaScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tampilkanWelcomeDialog();
    });
  }

  void _tampilkanWelcomeDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Pantau RUP",
          style: TextStyle(
            color: warnaPrimer,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Aplikasi ini dirancang khusus bagi aktivis dan masyarakat umum untuk mengawal transparansi anggaran Rencana Umum Pengadaan (RUP) tingkat Kementerian, Lembaga, dan Pemerintah Daerah (K/L/PD) Republik Indonesia secara mandiri dan offline.",
              style: TextStyle(fontSize: 13, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, thickness: 0.5),
            const SizedBox(height: 12),
            const Text(
              "Pengembang Aplikasi:",
              style: TextStyle(fontSize: 11, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            const Text(
              "Dimas Alfa Pratama",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: warnaAksen,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.favorite_rounded, color: warnaKritis, size: 18),
            label: const Text("Donasi", style: TextStyle(color: warnaKritis)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: warnaKritis),
            ),
            onPressed: () {
              _tampilkanDonasiDialog();
            },
          ),
          ElevatedButton(
            child: const Text("Lanjutkan"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  void _tampilkanDonasiDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          "Donasi Dukungan",
          style: TextStyle(color: warnaPrimer, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Pindai QR Code di bawah menggunakan aplikasi e-wallet Anda (DANA, OVO, GoPay, LinkAja, dll) untuk memberikan dukungan donasi.",
              style: TextStyle(fontSize: 12, height: 1.4),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                "assets/DonasiDANA/WhatsApp Image 2026-06-14 at 18.34.53.jpeg",
                height: 250,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "Terima kasih atas kontribusi Anda!",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: warnaAksen),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text("Tutup"),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pantau RUP"),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: "Pengaturan Analisis",
            onPressed: () {
              context.push('/pengaturan');
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Muat Ulang Data",
            onPressed: () {
              Provider.of<BerandaProvider>(context, listen: false).loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: "Hapus Semua Data",
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      body: Consumer<BerandaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildSkeleton();
          }

          if (provider.paketList.isEmpty) {
            return KosongPlaceholder(
              actionLabel: "Impor Data Baru",
              onActionPressed: () => context.push('/impor'),
            );
          }

          final stats = provider.hasilAnalisis;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome and introduction
                const Text(
                  "Status Pengadaan Nasional (K/L/PD)",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: warnaPrimer,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  "Ringkasan rencana umum pengadaan berdasarkan analisis data terbaru.",
                  style: TextStyle(fontSize: 13, color: Colors.black54),
                ),
                const SizedBox(height: 16),

                // Statistics Grid
                LayoutBuilder(
                  builder: (context, constraints) {
                    final itemWidth = (constraints.maxWidth - 16) / 2;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        SizedBox(
                          width: constraints.maxWidth,
                          child: KartuStatistik(
                            label: "Total Nilai Anggaran",
                            nilai: formatRupiah(stats.totalAnggaran),
                            ikon: Icons.monetization_on_outlined,
                            warnaIkon: warnaAksen,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: KartuStatistik(
                            label: "Total Paket Kerja",
                            nilai: "${stats.totalPaket} Paket",
                            ikon: Icons.work_outline_rounded,
                            warnaIkon: warnaPrimer,
                          ),
                        ),
                        SizedBox(
                          width: itemWidth,
                          child: KartuStatistik(
                            label: "Satuan Kerja (SKPD)",
                            nilai: "${stats.totalSatuanKerja} SKPD",
                            ikon: Icons.business_outlined,
                            warnaIkon: warnaNormal,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),

                // Alarm / Risk Summary Category card
                const Text(
                  "Tingkat Kejanggalan Anggaran",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: warnaPrimer,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRiskSummaryCard(stats),

                const SizedBox(height: 28),

                // Big action buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/impor'),
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text("Impor Data"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/ringkasan'),
                        icon: const Icon(Icons.analytics_outlined),
                        label: const Text("Hasil Analisis"),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => context.push('/daftar-paket'),
                    icon: const Icon(Icons.list_alt_rounded, color: warnaPrimer),
                    label: const Text(
                      "Lihat Semua Paket Kerja",
                      style: TextStyle(color: warnaPrimer, fontWeight: FontWeight.bold),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRiskSummaryCard(stats) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildRiskRow(
              color: warnaKritis,
              label: "Perlu Perhatian Segera",
              count: stats.totalKritis,
            ),
            const Divider(height: 20, thickness: 0.5),
            _buildRiskRow(
              color: warnaTinggi,
              label: "Perlu Diperiksa",
              count: stats.totalTinggi,
            ),
            const Divider(height: 20, thickness: 0.5),
            _buildRiskRow(
              color: warnaWaspada,
              label: "Pantau",
              count: stats.totalWaspada,
            ),
            const Divider(height: 20, thickness: 0.5),
            _buildRiskRow(
              color: warnaNormal,
              label: "Wajar",
              count: stats.totalNormal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRow({required Color color, required String label, required int count}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        Text(
          "$count paket",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: count > 0 ? color : Colors.black38,
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
          const SkeletonLoader(width: 200, height: 24),
          const SizedBox(height: 8),
          const SkeletonLoader(width: 300, height: 16),
          const SizedBox(height: 24),
          const SkeletonLoader(width: double.infinity, height: 100),
          const SizedBox(height: 16),
          const Row(
            children: [
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80)),
              SizedBox(width: 16),
              Expanded(child: SkeletonLoader(width: double.infinity, height: 80)),
            ],
          ),
          const SizedBox(height: 24),
          const SkeletonLoader(width: 200, height: 20),
          const SizedBox(height: 12),
          const SkeletonLoader(width: double.infinity, height: 200),
          const SizedBox(height: 24),
          const Row(
            children: [
              Expanded(child: SkeletonLoader(width: double.infinity, height: 50)),
              SizedBox(width: 12),
              Expanded(child: SkeletonLoader(width: double.infinity, height: 50)),
            ],
          ),
        ],
      ),
    );
  }

  void _konfirmasiHapus(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        scrollable: true,
        title: const Text("Hapus Semua Data"),
        content: const Text(
          "Apakah Anda yakin ingin menghapus seluruh data yang tersimpan? Tindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            child: const Text("Batal", style: TextStyle(color: Colors.black54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: warnaKritis),
            child: const Text("Hapus"),
            onPressed: () {
              Provider.of<BerandaProvider>(context, listen: false).hapusSemuaData();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
