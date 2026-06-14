import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../data/models/paket_pengadaan.dart';
import '../data/models/hasil_analisis.dart';
import 'format_rupiah.dart';

class PdfExportService {
  /// Membuat dan mengekspor dokumen PDF laporan audit RUP secara offline.
  static Future<String?> exportToPdf({
    required List<PaketPengadaan> list,
    required HasilAnalisis stats,
    String instansiName = "Nasional (K/L/PD)",
  }) async {
    final pdf = pw.Document();

    // Definisikan palet warna formal secara eksplisit untuk menghindari pemanggilan method darker/lighter
    final primaryColor = PdfColor.fromHex('#0f2042');     // Deep Navy
    final primaryLighter = PdfColor.fromHex('#eef2f7');   // Very light navy-blue background
    
    final accentColor = PdfColor.fromHex('#d32f2f');      // Crimson Red
    final accentLighter = PdfColor.fromHex('#fdf2f2');    // Very light crimson background
    
    final grayColor = PdfColor.fromHex('#757575');        // Cool Gray
    final lightGrayColor = PdfColor.fromHex('#f5f5f5');   // Background Gray

    // Definisikan font standar PDF
    final titleFont = pw.Font.timesBold();
    final headerFont = pw.Font.helveticaBold();
    final bodyFont = pw.Font.helvetica();

    // 1. Dapatkan daftar paket kritis (tingkat 3) untuk ditampilkan di tabel detail (dibatasi top 50)
    final criticalPackages = list.where((p) => p.tingkatKejanggalan == 3).toList();
    criticalPackages.sort((a, b) => b.totalNilai.compareTo(a.totalNilai));
    final displayPackages = criticalPackages.length > 50 
        ? criticalPackages.sublist(0, 50) 
        : criticalPackages;

    // 2. Susun Halaman Cover (Page 1)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Spacer(flex: 1),
              // Garis aksen atas
              pw.Container(height: 5, color: primaryColor),
              pw.SizedBox(height: 20),
              
              // Judul Utama
              pw.Text(
                "LAPORAN HASIL AUDIT",
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 26,
                  color: primaryColor,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                "RENCANA UMUM PENGADAAN (RUP) TAHUN ANGGARAN 2026",
                style: pw.TextStyle(
                  font: titleFont,
                  fontSize: 16,
                  color: grayColor,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                "ANALISIS RISIKO & DETEKSI ANOMALI REGULASI SECARA MANDIRI",
                style: pw.TextStyle(
                  font: bodyFont,
                  fontSize: 10,
                  color: accentColor,
                  fontWeight: pw.FontWeight.bold,
                ),
                textAlign: pw.TextAlign.center,
              ),
              pw.SizedBox(height: 24),
              pw.Container(height: 1, color: lightGrayColor),
              pw.SizedBox(height: 32),
              
              // Info Instansi
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: pw.BoxDecoration(
                    color: lightGrayColor,
                    borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
                  ),
                  child: pw.Column(
                    children: [
                      pw.Text(
                        "LINGKUP INSTANSI:",
                        style: pw.TextStyle(font: headerFont, fontSize: 8, color: grayColor),
                      ),
                      pw.SizedBox(height: 4),
                      pw.Text(
                        instansiName.toUpperCase(),
                        style: pw.TextStyle(font: titleFont, fontSize: 16, color: primaryColor),
                        textAlign: pw.TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),

              pw.Spacer(flex: 2),

              // Metadata Block
              pw.Align(
                alignment: pw.Alignment.centerLeft,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      "Tanggal Analisis: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                      style: pw.TextStyle(font: bodyFont, fontSize: 10, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Metodologi: Deteksi Anomali Regulasi Perpres No. 12/2021",
                      style: pw.TextStyle(font: bodyFont, fontSize: 10, color: primaryColor),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      "Penyusun: Tim Pengawas Independen / Jurnalis Pengawal Transparansi",
                      style: pw.TextStyle(font: bodyFont, fontSize: 10, color: primaryColor),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              // Garis aksen bawah
              pw.Container(height: 2, color: primaryColor),
            ],
          );
        },
      ),
    );

    // 3. Susun Halaman Ringkasan Statistik & Temuan Kategori (Page 2)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          final totalAnomaliPagu = stats.rincianKejanggalan.values.fold<double>(
            0.0, 
            (sum, item) => sum + item.totalNilaiTerdampak
          );

          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                "RINGKASAN EKSEKUTIF",
                style: pw.TextStyle(font: headerFont, fontSize: 16, color: primaryColor),
              ),
              pw.SizedBox(height: 4),
              pw.Container(height: 2, color: primaryColor),
              pw.SizedBox(height: 16),

              // KPI Blocks Grid
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiCard(
                    "TOTAL ANGGARAN", 
                    formatRupiah(stats.totalAnggaran), 
                    textColor: primaryColor, 
                    bgColor: primaryLighter, 
                    borderColor: primaryColor, 
                    labelFont: bodyFont, 
                    valFont: headerFont
                  ),
                  _buildKpiCard(
                    "TOTAL PAKET", 
                    "${stats.totalPaket} Paket", 
                    textColor: primaryColor, 
                    bgColor: primaryLighter, 
                    borderColor: primaryColor, 
                    labelFont: bodyFont, 
                    valFont: headerFont
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildKpiCard(
                    "PAGU TERDAMPAK ANOMALI", 
                    formatRupiah(totalAnomaliPagu), 
                    textColor: accentColor, 
                    bgColor: accentLighter, 
                    borderColor: accentColor, 
                    labelFont: bodyFont, 
                    valFont: headerFont
                  ),
                  _buildKpiCard(
                    "AKUMULASI SATKER", 
                    "${stats.totalSatuanKerja} SKPD", 
                    textColor: primaryColor, 
                    bgColor: primaryLighter, 
                    borderColor: primaryColor, 
                    labelFont: bodyFont, 
                    valFont: headerFont
                  ),
                ],
              ),
              pw.SizedBox(height: 24),

              // Judul Tabel Temuan
              pw.Text(
                "SEBARAN KATEGORI KEJANGGALAN REGULASI",
                style: pw.TextStyle(font: headerFont, fontSize: 12, color: primaryColor),
              ),
              pw.SizedBox(height: 8),

              // Tabel Temuan Kategori
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(5),
                  1: pw.FlexColumnWidth(2),
                  2: pw.FlexColumnWidth(4),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _buildTableCell("Kategori Indikasi Kejanggalan", headerFont, color: PdfColors.white, isHeader: true),
                      _buildTableCell("Kasus", headerFont, color: PdfColors.white, isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell("Nilai Pagu Terdampak", headerFont, color: PdfColors.white, isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Rows
                  ...stats.rincianKejanggalan.values.map((ringkasan) {
                    return pw.TableRow(
                      children: [
                        _buildTableCell(ringkasan.namaKategori, bodyFont),
                        _buildTableCell("${ringkasan.jumlahTemuan} Kasus", bodyFont, align: pw.TextAlign.center),
                        _buildTableCell(formatRupiah(ringkasan.totalNilaiTerdampak), bodyFont, align: pw.TextAlign.right),
                      ],
                    );
                  }),
                ],
              ),

              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "Halaman 2 dari 3  |  Laporan Audit RUP 2026",
                  style: pw.TextStyle(font: bodyFont, fontSize: 8, color: grayColor),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 4. Halaman Detail Paket Kritis (Page 3)
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Text(
                "RINCIAN TEMUAN KRITIS (TOP 50)",
                style: pw.TextStyle(font: headerFont, fontSize: 16, color: primaryColor),
              ),
              pw.SizedBox(height: 4),
              pw.Container(height: 2, color: primaryColor),
              pw.SizedBox(height: 12),
              pw.Text(
                "Daftar paket pengadaan dengan tingkat risiko tertinggi (Perlu Perhatian Segera / Kritis = 3) berdasarkan nilai pagu terbesar:",
                style: pw.TextStyle(font: bodyFont, fontSize: 9, color: PdfColors.black),
              ),
              pw.SizedBox(height: 12),

              // Tabel Paket Kritis
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                columnWidths: const {
                  0: pw.FlexColumnWidth(3),
                  1: pw.FlexColumnWidth(3),
                  2: pw.FlexColumnWidth(2.5),
                  3: pw.FlexColumnWidth(2.5),
                },
                children: [
                  // Header
                  pw.TableRow(
                    decoration: pw.BoxDecoration(color: primaryColor),
                    children: [
                      _buildTableCell("Nama Pekerjaan", headerFont, color: PdfColors.white, isHeader: true),
                      _buildTableCell("Satuan Kerja", headerFont, color: PdfColors.white, isHeader: true),
                      _buildTableCell("Metode", headerFont, color: PdfColors.white, isHeader: true, align: pw.TextAlign.center),
                      _buildTableCell("Nilai Pagu", headerFont, color: PdfColors.white, isHeader: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Rows
                  if (displayPackages.isEmpty)
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(12),
                          child: pw.Text(
                            "Tidak ada temuan kejanggalan tingkat kritis.",
                            style: pw.TextStyle(font: bodyFont, fontSize: 10),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Padding(padding: pw.EdgeInsets.zero, child: pw.SizedBox.shrink()),
                        pw.Padding(padding: pw.EdgeInsets.zero, child: pw.SizedBox.shrink()),
                        pw.Padding(padding: pw.EdgeInsets.zero, child: pw.SizedBox.shrink()),
                      ],
                    )
                  else
                    ...displayPackages.map((paket) {
                      return pw.TableRow(
                        children: [
                          _buildTableCell(paket.namaPaket, bodyFont, fontSize: 8),
                          _buildTableCell(paket.namaSatuanKerja, bodyFont, fontSize: 8),
                          _buildTableCell(paket.metodePengadaan, bodyFont, fontSize: 8, align: pw.TextAlign.center),
                          _buildTableCell(formatRupiah(paket.totalNilai), bodyFont, fontSize: 8, align: pw.TextAlign.right),
                        ],
                      );
                    }),
                ],
              ),

              pw.Spacer(),
              pw.Align(
                alignment: pw.Alignment.center,
                child: pw.Text(
                  "Halaman 3 dari 3  |  Laporan Audit RUP 2026",
                  style: pw.TextStyle(font: bodyFont, fontSize: 8, color: grayColor),
                ),
              ),
            ],
          );
        },
      ),
    );

    // 5. Simpan dan Pemicu Share Dialog
    try {
      final bytes = await pdf.save();
      String? savedPath;

      if (Platform.isWindows) {
        final downloadsDir = await getDownloadsDirectory();
        if (downloadsDir != null) {
          final file = File('${downloadsDir.path}/laporan_audit_rup.pdf');
          await file.writeAsBytes(bytes);
          savedPath = file.path;
        }
      }

      // Selalu trigger share_plus agar pengguna bisa menyimpan berkas atau membagikannya
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/laporan_audit_rup.pdf');
      await tempFile.writeAsBytes(bytes);

      final xFile = XFile(tempFile.path);
      await Share.shareXFiles([xFile], subject: 'Laporan Audit Transparansi RUP 2026');

      if (savedPath != null) {
        return "Laporan PDF berhasil disimpan di folder Unduhan:\n$savedPath";
      }
      return null; // Sukses melalui share sheet
    } catch (e) {
      return "Gagal membuat PDF: $e";
    }
  }

  // Helper untuk membuat widget KPI Block dengan parameter warna eksplisit
  static pw.Widget _buildKpiCard(
    String label, 
    String value, {
    required PdfColor textColor,
    required PdfColor bgColor,
    required PdfColor borderColor,
    required pw.Font labelFont,
    required pw.Font valFont,
  }) {
    return pw.Expanded(
      child: pw.Container(
        margin: const pw.EdgeInsets.symmetric(horizontal: 4),
        padding: const pw.EdgeInsets.all(12),
        decoration: pw.BoxDecoration(
          border: pw.Border.all(color: borderColor, width: 1.5),
          color: bgColor,
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(font: labelFont, fontSize: 8, color: textColor),
            ),
            pw.SizedBox(height: 6),
            pw.Text(
              value,
              style: pw.TextStyle(font: valFont, fontSize: 13, color: textColor, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Helper untuk memformat sel tabel
  static pw.Widget _buildTableCell(
    String text, 
    pw.Font font, {
    double fontSize = 9, 
    PdfColor color = PdfColors.black, 
    bool isHeader = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: pw.EdgeInsets.symmetric(
        horizontal: 8, 
        vertical: isHeader ? 6 : 4
      ),
      child: pw.Text(
        text,
        style: pw.TextStyle(font: font, fontSize: fontSize, color: color),
        textAlign: align,
      ),
    );
  }
}
