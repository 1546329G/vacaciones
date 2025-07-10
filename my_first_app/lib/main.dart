// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Para leer el rol

// Este archivo firebase_options.dart debe estar en la misma carpeta 'lib' que main.dart
import 'firebase_options.dart';

// Importa las pantallas usando la ruta del paquete (es la forma correcta)
import 'package:my_first_app/screens/cliente_auth_screen.dart';
import 'package:my_first_app/screens/cliente_dashboard_screen.dart';
import 'package:my_first_app/screens/establecimiento_auth_screen.dart';
import 'package:my_first_app/screens/establecimiento_dashboard_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuComidaYa',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Usamos StreamBuilder para manejar el estado de autenticación
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // Usuario logueado. Intentar determinar su rol.
            final user = snapshot.data!;
            return FutureBuilder<DocumentSnapshot>(
              future: _getUserRole(user.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (roleSnapshot.hasData && roleSnapshot.data!.exists) {
                  String? role = roleSnapshot.data!['rol'];
                  if (role == 'establecimiento') {
                    return const EstablecimientoDashboardScreen();
                  } else if (role == 'cliente') {
                    return const ClienteDashboardScreen();
                  }
                  // Si no se encuentra un rol válido, o es un rol desconocido
                  return const RoleSelectionScreen();
                }
                // Si el documento de usuario no existe en Firestore después de autenticación
                // Esto podría significar un usuario antiguo sin rol guardado, o un error.
                // En este caso, podemos pedirle que seleccione su rol o lo mandamos a una pantalla de error.
                // Por ahora, lo mandaremos a la selección de rol.
                return const RoleSelectionScreen();
              },
            );
          }
          // No hay usuario logueado, mostrar la pantalla de selección de rol
          return const RoleSelectionScreen();
        },
      ),
      routes: {
        // Rutas para las pantallas de autenticación
        '/establecimientoAuth': (context) => const EstablecimientoAuthScreen(),
        '/clienteAuth': (context) => const ClienteAuthScreen(),
        // Rutas para los dashboards
        '/establecimientoDashboard': (context) => const EstablecimientoDashboardScreen(),
        '/clienteDashboard': (context) => const ClienteDashboardScreen(),
      },
    );
  }

  // Función auxiliar para obtener el rol del usuario desde Firestore
  Future<DocumentSnapshot> _getUserRole(String uid) async {
    // Primero, intenta en la colección 'establecimientos'
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('establecimientos').doc(uid).get();
    if (doc.exists) {
      return doc;
    }
    // Si no está en 'establecimientos', intenta en la colección 'clientes'
    doc = await FirebaseFirestore.instance.collection('clientes').doc(uid).get();
    if (doc.exists) {
      return doc;
    }
    // Puedes añadir más roles aquí (repartidores, admin)
    // Si no se encuentra en ninguna, retorna un documento que no existe.
    return FirebaseFirestore.instance.collection('temp_roles').doc('non_existent').get();
  }
}

// Pantalla para que el usuario elija su rol inicial si no está logueado o no tiene rol definido
class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido a PideYa'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              '¿Cómo deseas ingresar?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/clienteAuth');
              },
              icon: const Icon(Icons.person),
              label: const Text('Soy Cliente', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/establecimientoAuth');
              },
              icon: const Icon(Icons.store),
              label: const Text('Soy Establecimiento', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Login de Repartidores (próximamente)')),
                );
                // Navigator.pushNamed(context, '/repartidorAuth');
              },
              icon: const Icon(Icons.delivery_dining),
              label: const Text('Soy Repartidor', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(250, 60),
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}