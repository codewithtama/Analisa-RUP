import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pengaturan_provider.dart';
import '../beranda/beranda_provider.dart';
import '../../app/theme.dart';

class PengaturanScreen extends StatefulWidget {
  const PengaturanScreen({super.key});

  @override
  State<PengaturanScreen> createState() => _PengaturanScreenState();
}

class _PengaturanScreenState extends State<PengaturanScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final berandaProvider = Provider.of<BerandaProvider>(context, listen: false);

    return ChangeNotifierProvider<PengaturanProvider>(
      create: (context) => PengaturanProvider(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pengaturan Analisis"),
        ),
        body: Consumer<PengaturanProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const LinearProgressIndicator(color: warnaAksen);
            }

            return Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (provider.isSaving) ...[
                      const LinearProgressIndicator(color: warnaAksen),
                      const SizedBox(height: 16),
                    ],
                    const Text(
                      "Kalkulator Regulasi Pengadaan",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: warnaPrimer,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Sesuaikan batas nominal peraturan pengadaan barang/jasa pemerintah. Nilai ini akan digunakan untuk mendeteksi potensi pemecahan paket dan penunjukan langsung bernilai besar secara otomatis.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Card Batas Pengadaan Langsung
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Batas Pengadaan Langsung (PL)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: warnaPrimer,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Batas nominal maksimal untuk metode Pengadaan Langsung. Paket non-tender sejenis yang diakumulasikan melebihi batas ini akan memicu indikasi pemecahan paket pekerjaan.",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: provider.controllerPL,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: "Rp ",
                                labelText: "Nominal Batas PL",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Batas nominal PL tidak boleh kosong";
                                }
                                final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), ''));
                                if (parsed == null || parsed <= 0) {
                                  return "Masukkan nilai angka positif yang valid";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Default: Rp200.000.000 (Dua Ratus Juta Rupiah)",
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Card Batas Penunjukan Langsung
                    Card(
                      margin: EdgeInsets.zero,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(color: Colors.grey.shade200),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Batas Penunjukan Langsung (PenL)",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: warnaPrimer,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              "Batas nominal maksimal yang diperbolehkan untuk Penunjukan Langsung secara regulasi umum (keadaan tertentu).",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black45,
                                height: 1.3,
                              ),
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: provider.controllerPenunjukan,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                prefixText: "Rp ",
                                labelText: "Nominal Batas PenL",
                              ),
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return "Batas nominal Penunjukan Langsung tidak boleh kosong";
                                }
                                final parsed = double.tryParse(value.replaceAll(RegExp(r'[^0-9.-]'), ''));
                                if (parsed == null || parsed <= 0) {
                                  return "Masukkan nilai angka positif yang valid";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Default: Rp500.000.000 (Lima Ratus Juta Rupiah)",
                              style: TextStyle(
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    ElevatedButton(
                      onPressed: provider.isSaving
                          ? null
                          : () async {
                              if (_formKey.currentState?.validate() ?? false) {
                                final success = await provider.simpanPengaturan(berandaProvider);
                                if (!context.mounted) return;
                                
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Pengaturan berhasil disimpan dan seluruh paket dianalisis ulang"),
                                      backgroundColor: warnaNormal,
                                    ),
                                  );
                                  Navigator.pop(context);
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Gagal menyimpan pengaturan. Pastikan format angka benar."),
                                      backgroundColor: warnaKritis,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 52),
                      ),
                      child: Text(provider.isSaving ? "Menyimpan & Menganalisis..." : "Simpan & Terapkan"),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
