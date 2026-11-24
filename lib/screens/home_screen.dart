import 'package:flutter/material.dart';
import 'ajustes_screen.dart';
import 'historial_screen.dart';
import 'inicio_screen.dart';
import 'ranking_screen.dart';

/// Contenedor de la navegación principal (NavigationBar inferior):
/// Inicio, Historial, Ranking y Ajustes.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _indice = 0;

  static const _titulos = ['2048', 'Historial', 'Ranking y estadísticas', 'Ajustes'];

  void _ir(int i) {
    setState(() {
      _indice = i;
    });
  }

  Widget _pantalla() {
    switch (_indice) {
      case 1:
        return const HistorialScreen();
      case 2:
        return const RankingScreen();
      case 3:
        return const AjustesScreen();
      default:
        return InicioScreen(onIrA: _ir);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titulos[_indice])),
      // Al cambiar de pestaña la pantalla se recrea y vuelve a consultar la BD.
      body: _pantalla(),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _indice,
        onDestinationSelected: _ir,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Historial'),
          NavigationDestination(icon: Icon(Icons.emoji_events), label: 'Ranking'),
          NavigationDestination(icon: Icon(Icons.settings), label: 'Ajustes'),
        ],
      ),
    );
  }
}
