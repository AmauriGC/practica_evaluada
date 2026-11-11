// Capa de DATOS: configuración del cliente HTTP (Dio).
//
// Se arma en una función para que todos los que necesiten Dio lo obtengan
// igual de configurado, y para que las pruebas puedan crearlo y cambiarle el
// adaptador (la "red") por uno falso.

import 'package:dio/dio.dart';

import 'bitacora_interceptor.dart';

/// Siempre HTTPS: el tráfico va cifrado. Además, Android e iOS bloquean
/// HTTP en claro por defecto en modo release.
const urlDummyJson = 'https://dummyjson.com';

/// Crea el Dio de la app.
///
/// [interceptores] permite agregar comportamiento extra sin tocar este
/// archivo (en la etapa 6 se usa para provocar errores a propósito).
Dio crearDioRecetas({List<Interceptor> interceptores = const []}) {
  final dio = Dio(
    BaseOptions(
      baseUrl: urlDummyJson,
      // Sin timeouts, una red mala dejaría la pantalla cargando para siempre.
      // connectTimeout: cuánto esperar a que se abra la conexión.
      connectTimeout: const Duration(seconds: 5),
      // receiveTimeout: cuánto esperar la respuesta una vez conectados.
      receiveTimeout: const Duration(seconds: 10),
      // Pedimos que Dio decodifique el cuerpo como JSON.
      responseType: ResponseType.json,
    ),
  );
  // La bitácora va PRIMERO para que registre todas las peticiones,
  // incluso las que modifiquen los interceptores que vengan después.
  dio.interceptors
    ..add(BitacoraInterceptor())
    ..addAll(interceptores);
  return dio;
}
