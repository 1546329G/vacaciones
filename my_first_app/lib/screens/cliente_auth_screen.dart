// lib/screens/cliente_auth_screen.dart

import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:my_first_app/models/user.dart';
import 'package:my_first_app/screens/cliente_dashboard_screen.dart'; // <<< ¡MOVER AQUÍ!


// !!! ELIMINA O COMENTA ESTAS LÍNEAS SI ESTÁN PRESENTES !!!
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';


class ClienteAuthScreen extends StatefulWidget {
  const ClienteAuthScreen({Key? key}) : super(key: key);

  @override
  State<ClienteAuthScreen> createState() => _ClienteAuthScreenState();
}

class _ClienteAuthScreenState extends State<ClienteAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRol; // Para el registro, si el rol se elige en esta pantalla
  bool _isLogin = true; // Para alternar entre login y registro

  // !!! ELIMINA O COMENTA ESTA LÍNEA !!!
  // final FirebaseAuth _auth = FirebaseAuth.instance;


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submitAuthForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      if (_isLogin) {
        // --- LÓGICA DE LOGIN ---
        // !!! ASEGÚRATE DE QUE ESTA ES LA LÍNEA QUE SE EJECUTA PARA EL LOGIN !!!
        User loggedInUser = await ApiService().loginUser(email, password);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Inicio de sesión exitoso. ¡Bienvenido, ${loggedInUser.nombre ?? loggedInUser.email}!')),
        );
        // Navegar al dashboard después del login exitoso
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ClienteDashboardScreen(currentUser: loggedInUser)),
          );
        }

      } else {
        // --- LÓGICA DE REGISTRO ---
        if (_selectedRol == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Por favor, selecciona un rol.')),
          );
          return;
        }
        // !!! ASEGÚRATE DE QUE ESTA ES LA LÍNEA QUE SE EJECUTA PARA EL REGISTRO !!!
        User newUser = await ApiService().registerUser(email, password, _selectedRol!);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registro exitoso para ${newUser.email}. Por favor, inicia sesión.')),
        );
        setState(() {
          _isLogin = true; // Volver a la pantalla de login después del registro
        });
      }
    }
    // !!! CAMBIA EL TIPO DE EXCEPCIÓN A 'Exception' O UN TIPO MÁS ESPECÍFICO DE TU API !!!
    on Exception catch (e) { // Captura cualquier tipo de excepción general
      print('Error en la autenticación: $e');
      String errorMessage = 'Ocurrió un error. Inténtalo de nuevo.';
      if (e.toString().contains('Error al iniciar sesión')) {
        errorMessage = 'Credenciales inválidas. Por favor, verifica tu email y contraseña.';
      } else if (e.toString().contains('Error al registrar usuario')) {
        errorMessage = 'El usuario ya existe o hubo un problema al registrar.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    }
    // !!! ELIMINA ESTE BLOQUE 'on FirebaseAuthException' SI ESTÁ PRESENTE !!!
    // on FirebaseAuthException catch (e) {
    //   String message = 'Ocurrió un error de Firebase Auth.';
    //   if (e.code == 'user-not-found') {
    //     message = 'Usuario no encontrado.';
    //   } else if (e.code == 'wrong-password') {
    //     message = 'Contraseña incorrecta.';
    //   } else if (e.code == 'email-already-in-use') {
    //     message = 'El email ya está en uso.';
    //   }
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(message)),
    //   );
    // }
  }

  @override
  Widget build(BuildContext context) {
    // ... (Tu código actual del build, con TextFormField para email, password, etc.)
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    key: const ValueKey('email'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Correo electrónico'),
                    validator: (value) {
                      if (value == null || value.isEmpty || !value.contains('@')) {
                        return 'Por favor, ingresa un correo electrónico válido.';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: (value) {
                      if (value == null || value.length < 6) {
                        return 'La contraseña debe tener al menos 6 caracteres.';
                      }
                      return null;
                    },
                  ),
                  if (!_isLogin) // Campo de rol solo para registro
                    DropdownButtonFormField<String>(
                      value: _selectedRol,
                      decoration: const InputDecoration(labelText: 'Rol'),
                      items: const [
                        DropdownMenuItem(value: 'cliente', child: Text('Cliente')),
                        DropdownMenuItem(value: 'establecimiento', child: Text('Establecimiento')),
                        DropdownMenuItem(value: 'repartidor', child: Text('Repartidor')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRol = value;
                        });
                      },
                      validator: (value) {
                        if (!_isLogin && value == null) {
                          return 'Por favor, selecciona un rol.';
                        }
                        return null;
                      },
                    ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    child: Text(_isLogin ? 'Iniciar Sesión' : 'Registrarse'),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLogin = !_isLogin;
                        _emailController.clear();
                        _passwordController.clear();
                        _selectedRol = null; // Limpiar rol al cambiar de modo
                      });
                    },
                    child: Text(_isLogin
                        ? 'Crear nueva cuenta'
                        : 'Ya tengo una cuenta'),
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

