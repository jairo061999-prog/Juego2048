import 'dart:convert'; // Para serializar y deserializar el tablero en formato JSON.

// Modelo inmutable que guarda el progreso de una partida en curso para reanudarla más tarde.
class PartidaGuardada {
  final List<int> tablero; // Lista plana con los valores de cada celda del tablero.
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
  // Convierte el estado actual en un mapa para SQLite, codificando el tablero a texto JSON.
  Map<String, Object?> toMap() => {
        'id': 1, // Fuerza un único registro sobrescribible en la tabla.
        'tablero': jsonEncode(tablero),
        'puntuacion': puntuacion,
        'movimientos': movimientos,
        'segundos_transcurridos': segundos,
      };

  // Reconstruye el estado de la partida desde un mapa de BD, decodificando el JSON del tablero.
  factory PartidaGuardada.fromMap(Map<String, Object?> m) => PartidaGuardada(
        tablero: (jsonDecode(m['tablero'] as String) as List).cast<int>(),
        puntuacion: m['puntuacion'] as int,
        movimientos: m['movimientos'] as int,
        segundos: m['segundos_transcurridos'] as int,
      );
}
