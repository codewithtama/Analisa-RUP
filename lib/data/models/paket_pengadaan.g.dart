// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'paket_pengadaan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaketPengadaanAdapter extends TypeAdapter<PaketPengadaan> {
  @override
  final int typeId = 0;

  @override
  PaketPengadaan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaketPengadaan(
      namaInstansi: fields[0] as String,
      namaSatuanKerja: fields[1] as String,
      tahunAnggaran: fields[2] as String,
      caraPengadaan: fields[3] as String,
      metodePengadaan: fields[4] as String,
      jenisPengadaan: fields[5] as String,
      namaPaket: fields[6] as String,
      kodeRup: fields[7] as String,
      sumberDana: fields[8] as String,
      totalNilai: fields[9] as double,
      tingkatKejanggalan: fields[10] as int,
      catatanKejanggalan: (fields[11] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, PaketPengadaan obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.namaInstansi)
      ..writeByte(1)
      ..write(obj.namaSatuanKerja)
      ..writeByte(2)
      ..write(obj.tahunAnggaran)
      ..writeByte(3)
      ..write(obj.caraPengadaan)
      ..writeByte(4)
      ..write(obj.metodePengadaan)
      ..writeByte(5)
      ..write(obj.jenisPengadaan)
      ..writeByte(6)
      ..write(obj.namaPaket)
      ..writeByte(7)
      ..write(obj.kodeRup)
      ..writeByte(8)
      ..write(obj.sumberDana)
      ..writeByte(9)
      ..write(obj.totalNilai)
      ..writeByte(10)
      ..write(obj.tingkatKejanggalan)
      ..writeByte(11)
      ..write(obj.catatanKejanggalan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaketPengadaanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
