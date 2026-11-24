import 'package:flutter/material.dart';

class AppTheme {
  static const double radio = 10;
  static const double radioFicha = 6;

  // Espaciados
  static const double espacioXS = 4;
  static const double espacioS = 8;
  static const double espacioM = 12;
  static const double espacioL = 16;
  static const double espacioXL = 24;

  // Tamanos de texto
  static const double tamTitulo = 80;
  static const double tamJugador = 26;
  static const double tamGrande = 22;
  static const double tamMedio = 20;
  static const double tamTexto = 18;
  static const double tamEtiqueta = 12;

  // Tamanos de fichas
  static const double tamFichaS = 20;
  static const double tamFichaM = 26;
  static const double tamFichaL = 32;

  // Otros tamanos
  static const double tamIconoGrande = 64;
  static const double tamIconoFlecha = 32;
  static const double tamPunto = 22;
  static const double tamFichaDetalle = 110;
  static const double altoVacio = 300;
  static const double altoVacioS = 150;
  static const double grosorSeleccion = 3;
  static const double proporcionTarjeta = 1.5;
  static const double umbralSwipe = 24;

  // Duraciones
  static const Duration duracionAnimacion = Duration(milliseconds: 180);
  static const Duration intervaloReloj = Duration(seconds: 1);

  // Paleta del logo GameInt Ilerna
  static const Color fondo = Color(0xFF12171B);
  static const Color superficie = Color(0xFF1B2229);
  static const Color tablero = Color(0xFF0C1014);
  static const Color celdaVacia = Color(0xFF1F2830);
  static const Color tableroClaro = Color(0xFFD9BF9A);
  static const Color celdaVaciaClaro = Color(0xFFEBD9BC);
  static const Color rosa = Color(0xFFD8178A); // magenta
  static const Color naranja = Color(0xFFFC9C2B);
  static const Color naranjaFuerte = Color(0xFFFC7523);
  static const Color verde = Color(0xFF34F248);
  static const Color azul = Color(0xFF249BDF);
  static const Color morado = Color(0xFFB52BF0);
  static const Color turquesa = Color(0xFF18BBF6); // cian del brillo
  static const Color amarillo = Color(0xFFFCCD43);

  // Paletas de fichas (2, 4, 8 ... 2048 y mas)
  static const List<String> nombresPaletas = ['Pixel (logo)', 'Océano', 'Fuego', 'Caramelo'];
  static const List<List<Color>> paletas = [
    [
      Color(0xFF18BBF6), Color(0xFF249BDF), Color(0xFF21BDA7), Color(0xFF34F248),
      Color(0xFFFCCD43), Color(0xFFFC9C2B), Color(0xFFFC7523), Color(0xFFD8178A),
      Color(0xFFB52BF0), Color(0xFFFF5CA8), Color(0xFFFFE08A), Color(0xFFFFF3D6),
    ],
    [
      Color(0xFF80DEEA), Color(0xFF4DD0E1), Color(0xFF26C6DA), Color(0xFF00BCD4),
      Color(0xFF00ACC1), Color(0xFF0097A7), Color(0xFF00838F), Color(0xFF0288D1),
      Color(0xFF0277BD), Color(0xFF01579B), Color(0xFF3949AB), Color(0xFF1A237E),
    ],
    [
      Color(0xFFFFF176), Color(0xFFFFEE58), Color(0xFFFFCA28), Color(0xFFFFA726),
      Color(0xFFFF7043), Color(0xFFFF5722), Color(0xFFF4511E), Color(0xFFE53935),
      Color(0xFFD81B60), Color(0xFFC2185B), Color(0xFFAD1457), Color(0xFF880E4F),
    ],
    [
      Color(0xFFFF80AB), Color(0xFFEA80FC), Color(0xFFB388FF), Color(0xFF8C9EFF),
      Color(0xFF82B1FF), Color(0xFF80D8FF), Color(0xFF84FFFF), Color(0xFFA7FFEB),
      Color(0xFFB9F6CA), Color(0xFFCCFF90), Color(0xFFFFFF8D), Color(0xFFFFD180),
    ],
  ];

  static Color colorFicha(int valor, int paleta) {
    final colores = paletas[paleta];
    int indice = 0;
    int v = valor;
    while (v > 2) {
      v = v ~/ 2;
      indice++;
    }
    if (indice >= colores.length) {
      indice = colores.length - 1;
    }
    return colores[indice];
  }

  static Color colorTexto(Color fondo) {
    return fondo.computeLuminance() > 0.3 ? Colors.black87 : Colors.white;
  }

  static ThemeData _tema(Brightness brillo) {
    final oscuro = brillo == Brightness.dark;
    final crema = const Color(0xFFFFF8EE);
    final cs = ColorScheme.fromSeed(seedColor: naranja, brightness: brillo).copyWith(
      primary: naranja,
      onPrimary: Colors.black,
      secondary: morado,
      onSecondary: Colors.white,
      tertiary: turquesa,
      onTertiary: Colors.black,
      error: rosa,
      surface: oscuro ? superficie : crema,
      onSurface: oscuro ? Colors.white : const Color(0xFF1B1B1F),
      primaryContainer: oscuro ? const Color(0xFF3A2410) : const Color(0xFFFFE0B8),
      onPrimaryContainer: oscuro ? amarillo : const Color(0xFF3A2410),
      surfaceContainerLow: oscuro ? const Color(0xFF1F2830) : Colors.white,
      surfaceContainerHigh: oscuro ? const Color(0xFF232D37) : Colors.white,
    );
    OutlineInputBorder borde(Color c, double g) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(radio),
          borderSide: BorderSide(color: c, width: g),
        );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      scaffoldBackgroundColor: oscuro ? fondo : crema,
      appBarTheme: AppBarTheme(
        backgroundColor: oscuro ? tablero : naranja,
        foregroundColor: oscuro ? naranja : Colors.black,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'monospace',
          fontWeight: FontWeight.w900,
          fontSize: 20,
          letterSpacing: 1.5,
          color: oscuro ? naranja : Colors.black,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: oscuro ? tablero : Colors.white,
        border: borde(naranja.withAlpha(140), 1.5),
        enabledBorder: borde(naranja.withAlpha(140), 1.5),
        focusedBorder: borde(turquesa, 2.5),
        errorBorder: borde(rosa, 1.5),
        focusedErrorBorder: borde(rosa, 2.5),
        labelStyle: TextStyle(color: oscuro ? amarillo : const Color(0xFF3A2410)),
        prefixIconColor: naranja,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radio)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: oscuro ? turquesa : const Color(0xFF0B6E94)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: oscuro ? tablero : cs.primaryContainer,
        indicatorColor: naranja,
        iconTheme: WidgetStateProperty.resolveWith((estados) {
          final activo = estados.contains(WidgetState.selected);
          return IconThemeData(color: activo ? Colors.black : (oscuro ? Colors.white70 : cs.onPrimaryContainer));
        }),
        labelTextStyle: WidgetStateProperty.all(
          TextStyle(color: oscuro ? Colors.white70 : cs.onPrimaryContainer, fontSize: 12),
        ),
      ),
    );
  }

  static final ThemeData claro = _tema(Brightness.light);
  static final ThemeData oscuro = _tema(Brightness.dark);
}
