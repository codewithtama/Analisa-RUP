import 'package:go_router/go_router.dart';
import '../presentation/beranda/beranda_screen.dart';
import '../presentation/impor/impor_screen.dart';
import '../presentation/ringkasan/ringkasan_screen.dart';
import '../presentation/daftar_paket/daftar_paket_screen.dart';
import '../presentation/detail_kejanggalan/detail_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const BerandaScreen(),
    ),
    GoRoute(
      path: '/impor',
      builder: (context, state) => const ImporScreen(),
    ),
    GoRoute(
      path: '/ringkasan',
      builder: (context, state) => const RingkasanScreen(),
    ),
    GoRoute(
      path: '/daftar-paket',
      builder: (context, state) => const DaftarPaketScreen(),
    ),
    GoRoute(
      path: '/detail-kejanggalan/:kategori',
      builder: (context, state) {
        final kategori = state.pathParameters['kategori'] ?? '';
        return DetailScreen(kategori: kategori);
      },
    ),
  ],
);
