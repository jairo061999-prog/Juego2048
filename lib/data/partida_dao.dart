import 'package:sqflite/sqflite.dart';
import '../models/estadisticas.dart';
import '../models/partida.dart';
import 'database_helper.dart';

/// Todas las consultas SQL de la tabla partidas. Siempre con whereArgs / ?.
class PartidaDao {
  Future<Database> get _db => DatabaseHelper.instance.database;

  /// [ejecutor] permite usarlo dentro de una transacción (txn).
  Future<int> insertar(Partida p, {DatabaseExecutor? ejecutor}) async {
    final db = ejecutor ?? await _db;
    return db.insert('partidas', p.toMap());
  }

  Future<List<Partida>> obtenerHistorial() async {
    final db = await _db;
    final filas = await db.query('partidas', orderBy: 'fecha DESC');
    return filas.map(Partida.fromMap).toList();
  }

  Future<Partida?> obtenerPorId(int id) async {
    final db = await _db;
    final filas = await db.query('partidas', where: 'id = ?', whereArgs: [id], limit: 1);
    return filas.isEmpty ? null : Partida.fromMap(filas.first);
  }

  Future<int> eliminar(int id) async {
    final db = await _db;
    return db.delete('partidas', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> vaciarHistorial() async {
    final db = await _db;
    return db.delete('partidas');
  }

  /// Para "Deshacer": vuelve a insertar la partida con su id original.
  Future<void> restaurar(Partida p) async {
    final db = await _db;
    await db.insert('partidas', p.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  /// Filtro por nombre de jugador (contiene) y/o ficha máxima mínima.
  Future<List<Partida>> filtrar({String? usuario, int? fichaMinima}) async {
    final db = await _db;
    final condiciones = <String>[];
    final args = <Object?>[];
    if (usuario != null && usuario.trim().isNotEmpty) {
      condiciones.add('usuario LIKE ?');
      args.add('%${usuario.trim()}%');
    }
    if (fichaMinima != null) {
      condiciones.add('ficha_maxima >= ?');
      args.add(fichaMinima);
    }
    final filas = await db.query(
      'partidas',
      where: condiciones.isEmpty ? null : condiciones.join(' AND '),
      whereArgs: args.isEmpty ? null : args,
      orderBy: 'fecha DESC',
    );
    return filas.map(Partida.fromMap).toList();
  }

  /// Top N por puntuación (ORDER BY + LIMIT).
  Future<List<Partida>> obtenerRanking({int limite = 10}) async {
    final db = await _db;
    final filas = await db.query(
      'partidas',
      orderBy: 'puntuacion DESC, fecha ASC',
      limit: limite,
    );
    return filas.map(Partida.fromMap).toList();
  }

  /// COUNT, MAX, AVG, SUM.
  Future<Estadisticas> obtenerEstadisticasGlobales() async {
    final db = await _db;
    final filas = await db.rawQuery('''
      SELECT COUNT(*) AS total,
             MAX(puntuacion) AS max_punt,
             AVG(puntuacion) AS media_punt,
             MAX(ficha_maxima) AS max_ficha,
             SUM(duracion_segundos) AS tiempo
      FROM partidas
    ''');
    return Estadisticas.fromMap(filas.first);
  }

  /// GROUP BY jugador.
  Future<List<EstadisticaJugador>> obtenerEstadisticasPorJugador() async {
    final db = await _db;
    final filas = await db.rawQuery('''
      SELECT usuario, MAX(puntuacion) AS mejor, COUNT(*) AS total
      FROM partidas
      GROUP BY usuario
      ORDER BY mejor DESC
    ''');
    return filas.map(EstadisticaJugador.fromMap).toList();
  }
}
