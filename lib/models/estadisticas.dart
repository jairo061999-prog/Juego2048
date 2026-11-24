class Estadisticas { // Modelo inmutable que representa las estadísticas globales o agregadas de juego.
  final int partidas; // Número total de partidas jugadas.
  final int puntuacionMaxima; // Puntuación más alta registrada.
  final double puntuacionMedia; // Promedio de puntuación obtenido entre todas las partidas.
  final int fichaMaxima; // Valor de la ficha más alta alcanzada.
  final int tiempoTotalSegundos; // Tiempo acumulado de juego medido en segundos.

  const Estadisticas({ // Constructor constante que requiere inicializar todas las métricas.
    required this.partidas, // Cantidad de partidas disputadas.
    required this.puntuacionMaxima, // Récord máximo de puntos.
    required this.puntuacionMedia, // Media aritmética de puntos.
    required this.fichaMaxima, // Ficha de mayor valor conseguida.
    required this.tiempoTotalSegundos, // Suma total de segundos jugados.
  });

  factory Estadisticas.fromMap(Map<String, Object?> m) => Estadisticas( // Constructor de fábrica que transforma un mapa de BD en una instancia (MAX, AVG y SUM devuelven NULL con la tabla vacía: se controla con ??).
        partidas: (m['total'] as int?) ?? 0, // Asigna el total de partidas o 0 si el valor es nulo.
        puntuacionMaxima: (m['max_punt'] as int?) ?? 0, // Asigna la puntuación máxima o 0 si el valor es nulo.
        puntuacionMedia: ((m['media_punt'] as num?) ?? 0).toDouble(), // Convierte la media numérica a double, usando 0 como respaldo si es nulo.
        fichaMaxima: (m['max_ficha'] as int?) ?? 0, // Asigna el valor de la ficha máxima o 0 si es nulo.
        tiempoTotalSegundos: (m['tiempo'] as int?) ?? 0, // Asigna el tiempo total en segundos o 0 si es nulo.
      );
}

class EstadisticaJugador { // Modelo inmutable que almacena el resumen de estadísticas de un jugador específico (útil para rankings).
  final String usuario; // Nombre o identificador del usuario.
  final int mejorPuntuacion; // Récord personal de puntuación del jugador.
  final int partidas; // Cantidad total de partidas disputadas por el jugador.

  const EstadisticaJugador({ // Constructor constante para instanciar las estadísticas de un jugador.
    required this.usuario, // Identificador del jugador.
    required this.mejorPuntuacion, // Puntuación más alta del jugador.
    required this.partidas, // Total de partidas jugadas por el usuario.
  });

  factory EstadisticaJugador.fromMap(Map<String, Object?> m) => EstadisticaJugador( // Constructor de fábrica que crea un objeto EstadisticaJugador a partir de un mapa de datos.
        usuario: m['usuario'] as String, // Extrae el nombre del usuario asumiendo que siempre viene como String no nulo.
        mejorPuntuacion: (m['mejor'] as int?) ?? 0, // Extrae la mejor puntuación del jugador o asigna 0 por defecto.
        partidas: (m['total'] as int?) ?? 0, // Extrae el total de partidas jugadas o asigna 0 por defecto.
      );
}
