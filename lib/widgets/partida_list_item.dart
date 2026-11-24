import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../models/partida.dart';
import '../utils/formato.dart';
import 'tile_widget.dart';

/// Resumen de una partida (historial y ranking).
class PartidaListItem extends StatelessWidget {
  final Partida partida;
  final int paleta;
  final int? posicion;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const PartidaListItem({
    super.key,
    required this.partida,
    required this.paleta,
    this.posicion,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: cs.surfaceContainerLow,
      child: ListTile(
        onTap: onTap,
        onLongPress: onLongPress,
        leading: SizedBox(
          width: 52,
          height: 52,
          child: TileWidget(valor: partida.fichaMaxima, paleta: paleta),
        ),
        title: Text(
          '${posicion != null ? '#$posicion  ' : ''}${partida.puntuacion} pts · ${partida.usuario}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
            '${formatoFecha(partida.fecha)} · ${partida.movimientos} movs · ${formatoTiempo(partida.duracionSegundos)}'),
        trailing: const Icon(Icons.chevron_right),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTheme.espacioM),
      ),
    );
  }
}
