import 'package:flutter/material.dart';

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