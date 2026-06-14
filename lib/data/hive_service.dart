import 'package:hive_flutter/hive_flutter.dart';
import 'models/paket_pengadaan.dart';

class HiveService {
  static const String boxName = 'paket_pengadaan';
  static const String settingsBoxName = 'pengaturan';

  Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PaketPengadaanAdapter());
    }
    await openBox();
    await openSettingsBox();
  }

  Future<Box<PaketPengadaan>> openBox() async {
    if (Hive.isBoxOpen(boxName)) {
      return Hive.box<PaketPengadaan>(boxName);
    }
    return await Hive.openBox<PaketPengadaan>(boxName);
  }

  Future<Box> openSettingsBox() async {
    if (Hive.isBoxOpen(settingsBoxName)) {
      return Hive.box(settingsBoxName);
    }
    return await Hive.openBox(settingsBoxName);
  }

  Future<double> getBatasPL() async {
    final box = await openSettingsBox();
    final val = box.get('batas_pl', defaultValue: 200000000.0);
    if (val is num) return val.toDouble();
    return 200000000.0;
  }

  Future<void> setBatasPL(double val) async {
    final box = await openSettingsBox();
    await box.put('batas_pl', val);
  }

  Future<double> getBatasPenunjukan() async {
    final box = await openSettingsBox();
    final val = box.get('batas_penunjukan', defaultValue: 500000000.0);
    if (val is num) return val.toDouble();
    return 500000000.0;
  }

  Future<void> setBatasPenunjukan(double val) async {
    final box = await openSettingsBox();
    await box.put('batas_penunjukan', val);
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
