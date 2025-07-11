import 'package:flutter/material.dart';
// Asegúrate de importar la pantalla de login si aún no lo haces
import 'package:my_first_app/screens/home/login_screen.dart'; 

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pide YAAAAA   :)    '), // Puedes personalizar el título
        actions: [
          // ¡Aquí va el botón de la personita!
          IconButton(
            icon: const Icon(Icons.person), // Icono de persona
            tooltip: 'Iniciar sesión / Mi perfil', // Texto que aparece al mantener presionado
            onPressed: () {
              // Redirige al usuario a la pantalla de login
              // Usamos push para que el usuario pueda volver al Home con el botón de atrás
              Navigator.pushNamed(context, '/login'); 
              // O si no usas rutas nombradas:
              // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
          // Puedes añadir más acciones si es necesario, como un carrito, etc.
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Aquí iría el contenido que muestras en tus imágenes:
              // - Categorías (Restaurantes, Bebidas, etc.)
              // - Sugerencias
              // - Promociones
              // - Descubre estas opciones
              // - Aprovecha estos descuentos
              // - Restaurantes con el mejor precio

              // EJEMPLO DE UN WIDGET DE TEXTO PARA SIMULAR CONTENIDO:
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hola, ¿Qué vas a pedir hoy?',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    // Aquí irían tus widgets para categorías
                    Container(
                      height: 100,
                      color: Colors.grey[200],
                      alignment: Alignment.center,
                      child: const Text('Área de categorías (ej. Restaurantes, Bebidas)'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'cuando me vas a dar mi varco marino',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Aquí irían tus widgets para sugerencias
                    Container(
                      height: 150,
                      color: Colors.lightBlue[100],
                      alignment: Alignment.center,
                      child: const Text('Área de sugerencias (ej. Xipe - Surquillo)'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'No te pierdas estas promociones',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Aquí irían tus widgets para promociones
                    Container(
                      height: 120,
                      color: Colors.purple[100],
                      alignment: Alignment.center,
                      child: const Text('Área de promociones (ej. Restaurantes, Medios de pago)'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Descubre estas opciones',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Aquí irían tus widgets para otras opciones
                    Container(
                      height: 200,
                      color: Colors.green[100],
                      alignment: Alignment.center,
                      child: const Text('Área de opciones (ej. La Cusqueñita, Caravana)'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Aprovecha estos descuentos',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Aquí irían tus widgets para descuentos
                    Container(
                      height: 150,
                      color: Colors.yellow[100],
                      alignment: Alignment.center,
                      child: const Text('Área de descuentos (ej. Pardo, Mazar)'),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Restaurantes con el mejor precio',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    // Aquí irían tus widgets para restaurantes top
                    Container(
                      height: 200,
                      color: Colors.red[100],
                      alignment: Alignment.center,
                      child: const Text('Área de restaurantes top (ej. McDonald\'s, Pollos)'),
                    ),
                    const SizedBox(height: 50), // Espacio al final
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}