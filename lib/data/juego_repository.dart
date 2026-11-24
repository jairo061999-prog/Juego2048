import '../models/partida.dart';
import 'database_helper.dart';
import 'partida_dao.dart';
import 'partida_guardada_dao.dart';

/// Une dos DAOs en una operación atómica.
class JuegoRepository {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();

  /// Transacción: inserta la partida en el historial y elimina la partida en
  /// curso. O se hacen las dos cosas o ninguna.
  Future<int> terminarPartida(Partida partida) async {
    final db = await DatabaseHelper.instance.database;
    return db.transaction((txn) async {
      final id = await _partidaDao.insertar(partida, ejecutor: txn);
      await _guardadaDao.borrar(ejecutor: txn);
      return id;
    });
  }
}
