// Modelo inmutable que representa el registro de una partida individual jugada.
class Partida {
  // Identificador único autoincremental en la base de datos (nulo antes de insertarse).
  final int? id;
  // Nombre o identificador del jugador que disputó la partida.
  final String usuario;
  // Puntaje final obtenido al terminar la partida.
  final int puntuacion;
  // Valor numérico de la ficha más alta alcanzada en el tablero.
  final int fichaMaxima;
  // Cantidad total de desplazamientos realizados durante la partida.
  final int movimientos;
  // Tiempo total que duró la partida expresado en segundos.
  final int duracionSegundos;
  // Fecha y hora exacta en la que se registró o finalizó la partida.
  final DateTime fecha;
  // Dimensión de la cuadrícula del tablero (ej. 4 para 4x4).
  final int tamanoTablero; // columna añadida en la migración v1 -> v2

  // Constructor constante con valor por defecto de 4 para el tamaño del tablero.
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

  // Convierte la instancia de Partida en un mapa clave-valor compatible con SQLite.
  Map<String, Object?> toMap() => {
        // Incluye el 'id' solo si existe, permitiendo que la base de datos lo autogenere si es nulo.
        if (id != null) 'id': id,
        'usuario': usuario,
        'puntuacion': puntuacion,
        'ficha_maxima': fichaMaxima,
        'movimientos': movimientos,
        'duracion_segundos': duracionSegundos,
        // Serializa la fecha en formato texto estándar ISO 8601 para almacenarla.
        'fecha': fecha.toIso8601String(),
        'tamano_tablero': tamanoTablero,
      };

  // Constructor de fábrica que reconstruye un objeto Partida a partir de una fila de base de datos.
  factory Partida.fromMap(Map<String, Object?> m) => Partida(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        puntuacion: m['puntuacion'] as int,
        fichaMaxima: m['ficha_maxima'] as int,
        movimientos: m['movimientos'] as int,
        duracionSegundos: m['duracion_segundos'] as int,
        // Parsea la cadena ISO 8601 almacenada de vuelta a un objeto DateTime.
        fecha: DateTime.parse(m['fecha'] as String),
        // Asigna el tamaño del tablero o usa 4 como respaldo por compatibilidad con registros antiguos.
        tamanoTablero: (m['tamano_tablero'] as int?) ?? 4,
      );
}
