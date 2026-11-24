import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../data/usuario_dao.dart';
import '../models/usuario.dart';

/// Registro y login. La contraseña se guarda como "sal:SHA256(sal+clave)".
class AuthService {
  final _dao = UsuarioDao();

  String _hash(String sal, String clave) =>
      sha256.convert(utf8.encode('$sal$clave')).toString();

  String _nuevaSal() {
    final r = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => r.nextInt(256)));
  }

  /// false si el usuario ya existe.
  Future<bool> registrar(String usuario, String email, String clave) async {
    if (await _dao.obtenerPorNombre(usuario) != null) {
      return false;
    }
    final sal = _nuevaSal();
    await _dao.insertar(Usuario(
      usuario: usuario,
      fechaRegistro: DateTime.now(),
      email: email,
      contrasena: '$sal:${_hash(sal, clave)}',
    ));
    return true;
  }

  /// Devuelve el usuario si las credenciales son correctas, o null.
  Future<Usuario?> login(String usuario, String clave) async {
    final u = await _dao.obtenerPorNombre(usuario);
    if (u == null) {
      return null;
    }
    final partes = u.contrasena.split(':');
    if (partes.length != 2) {
      return null;
    }
    return _hash(partes[0], clave) == partes[1] ? u : null;
  }
}
