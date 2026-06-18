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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Column(
          children: [
            Text(
              'Pantau RUP',
              style: TextStyle(
                color: warnaPrimer,
                fontWeight: FontWeight.w800,
                fontSize: 22,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Analisis pengadaan yang lebih rapi, cepat, dan bisa dipertanggungjawabkan.',
              style: TextStyle(fontSize: 12, color: Colors.black54, height: 1.45),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Aplikasi ini dirancang khusus bagi aktivis dan masyarakat umum untuk mengawal transparansi anggaran Rencana Umum Pengadaan (RUP) tingkat Kementerian, Lembaga, dan Pemerintah Daerah (K/L/PD) Republik Indonesia secara mandiri dan offline.',
              style: TextStyle(fontSize: 13, height: 1.55),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Divider(height: 1),
            SizedBox(height: 12),
            Text(
              'Pengembang Aplikasi:',
              style: TextStyle(fontSize: 11, color: Colors.black45),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4),
            Text(
              'Dimas Alfa Pratama',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: warnaAksen,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          OutlinedButton.icon(
            icon: const Icon(Icons.favorite_rounded, color: warnaKritis, size: 18),
            label: const Text('Donasi', style: TextStyle(color: warnaKritis)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: warnaKritis),
            ),
            onPressed: _tampilkanDonasiDialog,
          ),
          ElevatedButton(
            child: const Text('Lanjutkan'),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Donasi Dukungan',
          style: TextStyle(color: warnaPrimer, fontWeight: FontWeight.w800, fontSize: 22),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Pindai QR Code di bawah menggunakan aplikasi e-wallet Anda (DANA, OVO, GoPay, LinkAja, dll) untuk memberikan dukungan donasi.',
              style: TextStyle(fontSize: 12, height: 1.55),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/DonasiDANA/WhatsApp Image 2026-06-14 at 18.34.53.jpeg',
                height: 250,
                width: 250,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Terima kasih atas kontribusi Anda!',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: warnaAksen),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Tutup'),
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
        title: const Text('Pantau RUP'),
        actions: [
          IconButton(
            icon: const Icon(Icons.gavel_rounded),
            tooltip: 'Kamus Hukum Pengadaan',
            onPressed: () => context.push('/kamus-hukum'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Pengaturan Analisis',
            onPressed: () => context.push('/pengaturan'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Muat Ulang Data',
            onPressed: () {
              Provider.of<BerandaProvider>(context, listen: false).loadData();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Hapus Semua Data',
            onPressed: () => _konfirmasiHapus(context),
          ),
        ],
      ),
      backgroundColor: warnaLatarBelakang,
      body: Consumer<BerandaProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildSkeleton();
          }

          if (provider.paketList.isEmpty) {
            return KosongPlaceholder(
              actionLabel: 'Mulai',
              onActionPressed: () => context.push('/impor'),
            );
          }

          final stats = provider.hasilAnalisis;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF4F7FB),
                  Color(0xFFEEF3FA),
                  Color(0xFFF9FBFD),
                ],
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroSection(context, stats),
                  const SizedBox(height: 16),
                  const Text(
                    'Statistik Utama',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: warnaPrimer,
                    ),
                  ),
                  const SizedBox(height: 12),
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
                              label: 'Total Nilai Anggaran',
                              nilai: formatRupiah(stats.totalAnggaran),
                              ikon: Icons.monetization_on_outlined,
                              warnaIkon: warnaAksen,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: KartuStatistik(
                              label: 'Total Paket Kerja',
                              nilai: '${stats.totalPaket} Paket',
                              ikon: Icons.work_outline_rounded,
                              warnaIkon: warnaPrimer,
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: KartuStatistik(
                              label: 'Satuan Kerja (SKPD)',
                              nilai: '${stats.totalSatuanKerja} SKPD',
                              ikon: Icons.business_outlined,
                              warnaIkon: warnaNormal,
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  const Text(
                    'Tingkat Kejanggalan Anggaran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: warnaPrimer,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRiskSummaryCard(stats),
                  const SizedBox(height: 20),
                  _buildInsightBanner(context),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () => context.push('/daftar-paket'),
                      icon: const Icon(Icons.list_alt_rounded, color: warnaPrimer),
                      label: const Text(
                        'Lihat Semua Paket Kerja',
                        style: TextStyle(color: warnaPrimer, fontWeight: FontWeight.bold),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        minimumSize: const Size(double.infinity, 48),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context, dynamic stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0D1B4C),
            Color(0xFF163B8A),
            Color(0xFF1C5DB6),
          ],
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: warnaPrimer.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -18,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          Positioned(
            left: -24,
            bottom: -36,
            child: Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.06),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.10),
                        ),
                      ),
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Pantau RUP',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          ),
                          Text(
                            'Audit pengadaan dengan tampilan yang lebih profesional.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.88),
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  'Status Pengadaan Nasional (K/L/PD)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.94),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Ringkasan rencana umum pengadaan berdasarkan analisis data terbaru.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _buildHeroStatChip(
                      icon: Icons.bar_chart_rounded,
                      label: '${stats.totalPaket} paket',
                    ),
                    _buildHeroStatChip(
                      icon: Icons.apartment_rounded,
                      label: '${stats.totalSatuanKerja} SKPD',
                    ),
                    _buildHeroStatChip(
                      icon: Icons.notifications_active_outlined,
                      label: '${stats.totalKritis + stats.totalTinggi} prioritas',
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push('/impor'),
                        icon: const Icon(Icons.file_upload_outlined),
                        label: const Text('Impor Data'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: warnaPrimer,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.push('/ringkasan'),
                        icon: const Icon(Icons.analytics_outlined),
                        label: const Text('Ringkasan'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white, width: 1.2),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroStatChip({required IconData icon, required String label}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: warnaPrimer,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _QuickActionChip(
              icon: Icons.description_outlined,
              label: 'Impor',
              onTap: () => context.push('/impor'),
            ),
            _QuickActionChip(
              icon: Icons.analytics_outlined,
              label: 'Ringkasan',
              onTap: () => context.push('/ringkasan'),
            ),
            _QuickActionChip(
              icon: Icons.list_alt_rounded,
              label: 'Daftar Paket',
              onTap: () => context.push('/daftar-paket'),
            ),
            _QuickActionChip(
              icon: Icons.gavel_rounded,
              label: 'Kamus Hukum',
              onTap: () => context.push('/kamus-hukum'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInsightBanner(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              const Color(0xFFEAF1FF),
            ],
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: warnaAksen.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.insights_outlined,
                color: warnaAksen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tinjau pola risiko yang paling dominan.',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      color: warnaPrimer,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Masuk ke ringkasan untuk melihat sebaran metode, sumber dana, dan titik rawan pengadaan.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            TextButton(
              onPressed: () => context.push('/ringkasan'),
              child: const Text('Buka'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskSummaryCard(stats) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
        child: Column(
          children: [
            _buildRiskRow(
              color: warnaKritis,
              label: 'Perlu Perhatian Segera',
              count: stats.totalKritis,
              onTap: () => context.push('/daftar-paket?tingkat=3'),
            ),
            const Divider(height: 1, thickness: 0.5),
            _buildRiskRow(
              color: warnaTinggi,
              label: 'Perlu Diperiksa',
              count: stats.totalTinggi,
              onTap: () => context.push('/daftar-paket?tingkat=2'),
            ),
            const Divider(height: 1, thickness: 0.5),
            _buildRiskRow(
              color: warnaWaspada,
              label: 'Pantau',
              count: stats.totalWaspada,
              onTap: () => context.push('/daftar-paket?tingkat=1'),
            ),
            const Divider(height: 1, thickness: 0.5),
            _buildRiskRow(
              color: warnaNormal,
              label: 'Wajar',
              count: stats.totalNormal,
              onTap: () => context.push('/daftar-paket?tingkat=0'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskRow({
    required Color color,
    required String label,
    required int count,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
        child: Row(
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
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.18),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
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
            Row(
              children: [
                Text(
                  '$count paket',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: count > 0 ? color : Colors.black38,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.black26,
                ),
              ],
            ),
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        title: const Text(
          'Hapus Semua Data',
          style: TextStyle(fontWeight: FontWeight.w800, color: warnaPrimer),
        ),
        content: const Text(
          'Apakah Anda yakin ingin menghapus seluruh data yang tersimpan? Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            child: const Text('Batal', style: TextStyle(color: Colors.black54)),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: warnaKritis),
            child: const Text('Hapus'),
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

class _QuickActionChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.blueGrey.shade100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: warnaPrimer),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: warnaPrimer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
