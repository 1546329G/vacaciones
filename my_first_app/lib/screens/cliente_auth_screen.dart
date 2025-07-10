// lib/screens/cliente_auth_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClienteAuthScreen extends StatefulWidget {
  const ClienteAuthScreen({super.key});

  @override
  State<ClienteAuthScreen> createState() => _ClienteAuthScreenState();
}

class _ClienteAuthScreenState extends State<ClienteAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController(); // Para el nombre en registro
  final TextEditingController _apellidoController = TextEditingController(); // Para el apellido en registro
  bool _isLoginMode = true;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  void _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      if (_isLoginMode) {
        // --- Lógica de INICIO DE SESIÓN ---
        await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inicio de sesión de cliente exitoso!')),
        );
        // La navegación la manejará el StreamBuilder en main.dart
      } else {
        // --- Lógica de REGISTRO ---
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        if (userCredential.user != null) {
          await _firestore.collection('clientes').doc(userCredential.user!.uid).set({
            'email': userCredential.user!.email,
            'nombre': _nombreController.text.trim(),
            'apellido': _apellidoController.text.trim(),
            'telefono': null, // Se puede añadir más tarde
            'fecha_registro': FieldValue.serverTimestamp(),
            'activo': true,
            'rol': 'cliente',
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Registro de cliente exitoso! Cuenta creada y perfil guardado.')),
          );
          // La navegación la manejará el StreamBuilder en main.dart
        }
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El email ya está registrado para otra cuenta.';
      } else if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Credenciales inválidas. Verifica tu email y contraseña.';
      } else {
        message = 'Ocurrió un error: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
      print('Error de autenticación de cliente: ${e.code} - ${e.message}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ocurrió un error inesperado: $e')),
      );
      print('Error inesperado al autenticar cliente: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Acceso de Clientes' : 'Registro de Clientes'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    _isLoginMode ? Icons.person : Icons.person_add,
                    size: 80,
                    color: Colors.blueAccent,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _isLoginMode ? 'Inicia Sesión como Cliente' : 'Crea tu Cuenta de Cliente',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'tu@email.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu email';
                      }
                      if (!value.contains('@')) {
                        return 'Email no válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      hintText: 'Mínimo 6 caracteres',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa tu contraseña';
                      }
                      if (value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres';
                      }
                      return null;
                    },
                  ),
                  if (!_isLoginMode) ...[ // Mostrar estos campos solo en modo registro
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nombreController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Tu nombre',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor, ingresa tu nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _apellidoController,
                      keyboardType: TextInputType.name,
                      decoration: const InputDecoration(
                        labelText: 'Apellido (Opcional)',
                        hintText: 'Tu apellido',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.badge),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _isLoginMode ? 'Iniciar Sesión' : 'Registrar Cliente',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode;
                      });
                    },
                    child: Text(
                      _isLoginMode
                          ? '¿No tienes cuenta? Regístrate aquí'
                          : '¿Ya tienes cuenta? Inicia Sesión',
                      style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                    ),
                  ),
                  if (_isLoginMode)
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de Recuperar Contraseña (próximamente)')),
                        );
                      },
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}