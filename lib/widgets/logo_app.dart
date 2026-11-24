import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Logo de la app con bordes difuminados. Si [animado], aparece con zoom,
/// flota y "respira" con un halo de colores del logo.
class LogoApp extends StatefulWidget {
  final double ancho;
  final bool animado;

  const LogoApp({super.key, this.ancho = 320, this.animado = false});

  @override
  State<LogoApp> createState() => _LogoAppState();
}

class _LogoAppState extends State<LogoApp> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
      AnimationController(vsync: this, duration: const Duration(seconds: 4));

  @override
  void initState() {
    super.initState();
    if (widget.animado) _ctrl.repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Widget _imagen() {
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) => const RadialGradient(
        radius: 0.95,
        colors: [Colors.white, Colors.white, Colors.transparent],
        stops: [0, 0.8, 1],
      ).createShader(r),
      child: Image.asset('assets/images/ic_logo.png', width: widget.ancho, fit: BoxFit.contain),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.animado) return _imagen();
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.elasticOut,
      builder: (context, entrada, hijo) => Transform.scale(scale: entrada, child: hijo),
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final s = sin(_ctrl.value * 2 * pi);
          return Transform.translate(
            offset: Offset(0, -8 * s),
            child: Transform.scale(
              scale: 1 + 0.025 * s,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: widget.ancho * 0.7,
                    height: widget.ancho * 0.4,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Color.lerp(AppTheme.naranja, AppTheme.morado, (s + 1) / 2)!
                              .withAlpha(70),
                          blurRadius: 60 + 20 * s,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),
                  _imagen(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
