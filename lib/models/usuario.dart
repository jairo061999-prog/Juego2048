// Modelo inmutable que representa a un usuario registrado en la aplicación.
class Usuario {
  final int? id; // Identificador único autoincremental en BD (nulo antes de insertarse).
  final String usuario;
  final DateTime fechaRegistro;
  final String email;
  final String contrasena; // "sal:hash" (SHA-256), nunca en claro.

  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  // Convierte el usuario en un mapa para SQLite (serializando la fecha a ISO 8601).
  Map<String, Object?> toMap() => {
        if (id != null) 'id': id, // Omite el ID si es nulo para que la BD lo autogenere.
        'usuario': usuario,
        'fecha_registro': fechaRegistro.toIso8601String(),
        'email': email,
        'contrasena': contrasena,
      };

  // Reconstruye un objeto Usuario a partir de una fila de la base de datos.
  factory Usuario.fromMap(Map<String, Object?> m) => Usuario(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        fechaRegistro: DateTime.parse(m['fecha_registro'] as String),
        email: m['email'] as String,
        contrasena: m['contrasena'] as String,
      );
}
