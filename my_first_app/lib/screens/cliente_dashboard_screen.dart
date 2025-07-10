import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Importa el paquete http
import 'dart:convert'; // Para decodificar JSON

class ClienteDashboardScreen extends StatefulWidget {
  const ClienteDashboardScreen({super.key});

  @override
  State<ClienteDashboardScreen> createState() => _ClienteDashboardScreenState();
}

class _ClienteDashboardScreenState extends State<ClienteDashboardScreen> {
  String _apiResponse = "Presiona el botón para obtener datos de Hostinger";

  // =========================================================================
  // URL DE TU FUNCIÓN DE FIREBASE FUNCTIONS EN EL EMULADOR LOCAL
  // ¡IMPORTANTE!: Asegúrate de que esta URL sea la correcta para tu entorno.
  // Esta es la URL que Codespaces te dio en la terminal:
  // http://4000-firebase-vacacionesgit-1752105328041.cluster-m7tpz3bmgjgoqrktlvd4ykrc2m.cloudworkstations.dev:443/functions/pideya-7aacb/us-central1/getDatos
  // =========================================================================
  // Asegúrate de COPIAR Y PEGAR TU URL EXACTA AQUÍ
  final String _functionUrl = 'http://4000-firebase-vacacionesgit-1752105328041.cluster-m7tpz3bmgjgoqrktlvd4ykrc2m.cloudworkstations.dev:443/functions/pideya-7aacb/us-central1/getDatos';

  Future<void> _callFirebaseFunction() async {
    setState(() {
      _apiResponse = "Obteniendo datos...";
    });
    try {
      final response = await http.get(Uri.parse(_functionUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          _apiResponse = "Datos recibidos:\n${json.encode(data['data'])}";
          print('Datos raw: ${response.body}'); // Para ver la respuesta completa en la consola
        });
      } else {
        setState(() {
          _apiResponse = 'Error ${response.statusCode}: ${response.body}';
        });
        print('Error al llamar a la función: ${response.statusCode}');
        print('Cuerpo del error: ${response.body}');
      }
    } catch (e) {
      setState(() {
        _apiResponse = 'Excepción al llamar a la función: $e';
      });
      print('Excepción al llamar a la función: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Cliente'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                '¡Bienvenido, Cliente!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _callFirebaseFunction, // Llama a la función aquí
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Color del botón
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Obtener Datos de Hostinger'),
              ),
              const SizedBox(height: 20),
              const Text(
                'Respuesta de la API:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _apiResponse,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                  ),
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  // Lógica para cerrar sesión
                  Navigator.pushNamedAndRemoveUntil(context, '/clienteAuth', (route) => false);
                  // Puedes añadir FirebaseAuth.instance.signOut(); aquí si quieres que el botón también cierre sesión
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Cerrar Sesión (Temporal)'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}