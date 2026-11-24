import 'package:flutter/material.dart';

enum ConfirmResultado { aceptar, neutro, cancelar }

/// Diálogo genérico de confirmación (borrar partida, borrar historial, salir...).
class ConfirmDialog {
  static Future<bool> mostrar(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    String textoAceptar = 'Aceptar',
    String textoCancelar = 'Cancelar',
  }) async {
    final r = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(textoCancelar)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(textoAceptar)),
        ],
      ),
    );
    return r ?? false;
  }

  /// Tres opciones: aceptar / neutro / cancelar (cerrar fuera = cancelar).
  static Future<ConfirmResultado> mostrarOpciones(
    BuildContext context, {
    required String titulo,
    required String mensaje,
    required String textoAceptar,
    required String textoNeutro,
    required String textoCancelar,
  }) async {
    final r = await showDialog<ConfirmResultado>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(titulo),
        content: Text(mensaje),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, ConfirmResultado.cancelar),
              child: Text(textoCancelar)),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ConfirmResultado.neutro),
              child: Text(textoNeutro)),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, ConfirmResultado.aceptar),
              child: Text(textoAceptar)),
        ],
      ),
    );
    return r ?? ConfirmResultado.cancelar;
  }
}
