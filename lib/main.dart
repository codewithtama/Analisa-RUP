import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/router.dart';
import 'app/theme.dart';
import 'data/hive_service.dart';
import 'presentation/beranda/beranda_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final hiveService = HiveService();
  try {
    await hiveService.init();
  } catch (e) {
    debugPrint("Gagal menginisialisasi basis data: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<BerandaProvider>(
          create: (_) => BerandaProvider(),
        ),
      ],
      child: const PantauPengadaanApp(),
    ),
  );
}

class PantauPengadaanApp extends StatelessWidget {
  const PantauPengadaanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pantau RUP',
      theme: AppTheme.lightTheme,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
