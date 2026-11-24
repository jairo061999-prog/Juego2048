class Partida {
  final int? id;
  final String usuario;
  final int puntuacion;
  final int fichaMaxima;
  final int movimientos;
  final int duracionSegundos;
  final DateTime fecha;
  final int tamanoTablero; // columna añadida en la migración v1 -> v2

  const Partida({
    this.id,
    required this.usuario,
    required this.puntuacion,
    required this.fichaMaxima,
    required this.movimientos,
    required this.duracionSegundos,
    required this.fecha,
    this.tamanoTablero = 4,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'usuario': usuario,
        'puntuacion': puntuacion,
        'ficha_maxima': fichaMaxima,
        'movimientos': movimientos,
        'duracion_segundos': duracionSegundos,
        'fecha': fecha.toIso8601String(),
        'tamano_tablero': tamanoTablero,
      };

  factory Partida.fromMap(Map<String, Object?> m) => Partida(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        puntuacion: m['puntuacion'] as int,
        fichaMaxima: m['ficha_maxima'] as int,
        movimientos: m['movimientos'] as int,
        duracionSegundos: m['duracion_segundos'] as int,
        fecha: DateTime.parse(m['fecha'] as String),
        tamanoTablero: (m['tamano_tablero'] as int?) ?? 4,
      );
}
