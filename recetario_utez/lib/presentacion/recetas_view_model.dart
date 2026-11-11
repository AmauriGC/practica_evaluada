// Capa de PRESENTACIÓN: el ViewModel.
//
// Coordina: recibe la orden de la pantalla ("buscar"), le pide los datos al
// repositorio y traduce el resultado a un ESTADO que la pantalla dibuja.
// No dibuja nada (no importa material.dart) y no sabe de HTTP: solo conoce
// el contrato RecetasRepositorio y las fallas del dominio.

// foundation.dart trae ChangeNotifier sin cargar todos los widgets.
import 'package:flutter/foundation.dart';

import '../datos/recetas_repositorio.dart';
import '../dominio/falla_red.dart';
import '../dominio/receta.dart';
import 'mensajes.dart';

// ─── Estados de la pantalla ───────────────────────────────────────────────
// Un estado `sealed` con una subclase por situación. La pantalla solo puede
// estar en UNO a la vez: es imposible estar "cargando" y "con error" al
// mismo tiempo, cosa que sí podría pasar con varios bool sueltos.

sealed class EstadoRecetas {
  const EstadoRecetas();
}

/// Recién abierta: todavía no se ha buscado nada.
final class RecetasInicial extends EstadoRecetas {
  const RecetasInicial();
}

/// La petición va en camino.
final class RecetasCargando extends EstadoRecetas {
  const RecetasCargando();
}

/// Llegaron recetas. `total` es el que reporta el servidor.
final class RecetasListas extends EstadoRecetas {
  const RecetasListas(this.recetas, this.total);
  final List<Receta> recetas;
  final int total;
}

/// La búsqueda salió bien pero sin resultados. Se recuerda qué se buscó
/// para poder decírselo a la persona.
final class RecetasVacias extends EstadoRecetas {
  const RecetasVacias(this.busqueda);
  final String busqueda;
}

/// Algo falló. Solo se guarda el mensaje ya listo para mostrar.
final class RecetasFallidas extends EstadoRecetas {
  const RecetasFallidas(this.mensaje);
  final String mensaje;
}

// ─── ViewModel ────────────────────────────────────────────────────────────

class RecetasViewModel extends ChangeNotifier {
  // Recibe el CONTRATO, no la clase concreta: en la app es DummyJSON y en las
  // pruebas un repositorio falso. El ViewModel no nota la diferencia.
  RecetasViewModel(this._repositorio);

  final RecetasRepositorio _repositorio;

  EstadoRecetas _estado = const RecetasInicial();
  String _ultimaBusqueda = '';
  // Se marca en dispose() para no avisar a una pantalla que ya se cerró.
  bool _liberado = false;

  EstadoRecetas get estado => _estado;

  /// Derivado del estado (no es un bool aparte que se pueda desincronizar).
  bool get cargando => _estado is RecetasCargando;

  /// Último texto buscado, ya sin espacios. Lo usa reintentar().
  String get ultimaBusqueda => _ultimaBusqueda;

  /// Cuántas recetas rápidas hay en el resultado; 0 en cualquier otro estado.
  int get rapidas => switch (_estado) {
    RecetasListas(:final recetas) => recetas.where((r) => r.esRapida).length,
    _ => 0,
  };

  Future<void> buscar(String texto) async {
    // a) Evita peticiones duplicadas si tocan el botón dos veces.
    if (cargando) return;

    // b) Se guarda limpio para reintentar y para el mensaje de "vacío".
    _ultimaBusqueda = texto.trim();

    // c) Primer aviso: la pantalla muestra el indicador y apaga el botón.
    _cambiar(const RecetasCargando());

    try {
      // d) Se pide la página al repositorio.
      final pagina = await _repositorio.buscar(texto: _ultimaBusqueda);
      // e) Sin recetas NO es error: es un estado propio.
      _cambiar(
        pagina.recetas.isEmpty
            ? RecetasVacias(_ultimaBusqueda)
            : RecetasListas(pagina.recetas, pagina.total),
      );
    } on FallaRed catch (falla) {
      // f) Falla conocida → mensaje claro para la persona.
      _cambiar(RecetasFallidas(mensajePara(falla)));
    } catch (_) {
      // g) Cualquier otra cosa (un bug): la pantalla no se queda cargando.
      _cambiar(const RecetasFallidas(mensajeInesperado));
    }
    // h) El segundo aviso ocurre dentro de _cambiar. En total, dos avisos
    //    por búsqueda: uno al empezar y otro al terminar.
  }

  /// Repite la misma búsqueda (la usa el botón Reintentar).
  Future<void> reintentar() => buscar(_ultimaBusqueda);

  /// Único lugar donde cambia el estado: así nunca se olvida avisar.
  void _cambiar(EstadoRecetas nuevo) {
    _estado = nuevo;
    // Si la pantalla se cerró mientras la petición viajaba, avisar después
    // de dispose() lanzaría un error.
    if (!_liberado) notifyListeners();
  }

  @override
  void dispose() {
    _liberado = true;
    super.dispose();
  }
}
