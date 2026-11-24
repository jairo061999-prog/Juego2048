import 'package:flutter/material.dart';
import 'preferencias_service.dart';

/// Estado global observable: tema, paleta de fichas y usuario activo.
/// Al notificar, MaterialApp se reconstruye y el cambio es inmediato.
class AppState extends ChangeNotifier {
  final _prefs = PreferenciasService();

  ThemeMode themeMode = ThemeMode.system;
  int paleta = 0;
  bool ofertaMostrada = false;
  String? _usuario;

  String? get usuario => _usuario;
  set usuario(String? valor) {
    _usuario = valor;
    ofertaMostrada = false; // en cada login se vuelve a ofrecer continuar
  }

  /// Se llama antes de runApp para evitar el parpadeo de tema.
  Future<void> cargar() async {
    themeMode = await _prefs.leerModoTema();
    paleta = await _prefs.leerPaleta();
  }

  Future<void> cambiarTema(ThemeMode modo) async {
    themeMode = modo;
    notifyListeners();
    await _prefs.guardarModoTema(modo);
  }

  Future<void> cambiarPaleta(int indice) async {
    paleta = indice;
    notifyListeners();
    await _prefs.guardarPaleta(indice);
  }
}

final AppState appState = AppState();
