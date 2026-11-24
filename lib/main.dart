import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'routes.dart';
import 'services/app_state.dart';
import 'services/navegacion.dart';
import 'widgets/boton_tema.dart';

final ObservadorRutas _observador = ObservadorRutas();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await appState.cargar();
  runApp(const Game2048App());
}

class Game2048App extends StatelessWidget {
  const Game2048App({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: appState,
      builder: (context, _) {
        return MaterialApp(
          title: 'GameInt Ilerna',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.claro,
          darkTheme: AppTheme.oscuro,
          themeMode: appState.themeMode,
          navigatorKey: navigatorKey,
          navigatorObservers: [_observador],
          initialRoute: Rutas.bienvenida,
          onGenerateRoute: Rutas.generar,
          builder: (context, child) => Stack(
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