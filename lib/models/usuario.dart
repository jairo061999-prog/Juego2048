// Modelo inmutable que representa a un usuario registrado en la aplicación.
class Usuario {
  // Identificador único autoincremental en la base de datos (nulo antes de insertarse).
  final int? id;
  // Nombre de usuario elegido para identificarse o mostrarse en rankings.
  final String usuario;
  // Fecha y hora exacta en la que se creó la cuenta del usuario.
  final DateTime fechaRegistro;
  // Dirección de correo electrónico asociada al usuario.
  final String email;
  // Credencial encriptada del usuario almacenada de forma segura.
  final String contrasena; // "sal:hash" (SHA-256), nunca en claro

  // Constructor constante que requiere los datos principales del usuario.
  const Usuario({
    this.id,
    required this.usuario,
    required this.fechaRegistro,
    required this.email,
    required this.contrasena,
  });

  // Convierte la instancia de Usuario en un mapa clave-valor compatible con la base de datos.
  Map<String, Object?> toMap() => {
        // Incluye el 'id' solo si existe, permitiendo la autogeneración en inserciones nuevas.
        if (id != null) 'id': id,
        'usuario': usuario,
        // Serializa la fecha de registro a texto en formato estándar ISO 8601.
        'fecha_registro': fechaRegistro.toIso8601String(),
        'email': email,
        'contrasena': contrasena,
      };

  // Constructor de fábrica que reconstruye un objeto Usuario a partir de un registro de base de datos.
  factory Usuario.fromMap(Map<String, Object?> m) => Usuario(
        id: m['id'] as int?,
        usuario: m['usuario'] as String,
        // Convierte la cadena ISO 8601 almacenada de vuelta a un objeto DateTime.
        fechaRegistro: DateTime.parse(m['fecha_registro'] as String),
        email: m['email'] as String,
        contrasena: m['contrasena'] as String,
      );
}
