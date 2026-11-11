// Capa de PRESENTACIÓN (vista): la pantalla principal.
//
// Solo dibuja lo que dice el ViewModel y le pasa las órdenes de la persona.
// No importa nada de lib/datos: no sabe de dónde vienen las recetas.

import 'package:flutter/material.dart';

import 'recetas_view_model.dart';
import 'tarjeta_receta.dart';

/// StatefulWidget porque tiene un TextEditingController, que debe crearse
/// una sola vez y liberarse en dispose().
class RecetasPagina extends StatefulWidget {
  const RecetasPagina({super.key, required this.vm});

  final RecetasViewModel vm;

  @override
  State<RecetasPagina> createState() => _RecetasPaginaState();
}

class _RecetasPaginaState extends State<RecetasPagina> {
  final _texto = TextEditingController();

  // OJO: no se busca en initState ni en build. La pantalla espera a que la
  // persona toque el botón (una prueba revisa que al abrir no se pida nada).

  @override
  void dispose() {
    // El controller reserva recursos; si no se libera, hay fuga de memoria.
    _texto.dispose();
    super.dispose();
  }

  void _buscar() => widget.vm.buscar(_texto.text);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recetario UTEZ')),
      // ListenableBuilder se redibuja cada vez que el ViewModel avisa
      // (notifyListeners). Así el botón y el contenido siguen al estado.
      body: ListenableBuilder(
        listenable: widget.vm,
        builder: (context, _) {
          final vm = widget.vm;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('busqueda'),
                  controller: _texto,
                  decoration: const InputDecoration(
                    labelText: 'Buscar receta',
                    hintText: 'Ej. pasta, chicken, pizza',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  // Muestra la tecla "buscar" en el teclado del celular y
                  // al presionarla (o Enter) también busca.
                  textInputAction: TextInputAction.search,
                  onSubmitted: (_) => _buscar(),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  key: const Key('buscar'),
                  // onPressed null = botón desactivado. Mientras carga no se
                  // puede volver a tocar.
                  onPressed: vm.cargando ? null : _buscar,
                  child: const Text('Buscar recetas'),
                ),
                const SizedBox(height: 16),
                // Expanded: el contenido (y su ListView) toma el espacio
                // restante. Sin él, un ListView dentro de Column truena.
                Expanded(child: _contenido(vm)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Un widget por estado. Como EstadoRecetas es sealed, si falta un caso
  /// el código no compila.
  Widget _contenido(RecetasViewModel vm) {
    return switch (vm.estado) {
      RecetasInicial() => const Center(
        child: Text(
          'Escribe una receta o déjalo vacío y toca Buscar recetas.',
          textAlign: TextAlign.center,
        ),
      ),
      RecetasCargando() => const Center(child: CircularProgressIndicator()),
      // Vacío no es error: se dice qué se buscó (o que no hay en general).
      RecetasVacias(:final busqueda) => Center(
        child: Text(
          busqueda.isEmpty
              ? 'No hay recetas disponibles.'
              : 'No encontramos recetas para "$busqueda".',
          textAlign: TextAlign.center,
        ),
      ),
      // Solo se muestra el mensaje ya preparado, nunca detalles técnicos.
      RecetasFallidas(:final mensaje) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off, size: 48),
            const SizedBox(height: 8),
            Text(mensaje, textAlign: TextAlign.center),
            const SizedBox(height: 8),
            OutlinedButton(
              // Repite la MISMA búsqueda, aunque el campo haya cambiado.
              onPressed: vm.reintentar,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
      RecetasListas(:final recetas, :final total) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // `rapidas` lo calcula el ViewModel; la vista no hace cuentas.
          Text(
            'Mostrando ${recetas.length} de $total recetas · '
            'Rápidas: ${vm.rapidas}',
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.separated(
              itemCount: recetas.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) => TarjetaReceta(receta: recetas[i]),
            ),
          ),
        ],
      ),
    };
  }
}
