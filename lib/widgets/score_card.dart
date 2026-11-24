import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Etiqueta + valor (PUNTOS, MEJOR, MOVS, TIEMPO...).
// Tarjeta compacta con borde de color personalizado para destacar indicadores clave en el tablero y menú.
class ScoreCard extends StatelessWidget {
  final String etiqueta; // Título superior en mayúsculas que identifica la métrica.
  final String valor; // Dato principal formateado que se muestra debajo de la etiqueta.
  final Color color; // Color temático aplicado tanto al borde de la tarjeta como al texto de la etiqueta.

  const ScoreCard({super.key, required this.etiqueta, required this.valor, required this.color});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // Obtiene los colores base del tema activo (claro u oscuro).

    return Card(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radio),
        side: BorderSide(color: color, width: 2), // Resalta el contorno con el color asignado a la métrica.
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.espacioS, horizontal: AppTheme.espacioM),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta la altura de la tarjeta únicamente a su contenido.
          children: [
            // --- ETIQUETA DE LA MÉTRICA ---
            Text(etiqueta,
                style: TextStyle(
                    fontSize: AppTheme.tamEtiqueta, fontWeight: FontWeight.bold, color: color)),

            // --- VALOR PRINCIPAL ---
            Text(valor,
                style: TextStyle(
                    fontSize: AppTheme.tamGrande, fontWeight: FontWeight.w900, color: cs.onSurface)),
          ],
        ),
      ),
    );
  }
}
