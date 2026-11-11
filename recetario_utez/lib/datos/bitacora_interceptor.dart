// Capa de DATOS: bitácora (log) de las peticiones HTTP.
//
// Un interceptor es un "filtro" por el que pasa cada petición, respuesta y
// error de Dio. Aquí solo se aprovecha para escribir una línea en cada paso.
//
// Bitácora SEGURA: solo se registra método, ruta (path), código, tipo de
// error y tiempo. Nunca la URL completa ni la query: ahí viaja lo que la
// persona buscó (y en otras apps, tokens o datos personales). Tampoco
// encabezados ni cuerpo, por la misma razón.

import 'dart:developer' as developer;

import 'package:dio/dio.dart';

class BitacoraInterceptor extends Interceptor {
  /// [escribir] permite decidir a dónde va cada línea. Las pruebas pasan
  /// una lista para revisar lo que se escribió; si no se pasa nada, se usa
  /// developer.log (sale en la consola de flutter run y en DevTools).
  BitacoraInterceptor({void Function(String linea)? escribir})
    : _escribir = escribir ?? _alLog;

  final void Function(String linea) _escribir;

  // Llave para guardar el cronómetro dentro de la petición.
  static const _llaveCronometro = 'bitacora.cronometro';

  static void _alLog(String linea) => developer.log(linea, name: 'http');

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // `extra` es un mapa que viaja con la petición hasta la respuesta o el
    // error; ahí guardamos un cronómetro para medir cuánto tardó.
    options.extra[_llaveCronometro] = Stopwatch()..start();
    // `path` es solo la ruta (/recipes/search), sin ?q=...
    _escribir('→ ${options.method} ${options.path}');
    // SIEMPRE hay que llamar a handler.next: si no, la petición se queda
    // detenida aquí y nunca termina.
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final o = response.requestOptions;
    _escribir('← ${response.statusCode} ${o.method} ${o.path} (${_ms(o)} ms)');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final o = err.requestOptions;
    // Solo hay código si el servidor alcanzó a responder (ej. 503).
    // En "sin red" o "timeout" no hay respuesta, así que no hay código.
    final codigo = err.response?.statusCode;
    final textoCodigo = codigo == null ? '' : ' $codigo';
    _escribir(
      '✗ ${err.type.name}$textoCodigo ${o.method} ${o.path} (${_ms(o)} ms)',
    );
    handler.next(err);
  }

  /// Milisegundos transcurridos desde onRequest (0 si no hay cronómetro).
  int _ms(RequestOptions o) =>
      (o.extra[_llaveCronometro] as Stopwatch?)?.elapsedMilliseconds ?? 0;
}
