// Capa de DATOS: implementación real del repositorio usando DummyJSON.
//
// Solo main.dart importa esta clase (para "enchufarla" a la app). Todos los
// demás trabajan con el contrato RecetasRepositorio.

import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';
import '../dominio/receta.dart';
import 'recetas_json.dart';
import 'recetas_repositorio.dart';
import 'traducir_error.dart';

/// Cuántas recetas pedir por búsqueda.
const recetasPorPagina = 10;

class DummyJsonRepositorio implements RecetasRepositorio {
  // Recibe el Dio ya configurado (inyección de dependencias): así las
  // pruebas pueden pasarle un Dio con una red falsa.
  DummyJsonRepositorio(this._dio);

  final Dio _dio;

  @override
  Future<PaginaRecetas> buscar({String texto = ''}) async {
    // "  pasta " y "pasta" deben ser la misma búsqueda; "   " cuenta como vacío.
    final limpio = texto.trim();

    try {
      // La query SIEMPRE va en queryParameters, nunca concatenada en la URL:
      // Dio se encarga de codificar espacios, acentos y símbolos (&, ?, #).
      final respuesta = limpio.isEmpty
          ? await _dio.get<Object?>(
              '/recipes',
              queryParameters: {'limit': recetasPorPagina},
            )
          : await _dio.get<Object?>(
              '/recipes/search',
              queryParameters: {'q': limpio, 'limit': recetasPorPagina},
            );

      // Se pide Object? y se revisa el tipo: no confiamos en que el servidor
      // mande lo que esperamos. Si no es un objeto JSON, es inválida.
      return switch (respuesta.data) {
        Map<String, dynamic> json => paginaDesdeJson(json),
        _ => throw const RespuestaInvalida(),
      };
    } on DioException catch (e) {
      // Error de red/HTTP → se traduce a una falla del dominio.
      throw traducirError(e);
    } on FormatException {
      // El JSON era un objeto, pero sin la forma esperada (ver recetas_json).
      throw const RespuestaInvalida();
    }
  }
}
