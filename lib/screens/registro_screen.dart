import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../services/auth_service.dart';
import '../widgets/fondo_degradado.dart';

// Pantalla de creación de nueva cuenta con validación de usuario, formato de email y longitud de contraseña.
class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen> {
  final _formKey = GlobalKey<FormState>(); // Clave para ejecutar las validaciones del formulario.
  final _usuarioCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _claveCtrl = TextEditingController();
  final _auth = AuthService(); // Servicio encargado de registrar el usuario en la base de datos.

  @override
  void dispose() {
    _usuarioCtrl.dispose(); // Libera los controladores de texto al cerrar la pantalla.
    _emailCtrl.dispose();
    _claveCtrl.dispose();
    super.dispose();
  }

  void _aviso(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  // Valida los campos, intenta dar de alta al usuario y regresa a la pantalla anterior si tiene éxito.
  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) {
      return; // Aborta el registro si algún campo es inválido.
    }
    try {
      final usuario = _usuarioCtrl.text.trim();
      final creado =
          await _auth.registrar(usuario, _emailCtrl.text.trim(), _claveCtrl.text);
      if (!mounted) {
        return;
      }
      if (!creado) { // Evita duplicados si el nombre de usuario ya está en uso.
        _aviso('Ese usuario ya existe');
        return;
      }
      _aviso('Registro correcto. Ya puedes entrar');
      Navigator.pop(context); // Vuelve a la pantalla previa (Login o Bienvenida).
    } catch (e) {
      if (mounted) {
        _aviso('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: FondoDegradado( // Fondo decorativo con estética pixelada.
        pixeles: true,
        intensidad: 0.6,
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacioXL),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.espacioL),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- CAMPO: NOMBRE DE USUARIO ---
                      TextFormField(
                        controller: _usuarioCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Usuario', prefixIcon: Icon(Icons.person)),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Escribe un usuario' : null,
                      ),
                      const SizedBox(height: AppTheme.espacioM),

                      // --- CAMPO: CORREO ELECTRÓNICO ---
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                            labelText: 'Email', prefixIcon: Icon(Icons.email)),
                        validator: (v) {
                          final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$'); // Expresión regular básica para verificar formato usuario@dominio.ext.
                          if (v == null || !ok.hasMatch(v.trim())) {
                            return 'Email no válido (debe llevar @)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppTheme.espacioM),

                      // --- CAMPO: CONTRASEÑA ---
                      TextFormField(
                        controller: _claveCtrl,
                        obscureText: true, // Oculta el texto introducido.
                        decoration: const InputDecoration(
                            labelText: 'Contraseña', prefixIcon: Icon(Icons.lock)),
                        validator: (v) =>
                            (v == null || v.length < 4) ? 'Mínimo 4 caracteres' : null,
                      ),
                      const SizedBox(height: AppTheme.espacioL),

                      // --- BOTÓN DE CONFIRMACIÓN ---
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _registrar,
                          style: FilledButton.styleFrom(backgroundColor: AppTheme.morado, foregroundColor: Colors.white),
                          icon: const Icon(Icons.person_add),
                          label: const Text('Crear cuenta'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
