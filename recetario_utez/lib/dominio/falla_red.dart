// Capa de DOMINIO: las fallas que la app sabe manejar.
//
// Son del dominio (y no de Dio) para que el ViewModel pueda reaccionar a
// ellas sin saber qué librería HTTP se usa. La capa de datos traduce cada
// DioException a una de estas (ver lib/datos/traducir_error.dart).

/// `sealed`: solo puede tener las subclases de este archivo. Gracias a eso,
/// un `switch` sobre FallaRed obliga a cubrir los cinco casos; si mañana se
/// agrega uno nuevo, el compilador marca cada switch que falte actualizar.
/// `implements Exception` permite lanzarla con `throw` como cualquier error.
sealed class FallaRed implements Exception {
  const FallaRed();
}

/// No se pudo llegar al servidor (modo avión, sin Wi-Fi, DNS que no existe).
/// Nunca hubo respuesta HTTP.
final class SinConexion extends FallaRed {
  const SinConexion();
}

/// La conexión o la respuesta tardaron más que el timeout configurado.
final class TiempoAgotado extends FallaRed {
  const TiempoAgotado();
}

/// El servidor SÍ respondió, pero con un código 5xx: el problema es de él.
/// Se guarda el código para poder mostrarlo (ej. 503).
final class ErrorDelServidor extends FallaRed {
  const ErrorDelServidor(this.codigo);
  final int codigo;
}

/// El servidor respondió con 4xx: rechazó la petición (la culpa es nuestra,
/// por ejemplo una ruta mal escrita → 404).
final class PeticionRechazada extends FallaRed {
  const PeticionRechazada(this.codigo);
  final int codigo;
}

/// Llegó un 200, pero el cuerpo no tiene la forma esperada (JSON roto,
/// faltan campos, una lista en vez de un objeto...).
final class RespuestaInvalida extends FallaRed {
  const RespuestaInvalida();
}
