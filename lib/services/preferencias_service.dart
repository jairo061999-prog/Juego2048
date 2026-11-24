import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Único punto de acceso a SharedPreferences. Las claves son constantes.
class PreferenciasService {
  static const String _claveTema = 'modo_tema';
  static const String _clavePaleta = 'paleta_fichas';
  static const String _claveUltimoUsuario = 'ultimo_usuario';

  Future<void> guardarModoTema(ThemeMode modo) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_claveTema, modo.name);
  }

  /// Sin valor guardado -> ThemeMode.system.
  Future<ThemeMode> leerModoTema() async {
    final p = await SharedPreferences.getInstance();
    final v = p.getString(_claveTema);
    return ThemeMode.values.firstWhere((m) => m.name == v, orElse: () => ThemeMode.system);
  }

  Future<void> guardarPaleta(int indice) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_clavePaleta, indice);
  }

  Future<int> leerPaleta() async {
    final p = await SharedPreferences.getInstance();
    return p.getInt(_clavePaleta) ?? 0;
  }

  Future<void> guardarUltimoUsuario(String usuario) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_claveUltimoUsuario, usuario);
  }

  Future<String> leerUltimoUsuario() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_claveUltimoUsuario) ?? '';
  }
}
