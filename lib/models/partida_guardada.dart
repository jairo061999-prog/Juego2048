import 'dart:convert';

class PartidaGuardada {
  final List<int> tablero;
  final int puntuacion;
  final int movimientos;
  final int segundos;

  const PartidaGuardada({
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundos,
  });

  /// La fila es única: id siempre 1.
  Map<String, Object?> toMap() => {
        'id': 1,
        'tablero': jsonEncode(tablero),
        'puntuacion': puntuacion,
        'movimientos': movimientos,
        'segundos_transcurridos': segundos,
      };

  factory PartidaGuardada.fromMap(Map<String, Object?> m) => PartidaGuardada(
        tablero: (jsonDecode(m['tablero'] as String) as List).cast<int>(),
        puntuacion: m['puntuacion'] as int,
        movimientos: m['movimientos'] as int,
        segundos: m['segundos_transcurridos'] as int,
      );
}
