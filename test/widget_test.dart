import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:game2048/main.dart';
import 'package:game2048/services/app_state.dart';

void main() {
  testWidgets('Muestra la bienvenida y el botón cambia el tema', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await appState.cargar();

    await tester.pumpWidget(const Game2048App());
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Registro'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.dark_mode));
    await tester.pump();
    expect(appState.themeMode, ThemeMode.dark);
  });
}
