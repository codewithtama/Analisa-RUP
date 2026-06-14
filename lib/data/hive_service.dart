import 'package:hive_flutter/hive_flutter.dart';
import 'models/paket_pengadaan.dart';

class HiveService {
  static const String boxName = 'paket_pengadaan';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PaketPengadaanAdapter());
    }
    await openBox();
  }

  Future<Box<PaketPengadaan>> openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<PaketPengadaan>(boxName);
    }
    return await Hive.openBox<PaketPengadaan>(boxName);
  }

  Future<List<PaketPengadaan>> getSemuaPaket() async {
    final box = await openBox();
    return box.values.toList();
  }

  Future<void> simpanSemuaPaket(List<PaketPengadaan> paketList) async {
    final box = await openBox();
    await box.clear();
    // Add all to Hive
    await box.addAll(paketList);
  }

  Future<void> hapusSemua() async {
    final box = await openBox();
    await box.clear();
  }
}
