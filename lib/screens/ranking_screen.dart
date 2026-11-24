import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/estadisticas.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../utils/formato.dart';
import '../widgets/async_data_view.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';
import '../widgets/stat_card.dart';

// Clase auxiliar privada que agrupa los tres conjuntos de datos cargados desde la BD.
class _DatosRanking {
  final List<Partida> top;
  final Estadisticas global;
  final List<EstadisticaJugador> jugadores;
  const _DatosRanking(this.top, this.global, this.jugadores);
}

// Pantalla de clasificación y métricas que muestra estadísticas globales, el Top 10 de partidas y el resumen por jugador.
class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  final _dao = PartidaDao();
  late Future<_DatosRanking> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar(); // Inicia la consulta de todas las estadísticas al abrir la pantalla.
  }

  // Consulta secuencialmente el top 10, las métricas globales y el desglose por jugador.
  Future<_DatosRanking> _cargar() async {
    final top = await _dao.obtenerRanking(limite: 10);
    final global = await _dao.obtenerEstadisticasGlobales();
    final jugadores = await _dao.obtenerEstadisticasPorJugador();
    return _DatosRanking(top, global, jugadores);
  }

  // Vuelve a consultar la BD (usado al deslizar para refrescar, reintentar o volver del detalle).
  Future<void> _recargar() async {
    final nuevo = _cargar();
    setState(() {
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {
      // el error lo muestra AsyncDataView
    }
  }

  // Helper visual para estandarizar los encabezados de cada sección.
  Widget _titulo(String texto) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.espacioS),
        child: Text(texto,
            style: const TextStyle(fontSize: AppTheme.tamMedio, fontWeight: FontWeight.bold)),
      );

  @override
  Widget build(BuildContext context) {
    return AsyncDataView<_DatosRanking>( // Gestiona automáticamente los estados de carga, error y datos listos.
      future: _futuro,
      onReintentar: _recargar,
      builder: (context, d) {
        if (d.global.partidas == 0) { // Muestra estado vacío si aún no existe ninguna partida registrada.
          return RefreshIndicator( // Envuelve en ListView para permitir pull-to-refresh incluso sin datos.
            onRefresh: _recargar,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: const [
                SizedBox(
                  height: AppTheme.altoVacio,
                  child: EmptyStateView(
                    icono: Icons.emoji_events_outlined,
                    mensaje: 'Aún no hay partidas.\nJuega una para ver el ranking.',
                  ),
                ),
              ],
            ),
          );
        }
        final g = d.global;
        return RefreshIndicator(
          onRefresh: _recargar,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppTheme.espacioM),
            children: [
              // --- SECCIÓN 1: CUADRÍCULA DE ESTADÍSTICAS GLOBALES ---
              _titulo('Estadísticas globales'),
              GridView.count(
                crossAxisCount: 3, // Distribuye las tarjetas métricas en 3 columnas.
                shrinkWrap: true, // Ajusta su altura al contenido dentro del ListView padre.
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: AppTheme.proporcionTarjeta,
                children: [
                  StatCard(titulo: 'Partidas', valor: '${g.partidas}', icono: Icons.sports_esports),
                  StatCard(
                      titulo: 'Récord',
                      valor: '${g.puntuacionMaxima}',
                      icono: Icons.emoji_events,
                      color: AppTheme.amarillo),
                  StatCard(
                      titulo: 'Media',
                      valor: g.puntuacionMedia.toStringAsFixed(0), // Redondea la puntuación media sin decimales.
                      icono: Icons.bar_chart,
                      color: AppTheme.azul),
                  StatCard(
                      titulo: 'Ficha máx.',
                      valor: '${g.fichaMaxima}',
                      icono: Icons.grid_view,
                      color: AppTheme.morado),
                  StatCard(
                      titulo: 'Tiempo total',
                      valor: formatoTiempo(g.tiempoTotalSegundos),
                      icono: Icons.timer,
                      color: AppTheme.turquesa),
                ],
              ),

              // --- SECCIÓN 2: TOP 10 MEJORES PARTIDAS ---
              _titulo('Top 10 partidas'),
              for (int i = 0; i < d.top.length; i++)
                PartidaListItem(
                  partida: d.top[i],
                  paleta: appState.paleta,
                  posicion: i + 1, // Asigna el puesto numérico (1 al 10) en el podio.
                  onTap: () async {
                    await Navigator.pushNamed(context, Rutas.detalle, arguments: d.top[i].id);
                    if (mounted) _recargar(); // Refresca el ranking por si la partida fue eliminada en el detalle.
                  },
                ),

              // --- SECCIÓN 3: CLASIFICACIÓN AGREGADA POR JUGADOR ---
              _titulo('Por jugador'),
              for (final j in d.jugadores)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(j.usuario),
                    subtitle: Text('${j.partidas} partida(s)'),
                    trailing: Text('${j.mejorPuntuacion} pts',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
