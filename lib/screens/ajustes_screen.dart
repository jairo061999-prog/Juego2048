import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../widgets/confirm_dialog.dart';

// Pantalla de configuración donde el usuario cambia el tema, la paleta de fichas, borra datos o cierra sesión.
class AjustesScreen extends StatefulWidget {
  const AjustesScreen({super.key});

  @override
  State<AjustesScreen> createState() => _AjustesScreenState();
}

class _AjustesScreenState extends State<AjustesScreen> {
  final _dao = PartidaDao(); // Acceso a BD para gestionar el historial de partidas.

  // Muestra una notificación breve (SnackBar) en la parte inferior de la pantalla.
  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Solicita confirmación al usuario mediante un diálogo modal y elimina todas las partidas guardadas.
  Future<void> _borrarHistorial() async {
    final ok = await ConfirmDialog.mostrar(
      context,
      titulo: 'Borrar historial',
      mensaje: 'Se eliminarán todas las partidas. ¿Seguro?',
      textoAceptar: 'Borrar',
    );
    if (!ok) {
      return; // Aborta si el usuario cancela el diálogo.
    }
    try {
      await _dao.vaciarHistorial();
      if (mounted) { // Comprueba que la pantalla siga activa antes de actualizar la UI.
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
    final cs = Theme.of(context).colorScheme; // Esquema de colores del tema actual.
    return ListView(
      padding: const EdgeInsets.all(AppTheme.espacioL),
      children: [
        // --- SECCIÓN: SELECCIÓN DE TEMA ---
        const Text('Tema', style: TextStyle(fontSize: AppTheme.tamMedio, fontWeight: FontWeight.bold)),
        const SizedBox(height: AppTheme.espacioS),
        SegmentedButton<ThemeMode>( // Selector segmentado para alternar entre modo claro, oscuro o del sistema.
          segments: const [
            ButtonSegment(value: ThemeMode.light, label: Text('Claro'), icon: Icon(Icons.light_mode)),
            ButtonSegment(value: ThemeMode.dark, label: Text('Oscuro'), icon: Icon(Icons.dark_mode)),
            ButtonSegment(value: ThemeMode.system, label: Text('Sistema'), icon: Icon(Icons.phone_android)),
          ],
          selected: {appState.themeMode},
          onSelectionChanged: (s) async {
            await appState.cambiarTema(s.first); // Persiste el nuevo tema en el estado global.
            if (mounted) {
              setState(() {}); // Reconstruye la pantalla para reflejar la selección.
            }
          },
        ),
        const SizedBox(height: AppTheme.espacioL),

        // --- SECCIÓN: PALETAS DE COLORES DE FICHAS ---
        const Text('Colores de fichas',
            style: TextStyle(fontSize: AppTheme.tamMedio, fontWeight: FontWeight.bold)),
        for (int i = 0; i < AppTheme.paletas.length; i++) // Genera una tarjeta interactiva por cada paleta disponible.
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radio),
              side: BorderSide(
                color: appState.paleta == i ? cs.primary : Colors.transparent, // Resalta el borde de la paleta activa.
                width: AppTheme.grosorSeleccion,
              ),
            ),
            child: ListTile(
              onTap: () async {
                await appState.cambiarPaleta(i); // Guarda la nueva paleta elegida y refresca la interfaz.
                if (mounted) {
                  setState(() {});
                }
              },
              title: Text(AppTheme.nombresPaletas[i]),
              subtitle: Row(
                children: [
                  // Muestra los primeros 8 colores de la paleta como círculos de vista previa.
                  for (final c in AppTheme.paletas[i].take(8))
                    Container(
                      width: AppTheme.tamPunto,
                      height: AppTheme.tamPunto,
                      margin: const EdgeInsets.only(top: AppTheme.espacioXS, right: AppTheme.espacioXS),
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                ],
              ),
              trailing: appState.paleta == i ? const Icon(Icons.check_circle) : null, // Icono de verificación en la opción activa.
            ),
          ),
        const SizedBox(height: AppTheme.espacioM),

        // --- SECCIÓN: ACCIONES DE DATOS Y SESIÓN ---
        FilledButton.icon( // Botón de acción destructiva para vaciar el historial.
          onPressed: _borrarHistorial,
          style: FilledButton.styleFrom(backgroundColor: AppTheme.rosa),
          icon: const Icon(Icons.delete_forever),
          label: const Text('Borrar todo el historial'),
        ),
        const SizedBox(height: AppTheme.espacioM),
        FilledButton.icon( // Botón para cerrar la sesión actual.
          onPressed: () {
            appState.usuario = null; // Limpia el usuario activo.
            Navigator.pushNamedAndRemoveUntil(context, Rutas.bienvenida, (r) => false); // Vuelve al inicio borrando la pila de navegación.
          },
          style: FilledButton.styleFrom(backgroundColor: AppTheme.azul),
          icon: const Icon(Icons.logout),
          label: const Text('Cerrar sesión'),
        ),
      ],
    );
  }
}
