String _dos(int n) => n.toString().padLeft(2, '0');

/// 125 -> "02:05"; a partir de una hora "1:02:05".
String formatoTiempo(int segundos) {
  final h = segundos ~/ 3600;
  final m = (segundos % 3600) ~/ 60;
  final s = segundos % 60;
  return h > 0 ? '$h:${_dos(m)}:${_dos(s)}' : '${_dos(m)}:${_dos(s)}';
}

String formatoFecha(DateTime f) =>
    '${_dos(f.day)}/${_dos(f.month)}/${f.year} ${_dos(f.hour)}:${_dos(f.minute)}';
