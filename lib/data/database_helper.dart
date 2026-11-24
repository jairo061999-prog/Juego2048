import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Singleton: una única conexión a game2048.db para toda la app.
class DatabaseHelper {
  static const String nombreBd = 'game2048.db';
  static const int versionBd = 2;

  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _abrir();
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), nombreBd);
    return openDatabase(
      ruta,
      version: versionBd,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: _crear,
      onUpgrade: _migrar,
    );
  }

  /// Instalación nueva: esquema completo de la versión 2.
  Future<void> _crear(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL UNIQUE,
        fecha_registro TEXT NOT NULL,
        email TEXT NOT NULL,
        contrasena TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE partidas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        ficha_maxima INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        duracion_segundos INTEGER NOT NULL,
        fecha TEXT NOT NULL,
        tamano_tablero INTEGER NOT NULL DEFAULT 4
      )
    ''');
    await db.execute('''
      CREATE TABLE partida_guardada (
        id INTEGER PRIMARY KEY,
        tablero TEXT NOT NULL,
        puntuacion INTEGER NOT NULL,
        movimientos INTEGER NOT NULL,
        segundos_transcurridos INTEGER NOT NULL
      )
    ''');
  }

  /// Migración sin pérdida de datos.
  /// v1 -> v2: nueva columna tamano_tablero (por defecto 4) en partidas.
  Future<void> _migrar(Database db, int anterior, int nueva) async {
    if (anterior < 2) {
      await db.execute(
        'ALTER TABLE partidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4',
      );
    }
    // if (anterior < 3) { ... } // migraciones futuras
  }
}
