// Capa de PRESENTACIÓN: lo que lee la persona cuando algo falla.
//
// Cada mensaje dice qué pasó y qué puede hacer, en lenguaje claro. Nunca se
// muestra la excepción, la URL ni detalles técnicos: no le sirven a quien usa
// la app y pueden revelar información interna.

import '../dominio/falla_red.dart';

/// Para errores que no son FallaRed (un bug nuestro, algo no previsto).
const mensajeInesperado = 'Algo salió mal. Intenta de nuevo.';

/// Como FallaRed es `sealed`, este switch no necesita `_`: el compilador
/// sabe que estos son todos los casos posibles.
String mensajePara(FallaRed falla) {
  return switch (falla) {
    SinConexion() => 'Sin conexión. Revisa tu red e intenta de nuevo.',
    TiempoAgotado() =>
      'El recetario tardó demasiado en responder. Intenta de nuevo.',
    // `:final codigo` saca el campo `codigo` de la falla para usarlo.
    ErrorDelServidor(:final codigo) =>
      'El recetario no está disponible ($codigo). Intenta más tarde.',
    // 4xx: el error es de la app, la persona no puede arreglarlo.
    PeticionRechazada() =>
      'No pudimos hacer esa búsqueda. Avisa al equipo de desarrollo.',
    RespuestaInvalida() => 'Las recetas llegaron con un formato inesperado.',
  };
}
