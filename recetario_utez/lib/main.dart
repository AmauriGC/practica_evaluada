// Punto de entrada. Es el ÚNICO lugar que conoce todas las piezas reales y
// las conecta: Dio configurado → repositorio de DummyJSON → app.
// Para usar otra fuente de datos, solo se cambiaría esta línea.

import 'package:flutter/material.dart';

import 'app.dart';
import 'datos/cliente_http.dart';
import 'datos/dummyjson_repositorio.dart';

void main() {
  runApp(AppRecetario(repositorio: DummyJsonRepositorio(crearDioRecetas())));
}
