// Modelo inmutable que representa el registro de una partida individual jugada.
class Partida {
  final int? id; // Identificador único autoincremental en BD (nulo antes de insertarse).
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final DateTime fecha;
  final int tamanoTablero; // Dimensión de la cuadrícula (columna añadida en migración v1 -> v2).

  const Partida({
    this.id,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
    this.tamanoTablero = 4, // Por defecto 4x4.
  });

  // Convierte la instancia en un mapa clave-valor compatible con SQLite (serializando la fecha a ISO 8601).
  Map<String, Object?> toMap() => {
        if (id != null) 'id': id, // Omite el ID si es nulo para que SQLite lo autogenere.
        'usuario': usuario,
        'puntuacion': puntuacion,
        'ficha_maxima': fichaMaxima,
        'movimientos': movimientos,
        'duracion_segundos': duracionSegundos,
        'fecha': fecha.toIso8601String(),
        'tamano_tablero': tamanoTablero,
      };

  // Reconstruye un objeto Partida a partir de una fila de la base de datos.
  factory Partida.fromMap(Map<String, Object?> m) => Partida(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        puntuacion: m['puntuacion'] as int,
        fichaMaxima: m['ficha_maxima'] as int,
        movimientos: m['movimientos'] as int,
        duracionSegundos: m['duracion_segundos'] as int,
        fecha: DateTime.parse(m['fecha'] as String),
        tamanoTablero: (m['tamano_tablero'] as int?) ?? 4, // Respaldo de 4 para registros antiguos sin este campo.
      );
}
