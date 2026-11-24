import 'package:flutter/material.dart';
import 'screens/bienvenida_screen.dart';
import 'screens/detalle_screen.dart';
import 'screens/home_screen.dart';
import 'screens/juego_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registro_screen.dart';

class Rutas {
  static const String bienvenida = '/bienvenida';
  static const String login = '/login';
  static const String registro = '/registro';
  static const String home = '/home';
  static const String juego = '/juego';
  static const String detalle = '/detalle';

  static Route<dynamic> generar(RouteSettings ajustes) {
    final Widget pantalla;
    if (ajustes.name == login) {
      pantalla = const LoginScreen();
    } else if (ajustes.name == registro) {
      pantalla = const RegistroScreen();
    } else if (ajustes.name == home) {
      pantalla = const HomeScreen();
    } else if (ajustes.name == juego) {
      pantalla = JuegoScreen(continuar: ajustes.arguments as bool);
    } else if (ajustes.name == detalle) {
      pantalla = DetalleScreen(id: ajustes.arguments as int);
    } else {
      pantalla = const BienvenidaScreen();
    }
    return MaterialPageRoute(builder: (_) => pantalla, settings: ajustes);
  }
}
