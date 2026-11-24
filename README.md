# 2048 – Flutter (sqflite + shared_preferences)

Si la carpeta no contiene `android/`, ejecutar una vez en la raíz: `flutter create .` y después `flutter pub get`.

## Capas (lib/)
- models/: Usuario, Partida, PartidaGuardada, Estadisticas (toMap/fromMap)
- data/: DatabaseHelper (singleton, v2, onConfigure/onCreate/onUpgrade), UsuarioDao, PartidaDao, PartidaGuardadaDao, JuegoRepository (transacción terminarPartida)
- services/: PreferenciasService, AppState (ChangeNotifier), AuthService (SHA-256 + sal), game_logic
- screens/ y widgets/: interfaz, sin SQL
- routes.dart: rutas con nombre (onGenerateRoute); app_theme.dart: tema, constantes y paletas

## Migración v1 -> v2
`ALTER TABLE partidas ADD COLUMN tamano_tablero INTEGER NOT NULL DEFAULT 4` en onUpgrade; onCreate crea ya el esquema v2.
Nota: la columna de la tabla usuarios se llama `contrasena` (sin ñ) para evitar problemas con identificadores no ASCII.
