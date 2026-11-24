class Usuario {
  final int? id;
  final String usuario;
  final DateTime fechaRegistro;
  final String email;
  final String contrasena; // "sal:hash" (SHA-256), nunca en claro

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  Map<String, Object?> toMap() => {
        if (id != null) 'id': id,
        'usuario': usuario,
        'fecha_registro': fechaRegistro.toIso8601String(),
        'email': email,
        'contrasena': contrasena,
      };

  factory Usuario.fromMap(Map<String, Object?> m) => Usuario(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        fechaRegistro: DateTime.parse(m['fecha_registro'] as String),
        email: m['email'] as String,
        contrasena: m['contrasena'] as String,
      );
}
