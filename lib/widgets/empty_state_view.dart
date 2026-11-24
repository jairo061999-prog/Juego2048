import 'package:flutter/material.dart';
import '../app_theme.dart';

// Vista reutilizable para mostrar un icono y un mensaje centrado cuando una lista o consulta no devuelve datos.
class EmptyStateView extends StatelessWidget {
  final IconData icono; // Icono ilustrativo del estado vacío (por defecto una bandeja vacía).
  final String mensaje; // Texto descriptivo que explica al usuario por qué no hay contenido.

  const EmptyStateView({super.key, required this.mensaje, this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // Obtiene la paleta del tema activo para aplicar tonos secundarios coherentes.

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacioXL),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Ajusta la altura de la columna únicamente al espacio que ocupan sus hijos.
          children: [
            // --- ICONO ILUSTRATIVO ---
            Icon(icono, size: AppTheme.tamIconoGrande, color: cs.onSurfaceVariant),
            const SizedBox(height: AppTheme.espacioM),

            // --- MENSAJE INFORMATIVO ---
            Text(mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTheme.tamTexto, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
