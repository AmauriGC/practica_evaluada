// Capa de PRESENTACIÓN (vista): dibuja UNA receta.
//
// Es StatelessWidget porque no tiene estado propio: todo lo que muestra
// viene de la Receta que recibe. Solo conoce el dominio.

import 'package:flutter/material.dart';

import '../dominio/receta.dart';

class TarjetaReceta extends StatelessWidget {
  const TarjetaReceta({super.key, required this.receta});

  final Receta receta;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título: el nombre de la receta.
            Text(receta.nombre, style: tema.textTheme.titleMedium),
            const SizedBox(height: 4),
            // Subtítulo: cocina · etiqueta en español de la dificultad.
            Text(
              '${receta.cocina} · ${receta.dificultad.etiqueta}',
              style: tema.textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            // tiempoTotal lo calcula el dominio; la vista solo lo muestra.
            Text(
              'Tiempo: ${receta.tiempoTotal} min · '
              'Porciones: ${receta.porciones}',
            ),
            // toStringAsFixed(1): siempre un decimal (5 → "5.0", 4.44 → "4.4").
            Text('Calificación: ${receta.calificacion.toStringAsFixed(1)}'),
            // El aviso solo se agrega a la lista si la receta es rápida.
            if (receta.esRapida) ...[
              const SizedBox(height: 8),
              const Chip(
                avatar: Icon(Icons.bolt, size: 18),
                label: Text('Rápida'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
