import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../services/auth_service.dart';
import '../services/preferencias_service.dart';
import '../widgets/fondo_degradado.dart';
import '../widgets/logo_app.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usuarioCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _auth = AuthService();
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _cargarUltimo();
  }

  @override
  void dispose() {
    _usuarioCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarUltimo() async {
    final ultimo = await PreferenciasService().leerUltimoUsuario();
    if (mounted) {
      _usuarioCtrl.text = ultimo;
    }
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) {
      return;
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
        appState.usuario = u.usuario;
        await PreferenciasService().guardarUltimoUsuario(u.usuario);
        if (!mounted) {
          return;
        }
        Navigator.pushNamedAndRemoveUntil(context, Rutas.home, (_) => false);
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
      body: FondoDegradado(
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
                    const LogoApp(ancho: 260),
                    const SizedBox(height: AppTheme.espacioL),
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
                              obscureText: true,
                              decoration: const InputDecoration(
                                  labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                              validator: (v) =>
                                  (v == null || v.isEmpty) ? 'Escribe tu contraseña' : null,
                            ),
                            const SizedBox(height: AppTheme.espacioL),
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
