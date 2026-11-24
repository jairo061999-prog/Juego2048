import 'package:flutter/material.dart';
import '../app_theme.dart';

// Representa una celda individual del tablero 2048 con animación de color y escala según su valor.
class TileWidget extends StatelessWidget {
  final int valor; // Número de la ficha (0 representa una casilla vacía).
  final int paleta; // Índice de la paleta de colores seleccionada en ajustes.

  const TileWidget({super.key, required this.valor, required this.paleta});

  @override
  Widget build(BuildContext context) {
    final oscuro = Theme.of(context).brightness == Brightness.dark;
    final vacia = oscuro ? AppTheme.celdaVacia : AppTheme.celdaVaciaClaro; // Color base cuando no hay ficha.
    final fondo = valor == 0 ? vacia : AppTheme.colorFicha(valor, paleta); // Calcula el color según el valor y la paleta.
    final texto = AppTheme.colorTexto(fondo); // Garantiza contraste legible sobre el color de fondo.
    final tamano = valor < 100 // Ajusta el tamaño de fuente según la cantidad de dígitos (1-2, 3 o 4+).
        ? AppTheme.tamFichaL
        : (valor < 1000 ? AppTheme.tamFichaM : AppTheme.tamFichaS);

    return AnimatedContainer( // Transiciona suavemente el color de fondo al aparecer o fusionarse una ficha.
      duration: AppTheme.duracionAnimacion,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(AppTheme.radioFicha),
      ),
      child: AnimatedSwitcher( // Aplica un efecto de escala (pop) cada vez que cambia el número de la celda.
        duration: AppTheme.duracionAnimacion,
        transitionBuilder: (hijo, animacion) => ScaleTransition(scale: animacion, child: hijo),
        child: valor == 0
            ? const SizedBox.shrink(key: ValueKey(0)) // No muestra texto si la celda está vacía.
            : Text(
                '$valor',
                key: ValueKey(valor), // La clave única dispara la animación al cambiar el valor.
                style: TextStyle(fontSize: tamano, fontWeight: FontWeight.w900, color: texto),
              ),
      ),
    );
  }
}
