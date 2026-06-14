import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:pantau_pengadaan/main.dart';
import 'package:pantau_pengadaan/presentation/beranda/beranda_provider.dart';

void main() {
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
    expect(find.text('Pantau Pengadaan'), findsAtLeast(1));
  });
}
