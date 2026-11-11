// Capa de DOMINIO: Dart puro.
// Aquí no se importa nada (ni Flutter, ni Dio, ni JSON). Así el modelo no
// depende de cómo llegan los datos ni de cómo se dibujan: si mañana cambia
// la API o la interfaz, este archivo no se toca.

/// Minutos máximos para que una receta cuente como "rápida".
/// Se deja como constante con nombre para no tener un 30 "mágico" regado.
const umbralRapidaMinutos = 30;

/// Dificultad de la receta, ya traducida al español.
///
/// Es un enum "mejorado" (con campo): cada valor lleva su etiqueta para la
/// interfaz. `desconocida` existe porque el servidor podría mandar un valor
/// nuevo ("Extreme") y la app no debe romperse por eso.
enum Dificultad {
  facil('Fácil'),
  media('Media'),
  dificil('Difícil'),
  desconocida('Sin dato');

  // Un enum con campo necesita un constructor const y un campo final.
  const Dificultad(this.etiqueta);
  final String etiqueta;
}

/// Una receta tal como la entiende la app (no como la manda DummyJSON).
/// Los nombres están en español y los tipos ya son los correctos
/// (por ejemplo, la calificación siempre es double).
class Receta {
  const Receta({
    required this.id,
    required this.nombre,
    required this.cocina,
    required this.dificultad,
    required this.minutosPreparacion,
    required this.minutosCoccion,
    required this.porciones,
    required this.calificacion,
    // Las listas son opcionales: si no vienen, quedan vacías (nunca null).
    this.etiquetas = const [],
    this.ingredientes = const [],
  });

  final int id;
  final String nombre;
  final String cocina;
  final Dificultad dificultad;
  final int minutosPreparacion;
  final int minutosCoccion;
  final int porciones;
  final double calificacion;
  final List<String> etiquetas;
  final List<String> ingredientes;

  /// Getter calculado: no se guarda, se deriva de otros campos.
  /// Así nunca puede quedar "desincronizado" con preparación y cocción.
  int get tiempoTotal => minutosPreparacion + minutosCoccion;

  /// "A lo más 30 minutos" significa <= (30 sí es rápida, 31 no).
  bool get esRapida => tiempoTotal <= umbralRapidaMinutos;
}

/// Lo que regresa una búsqueda: las recetas de esta página y el total que
/// reporta el servidor (puede ser mayor que las recetas recibidas).
class PaginaRecetas {
  const PaginaRecetas({required this.recetas, required this.total});
  final List<Receta> recetas;
  final int total;
}
