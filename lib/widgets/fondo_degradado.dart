import 'package:flutter/material.dart';
import '../app_theme.dart';
import 'pixel_fire_view.dart';

class FondoDegradado extends StatelessWidget {
  final Widget child;
  final bool pixeles;
  final double intensidad;

  const FondoDegradado({
    super.key,
    required this.child,
    this.pixeles = false,
    this.intensidad = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: oscuro
              ? const [AppTheme.fondo, Color(0xFF1A1430), AppTheme.fondo]
              : const [Color(0xFFFFF8EE), Color(0xFFFFE9CC), Color(0xFFF3E3FF)],
        ),
      ),
      child: pixeles
          ? PixelFireView(intensidad: intensidad, chispasAlFrente: false, child: child)
          : child,
    );
  }
}
