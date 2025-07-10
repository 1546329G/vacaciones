// lib/screens/cliente_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Si necesitas datos del perfil

class ClienteDashboardScreen extends StatelessWidget {
  const ClienteDashboardScreen({super.key});

  // Función para obtener el email del usuario logueado
  Future<String?> _getUserEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Opcional: Si quieres cargar datos adicionales del perfil desde Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('clientes').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.get('nombre') ?? user.email; // Muestra el nombre si existe, sino el email
      }
      return user.email;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bienvenido Cliente'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Cerrar sesión
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión de cliente cerrada correctamente.')),
              );
              // El StreamBuilder en main.dart se encargará de redirigir al login
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.shopping_bag, size: 120, color: Colors.blueAccent),
              const SizedBox(height: 30),
              FutureBuilder<String?>(
                future: _getUserEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      '¡Hola, ${snapshot.data}!',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const Text(
                    '¡Bienvenido a PideYa!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Descubre tus restaurantes y tiendas favoritas. ¡Haz tu pedido ahora!',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Explorar Tiendas (próximamente)')),
                  );
                },
                icon: const Icon(Icons.store),
                label: const Text('Explorar Tiendas', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ver Mis Pedidos (próximamente)')),
                  );
                },
                icon: const Icon(Icons.history),
                label: const Text('Ver Mis Pedidos', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.blueAccent.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}