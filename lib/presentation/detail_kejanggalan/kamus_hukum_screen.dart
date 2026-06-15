import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/theme.dart';
import '../../utils/kejanggalan_helper.dart';

class KamusHukumScreen extends StatelessWidget {
  const KamusHukumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kamus Hukum Pengadaan"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildIntroductionCard(),
            const SizedBox(height: 20),
            
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
              child: Text(
                "Panduan Rujukan Pasal & Modus Pelanggaran",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: warnaPrimer,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Legal Categories List
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idPenunjukanBesar,
              judul: "Penunjukan Langsung Nilai Besar",
              risiko: "Tingkat Risiko: Waspada - Kritis (Sesuai Nilai)",
              warnaRisiko: warnaTinggi,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 38",
              deskripsi: "Metode Penunjukan Langsung untuk barang, pekerjaan konstruksi, atau jasa lainnya secara umum dibatasi maksimal Rp 200 Juta (atau Rp 500 Juta untuk jasa konsultansi).\n\nPenunjukan langsung di atas batas tersebut hanya diperbolehkan dalam keadaan tertentu yang sangat khusus (seperti pertahanan negara, bencana alam, pemegang hak paten tunggal, atau kelanjutan sewa). Penggunaan metode ini untuk paket bernilai besar tanpa pemenuhan kriteria khusus tersebut merupakan indikasi pelanggaran prosedur lelang.",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idMendekatiBatasPL,
              judul: "Mendekati Batas Pengadaan Langsung",
              risiko: "Tingkat Risiko: Waspada - Kritis (Sesuai Batas)",
              warnaRisiko: warnaWaspada,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 38 Ayat (3)",
              deskripsi: "Pengadaan Langsung adalah metode non-tender untuk paket bernilai maksimal Rp 200 Juta.\n\nMembuat paket non-tender dengan nilai yang sengaja diletakkan di batas atas (misal: Rp 190 Juta - Rp 199 Juta) secara berulang mengindikasikan adanya upaya menghindari metode Lelang/Tender umum yang wajib dilakukan untuk paket dengan pagu di atas Rp 200 Juta agar paket bisa langsung ditunjuk ke rekanan tertentu.",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idNamaBerulangSkpd,
              judul: "Nama Paket Identik Berulang di SKPD",
              risiko: "Tingkat Risiko: Waspada - Kritis",
              warnaRisiko: warnaTinggi,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 20 Ayat (2) Huruf d",
              deskripsi: "Pengguna Anggaran (PA) dilarang memecah pengadaan barang/jasa menjadi beberapa paket dengan tujuan menghindari pelelangan umum.\n\nModus ini terdeteksi ketika nama paket yang persis sama dianggarkan berulang kali (lebih dari 3 kali) di dinas/SKPD yang sama, yang mengindikasikan satu pekerjaan utuh sengaja dibagi-bagi menjadi paket kecil non-tender.",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idNamaBerulangLintas,
              judul: "Nama Paket Berulang Lintas SKPD",
              risiko: "Tingkat Risiko: Pantau",
              warnaRisiko: warnaNormal,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 6 (Prinsip Efisiensi)",
              deskripsi: "Pengadaan Barang/Jasa Pemerintah harus menerapkan prinsip efisiensi keuangan negara.\n\nKetika paket dengan nama barang sejenis (seperti belanja lisensi perangkat lunak atau ATK standar) dibeli secara eceran oleh banyak SKPD secara terpisah, hal ini mengakibatkan pemborosan anggaran. Seharusnya paket-paket tersebut dikonsolidasikan/digabungkan agar pemda mendapatkan harga grosir (volume discount).",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idNilaiSangatKecil,
              judul: "Nilai Anggaran Paket Sangat Kecil",
              risiko: "Tingkat Risiko: Waspada - Kritis",
              warnaRisiko: warnaWaspada,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 6 (Efisiensi & Efektivitas)",
              deskripsi: "Setiap paket pengadaan menuntut biaya administrasi perencanaan, pelaporan, pengawasan, hingga serah terima barang.\n\nPaket dengan nilai pagu di bawah Rp 1 Juta (terlebih yang hanya bernilai ribuan rupiah) menunjukkan buruknya manajemen perencanaan pengadaan, karena biaya proses birokrasi pengadaan bisa lebih mahal dibanding nilai barang yang didapatkan.",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idNamaSerupaSkpd,
              judul: "Pola Paket Nama Serupa di SKPD",
              risiko: "Tingkat Risiko: Perlu Diperiksa - Perlu Perhatian Segera",
              warnaRisiko: warnaTinggi,
              regulasi: "Perpres No. 12 Tahun 2021 Pasal 20 Ayat (2) Huruf d",
              deskripsi: "Kemiripan nama paket di atas 85% pada dinas/SKPD yang sama dalam jumlah yang masif (30 paket atau lebih) mengindikasikan adanya pemecahan anggaran secara sengaja.\n\nHal ini merupakan variasi modus pemecahan paket di mana pelaku mengganti sedikit kata di nama paket (misal: 'Belanja ATK Bagian A', 'Belanja ATK Bagian B') agar tidak terdeteksi sebagai paket identik.",
            ),
            _buildHukumTile(
              context: context,
              catId: KejanggalanHelper.idPecahPaketTender,
              judul: "Indikasi Pemecahan Paket Mengindari Tender",
              risiko: "Tingkat Risiko: Perlu Perhatian Segera (Kritis)",
              warnaRisiko: warnaKritis,
              regulasi: "Perpres No. 12/2021 Pasal 20 Ayat (2) Huruf d jo. UU No. 20/2001 Pasal 2 & 3",
              deskripsi: "Pelanggaran serius di mana pekerjaan sejenis non-tender (Pengadaan Langsung/Penunjukan Langsung) dipecah-pecah sehingga nilai masing-masing di bawah Rp 200 Juta, namun jika diakumulasikan totalnya melebihi batas lelang umum.\n\nSecara hukum, unsur kesengajaan memecah paket untuk menghindari tender kompetitif dan mengarahkan proyek ke kontraktor tertentu dapat dikategorikan sebagai penyalahgunaan wewenang yang merugikan keuangan negara (Tindak Pidana Korupsi).",
            ),
            
            const SizedBox(height: 24),
            _buildFooterInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroductionCard() {
    return Card(
      margin: EdgeInsets.zero,
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: warnaPrimer.withValues(alpha: 0.1), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.gavel_rounded, color: warnaPrimer, size: 24),
                const SizedBox(width: 8),
                const Text(
                  "Mengapa Regulasi Ini Penting?",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: warnaPrimer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              "Pengadaan Barang/Jasa Pemerintah (PBJ) merupakan sektor yang paling rentan terhadap penyalahgunaan anggaran daerah. Dengan memahami Peraturan Presiden (Perpres) No. 12 Tahun 2021 dan Undang-Undang Pemberantasan Tindak Pidana Korupsi (UU Tipikor No. 20/2001), masyarakat dapat mengawal transparansi belanja daerah secara mandiri dan ilmiah.",
              style: TextStyle(
                fontSize: 13,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHukumTile({
    required BuildContext context,
    required String catId,
    required String judul,
    required String risiko,
    required Color warnaRisiko,
    required String regulasi,
    required String deskripsi,
  }) {
    final url = KejanggalanHelper.regulasiUrls[catId];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ExpansionTile(
        title: Text(
          judul,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: warnaPrimer,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: warnaRisiko,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                regulasi,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Risk label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: warnaRisiko.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    risiko,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: warnaRisiko,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                
                // Description Text
                Text(
                  deskripsi,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
                
                if (url != null) ...[
                  const Divider(height: 24),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final uri = Uri.parse(url);
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (e) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text("Gagal membuka halaman regulasi: $e"),
                              backgroundColor: warnaKritis,
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.open_in_new_rounded, size: 16),
                      label: const Text(
                        "Buka Lembar Regulasi Resmi JDIH",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Cara Melaporkan Temuan Kejanggalan:",
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: warnaPrimer,
            ),
          ),
          SizedBox(height: 6),
          Text(
            "1. Masuk ke daftar paket kerja yang terdeteksi janggal.\n2. Klik salah satu paket untuk membuka rincian temuan.\n3. Tekan tombol 'Laporkan Temuan' di bagian bawah dialog.\n4. Aplikasi akan menyusun dokumen laporan secara otomatis dan membuka draf email di Gmail Anda.\n5. Tinjau kembali isi laporan, tambahkan bukti foto fisik/lokasi jika ada, lalu kirimkan ke lembaga pengawas.",
            style: TextStyle(
              fontSize: 12,
              color: Colors.black54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
