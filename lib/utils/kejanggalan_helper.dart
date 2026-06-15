class KejanggalanHelper {
  // IDs for anomaly categories
  static const String idPenunjukanBesar = '1';
  static const String idMendekatiBatasPL = '2';
  static const String idNamaBerulangSkpd = '3';
  static const String idNamaBerulangLintas = '4';
  static const String idNilaiSangatKecil = '5';
  static const String idNamaSerupaSkpd = '6';
  static const String idPecahPaketTender = '7';

  /// Prepend category ID to warning message for structured persistence.
  static String format(String catId, String message) {
    return '[$catId] $message';
  }

  /// Strip structured category ID prefix for user-facing UI.
  static String clean(String note) {
    if (note.startsWith('[') && note.contains(']')) {
      final index = note.indexOf(']');
      if (index != -1 && index < 5) {
        return note.substring(index + 1).trim();
      }
    }
    return note;
  }

  /// Match note against a specific category ID, with backward compatibility fallback.
  static bool matches(String note, String catId) {
    // 1. Structured match via ID prefix
    if (note.startsWith('[$catId]')) {
      return true;
    }

    // 2. Backward compatibility fallback for legacy database strings
    switch (catId) {
      case idPenunjukanBesar:
        return note.startsWith('Ditunjuk langsung') && !note.startsWith('[');
      case idMendekatiBatasPL:
        return note.startsWith('Nilai paket mendekati batas atas') && !note.startsWith('[');
      case idNamaBerulangSkpd:
        return note.startsWith('Nama paket ini muncul') && !note.startsWith('[');
      case idNamaBerulangLintas:
        return note.startsWith('Paket dengan nama ini ditemukan') && !note.startsWith('[');
      case idNilaiSangatKecil:
        return note.startsWith('Nilai paket sangat kecil') && !note.startsWith('[');
      case idNamaSerupaSkpd:
        return note.startsWith('Terdapat') && note.contains('serupa') && !note.startsWith('[');
      case idPecahPaketTender:
        return note.startsWith('Terindikasi pemecahan paket') && !note.startsWith('[');
      default:
        return false;
    }
  }

  /// Map human-readable Category names (from UI routing) to internal IDs.
  static String? mapKategoriToId(String kategori) {
    switch (kategori) {
      case 'Penunjukan Langsung Nilai Besar':
        return idPenunjukanBesar;
      case 'Mendekati Batas Pengadaan Langsung':
        return idMendekatiBatasPL;
      case 'Nama Paket Berulang di SKPD':
        return idNamaBerulangSkpd;
      case 'Nama Paket Berulang Lintas SKPD':
        return idNamaBerulangLintas;
      case 'Nilai Paket Sangat Kecil':
        return idNilaiSangatKecil;
      case 'Pola Paket Serupa di SKPD':
        return idNamaSerupaSkpd;
      case 'Indikasi Pecah Paket Pekerjaan':
        return idPecahPaketTender;
      default:
        return null;
    }
  }
}
