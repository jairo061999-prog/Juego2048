import 'package:flutter/material.dart';
import '../app_theme.dart';

class TileWidget extends StatelessWidget {
  final int valor;
  final int paleta;

  const TileWidget({super.key, required this.valor, required this.paleta});

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final vacia = oscuro ? AppTheme.celdaVacia : AppTheme.celdaVaciaClaro;
    final fondo = valor == 0 ? vacia : AppTheme.colorFicha(valor, paleta);
    final texto = AppTheme.colorTexto(fondo);
    final tamano = valor < 100
        ? AppTheme.tamFichaL
        : (valor < 1000 ? AppTheme.tamFichaM : AppTheme.tamFichaS);
    return AnimatedContainer(
      duration: AppTheme.duracionAnimacion,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppTheme.radioFicha),
      ),
      child: AnimatedSwitcher(
        duration: AppTheme.duracionAnimacion,
        transitionBuilder: (hijo, animacion) => ScaleTransition(scale: animacion, child: hijo),
        child: valor == 0
            ? const SizedBox.shrink(key: ValueKey(0))
            : Text(
                '$valor',
                key: ValueKey(valor),
                style: TextStyle(fontSize: tamano, fontWeight: FontWeight.w900, color: texto),
              ),
      ),
    );
  }
}
