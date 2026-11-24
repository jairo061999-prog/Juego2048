// Modelo inmutable que representa las estadísticas globales o agregadas de juego.
class Estadisticas {
  // Número total de partidas jugadas.
  final int partidas;
  // Puntuación más alta registrada.
  final int puntuacionMaxima;
  // Promedio de puntuación obtenido entre todas las partidas.
  final double puntuacionMedia;
  // Valor de la ficha más alta alcanzada.
  final int fichaMaxima;
  // Tiempo acumulado de juego medido en segundos.
  final int tiempoTotalSegundos;

  // Constructor constante que requiere inicializar todas las métricas.
  const Estadisticas({
    required this.partidas,
    required this.puntuacionMaxima,
    required this.puntuacionMedia,
    required this.fichaMaxima,
    required this.tiempoTotalSegundos,
  });

  /// MAX, AVG y SUM devuelven NULL con la tabla vacía: se controla con ??.
  // Constructor de fábrica que transforma un mapa (resultado de base de datos) en una instancia de Estadisticas.
  factory Estadisticas.fromMap(Map<String, Object?> m) => Estadisticas(
        // Asigna el total de partidas o 0 si el valor es nulo.
        partidas: (m['total'] as int?) ?? 0,
        // Asigna la puntuación máxima o 0 si el valor es nulo.
        puntuacionMaxima: (m['max_punt'] as int?) ?? 0,
        // Convierte la media numérica a double, usando 0 como respaldo si es nulo.
        puntuacionMedia: ((m['media_punt'] as num?) ?? 0).toDouble(),
        // Asigna el valor de la ficha máxima o 0 si es nulo.
        fichaMaxima: (m['max_ficha'] as int?) ?? 0,
        // Asigna el tiempo total en segundos o 0 si es nulo.
        tiempoTotalSegundos: (m['tiempo'] as int?) ?? 0,
      );
}

// Modelo inmutable que almacena el resumen de estadísticas de un jugador específico (útil para rankings).
class EstadisticaJugador {
  // Nombre o identificador del usuario.
  final String usuario;
  // Récord personal de puntuación del jugador.
  final int mejorPuntuacion;
  // Cantidad total de partidas disputadas por el jugador.
  final int partidas;

  // Constructor constante para instanciar las estadísticas de un jugador.
  const EstadisticaJugador({
    required this.usuario,
    required this.mejorPuntuacion,
    required this.partidas,
  });

  // Constructor de fábrica que crea un objeto EstadisticaJugador a partir de un mapa de datos.
  factory EstadisticaJugador.fromMap(Map<String, Object?> m) => EstadisticaJugador(
        // Extrae el nombre del usuario asumiendo que siempre viene como String no nulo.
        usuario: m['usuario'] as String,
        // Extrae la mejor puntuación del jugador o asigna 0 por defecto.
        mejorPuntuacion: (m['mejor'] as int?) ?? 0,
        // Extrae el total de partidas jugadas o asigna 0 por defecto.
        partidas: (m['total'] as int?) ?? 0,
      );
}
