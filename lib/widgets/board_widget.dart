import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/game_logic.dart';
import 'tile_widget.dart';

// Tablero interactivo 4x4 que dibuja las fichas y traduce gestos táctiles (swipe) en direcciones de movimiento.
class BoardWidget extends StatefulWidget {
  final List<int> valores; // Lista plana de 16 enteros con el valor de cada celda del tablero.
  final int paleta; // Índice de la paleta de colores activa para las fichas.
  final void Function(Direccion) onMover; // Callback que notifica la dirección deslizada al padre.

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
  Offset _desplazamiento = Offset.zero; // Acumula el vector de arrastre desde que el dedo toca la pantalla.

  // Evalúa el desplazamiento acumulado al soltar y dispara el movimiento si supera el umbral mínimo.
  void _terminarGesto() {
    final dx = _desplazamiento.dx;
    final dy = _desplazamiento.dy;
    if (dx.abs() < AppTheme.umbralSwipe && dy.abs() < AppTheme.umbralSwipe) {
      return; // Ignora toques accidentales o arrastres demasiado cortos.
    }
    if (dx.abs() > dy.abs()) { // Determina si predomina el eje horizontal o el vertical.
      widget.onMover(dx > 0 ? Direccion.derecha : Direccion.izquierda);
    } else {
      widget.onMover(dy > 0 ? Direccion.abajo : Direccion.arriba);
    }
  }

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark; // Adapta el color base del tablero al tema.

    return GestureDetector( // Captura gestos de arrastre libre en cualquier dirección.
      onPanStart: (_) {
        _desplazamiento = Offset.zero; // Reinicia el acumulador al iniciar cada gesto.
      },
      onPanUpdate: (d) {
        _desplazamiento += d.delta; // Suma el desplazamiento incremental en cada fotograma.
      },
      onPanEnd: (_) => _terminarGesto(),
      child: AspectRatio(
        aspectRatio: 1, // Fuerza que el tablero sea siempre un cuadrado perfecto (1:1).
        child: Container(
          padding: const EdgeInsets.all(AppTheme.espacioS),
          decoration: BoxDecoration(
            color: oscuro ? AppTheme.tablero : AppTheme.tableroClaro,
            borderRadius: BorderRadius.circular(AppTheme.radio),
            border: Border.all(color: AppTheme.naranja, width: 2),
            boxShadow: [
              BoxShadow(color: AppTheme.naranja.withAlpha(90), blurRadius: 18, spreadRadius: 1), // Resplandor exterior estilo neón/retro.
            ],
          ),
          // --- CUADRÍCULA 4x4 DE FICHAS ---
          child: GridView.count(
            crossAxisCount: 4, // 4 columnas fijas para el tablero estándar de 2048.
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            physics: const NeverScrollableScrollPhysics(), // Desactiva el scroll interno para no interferir con los gestos de juego.
            children: [
              for (final v in widget.valores) TileWidget(valor: v, paleta: widget.paleta),
            ],
          ),
        ),
      ),
    );
  }
}
