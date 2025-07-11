// lib/main.dart

import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:my_first_app/screens/home/login_screen.dart'; // Importa tu pantalla de login
import 'package:my_first_app/screens/home_screen.dart'; // Importa tu pantalla principal

// ¡Asegúrate de que estas rutas de importación sean correctas!
// Basado en tu estructura actual, estos archivos deben estar directamente en lib/screens/
import 'package:my_first_app/screens/cliente.dart'; 
import 'package:my_first_app/screens/establecimiento.dart'; 

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
        // ¡AGREGA ESTAS LÍNEAS PARA DEFINIR LAS RUTAS DE LOS DASHBOARDS!
        '/clienteDashboard': (context) => const ClienteDashboardScreen(), // Define la ruta para el dashboard del cliente
        '/establecimientoDashboard': (context) => const EstablecimientoDashboardScreen(), // Define la ruta para el dashboard del establecimiento
      },
    );
  }
}