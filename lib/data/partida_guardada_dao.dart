import 'package:sqflite/sqflite.dart';
import '../models/partida_guardada.dart';
import 'database_helper.dart';

/// Partida en curso: una única fila con id = 1.
class PartidaGuardadaDao {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<void> guardar(PartidaGuardada g) async {
    final db = await _db;
    await db.insert('partida_guardada', g.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<PartidaGuardada?> leer() async {
    final db = await _db;
    final filas = await db.query('partida_guardada', where: 'id = ?', whereArgs: [1], limit: 1);
    return filas.isEmpty ? null : PartidaGuardada.fromMap(filas.first);
  }

  Future<bool> existe() async => (await leer()) != null;

  Future<int> borrar({DatabaseExecutor? ejecutor}) async {
    final db = ejecutor ?? await _db;
    return db.delete('partida_guardada', where: 'id = ?', whereArgs: [1]);
  }
}
