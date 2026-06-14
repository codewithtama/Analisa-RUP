import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ChipRisiko extends StatelessWidget {
  final int tingkat; // 0=normal, 1=waspada, 2=tinggi, 3=kritis

  const ChipRisiko({super.key, required this.tingkat});

  @override
  Widget build(BuildContext context) {
    Color labelColor;
    Color bgColor;
    String text;

    switch (tingkat) {
      case 3:
        bgColor = warnaKritis;
        labelColor = Colors.white;
        text = "Perlu Perhatian Segera";
        break;
      case 2:
        bgColor = warnaTinggi;
        labelColor = Colors.white;
        text = "Perlu Diperiksa";
        break;
      case 1:
        bgColor = warnaWaspada;
        labelColor = Colors.black87;
        text = "Pantau";
        break;
      case 0:
      default:
        bgColor = const Color(0xFFE8F5E9); // latar hijau muda
        labelColor = warnaNormal;
        text = "Wajar";
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: labelColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
