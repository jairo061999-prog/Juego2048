import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../widgets/confirm_dialog.dart';

class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _dao = PartidaDao();

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _borrarHistorial() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Borrar historial',
      mensaje: 'Se eliminarán todas las partidas. ¿Seguro?',
      textoAceptar: 'Borrar',
    );
    if (!ok) {
      return;
    }
    try {
      await _dao.vaciarHistorial();
      if (mounted) {
        _aviso('Historial borrado');
      }
    } catch (e) {
      if (mounted) {
        _aviso('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListView(
      padding: const EdgeInsets.all(AppTheme.espacioL),
      children: [
        const Text('Tema', style: TextStyle(fontSize: AppTheme.tamMedio, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.espacioS),
        SegmentedButton<ThemeMode>(
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.dark_mode)),
            ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.phone_android)),
          ],
          selected: {appState.themeMode},
          onSelectionChanged: (s) async {
            await appState.cambiarTema(s.first);
            if (mounted) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: AppTheme.espacioL),
        const Text('Colores de fichas',
            style: TextStyle(fontSize: AppTheme.tamMedio, fontWeight: FontWeight.bold)),
        for (int i = 0; i < AppTheme.paletas.length; i++)
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radio),
              side: BorderSide(
                color: appState.paleta == i ? cs.primary : Colors.transparent,
                width: AppTheme.grosorSeleccion,
              ),
            ),
            child: ListTile(
              onTap: () async {
                await appState.cambiarPaleta(i);
                if (mounted) {
                  setState(() {});
                }
              },
              title: Text(AppTheme.nombresPaletas[i]),
              subtitle: Row(
                children: [
                  for (final c in AppTheme.paletas[i].take(8))
                    Container(
                      width: AppTheme.tamPunto,
                      height: AppTheme.tamPunto,
                      margin: const EdgeInsets.only(top: AppTheme.espacioXS, right: AppTheme.espacioXS),
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                ],
              ),
              trailing: appState.paleta == i ? const Icon(Icons.check_circle) : null,
            ),
          ),
        const SizedBox(height: AppTheme.espacioM),
        FilledButton.icon(
          onPressed: _borrarHistorial,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.rosa),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Borrar todo el historial'),
        ),
        const SizedBox(height: AppTheme.espacioM),
        FilledButton.icon(
          onPressed: () {
            appState.usuario = null;
            Navigator.pushNamedAndRemoveUntil(context, Rutas.bienvenida, (r) => false);
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.azul),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
