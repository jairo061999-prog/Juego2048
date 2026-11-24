// Importa la librería estándar para codificar y decodificar datos en formato JSON.
import 'dart:convert';

// Modelo inmutable que representa el estado de una partida en curso guardada para continuarla después.
class PartidaGuardada {
  // Lista plana de enteros que representa los valores de cada celda del tablero.
  final List<int> tablero;
  // Puntuación acumulada hasta el momento de guardar la partida.
  final int puntuacion;
  // Cantidad de movimientos realizados hasta el momento del guardado.
  final int movimientos;
  // Tiempo de juego transcurrido en segundos antes de pausar o cerrar.
  final int segundos;

  // Constructor constante que exige todos los datos del estado de la partida.
  const PartidaGuardada({
    required this.tablero,
    required this.puntuacion,
    required this.movimientos,
    required this.segundos,
  });

  /// La fila es única: id siempre 1.
  // Serializa el estado de la partida a un mapa compatible con la base de datos.
  Map<String, Object?> toMap() => {
        // Fija el identificador en 1 para sobrescribir siempre el mismo registro único.
        'id': 1,
        // Convierte la lista de enteros del tablero en una cadena JSON para guardarla como texto.
        'tablero': jsonEncode(tablero),
        'puntuacion': puntuacion,
        'movimientos': movimientos,
        'segundos_transcurridos': segundos,
      };

  // Constructor de fábrica que restaura una partida guardada a partir de un mapa de base de datos.
  factory PartidaGuardada.fromMap(Map<String, Object?> m) => PartidaGuardada(
        // Decodifica la cadena JSON del tablero y convierte sus elementos a una lista de enteros.
        tablero: (jsonDecode(m['tablero'] as String) as List).cast<int>(),
        puntuacion: m['puntuacion'] as int,
        movimientos: m['movimientos'] as int,
        segundos: m['segundos_transcurridos'] as int,
      );
}
