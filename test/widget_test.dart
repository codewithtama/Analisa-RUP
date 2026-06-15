import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:pantau_pengadaan/main.dart';
import 'package:pantau_pengadaan/presentation/beranda/beranda_provider.dart';
import 'package:pantau_pengadaan/data/models/paket_pengadaan.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    // Setup temporary directory for Hive in testing
    tempDir = Directory.systemTemp.createTempSync('hive_test_dir');
    Hive.init(tempDir.path);
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PaketPengadaanAdapter());
    }
    await Hive.openBox<PaketPengadaan>('paket_pengadaan');
    await Hive.openBox('pengaturan');
  });

  tearDown(() async {
    await Hive.close();
    try {
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    } catch (_) {}
  });

  testWidgets('Smoke test - App runs and loads Beranda', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<BerandaProvider>(
            create: (_) => BerandaProvider(),
          ),
        ],
        child: const PantauPengadaanApp(),
      ),
    );

    // Verify that the title is displayed.
    expect(find.text('Pantau RUP'), findsAtLeast(1));
  });
}
