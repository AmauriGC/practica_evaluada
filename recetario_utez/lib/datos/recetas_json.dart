// Capa de DATOS: traduce el JSON de DummyJSON a objetos del dominio.
//
// Este es el ÚNICO archivo que conoce los nombres de las llaves del JSON
// ("name", "cuisine", "rating"...). Si la API cambia un nombre, solo se
// modifica aquí: el dominio y la interfaz no se enteran.

import 'package:recetario_utez/dominio/receta.dart';

/// Traduce el texto de la API a nuestro enum.
///
/// Recibe `Object?` (no `String`) porque del JSON puede llegar cualquier
/// cosa: un texto desconocido, null o hasta un número. Nada de eso es un
/// error grave: la receta se puede mostrar igual, con "Sin dato".
/// Por eso esta función NUNCA lanza excepción.
Dificultad dificultadDesdeTexto(Object? valor) {
  return switch (valor) {
    'Easy' => Dificultad.facil,
    'Medium' => Dificultad.media,
    'Hard' => Dificultad.dificil,
    _ => Dificultad.desconocida, // cualquier otra cosa se tolera
  };
}

/// Convierte un objeto JSON en una [Receta].
///
/// Usa un patrón de mapa (`if (json case {...})`): en un solo bloque revisa
/// que cada llave obligatoria EXISTA y tenga el TIPO correcto, y de paso la
/// guarda en una variable. Si algo no cuadra, el patrón no coincide y se
/// lanza FormatException.
Receta recetaDesdeJson(Map<String, dynamic> json) {
  if (json case {
    'id': int id,
    'name': String nombre,
    'cuisine': String cocina,
    'prepTimeMinutes': int minutosPreparacion,
    'cookTimeMinutes': int minutosCoccion,
    'servings': int porciones,
    // `num` acepta int (5) y double (4.6): la API manda los dos.
    // Si pusiéramos `double`, el 5 entero no coincidiría.
    'rating': num calificacion,
  }) {
    return Receta(
      id: id,
      nombre: nombre,
      cocina: cocina,
      // difficulty NO es obligatorio: se tolera lo que venga.
      dificultad: dificultadDesdeTexto(json['difficulty']),
      minutosPreparacion: minutosPreparacion,
      minutosCoccion: minutosCoccion,
      porciones: porciones,
      // Se convierte a double para que el dominio siempre tenga el mismo tipo.
      calificacion: calificacion.toDouble(),
      etiquetas: _textosOpcionales(json['tags'], 'tags'),
      ingredientes: _textosOpcionales(json['ingredients'], 'ingredients'),
    );
  }
  // No se incluye el JSON en el mensaje: no hace falta exponer los datos.
  throw const FormatException('Receta con forma inesperada');
}

/// Lista de textos OPCIONAL (para tags e ingredients):
/// - si falta (null) → lista vacía;
/// - si viene pero no es lista, o algún elemento no es texto → error.
///
/// No se usa `as List<String>`: jsonDecode entrega `List<dynamic>` y el cast
/// truena en tiempo de ejecución. Por eso se recorre elemento por elemento.
List<String> _textosOpcionales(Object? valor, String llave) {
  return switch (valor) {
    null => const [],
    List lista => [
      for (final elemento in lista)
        if (elemento is String)
          elemento
        else
          throw FormatException('"$llave" trae un elemento que no es texto'),
    ],
    _ => throw FormatException('"$llave" no es una lista'),
  };
}

/// Convierte la respuesta completa ({"recipes": [...], "total": 50, ...}).
///
/// Una lista vacía es VÁLIDA: así responde DummyJSON cuando no encuentra nada
/// (200 con "recipes": []). Eso no es un error, es un resultado vacío.
PaginaRecetas paginaDesdeJson(Map<String, dynamic> json) {
  if (json case {'recipes': List lista, 'total': int total}) {
    return PaginaRecetas(
      recetas: [
        for (final elemento in lista)
          switch (elemento) {
            // Cada elemento debe ser un objeto JSON para poder convertirlo.
            Map<String, dynamic> receta => recetaDesdeJson(receta),
            _ => throw const FormatException('Elemento de "recipes" inválido'),
          },
      ],
      total: total,
    );
  }
  throw const FormatException('Página con forma inesperada');
}
