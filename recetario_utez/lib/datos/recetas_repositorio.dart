// Capa de DATOS: el CONTRATO del repositorio.
//
// Es una clase abstracta: dice QUÉ se puede pedir, no CÓMO se obtiene.
// El ViewModel depende de este contrato y no de DummyJSON. Gracias a eso:
//  - las pruebas le pasan un RepositorioFalso (sin red);
//  - si mañana cambia la fuente (otra API, una base local), el ViewModel
//    y la pantalla no se tocan.
// Este archivo no importa Dio a propósito: la presentación sí lo puede ver.

import '../dominio/receta.dart';

abstract class RecetasRepositorio {
  /// Busca recetas. Texto vacío = recetas en general.
  /// Si algo falla, lanza una [FallaRed] (nunca una DioException).
  Future<PaginaRecetas> buscar({String texto = ''});
}
