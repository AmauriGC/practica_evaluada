// Raíz de la app: arma el ViewModel y el MaterialApp.
//
// Recibe el repositorio desde afuera (main.dart o las pruebas). Por eso solo
// conoce el CONTRATO RecetasRepositorio y no DummyJSON.

import 'package:flutter/material.dart';

import 'datos/recetas_repositorio.dart';
import 'presentacion/recetas_pagina.dart';
import 'presentacion/recetas_view_model.dart';

/// StatefulWidget para que el ViewModel se cree UNA sola vez (en el State)
/// y no en cada build, y para poder liberarlo en dispose().
class AppRecetario extends StatefulWidget {
  const AppRecetario({super.key, required this.repositorio});

  final RecetasRepositorio repositorio;

  @override
  State<AppRecetario> createState() => _AppRecetarioState();
}

class _AppRecetarioState extends State<AppRecetario> {
  // `late` permite usar `widget` al inicializar; se crea al primer uso.
  late final _vm = RecetasViewModel(widget.repositorio);

  @override
  void dispose() {
    _vm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recetario UTEZ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.deepOrange),
      home: RecetasPagina(vm: _vm),
    );
  }
}
