import 'package:flutter/material.dart';
import '../../app/theme.dart';

class KosongPlaceholder extends StatelessWidget {
  final VoidCallback onActionPressed;
  final String actionLabel;

  const KosongPlaceholder({
    super.key,
    required this.onActionPressed,
    required this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    warnaPrimer.withValues(alpha: 0.12),
                    warnaAksen.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.insert_drive_file_outlined,
                size: 64,
                color: warnaAksen,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Belum Ada Data",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: warnaPrimer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              "Mulai dengan mengimpor berkas RUP Anda (format .xlsx atau .csv) untuk menganalisis kejanggalan anggaran.",
              style: TextStyle(
                fontSize: 14,
                color: Colors.black45,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onActionPressed,
              icon: const Icon(Icons.file_upload_outlined),
              label: Text(actionLabel),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                minimumSize: const Size(200, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
