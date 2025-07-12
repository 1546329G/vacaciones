// lib/screens/home/login_screen.dart

import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
// ¡Importa tus dashboards aquí!
import 'package:my_first_app/screens/cliente.dart';
import 'package:my_first_app/screens/establecimiento.dart';
import 'package:my_first_app/screens/repartidor.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rolController = TextEditingController(); 
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoginMode = true;

  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null;
      _emailController.clear();
      _passwordController.clear();
      _rolController.clear();
    });
  }

  Future<void> _authenticate() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // User user; // Declara user fuera de los bloques para que sea accesible
      if (_isLoginMode) {
        // Lógica para INICIAR SESIÓN
        final user = await _apiService.loginUser(
          _emailController.text,
          _passwordController.text,
        );
        
        if (user.email.isNotEmpty) {
          if (!mounted) return;
          // Redirigir según el rol del usuario
          _navigateToDashboard(user.rol); 
        } else {
          setState(() {
            _errorMessage = 'Credenciales incorrectas o usuario no encontrado.';
          });
        }
      } else {
        // Lógica para REGISTRAR USUARIO
        if (_rolController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Por favor, introduce un rol para el registro (ej. cliente, establecimiento).';
          });
          return;
        }

        final user = await _apiService.registerUser(
          _emailController.text,
          _passwordController.text,
          _rolController.text,
        );

        if (user.email.isNotEmpty) {
          if (!mounted) return;
          // Redirigir según el rol del usuario después del registro
          _navigateToDashboard(user.rol);
        } else {
          setState(() {
            _errorMessage = 'No se pudo registrar el usuario.';
          });
        }
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error: ${e.toString()}';
      });
      print('Error en LoginScreen (${_isLoginMode ? 'Login' : 'Registro'}): $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Nueva función para manejar la navegación según el rol
  void _navigateToDashboard(String? rol) {
    if (!mounted) return;
    switch (rol) {
      case 'cliente': // Asegúrate de que los nombres de rol coincidan con tu backend
        Navigator.of(context).pushReplacementNamed('/clienteDashboard');
        break;
      case 'establecimiento': // Asegúrate de que los nombres de rol coincidan
        Navigator.of(context).pushReplacementNamed('/establecimientoDashboard');
        break;
      case 'repartidor': // Si tienes este rol
        // Navigator.of(context).pushReplacementNamed('/repartidorDashboard');
        // break;
      default:
        // En caso de rol desconocido o nulo, redirige a una pantalla por defecto
        Navigator.of(context).pushReplacementNamed('/home');
        break;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _rolController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Iniciar Sesión' : 'Registrarse'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isLoginMode ? 'Bienvenido de nuevo!' : 'Crea tu cuenta',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Contraseña',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              if (!_isLoginMode)
                Column(
                  children: [
                    const SizedBox(height: 20),
                    TextField(
                      controller: _rolController,
                      decoration: const InputDecoration(
                        labelText: 'Rol (ej. cliente, establecimiento)',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 30),
              if (_errorMessage != null)
                Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _authenticate,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        _isLoginMode ? 'Iniciar Sesión' : 'Registrarse',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: _toggleMode,
                child: Text(
                  _isLoginMode
                      ? '¿No tienes cuenta? Regístrate aquí.'
                      : '¿Ya tienes cuenta? Inicia sesión aquí.',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}