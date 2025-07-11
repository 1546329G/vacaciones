import 'package:flutter/material.dart';
import 'package:my_first_app/services/api_service.dart';
import 'package:my_first_app/screens/home_screen.dart'; // Para redirigir al home

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _rolController = TextEditingController(); // Para el rol en el registro
  final ApiService _apiService = ApiService();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isLoginMode = true; // Controla si estamos en modo Login o Registro

  // Función para alternar entre modos Login y Registro
  void _toggleMode() {
    setState(() {
      _isLoginMode = !_isLoginMode;
      _errorMessage = null; // Limpiar mensaje de error al cambiar de modo
      _emailController.clear(); // Limpiar campos al cambiar de modo
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
      if (_isLoginMode) {
        // Lógica para INICIAR SESIÓN
        final user = await _apiService.loginUser(
          _emailController.text,
          _passwordController.text,
        );

        if (user.email.isNotEmpty) {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          setState(() {
            _errorMessage = 'Credenciales incorrectas o usuario no encontrado.';
          });
        }
      } else {
        // Lógica para REGISTRAR USUARIO
        // Asegúrate de que el rol se ingrese o se asigne por defecto si es necesario
        if (_rolController.text.isEmpty) {
          setState(() {
            _errorMessage = 'Por favor, introduce un rol para el registro (ej. cliente, establecimiento).';
          });
          return;
        }

        final user = await _apiService.registerUser(
          _emailController.text,
          _passwordController.text,
          _rolController.text, // Pasa el rol para el registro
        );

        if (user.email.isNotEmpty) {
          if (!mounted) return;
          // Después de un registro exitoso, puedes redirigir al home
          // o al login para que el usuario inicie sesión con sus nuevas credenciales.
          // Para este ejemplo, redirigimos directamente al home si el registro también devuelve token.
          Navigator.of(context).pushReplacementNamed('/home');
          // O si prefieres que vuelva al login para iniciar sesión:
          // setState(() {
          //   _isLoginMode = true; // Volver al modo login
          //   _errorMessage = 'Usuario registrado exitosamente. Por favor, inicia sesión.';
          //   _emailController.clear();
          //   _passwordController.clear();
          //   _rolController.clear();
          // });
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
              if (!_isLoginMode) // Mostrar campo de rol solo en modo registro
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
                      onPressed: _authenticate, // Llama a la función unificada
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
                onPressed: _toggleMode, // Cambia entre Login y Registro
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