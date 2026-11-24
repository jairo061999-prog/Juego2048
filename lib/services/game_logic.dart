import 'dart:math';

enum Direccion { izquierda, derecha, arriba, abajo }

/// Lógica pura del 2048 (sin interfaz ni base de datos).
class Juego2048 {
  static const int tam = 4;

  final List<int> tablero;
  int puntuacion;
  int movimientos;
  final Random _azar = Random();

  Juego2048()
      : tablero = List<int>.filled(tam * tam, 0),
        puntuacion = 0,
        movimientos = 0 {
    _nuevaFicha();
    _nuevaFicha();
  }

  Juego2048.desde(this.tablero, this.puntuacion, this.movimientos);

  int get fichaMaxima => tablero.reduce(max);

  bool get terminado {
    if (tablero.contains(0)) {
      return false;
    }
    for (int f = 0; f < tam; f++) {
      for (int c = 0; c < tam; c++) {
        final v = tablero[f * tam + c];
        if (c + 1 < tam && tablero[f * tam + c + 1] == v) return false;
        if (f + 1 < tam && tablero[(f + 1) * tam + c] == v) return false;
      }
    }
    return true;
  }

  void _nuevaFicha() {
    final libres = [
      for (int i = 0; i < tablero.length; i++)
        if (tablero[i] == 0) i
    ];
    if (libres.isEmpty) {
      return;
    }
    tablero[libres[_azar.nextInt(libres.length)]] = _azar.nextInt(10) == 0 ? 4 : 2;
  }

  List<int> _indices(Direccion d, int i) {
    switch (d) {
      case Direccion.izquierda:
        return List.generate(tam, (j) => i * tam + j);
      case Direccion.derecha:
        return List.generate(tam, (j) => i * tam + (tam - 1 - j));
      case Direccion.arriba:
        return List.generate(tam, (j) => j * tam + i);
      case Direccion.abajo:
        return List.generate(tam, (j) => (tam - 1 - j) * tam + i);
    }
  }

  List<int> _fusionar(List<int> linea) {
    final v = linea.where((x) => x != 0).toList();
    final salida = <int>[];
    int i = 0;
    while (i < v.length) {
      if (i + 1 < v.length && v[i] == v[i + 1]) {
        final suma = v[i] * 2;
        salida.add(suma);
        puntuacion += suma;
        i += 2;
      } else {
        salida.add(v[i]);
        i++;
      }
    }
    while (salida.length < tam) {
      salida.add(0);
    }
    return salida;
  }

  /// Devuelve true si algo se movió (solo entonces cuenta el movimiento y
  /// aparece una ficha nueva).
  bool mover(Direccion d) {
    bool cambio = false;
    for (int i = 0; i < tam; i++) {
      final idx = _indices(d, i);
      final nueva = _fusionar([for (final k in idx) tablero[k]]);
      for (int j = 0; j < tam; j++) {
        if (tablero[idx[j]] != nueva[j]) {
          tablero[idx[j]] = nueva[j];
          cambio = true;
        }
      }
    }
    if (cambio) {
      movimientos++;
      _nuevaFicha();
    }
    return cambio;
  }
}
