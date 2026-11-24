import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Gestiona los tres estados de un Future: carga, error (con reintento) y datos.
class AsyncDataView<T> extends StatelessWidget {
  final Future<T> future;
  final Widget Function(BuildContext context, T datos) builder;
  final VoidCallback onReintentar;

  const AsyncDataView({
    super.key,
    required this.future,
    required this.builder,
    required this.onReintentar,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.espacioXL),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: AppTheme.tamIconoGrande, color: AppTheme.rosa),
                  const SizedBox(height: AppTheme.espacioM),
                  Text('Error al cargar los datos\n${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: AppTheme.espacioM),
                  FilledButton.icon(
                    onPressed: onReintentar,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }
        return builder(context, snap.data as T);
      },
    );
  }
}
