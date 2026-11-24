import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/game_logic.dart';
import 'tile_widget.dart';

class BoardWidget extends StatefulWidget {
  final List<int> valores;
  final int paleta;
  final void Function(Direccion) onMover;

  const BoardWidget({
    super.key,
    required this.valores,
    required this.paleta,
    required this.onMover,
  });

  @override
  State<BoardWidget> createState() => _BoardWidgetState();
}

class _BoardWidgetState extends State<BoardWidget> {
  Offset _desplazamiento = Offset.zero;

  void _terminarGesto() {
    final dx = _desplazamiento.dx;
    final dy = _desplazamiento.dy;
    if (dx.abs() < AppTheme.umbralSwipe && dy.abs() < AppTheme.umbralSwipe) {
      return;
    }
    if (dx.abs() > dy.abs()) {
      widget.onMover(dx > 0 ? Direccion.derecha : Direccion.izquierda);
    } else {
      widget.onMover(dy > 0 ? Direccion.abajo : Direccion.arriba);
    }
  }

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onPanStart: (_) {
        _desplazamiento = Offset.zero;
      },
      onPanUpdate: (d) {
        _desplazamiento += d.delta;
      },
      onPanEnd: (_) => _terminarGesto(),
      child: AspectRatio(
        aspectRatio: 1,
        child: Container(
          padding: const EdgeInsets.all(AppTheme.espacioS),
          decoration: BoxDecoration(
            color: oscuro ? AppTheme.tablero : AppTheme.tableroClaro,
            borderRadius: BorderRadius.circular(AppTheme.radio),
            border: Border.all(color: AppTheme.naranja, width: 2),
            boxShadow: [
              BoxShadow(color: AppTheme.naranja.withAlpha(90), blurRadius: 18, spreadRadius: 1),
            ],
          ),
          child: GridView.count(
            crossAxisCount: 4,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              for (final v in widget.valores) TileWidget(valor: v, paleta: widget.paleta),
            ],
          ),
        ),
      ),
    );
  }
}
