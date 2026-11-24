class Estadisticas {
  final int partidas;
  final int puntuacionMaxima;
  final double puntuacionMedia;
  final int fichaMaxima;
  final int tiempoTotalSegundos;

  const Estadisticas({
    required this.partidas,
    required this.puntuacionMaxima,
    required this.puntuacionMedia,
    required this.fichaMaxima,
    required this.tiempoTotalSegundos,
  });

  /// MAX, AVG y SUM devuelven NULL con la tabla vacía: se controla con ??.
  factory Estadisticas.fromMap(Map<String, Object?> m) => Estadisticas(
        partidas: (m['total'] as int?) ?? 0,
        puntuacionMaxima: (m['max_punt'] as int?) ?? 0,
        puntuacionMedia: ((m['media_punt'] as num?) ?? 0).toDouble(),
        fichaMaxima: (m['max_ficha'] as int?) ?? 0,
        tiempoTotalSegundos: (m['tiempo'] as int?) ?? 0,
      );
}

class EstadisticaJugador {
  final String usuario;
  final int mejorPuntuacion;
  final int partidas;

  const EstadisticaJugador({
    required this.usuario,
    required this.mejorPuntuacion,
    required this.partidas,
  });

  factory EstadisticaJugador.fromMap(Map<String, Object?> m) => EstadisticaJugador(
        usuario: m['usuario'] as String,
        mejorPuntuacion: (m['mejor'] as int?) ?? 0,
        partidas: (m['total'] as int?) ?? 0,
      );
}
