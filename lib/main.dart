import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'routes.dart';
import 'services/app_state.dart';
import 'services/navegacion.dart';
import 'widgets/boton_tema.dart';

final ObservadorRutas _observador = ObservadorRutas(); // Rastrea los cambios y transiciones de rutas en la aplicación.

// Punto de entrada principal: inicializa los bindings de Flutter, carga el estado guardado y arranca la app.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario antes de ejecutar operaciones asíncronas previas a runApp.
  await appState.cargar(); // Recupera preferencias persistidas (como el tema o la paleta elegida).
  runApp(const Game2048App());
}

// Widget raíz que configura el tema, las rutas de navegación y los elementos globales superpuestos.
class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder( // Escucha los cambios en appState para reconstruir la app al cambiar el tema.
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'GameInt Ilerna',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: appState.themeMode, // Aplica dinámicamente el modo claro, oscuro o del sistema.
          navigatorKey: navigatorKey, // Clave global para navegar sin necesidad de BuildContext local.
          navigatorObservers: [_observador],
          initialRoute: Rutas.bienvenida,
          onGenerateRoute: Rutas.generar, // Centraliza la creación y paso de argumentos de todas las pantallas.

          // --- SUPERPOSICIÓN GLOBAL ---
          builder: (context, child) => Stack( // Superpone el botón flotante de cambio de tema por encima de cualquier pantalla.
            fit: StackFit.expand,
            children: [
              child ?? const SizedBox.shrink(),
              const BotonTema(),
            ],
          ),
        );
      },
    );
  }
}
