import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Etiqueta + valor (PUNTOS, MEJOR, MOVS, TIEMPO...).
class ScoreCard extends StatelessWidget {
  final String etiqueta;
  final String valor;
  final Color color;

  const ScoreCard({super.key, required this.etiqueta, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radio),
        side: BorderSide(color: color, width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.espacioS, horizontal: AppTheme.espacioM),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(etiqueta,
                style: TextStyle(
                    fontSize: AppTheme.tamEtiqueta, fontWeight: FontWeight.bold, color: color)),
            Text(valor,
                style: TextStyle(
                    fontSize: AppTheme.tamGrande, fontWeight: FontWeight.w900, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
