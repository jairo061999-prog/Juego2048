import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../services/app_state.dart';
import '../utils/formato.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/stat_card.dart';
import '../widgets/tile_widget.dart';

/// Recibe solo el id y consulta la BD. Si elimina la partida,
/// devuelve true con Navigator.pop para que el historial se actualice.
class DetalleScreen extends StatefulWidget {
  final int id; // Identificador único de la partida a consultar.

  const DetalleScreen({super.key, required this.id});

  @override
  State<DetalleScreen> createState() => _DetalleScreenState();
}

class _DetalleScreenState extends State<DetalleScreen> {
  final _dao = PartidaDao(); // Acceso a BD para consultar o eliminar la partida.
  late Future<Partida?> _futuro; // Promesa con los datos de la partida cargada.

  @override
  void initState() {
    super.initState();
    _futuro = _dao.obtenerPorId(widget.id); // Inicia la consulta en BD al abrir la pantalla.
  }

  // Vuelve a lanzar la consulta si ocurre un error o se solicita reintentar.
  void _recargar() {
    setState(() {
      _futuro = _dao.obtenerPorId(widget.id);
    });
  }

  // Pide confirmación al usuario, borra la partida en BD y cierra la pantalla notificando el cambio.
  Future<void> _eliminar() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar partida',
      mensaje: 'Esta acción no se puede deshacer. ¿Seguro?',
      textoAceptar: 'Eliminar',
    );
    if (!ok) return; // Cancela si el usuario rechaza el diálogo.
    try {
      await _dao.eliminar(widget.id);
      if (mounted) Navigator.pop(context, true); // Devuelve true para indicar que el listado previo debe refrescarse.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de partida')),
      body: AsyncDataView<Partida?>( // Gestiona automáticamente los estados de carga, error y datos listos.
        future: _futuro,
        onReintentar: _recargar,
        builder: (context, p) {
          if (p == null) {
            return const EmptyStateView(mensaje: 'La partida ya no existe'); // Muestra aviso si el registro no se encuentra.
          }
          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacioL),
            child: Column(
              children: [
                // --- CABECERA: FICHA MÁXIMA, JUGADOR Y FECHA ---
                SizedBox(
                  width: AppTheme.tamFichaDetalle,
                  height: AppTheme.tamFichaDetalle,
                  child: TileWidget(valor: p.fichaMaxima, paleta: appState.paleta), // Representación visual de la ficha récord.
                ),
                const SizedBox(height: AppTheme.espacioM),
                Text(p.usuario,
                    style: const TextStyle(
                        fontSize: AppTheme.tamJugador, fontWeight: FontWeight.bold)),
                Text(formatoFecha(p.fecha)),
                const SizedBox(height: AppTheme.espacioM),

                // --- CUADRÍCULA DE MÉTRICAS DE LA PARTIDA ---
                GridView.count(
                  crossAxisCount: 2, // Muestra las tarjetas en 2 columnas.
                  shrinkWrap: true, // Ajusta su altura al contenido dentro del ScrollView.
                  physics: const NeverScrollableScrollPhysics(), // Delega el desplazamiento al SingleChildScrollView padre.
                  childAspectRatio: AppTheme.proporcionTarjeta,
                  children: [
                    StatCard(titulo: 'Puntuación', valor: '${p.puntuacion}', icono: Icons.star, color: AppTheme.amarillo),
                    StatCard(titulo: 'Ficha máxima', valor: '${p.fichaMaxima}', icono: Icons.grid_view, color: AppTheme.morado),
                    StatCard(titulo: 'Movimientos', valor: '${p.movimientos}', icono: Icons.swipe, color: AppTheme.turquesa),
                    StatCard(titulo: 'Duración', valor: formatoTiempo(p.duracionSegundos), icono: Icons.timer, color: AppTheme.azul),
                  ],
                ),
                const SizedBox(height: AppTheme.espacioM),

                // --- BOTÓN DE ELIMINACIÓN ---
                FilledButton.icon(
                  onPressed: _eliminar,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.rosa),
                  icon: const Icon(Icons.delete),
                  label: const Text('Eliminar partida'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
