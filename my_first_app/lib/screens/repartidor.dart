import 'package:flutter/material.dart';

// ¡ASEGÚRATE DE QUE LA CLASE SE LLAME RepartidorDashboardScreen!
class RepartidorDashboardScreen extends StatelessWidget {
  const RepartidorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Repartidor')),
      body: const Center(child: Text('Bienvenido, Repartidor')),
    );
  }
}