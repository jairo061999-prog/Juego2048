import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../routes.dart';
import '../services/app_state.dart';
import '../widgets/async_data_view.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/fondo_degradado.dart';
import '../widgets/logo_app.dart';
import '../widgets/score_card.dart';

// Clase auxiliar privada que agrupa los datos necesarios para renderizar el menú principal.
class _DatosInicio {
  final int mejor;
  final bool hayGuardada;
  const _DatosInicio(this.mejor, this.hayGuardada);
}

// Pantalla principal (dashboard) con acceso a jugar, continuar partida y navegar entre pestañas.
class InicioScreen extends StatefulWidget {
  final void Function(int) onIrA; // Callback para cambiar la pestaña activa en la navegación inferior.

  const InicioScreen({super.key, required this.onIrA});

  @override
  State<InicioScreen> createState() => _InicioScreenState();
}

class _InicioScreenState extends State<InicioScreen> {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();
  late Future<_DatosInicio> _futuro;

  @override
  void initState() {
    super.initState();
    _futuro = _cargar(); // Inicia la carga del récord y comprueba si existe partida guardada.
  }

  // Consulta en BD la puntuación máxima y verifica si hay una partida en curso pendiente.
  Future<_DatosInicio> _cargar() async {
    final stats = await _partidaDao.obtenerEstadisticasGlobales();
    final hay = await _guardadaDao.existe();
    if (hay && !appState.ofertaMostrada) { // Ofrece reanudar la partida automáticamente solo una vez por sesión.
      appState.ofertaMostrada = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _ofrecerContinuar()); // Espera a que termine el frame actual antes de abrir el diálogo.
    }
    return _DatosInicio(stats.puntuacionMaxima, hay);
  }

  void _recargar() {
    setState(() {
      _futuro = _cargar();
    });
  }

  /// Al abrir la app con una partida guardada: continuar o empezar de nuevo.
  Future<void> _ofrecerContinuar() async {
    if (!mounted) {
      return;
    }
    final continuar = await ConfirmDialog.mostrar(
      context,
      titulo: 'Partida guardada',
      mensaje: 'Tienes una partida sin terminar. ¿Quieres continuarla o empezar una nueva?',
      textoAceptar: 'Continuar',
      textoCancelar: 'Nueva partida',
    );
    if (!mounted) {
      return;
    }
    if (continuar) {
      await _jugar(true);
    } else {
      await _guardadaDao.borrar(); // Descarta el progreso anterior si el usuario elige empezar de cero.
      _recargar();
    }
  }

  // Abre la pantalla de juego indicando si debe cargar el estado guardado y recarga los datos al volver.
  Future<void> _jugar(bool continuar) async {
    await Navigator.pushNamed(context, Rutas.juego, arguments: continuar);
    if (mounted) {
      _recargar();
    }
  }

  // Inicia una nueva partida, solicitando confirmación previa si se va a sobrescribir una guardada.
  Future<void> _nueva(bool hayGuardada) async {
    if (hayGuardada) {
      final ok = await ConfirmDialog.mostrar(
        context,
        titulo: 'Nueva partida',
        mensaje: 'Se descartará la partida guardada. ¿Seguro?',
        textoAceptar: 'Empezar',
      );
      if (!ok) {
        return;
      }
      await _guardadaDao.borrar();
    }
    if (mounted) {
      await _jugar(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FondoDegradado( // Fondo degradado con estética pixelada.
      pixeles: true,
      intensidad: 0.4,
      child: AsyncDataView<_DatosInicio>(
        future: _futuro,
        onReintentar: _recargar,
        builder: (context, d) => Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.espacioXL),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420), // Limita el ancho en pantallas grandes.
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // --- CABECERA: LOGO, USUARIO Y RÉCORD ---
                  const LogoApp(ancho: 220),
                  Text('Jugador: ${appState.usuario ?? 'Invitado'}',
                      style: const TextStyle(
                          fontSize: AppTheme.tamJugador, fontWeight: FontWeight.bold)),
                  ScoreCard(etiqueta: 'MEJOR PUNTUACIÓN', valor: '${d.mejor}', color: AppTheme.naranja),
                  const SizedBox(height: AppTheme.espacioM),

                  // --- ACCIONES DE JUEGO (NUEVA / CONTINUAR) ---
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _nueva(d.hayGuardada),
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Nueva partida'),
                    ),
                  ),
                  if (d.hayGuardada) ...[ // Muestra el botón de reanudar únicamente si existe una partida guardada.
                    const SizedBox(height: AppTheme.espacioS),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _jugar(true),
                        style: FilledButton.styleFrom(backgroundColor: AppTheme.verde, foregroundColor: Colors.black),
                        icon: const Icon(Icons.restore),
                        label: const Text('Continuar partida'),
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTheme.espacioS),

                  // --- ACCESOS DIRECTOS A OTRAS PESTAÑAS ---
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onIrA(1), // Cambia a la pestaña de Historial.
                          icon: const Icon(Icons.history),
                          label: const Text('Historial'),
                        ),
                      ),
                      const SizedBox(width: AppTheme.espacioS),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onIrA(2), // Cambia a la pestaña de Ranking.
                          icon: const Icon(Icons.emoji_events),
                          label: const Text('Ranking'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.espacioS),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => widget.onIrA(3), // Cambia a la pestaña de Ajustes.
                      icon: const Icon(Icons.settings),
                      label: const Text('Ajustes'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
