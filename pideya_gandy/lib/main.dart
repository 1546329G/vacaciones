// lib/main.dart

import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:my_first_app/screens/home/login_screen.dart';
import 'package:my_first_app/screens/home_screen.dart';

// ¡Ajusta estos imports para que apunten a tus archivos cortos!
import 'package:my_first_app/screens/cliente.dart';         // Apunta a cliente.dart
import 'package:my_first_app/screens/establecimiento.dart'; // Apunta a establecimiento.dart
import 'package:my_first_app/screens/repartidor.dart';      // Apunta a repartidor.dart


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PedidosYa Clone',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomeScreen(),

      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // Las rutas nombradas y los nombres de las CLASES se mantienen largos y descriptivos
        '/clienteDashboard': (context) => const ClienteDashboardScreen(),
        '/establecimientoDashboard': (context) => const EstablecimientoDashboardScreen(),
        '/repartidorDashboard': (context) => const RepartidorDashboardScreen(),
      },
    );
  }
}