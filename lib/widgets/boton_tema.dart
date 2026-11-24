import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/app_state.dart';
import '../services/navegacion.dart';

/// Botones flotantes: flecha para retroceder (solo si hay pantalla anterior)
/// y luna para cambiar entre modo claro y oscuro. Se arrastran con el dedo.
class BotonTema extends StatefulWidget {
  const BotonTema({super.key});

  @override
  State<BotonTema> createState() => _BotonTemaState();
}

class _BotonTemaState extends State<BotonTema> {
  static const double _tam = 48;
  static const double _sep = 8;
  Offset? _pos;

  Widget _boton({
    required IconData icono,
    required VoidCallback alTocar,
    required bool oscuro,
  }) {
    return GestureDetector(
      onTap: alTocar,
      child: Container(
        width: _tam,
        height: _tam,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: oscuro ? AppTheme.amarillo : Colors.black87,
          border: Border.all(color: oscuro ? Colors.white : AppTheme.amarillo, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black54, blurRadius: 8, offset: Offset(0, 3)),
          ],
        ),
        child: Icon(icono, color: oscuro ? Colors.black : AppTheme.amarillo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final alto = _tam * 2 + _sep;
    final inicio = _pos ?? Offset(size.width - _tam - 8, size.height * 0.5);
    final x = inicio.dx.clamp(0.0, size.width - _tam).toDouble();
    final y = inicio.dy.clamp(0.0, size.height - alto).toDouble();

    return Positioned(
      left: x,
      top: y,
      child: GestureDetector(
        onPanUpdate: (d) => setState(() => _pos = Offset(x + d.delta.dx, y + d.delta.dy)),
        child: ValueListenableBuilder<bool>(
          valueListenable: puedeRetroceder,
          builder: (context, puede, _) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (puede) ...[
                  _boton(
                    icono: Icons.arrow_back,
                    oscuro: oscuro,
                    alTocar: () => navigatorKey.currentState?.maybePop(),
                  ),
                  const SizedBox(height: _sep),
                ],
                _boton(
                  icono: Icons.dark_mode,
                  oscuro: oscuro,
                  alTocar: () =>
                      appState.cambiarTema(oscuro ? ThemeMode.light : ThemeMode.dark),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}