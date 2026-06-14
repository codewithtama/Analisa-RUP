String formatRupiah(double nilai) {
  final intVal = nilai.round();
  final buffer = StringBuffer();
  final str = intVal.toString();

  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    buffer.write(str[i]);
    count++;
    if (count % 3 == 0 && i != 0) {
      buffer.write('.');
    }
  }

  return 'Rp ${buffer.toString().split('').reversed.join('')}';
}
