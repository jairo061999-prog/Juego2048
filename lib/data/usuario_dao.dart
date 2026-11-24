import 'package:sqflite/sqflite.dart';
import '../models/usuario.dart';
import 'database_helper.dart';

class UsuarioDao {
  Future<Database> get _db => DatabaseHelper.instance.database;

  Future<int> insertar(Usuario u) async {
    final db = await _db;
    return db.insert('usuarios', u.toMap());
  }

  Future<Usuario?> obtenerPorNombre(String nombre) async {
    final db = await _db;
    final filas = await db.query(
      'usuarios',
      where: 'usuario = ?',
      whereArgs: [nombre],
      limit: 1,
    );
    return filas.isEmpty ? null : Usuario.fromMap(filas.first);
  }
}
