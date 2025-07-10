// lib/screens/establecimiento_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Opcional, si necesitas datos del perfil

class EstablecimientoDashboardScreen extends StatelessWidget {
  const EstablecimientoDashboardScreen({super.key});

  // Función para obtener el email del usuario logueado (o nombre del establecimiento)
  Future<String?> _getEstablecimientoNameOrEmail() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('establecimientos').doc(user.uid).get();
      if (userDoc.exists) {
        return userDoc.get('nombre_comercial') ?? user.email; // Muestra el nombre comercial si existe, sino el email
      }
      return user.email;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard del Establecimiento'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut(); // Cerrar sesión
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión de establecimiento cerrada correctamente.')),
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
              const Icon(Icons.dashboard, size: 120, color: Colors.teal),
              const SizedBox(height: 30),
              FutureBuilder<String?>(
                future: _getEstablecimientoNameOrEmail(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData && snapshot.data != null) {
                    return Text(
                      '¡Hola, ${snapshot.data}!',
                      style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const Text(
                    '¡Bienvenido Establecimiento!',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'Aquí gestionarás tus pedidos, menú, promociones y estadísticas.',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gestionar Menú (próximamente)')),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('Gestionar Menú', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.teal.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Ver Pedidos (próximamente)')),
                  );
                },
                icon: const Icon(Icons.receipt_long),
                label: const Text('Ver Pedidos', style: TextStyle(fontSize: 18)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.teal.shade700,
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