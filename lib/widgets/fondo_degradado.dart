import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'pixel_fire_view.dart';

// Contenedor decorativo que aplica un fondo degradado adaptado al tema y opcionalmente añade partículas pixeladas.
class FondoDegradado extends StatelessWidget {
  final Widget child; // Contenido principal que se renderizará sobre el fondo.
  final bool pixeles; // Activa o desactiva la capa de animación de chispas/fuego pixelado.
  final double intensidad; // Controla la densidad o visibilidad del efecto de píxeles.

  const FondoDegradado({
    super.key,
    required this.child,
    this.pixeles = false,
    this.intensidad = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark; // Detecta el brillo actual para elegir la gama cromática.

    return Container(
      decoration: BoxDecoration(
        // --- DEGRADADO VERTICAL SEGÚN TEMA CLARO U OSCURO ---
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: oscuro
              ? const [AppTheme.fondo, Color(0xFF1A1430), AppTheme.fondo] // Tonos oscuros morados/negros para modo noche.
              : const [Color(0xFFFFF8EE), Color(0xFFFFE9CC), Color(0xFFF3E3FF)], // Tonos cálidos crema/lavanda para modo día.
        ),
      ),
      // --- CAPA OPCIONAL DE EFECTO PIXELADO ---
      child: pixeles
          ? PixelFireView(intensidad: intensidad, chispasAlFrente: false, child: child) // Renderiza las partículas por detrás del contenido.
          : child,
    );
  }
}
