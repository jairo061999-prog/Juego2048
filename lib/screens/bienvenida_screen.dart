import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../routes.dart';
import '../widgets/logo_app.dart';
import '../widgets/pixel_fire_view.dart';

// Pantalla inicial de bienvenida que muestra el logotipo animado y da acceso al login o registro.
class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ancho = MediaQuery.of(context).size.width; // Ancho actual de la pantalla del dispositivo.
    final logo = (ancho * 0.95).clamp(220.0, 460.0).toDouble(); // Tamaño responsivo del logo acotado entre 220 y 460 px.
    final oscuro = Theme.of(context).brightness == Brightness.dark; // Detecta si está activo el modo oscuro.

    return Scaffold(
      backgroundColor: oscuro ? AppTheme.fondo : const Color(0xFFFFF8EE), // Fondo adaptado según el brillo del tema.
      body: PixelFireView( // Fondo decorativo animado con efecto de fuego pixelado.
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView( // Permite desplazamiento vertical en pantallas pequeñas o apaisadas.
              padding: const EdgeInsets.all(AppTheme.espacioXL),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420), // Limita el ancho máximo del contenido en pantallas grandes.
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // --- LOGOTIPO PRINCIPAL ---
                    LogoApp(ancho: logo, animado: true),
                    const SizedBox(height: AppTheme.espacioL),

                    // --- MENSAJE DE BIENVENIDA CON ANIMACIÓN DE ENTRADA ---
                    TweenAnimationBuilder<double>( // Anima la aparición progresiva (opacidad y desplazamiento vertical) del título.
                      tween: Tween(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 1200),
                      curve: Curves.easeOut,
                      builder: (context, v, hijo) => Opacity(
                        opacity: v,
                        child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: hijo),
                      ),
                      child: Text(
                        '¡Bienvenidos a los nuevos adversarios!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: oscuro ? Colors.white : Colors.black,
                          letterSpacing: 1,
                          shadows: oscuro
                              ? const [Shadow(color: AppTheme.naranjaFuerte, offset: Offset(2, 2))] // Sombra retro solo en modo oscuro.
                              : const [],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.espacioXL),

                    // --- BOTONES DE ACCESO ---
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon( // Botón principal para ir al inicio de sesión.
                        onPressed: () => Navigator.pushNamed(context, Rutas.login),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.naranja,
                          foregroundColor: Colors.black,
                        ),
                        icon: const Icon(Icons.login),
                        label: const Text('Login',
                            style: TextStyle(fontSize: AppTheme.tamTexto, fontWeight: FontWeight.w800)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.espacioM),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon( // Botón secundario con borde para crear una cuenta nueva.
                        onPressed: () => Navigator.pushNamed(context, Rutas.registro),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.turquesa,
                          side: const BorderSide(color: AppTheme.turquesa, width: 2),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radio)),
                        ),
                        icon: const Icon(Icons.person_add),
                        label: const Text('Registro',
                            style: TextStyle(fontSize: AppTheme.tamTexto, fontWeight: FontWeight.w800)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
