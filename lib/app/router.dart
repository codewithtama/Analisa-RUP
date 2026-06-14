import 'package:go_router/go_router.dart';
import '../presentation/beranda/beranda_screen.dart';
import '../presentation/impor/impor_screen.dart';
import '../presentation/ringkasan/ringkasan_screen.dart';
import '../presentation/daftar_paket/daftar_paket_screen.dart';
import '../presentation/detail_kejanggalan/detail_screen.dart';
import '../presentation/detail_kejanggalan/profil_skpd_screen.dart';
import '../presentation/pengaturan/pengaturan_screen.dart';

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
      builder: (context, state) {
        final tingkatStr = state.uri.queryParameters['tingkat'];
        final tingkat = tingkatStr != null ? int.tryParse(tingkatStr) : null;
        return DaftarPaketScreen(tingkatKejanggalan: tingkat);
      },
    ),
    GoRoute(
      path: '/detail-kejanggalan/:kategori',
      builder: (context, state) {
        final kategori = state.pathParameters['kategori'] ?? '';
        return DetailScreen(kategori: kategori);
      },
    ),
    GoRoute(
      path: '/profil-skpd/:skpd',
      builder: (context, state) {
        final skpd = state.pathParameters['skpd'] ?? '';
        return ProfilSkpdScreen(namaSkpd: skpd);
      },
    ),
    GoRoute(
      path: '/pengaturan',
      builder: (context, state) => const PengaturanScreen(),
    ),
  ],
);
