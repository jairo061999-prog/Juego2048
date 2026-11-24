import 'package:flutter/material.dart';

/// Llave global para poder retroceder desde el botón flotante.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// Indica si hay una pantalla anterior a la que volver.
final ValueNotifier<bool> puedeRetroceder = ValueNotifier<bool>(false);

/// Observa los cambios de pantalla para mostrar u ocultar la flecha.
class ObservadorRutas extends NavigatorObserver {
  void _actualizar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      puedeRetroceder.value = navigator?.canPop() ?? false;
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _actualizar();

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _actualizar();

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _actualizar();

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _actualizar();
}