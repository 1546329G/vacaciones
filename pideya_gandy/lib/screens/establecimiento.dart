import 'package:flutter/material.dart';

// ¡ASEGÚRATE DE QUE LA CLASE SE LLAME EstablecimientoDashboardScreen!
class EstablecimientoDashboardScreen extends StatelessWidget {
  const EstablecimientoDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Establecimiento')),
      body: const Center(child: Text('Bienvenido, Establecimiento')),
    );
  }
}