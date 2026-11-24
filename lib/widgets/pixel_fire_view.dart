import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../app_theme.dart';

/// Fondo pixelado estilo Unity: brasas de "fuego" subiendo por detrás del
/// contenido y chispas en forma de + (como las del logo) por delante.
class PixelFireView extends StatefulWidget {
  final Widget? child;
  final double intensidad; // 0.3 suave ... 1 completo
  final bool chispasAlFrente;

  const PixelFireView({
    super.key,
    this.child,
    this.intensidad = 1,
    this.chispasAlFrente = true,
  });

  @override
  State<PixelFireView> createState() => _PixelFireViewState();
}

class _Particula {
  double x0 = 0, x = 0, y = 0, vx = 0, vy = 0;
  double vida = 0, dur = 1, alcance = 1, fase = 0;
  int tam = 1;
  bool cruz = false;
  Color color = Colors.white;
}

class _PixelFireViewState extends State<PixelFireView> with SingleTickerProviderStateMixin {
  static const double _celda = 6;
  static const _coloresFuego = [AppTheme.amarillo, AppTheme.naranja, AppTheme.rosa, AppTheme.morado];
  static const _coloresChispa = [
    AppTheme.turquesa, AppTheme.azul, AppTheme.morado, AppTheme.verde,
    AppTheme.naranja, AppTheme.amarillo, AppTheme.rosa,
  ];

  final _rnd = Random();
  final _tick = ValueNotifier<int>(0);
  late final Ticker _ticker;
  late final List<_Particula> _brasas;
  late final List<_Particula> _chispas;
  Duration _ultimo = Duration.zero;

  @override
  void initState() {
    super.initState();
    final nB = (70 * widget.intensidad).round().clamp(8, 120).toInt();
    final nC = (28 * widget.intensidad).round().clamp(6, 60).toInt();
    _brasas = List.generate(nB, (_) => _nuevaBrasa(_Particula(), true));
    _chispas = List.generate(nC, (_) => _nuevaChispa(_Particula()));
    _ticker = createTicker(_paso)..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _tick.dispose();
    super.dispose();
  }

  _Particula _nuevaBrasa(_Particula p, bool inicial) {
    p.x0 = _rnd.nextDouble();
    p.dur = 2.5 + _rnd.nextDouble() * 3.5;
    p.alcance = 0.4 + _rnd.nextDouble() * 0.7;
    p.fase = _rnd.nextDouble() * 6.28;
    p.tam = 1 + _rnd.nextInt(3);
    p.vida = inicial ? _rnd.nextDouble() : 0;
    return p;
  }

  _Particula _nuevaChispa(_Particula p) {
    p.x = _rnd.nextDouble();
    p.y = _rnd.nextDouble();
    p.vx = (_rnd.nextDouble() - 0.5) * 0.02;
    p.vy = -(0.005 + _rnd.nextDouble() * 0.025);
    p.fase = _rnd.nextDouble() * 6.28;
    p.cruz = _rnd.nextDouble() < 0.4;
    p.tam = 1 + _rnd.nextInt(2);
    p.color = _coloresChispa[_rnd.nextInt(_coloresChispa.length)];
    p.vida = 0;
    return p;
  }

  void _paso(Duration t) {
    final dt = ((t - _ultimo).inMicroseconds / 1e6).clamp(0.0, 0.05).toDouble();
    _ultimo = t;
    for (final p in _brasas) {
      p.vida += dt / p.dur;
      if (p.vida >= 1) _nuevaBrasa(p, false);
    }
    for (final p in _chispas) {
      p.vida += dt; // tiempo acumulado (parpadeo)
      p.x += p.vx * dt;
      p.y += p.vy * dt;
      if (p.y < -0.05) p.y = 1.05;
      if (p.x < -0.05) p.x = 1.05;
      if (p.x > 1.05) p.x = -0.05;
    }
    _tick.value++;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(painter: _CapaPainter(_brasas, true, _tick)),
          ),
        ),
        if (widget.child != null) widget.child!,
        if (widget.chispasAlFrente)
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(painter: _CapaPainter(_chispas, false, _tick)),
              ),
            ),
          ),
      ],
    );
  }
}

class _CapaPainter extends CustomPainter {
  final List<_Particula> ps;
  final bool fuego;
  final Paint _pincel = Paint()..isAntiAlias = false;

  _CapaPainter(this.ps, this.fuego, Listenable repaint) : super(repaint: repaint);

  static Color _colorFuego(double v) {
    const c = _PixelFireViewState._coloresFuego;
    final t = (v * (c.length - 1)).clamp(0.0, c.length - 1.0).toDouble();
    final i = t.floor().clamp(0, c.length - 2).toInt();
    return Color.lerp(c[i], c[i + 1], t - i)!;
  }

  void _cuadro(Canvas canvas, Size s, double nx, double ny, int celdas, Color color, double alfa) {
    const cs = _PixelFireViewState._celda;
    final px = (nx * s.width / cs).floorToDouble() * cs;
    final py = (ny * s.height / cs).floorToDouble() * cs;
    _pincel.color = color.withAlpha((alfa.clamp(0.0, 1.0) * 255).round());
    canvas.drawRect(Rect.fromLTWH(px, py, cs * celdas, cs * celdas), _pincel);
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (fuego) {
      final rect = Rect.fromLTWH(0, size.height * 0.55, size.width, size.height * 0.45);
      canvas.drawRect(
        rect,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [AppTheme.naranjaFuerte.withAlpha(70), AppTheme.rosa.withAlpha(0)],
          ).createShader(rect),
      );
      for (final p in ps) {
        final v = p.vida;
        final y = 1.03 - v * p.alcance;
        final x = p.x0 + sin(p.fase + v * 5) * 0.025;
        final alfa = min(1.0, v * 12) * (1 - v) * 0.9;
        final celdas = max(1, (p.tam * (1 - v * 0.5)).round());
        _cuadro(canvas, size, x, y, celdas, _colorFuego(v), alfa);
      }
    } else {
      const cs = _PixelFireViewState._celda;
      for (final p in ps) {
        final alfa = 0.35 + 0.65 * (0.5 + 0.5 * sin(p.fase + p.vida * 3));
        if (p.cruz) {
          // "+" de 5 cuadros, como las chispas del logo
          final dx = 1 / (size.width / cs);
          final dy = 1 / (size.height / cs);
          _cuadro(canvas, size, p.x, p.y, 1, p.color, alfa);
          _cuadro(canvas, size, p.x - dx, p.y, 1, p.color, alfa);
          _cuadro(canvas, size, p.x + dx, p.y, 1, p.color, alfa);
          _cuadro(canvas, size, p.x, p.y - dy, 1, p.color, alfa);
          _cuadro(canvas, size, p.x, p.y + dy, 1, p.color, alfa);
        } else {
          _cuadro(canvas, size, p.x, p.y, p.tam, p.color, alfa);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _CapaPainter old) => false; // repinta vía `repaint`
}
