import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart'; // Necesario para ApiService.init()
import 'package:my_first_app/screens/home/login_screen.dart'; // Importa tu pantalla de login
import 'package:my_first_app/screens/home/home_screen.dart'; // Importa tu pantalla principal

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Asegúrate de inicializar ApiService.
  // Esto es bueno hacerlo al inicio para que el token esté cargado si es necesario
  // en alguna otra parte de la app que se cargue de inmediato.
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
      // La aplicación siempre comienza en la HomeScreen
      home: const HomeScreen(), // <-- ¡CAMBIO CLAVE AQUÍ!
      
      // Define las rutas nombradas para fácil navegación
      routes: {
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomeScreen(),
        // Puedes añadir más rutas aquí si las necesitas
      },
    );
  }
}