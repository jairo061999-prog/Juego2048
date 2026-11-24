import 'package:flutter/material.dart';
import '../app_theme.dart';

class EmptyStateView extends StatelessWidget {
  final IconData icono;
  final String mensaje;

  const EmptyStateView({super.key, required this.mensaje, this.icono = Icons.inbox_outlined});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.espacioXL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: AppTheme.tamIconoGrande, color: cs.onSurfaceVariant),
            const SizedBox(height: AppTheme.espacioM),
            Text(mensaje,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: AppTheme.tamTexto, color: cs.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
