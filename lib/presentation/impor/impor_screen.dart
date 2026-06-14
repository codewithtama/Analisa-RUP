import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'impor_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';

class ImporScreen extends StatelessWidget {
  const ImporScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ImporProvider>(
      create: (context) => ImporProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Impor Berkas RUP"),
        ),
        body: Consumer2<ImporProvider, BerandaProvider>(
          builder: (context, imporProvider, berandaProvider, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  // Header Icon
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: warnaAksen.withValues(alpha: 0.05),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.file_copy_rounded,
                      size: 72,
                      color: warnaAksen,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Unggah Berkas Rencana Pengadaan",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: warnaPrimer,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Pilih berkas Excel (.xlsx) atau CSV (.csv) dari sistem Anda. Sistem akan secara otomatis menganalisis kejanggalan dalam berkas.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black45,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Import Progress
                  if (imporProvider.isImporting) ...[
                    _buildProgressWidget(imporProvider),
                  ] else ...[
                    // Selection Button
                    ElevatedButton.icon(
                      onPressed: () {
                        imporProvider.pilihDanImporBerkas(
                          context: context,
                          forceOverwrite: false,
                          currentPaketList: berandaProvider.paketList,
                          onImportCompleted: (newList) {
                            berandaProvider.updatePaketList(newList);
                          },
                        );
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: const Text("Pilih Berkas"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        minimumSize: const Size(220, 52),
                      ),
                    ),
                    _buildPresetList(context, imporProvider, berandaProvider),
                  ],

                  // Result Card
                  if (imporProvider.importResult != null) ...[
                    const SizedBox(height: 32),
                    _buildResultCard(context, imporProvider.importResult!),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPresetList(BuildContext context, ImporProvider provider, BerandaProvider berandaProvider) {
    final List<Map<String, String>> presets = [
      {"name": "ANRI", "path": "assets/dataRUP/RUP ARSIP NASIONAL REPUBLIK INDONESIA.xlsx"},
      {"name": "Badan Gizi", "path": "assets/dataRUP/RUP BADAN GIZI NASIONAL.xlsx"},
      {"name": "BIN", "path": "assets/dataRUP/RUP BADAN INTELIJEN NEGARA.xlsx"},
      {"name": "BNN", "path": "assets/dataRUP/RUP BADAN NARKOTIKA NASIONAL.xlsx"},
      {"name": "BPK", "path": "assets/dataRUP/RUP BADAN PEMERIKSA KEUANGAN.xlsx"},
      {"name": "BSSN", "path": "assets/dataRUP/RUP BADAN SIBER DAN SANDI NEGARA.xlsx"},
      {"name": "DPR", "path": "assets/dataRUP/RUP DEWAN PERWAKILAN RAKYAT.xlsx"},
      {"name": "Kemenkeu", "path": "assets/dataRUP/RUP KEMENTRIAN KEUANGAN.xlsx"},
      {"name": "Kemensetneg", "path": "assets/dataRUP/RUP KEMENTRIAN SEKRETARIAT NEGARA.xlsx"},
      {"name": "Polri", "path": "assets/dataRUP/RUP KEPOLISIAN REPUBLIK INDONESIA.xlsx"},
      {"name": "MPR", "path": "assets/dataRUP/RUP MAJELIS PERMUSYAWARATAN RAKYAT.xlsx"},
      {"name": "Tangsel", "path": "assets/dataRUP/RUP TANGSEL.xlsx"},
    ];

    return Column(
      children: [
        const SizedBox(height: 32),
        const Row(
          children: [
            Expanded(child: Divider()),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text("Atau Pilih Data RUP 2026", style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          alignment: WrapAlignment.center,
          children: presets.map((preset) => ActionChip(
            label: Text(preset["name"]!),
            avatar: const Icon(Icons.table_chart, size: 16, color: warnaAksen),
            backgroundColor: warnaAksen.withValues(alpha: 0.05),
            side: BorderSide(color: warnaAksen.withValues(alpha: 0.3)),
            onPressed: () {
              provider.muatDariPreset(
                context: context,
                assetPath: preset["path"]!,
                forceOverwrite: false,
                currentPaketList: berandaProvider.paketList,
                onImportCompleted: (newList) {
                  berandaProvider.updatePaketList(newList);
                },
              );
            },
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildProgressWidget(ImporProvider provider) {
    return Card(
      margin: EdgeInsets.zero,
      color: warnaLatarKartu,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: warnaPrimer,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Memproses Berkas...",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: warnaPrimer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: provider.progress,
              backgroundColor: Colors.grey.shade300,
              color: warnaAksen,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    provider.statusText,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black54,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "${(provider.progress * 100).toStringAsFixed(0)}%",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: warnaPrimer,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, importResult) {
    final bool isSuccess = importResult.isSuccess;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSuccess ? warnaNormal.withValues(alpha: 0.3) : warnaKritis.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isSuccess ? Icons.check_circle_rounded : Icons.error_rounded,
                  color: isSuccess ? warnaNormal : warnaKritis,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  isSuccess ? "Impor Berhasil" : "Impor Gagal",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? warnaNormal : warnaKritis,
                  ),
                ),
              ],
            ),
            const Divider(height: 24, thickness: 0.5),
            if (isSuccess) ...[
              Text(
                "Berhasil memuat ${importResult.paketList.length} paket dari ${importResult.jumlahSatuanKerja} satuan kerja. Ditemukan ${importResult.jumlahKejanggalan} kejanggalan.",
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      child: const Text("Ke Beranda"),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      child: const Text("Hasil Analisis"),
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to Ringkasan
                        GoRouter.of(context).push('/ringkasan');
                      },
                    ),
                  ),
                ],
              ),
            ] else ...[
              Text(
                importResult.errorMessage,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Format file tidak dikenali. Pastikan file berasal dari SIRUP atau memiliki kolom: Nama Paket, Metode Pengadaan, Total Nilai.",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black45,
                  height: 1.3,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
