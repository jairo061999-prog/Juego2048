import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/preferencias_service.dart';
import '../widgets/fondo_degradado.dart';
import '../widgets/logo_app.dart';

// Pantalla de inicio de sesión con validación de formulario y autocompletado del último usuario.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave para validar los campos del formulario.
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _auth = AuthService(); // Servicio encargado de verificar credenciales en BD.
  bool _cargando = false; // Deshabilita el botón mientras se procesa la autenticación.

  @override
  void initState() {
    super.initState();
    _cargarUltimo(); // Recupera el último nombre de usuario usado en el dispositivo.
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose(); // Libera los controladores de texto para evitar fugas de memoria.
    _claveCtrl.dispose();
    super.dispose();
  }

  // Rellena el campo de usuario con el último inicio de sesión guardado en preferencias.
  Future<void> _cargarUltimo() async {
    final ultimo = await PreferenciasService().leerUltimoUsuario();
    if (mounted) {
      _usuarioCtrl.text = ultimo;
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Valida el formulario, autentica al usuario y navega a la pantalla principal limpiando el historial.
  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return; // Detiene el flujo si algún campo no cumple las reglas de validación.
    }
    setState(() {
      _cargando = true;
    });
    try {
      final u = await _auth.login(_usuarioCtrl.text.trim(), _claveCtrl.text);
      if (!mounted) {
        return;
      }
      if (u == null) {
        _aviso('Usuario o contraseña incorrectos');
      } else {
        appState.usuario = u.usuario; // Guarda el usuario activo en el estado global.
        await PreferenciasService().guardarUltimoUsuario(u.usuario); // Persiste el usuario para futuros inicios.
        if (!mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, Rutas.home, (_) => false); // Navega a Home sin permitir volver atrás al login.
      }
    } catch (e) {
      if (mounted) {
        _aviso('Error: $e');
      }
    }
    if (mounted) {
      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FondoDegradado( // Fondo decorativo con estética pixelada.
        pixeles: true,
        intensidad: 0.6,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.espacioXL),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // --- CABECERA: LOGOTIPO ---
                    const LogoApp(ancho: 260),
                    const SizedBox(height: AppTheme.espacioL),

                    // --- TARJETA DEL FORMULARIO DE ACCESO ---
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.espacioL),
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _usuarioCtrl,
                              decoration: const InputDecoration(
                                  labelText: 'Usuario', prefixIcon: Icon(Icons.person)),
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty) ? 'Escribe tu usuario' : null,
                            ),
                            const SizedBox(height: AppTheme.espacioM),
                            TextFormField(
                              controller: _claveCtrl,
                              obscureText: true, // Oculta los caracteres de la contraseña.
                              decoration: const InputDecoration(
                                  labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
                            ),
                            const SizedBox(height: AppTheme.espacioL),

                            // --- BOTÓN DE ENTRAR Y ENLACE A REGISTRO ---
                            SizedBox(
                              width: double.infinity,
                              child: FilledButton.icon(
                                onPressed: _cargando ? null : _entrar,
                                style: FilledButton.styleFrom(backgroundColor: AppTheme.naranja),
                                icon: const Icon(Icons.login),
                                label: const Text('Entrar'),
                              ),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pushNamed(context, Rutas.registro),
                              child: const Text('¿No tienes cuenta? Regístrate'),
                            ),
                          ],
                        ),
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
