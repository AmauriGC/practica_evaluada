// Capa de DATOS: traduce los errores de Dio a fallas del dominio.
//
// Es la frontera: de aquí hacia arriba (ViewModel, pantalla) nadie conoce
// DioException, solo FallaRed. Si cambiáramos Dio por otro paquete, solo
// cambiaría esta capa.

import 'package:dio/dio.dart';

import '../dominio/falla_red.dart';

FallaRed traducirError(DioException e) {
  // switch sobre TODOS los valores del enum DioExceptionType, sin `_`:
  // si una versión nueva de Dio agrega un tipo, el código deja de compilar
  // y nos obliga a decidir qué hacer con él.
  return switch (e.type) {
    // Cualquier tipo de timeout es "tardó demasiado".
    DioExceptionType.connectionTimeout ||
    DioExceptionType.sendTimeout ||
    DioExceptionType.receiveTimeout ||
    // transformTimeout (Dio 5.11+): tardó demasiado en decodificar la respuesta.
    DioExceptionType.transformTimeout => const TiempoAgotado(),

    // badResponse = el servidor SÍ respondió, pero con un código de error.
    DioExceptionType.badResponse => _porCodigo(e.response?.statusCode ?? 0),

    // `unknown` con FormatException = llegó algo que no es JSON válido.
    DioExceptionType.unknown when e.error is FormatException =>
      const RespuestaInvalida(),

    // Todo lo demás: no hubo comunicación útil con el servidor.
    DioExceptionType.connectionError ||
    DioExceptionType.badCertificate ||
    DioExceptionType.cancel ||
    DioExceptionType.unknown => const SinConexion(),
  };
}

/// 5xx: falla del servidor. Cualquier otro (4xx): rechazó nuestra petición.
FallaRed _porCodigo(int codigo) =>
    codigo >= 500 ? ErrorDelServidor(codigo) : PeticionRechazada(codigo);
