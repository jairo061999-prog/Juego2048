import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Tarjeta de estadística: icono, título y valor.
class StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const StatCard({
    super.key,
    required this.titulo,
    required this.valor,
    required this.icono,
    this.color = AppTheme.naranja,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacioM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, color: color),
            const SizedBox(height: AppTheme.espacioXS),
            Text(valor,
                style: TextStyle(
                    fontSize: AppTheme.tamMedio, fontWeight: FontWeight.w900, color: cs.onSurface)),
            Text(titulo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTheme.tamEtiqueta, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
