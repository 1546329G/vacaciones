import 'package:flutter/material.dart';

class ClienteDashboardScreen extends StatelessWidget {
  const ClienteDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard Cliente')),
      body: const Center(child: Text('Bienvenido, Cliente')),
    );
  }
}