import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../models/partida.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/partida_list_item.dart';

class HistorialScreen extends StatefulWidget {
  const HistorialScreen({super.key});

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  static const List<int?> _fichas = [null, 256, 512, 1024, 2048];

  final _dao = PartidaDao();
  final _nombreCtrl = TextEditingController();
  final Set<int> _ocultos = {}; // partidas deslizadas pendientes de recarga
  int? _fichaMinima;
  late Future<List<Partida>> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _consultar();
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    super.dispose();
  }

  Future<List<Partida>> _consultar() =>
      _dao.filtrar(usuario: _nombreCtrl.text, fichaMinima: _fichaMinima);

  /// Vuelve a consultar la BD (tras filtrar, borrar, deshacer o arrastrar).
  Future<void> _recargar() async {
    final nuevo = _consultar();
    setState(() {
      _ocultos.clear();
      _futuro = nuevo;
    });
    try {
      await nuevo;
    } catch (_) {
      // el error lo muestra AsyncDataView
    }
  }

  void _aviso(String texto, {SnackBarAction? accion}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(texto), action: accion));
  }

  /// Borrado con posibilidad de deshacer (gesto Dismissible).
  Future<void> _descartar(Partida p) async {
    setState(() {
      _ocultos.add(p.id!);
    });
    try {
      await _dao.eliminar(p.id!);
      if (!mounted) return;
      _aviso('Partida eliminada',
          accion: SnackBarAction(
            label: 'Deshacer',
            onPressed: () async {
              await _dao.restaurar(p);
              if (mounted) _recargar();
            },
          ));
    } catch (e) {
      if (mounted) _aviso('Error al eliminar: $e');
    }
  }

  /// Borrado desde el menú de pulsación larga: pide confirmación.
  Future<void> _eliminarConfirmando(Partida p) async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Eliminar partida',
      mensaje: 'Se borrará la partida de ${p.usuario} (${p.puntuacion} pts).',
      textoAceptar: 'Eliminar',
    );
    if (!ok || !mounted) return;
    try {
      await _dao.eliminar(p.id!);
      if (!mounted) return;
      _aviso('Partida eliminada');
      await _recargar();
    } catch (e) {
      if (mounted) _aviso('Error al eliminar: $e');
    }
  }

  Future<void> _abrirDetalle(Partida p) async {
    final borrada = await Navigator.pushNamed(context, Rutas.detalle, arguments: p.id);
    if (!mounted) return;
    if (borrada == true) {
      _aviso('Partida eliminada');
    }
    await _recargar();
  }

  Future<void> _menu(Partida p) async {
    final opcion = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Ver detalle'),
              onTap: () => Navigator.pop(ctx, 'detalle'),
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: AppTheme.rosa),
              title: const Text('Eliminar'),
              onTap: () => Navigator.pop(ctx, 'eliminar'),
            ),
          ],
        ),
      ),
    );
    if (opcion == 'detalle') {
      await _abrirDetalle(p);
    } else if (opcion == 'eliminar') {
      await _eliminarConfirmando(p);
    }
  }

  Widget _filtros() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.espacioM),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: TextField(
              controller: _nombreCtrl,
              decoration: const InputDecoration(
                labelText: 'Jugador',
                prefixIcon: Icon(Icons.search),
                isDense: true,
              ),
              onChanged: (_) => _recargar(),
            ),
          ),
          const SizedBox(width: AppTheme.espacioS),
          Expanded(
            flex: 2,
            child: DropdownButtonFormField<int?>(
              value: _fichaMinima,
              isDense: true,
              decoration: const InputDecoration(labelText: 'Ficha ≥', isDense: true),
              items: [
                for (final f in _fichas)
                  DropdownMenuItem<int?>(value: f, child: Text(f == null ? 'Todas' : '$f')),
              ],
              onChanged: (v) {
                _fichaMinima = v;
                _recargar();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _filtros(),
        Expanded(
          child: AsyncDataView<List<Partida>>(
            future: _futuro,
            onReintentar: _recargar,
            builder: (context, datos) {
              final lista = datos.where((p) => !_ocultos.contains(p.id)).toList();
              return RefreshIndicator(
                onRefresh: _recargar,
                child: lista.isEmpty
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: const [
                          SizedBox(
                            height: AppTheme.altoVacio,
                            child: EmptyStateView(
                              icono: Icons.history_toggle_off,
                              mensaje: 'No hay partidas que mostrar',
                            ),
                          ),
                        ],
                      )
                    : ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.espacioM),
                        itemCount: lista.length,
                        itemBuilder: (context, i) {
                          final p = lista[i];
                          return Dismissible(
                            key: ValueKey(p.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: AppTheme.espacioXL),
                              color: AppTheme.rosa,
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            onDismissed: (_) => _descartar(p),
                            child: PartidaListItem(
                              partida: p,
                              paleta: appState.paleta,
                              onTap: () => _abrirDetalle(p),
                              onLongPress: () => _menu(p),
                            ),
                          );
                        },
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}
