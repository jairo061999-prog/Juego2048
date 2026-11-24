import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../data/juego_repository.dart';
import '../data/partida_dao.dart';
import '../data/partida_guardada_dao.dart';
import '../models/partida.dart';
import '../models/partida_guardada.dart';
import '../services/app_state.dart';
import '../services/game_logic.dart';
import '../utils/formato.dart';
import '../widgets/board_widget.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/fondo_degradado.dart';
import '../widgets/score_card.dart';

class JuegoScreen extends StatefulWidget {
  final bool continuar;

  const JuegoScreen({super.key, required this.continuar});

  @override
  State<JuegoScreen> createState() => _JuegoScreenState();
}

class _JuegoScreenState extends State<JuegoScreen> with WidgetsBindingObserver {
  final _partidaDao = PartidaDao();
  final _guardadaDao = PartidaGuardadaDao();
  final _repositorio = JuegoRepository();
  Juego2048? _juego;
  int _segundos = 0;
  int _mejor = 0;
  bool _finalizada = false;
  bool _detalles = false;
  Timer? _timer;

  bool get _enCurso => _juego != null && _juego!.movimientos > 0 && !_finalizada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _cargar();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  // Guardado automatico al pasar a segundo plano
  @override
  void didChangeAppLifecycleState(AppLifecycleState estado) {
    if (estado == AppLifecycleState.paused && _enCurso) {
      _guardar();
    }
  }

  void _aviso(String texto) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
    }
  }

  Future<void> _cargar() async {
    try {
      final stats = await _partidaDao.obtenerEstadisticasGlobales();
      _mejor = stats.puntuacionMaxima;
      PartidaGuardada? g;
      if (widget.continuar) {
        g = await _guardadaDao.leer();
      }
      if (g != null) {
        _juego = Juego2048.desde(List<int>.from(g.tablero), g.puntuacion, g.movimientos);
        _segundos = g.segundos;
      } else {
        _juego = Juego2048();
      }
    } catch (e) {
      _juego = Juego2048();
      _aviso('Error al cargar: $e');
    }
    _iniciarReloj();
    if (mounted) {
      setState(() {});
    }
  }

  void _iniciarReloj() {
    _timer?.cancel();
    _timer = Timer.periodic(AppTheme.intervaloReloj, (_) {
      if (mounted && _juego != null && !_finalizada) {
        setState(() {
          _segundos++;
        });
      }
    });
  }

  void _nuevaPartida() {
    setState(() {
      _juego = Juego2048();
      _segundos = 0;
      _finalizada = false;
    });
    _iniciarReloj();
  }

  Future<void> _reiniciar() async {
    if (_enCurso) {
      final ok = await ConfirmDialog.mostrar(
        context,
        titulo: 'Reiniciar',
        mensaje: 'Se perderá la partida actual. ¿Seguro?',
        textoAceptar: 'Reiniciar',
      );
      if (!ok) {
        return;
      }
    }
    _nuevaPartida();
  }

  Future<void> _mover(Direccion d) async {
    final juego = _juego;
    if (juego == null || _finalizada) {
      return;
    }
    final cambio = juego.mover(d);
    setState(() {});
    if (cambio && juego.terminado) {
      await _finalizar(juego);
    }
  }

  Future<void> _finalizar(Juego2048 juego) async {
    _finalizada = true;
    _timer?.cancel();
    final partida = Partida(
      usuario: appState.usuario ?? 'Invitado',
      puntuacion: juego.puntuacion,
      fichaMaxima: juego.fichaMaxima,
      movimientos: juego.movimientos,
      duracionSegundos: _segundos,
      fecha: DateTime.now(),
    );
    try {
      await _repositorio.terminarPartida(partida);
    } catch (e) {
      _aviso('No se pudo registrar la partida: $e');
    }
    if (!mounted) {
      return;
    }
    final otra = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Fin de partida!'),
        content: Text(
            'Puntuación: ${juego.puntuacion}\nFicha máxima: ${juego.fichaMaxima}\nTiempo: ${formatoTiempo(_segundos)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Inicio')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, true), child: const Text('Jugar de nuevo')),
        ],
      ),
    );
    if (!mounted) {
      return;
    }
    if (otra == true) {
      _nuevaPartida();
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _guardar() async {
    final juego = _juego;
    if (juego == null) {
      return;
    }
    try {
      await _guardadaDao.guardar(PartidaGuardada(
        tablero: List<int>.from(juego.tablero),
        puntuacion: juego.puntuacion,
        movimientos: juego.movimientos,
        segundos: _segundos,
      ));
    } catch (e) {
      _aviso('No se pudo guardar: $e');
    }
  }

  Future<void> _preguntarSalida() async {
    final r = await ConfirmDialog.mostrarOpciones(
      context,
      titulo: '¿Salir de la partida?',
      mensaje: 'Tienes una partida en curso.',
      textoAceptar: 'Guardar y salir',
      textoNeutro: 'Salir sin guardar',
      textoCancelar: 'Cancelar',
    );
    if (r == ConfirmResultado.cancelar) {
      return;
    }
    if (r == ConfirmResultado.aceptar) {
      await _guardar();
      _aviso('Partida guardada');
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget _marcadores(Juego2048 j) {
    return GestureDetector(
      onDoubleTap: () {
        setState(() {
          _detalles = !_detalles;
        });
      },
      child: Column(
        children: [
          Row(children: [
            Expanded(child: ScoreCard(etiqueta: 'PUNTOS', valor: '${j.puntuacion}', color: AppTheme.rosa)),
            Expanded(
                child: ScoreCard(
                    etiqueta: 'MEJOR', valor: '${max(_mejor, j.puntuacion)}', color: AppTheme.naranja)),
          ]),
          Row(children: [
            Expanded(child: ScoreCard(etiqueta: 'MOVS', valor: '${j.movimientos}', color: AppTheme.turquesa)),
            Expanded(
                child: ScoreCard(etiqueta: 'TIEMPO', valor: formatoTiempo(_segundos), color: AppTheme.azul)),
          ]),
          if (_detalles)
            Row(children: [
              Expanded(
                  child: ScoreCard(
                      etiqueta: 'FICHA MÁX', valor: '${j.fichaMaxima}', color: AppTheme.morado)),
              const Expanded(child: ScoreCard(etiqueta: 'TABLERO', valor: '4x4', color: AppTheme.verde)),
            ]),
        ],
      ),
    );
  }

  Widget _flecha(IconData icono, Direccion d) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.espacioXS),
      child: IconButton.filled(
        onPressed: () => _mover(d),
        icon: Icon(icono),
        iconSize: AppTheme.tamIconoFlecha,
      ),
    );
  }

  Widget _flechas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _flecha(Icons.arrow_back, Direccion.izquierda),
        _flecha(Icons.arrow_upward, Direccion.arriba),
        _flecha(Icons.arrow_downward, Direccion.abajo),
        _flecha(Icons.arrow_forward, Direccion.derecha),
      ],
    );
  }

  Widget _botonReiniciar() {
    return FilledButton.icon(
      onPressed: _reiniciar,
      style: FilledButton.styleFrom(backgroundColor: AppTheme.verde),
      icon: const Icon(Icons.refresh),
      label: const Text('Reiniciar'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final juego = _juego;
    return PopScope(
      canPop: !_enCurso,
      onPopInvokedWithResult: (didPop, resultado) {
        if (!didPop) {
          _preguntarSalida();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('2048')),
        body: FondoDegradado(
          pixeles: true,
          intensidad: 0.35,
          child: juego == null
              ? const Center(child: CircularProgressIndicator())
              : OrientationBuilder(
                  builder: (context, orientacion) {
                    final tablero = BoardWidget(
                      valores: juego.tablero,
                      paleta: appState.paleta,
                      onMover: _mover,
                    );
                    if (orientacion == Orientation.landscape) {
                      return Row(
                        children: [
                          Expanded(child: Padding(padding: const EdgeInsets.all(AppTheme.espacioS), child: Center(child: tablero))),
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(AppTheme.espacioS),
                              child: Column(children: [
                                _marcadores(juego),
                                _flechas(),
                                _botonReiniciar(),
                              ]),
                            ),
                          ),
                        ],
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.all(AppTheme.espacioM),
                      child: Column(
                        children: [
                          _marcadores(juego),
                          Expanded(child: Center(child: tablero)),
                          _flechas(),
                          _botonReiniciar(),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
