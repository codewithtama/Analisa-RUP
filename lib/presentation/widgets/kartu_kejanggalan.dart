import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../utils/format_rupiah.dart';

class KartuKejanggalan extends StatelessWidget {
  final String judul;
  final String penjelasan;
  final int jumlahTemuan;
  final double totalNilaiTerdampak;
  final int tingkatRisiko;
  final VoidCallback onTap;

  const KartuKejanggalan({
    super.key,
    required this.judul,
    required this.penjelasan,
    required this.jumlahTemuan,
    required this.totalNilaiTerdampak,
    required this.tingkatRisiko,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color warnaTema;
    IconData ikon;

    switch (tingkatRisiko) {
      case 3:
        warnaTema = warnaKritis;
        ikon = Icons.gavel_rounded;
        break;
      case 2:
        warnaTema = warnaTinggi;
        ikon = Icons.warning_amber_rounded;
        break;
      case 1:
        warnaTema = warnaWaspada;
        ikon = Icons.visibility_rounded;
        break;
      default:
        warnaTema = warnaNormal;
        ikon = Icons.check_circle_outline_rounded;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white,
                warnaTema.withValues(alpha: 0.04),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: warnaTema.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        ikon,
                        color: warnaTema,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        judul,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: warnaPrimer,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  penjelasan,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Jumlah Temuan",
                          style: TextStyle(fontSize: 11, color: Colors.black38),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "$jumlahTemuan paket",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          "Total Nilai Terdampak",
                          style: TextStyle(fontSize: 11, color: Colors.black38),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatRupiah(totalNilaiTerdampak),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: warnaTema,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      "Lihat Detail",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: warnaTema,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 12,
                      color: warnaTema,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
