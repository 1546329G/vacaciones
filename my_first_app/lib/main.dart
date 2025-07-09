import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TuComidaYa - Portal de Establecimientos',
      theme: ThemeData(
        primarySwatch: Colors.teal, // Un color diferente para el portal de establecimientos
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // La pantalla inicial será el Login/Registro de Establecimiento
      home: const EstablecimientoAuthScreen(),
      // Aquí puedes añadir rutas si el portal web tiene múltiples páginas
      routes: {
        '/establecimientoDashboard': (context) => const EstablecimientoDashboardScreen(),
        // '/establecimientoRegistro': (context) => const EstablecimientoRegistroScreen(), // Si quieres una pantalla de registro separada
      },
    );
  }
}

// ====================================================================
// PANTALLA DE AUTENTICACIÓN (LOGIN/REGISTRO) PARA ESTABLECIMIENTOS
// ====================================================================
class EstablecimientoAuthScreen extends StatefulWidget {
  const EstablecimientoAuthScreen({super.key});

  @override
  State<EstablecimientoAuthScreen> createState() => _EstablecimientoAuthScreenState();
}

class _EstablecimientoAuthScreenState extends State<EstablecimientoAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoginMode = true; // true para login, false para registro

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitAuthForm() {
    if (_formKey.currentState!.validate()) {
      // Aquí iría la lógica real de autenticación/registro
      if (_isLoginMode) {
        // Lógica de Inicio de Sesión
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Iniciando sesión como Establecimiento con: ${_emailController.text}'),
          ),
        );
        // Navegar al dashboard del establecimiento
        Navigator.pushReplacementNamed(context, '/establecimientoDashboard');
      } else {
        // Lógica de Registro
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registrando nuevo Establecimiento con: ${_emailController.text}'),
          ),
        );
        // Podrías navegar al dashboard o a una pantalla de confirmación
        Navigator.pushReplacementNamed(context, '/establecimientoDashboard');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Para la web, podemos hacer un layout más adaptable
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLoginMode ? 'Acceso de Establecimientos' : 'Registro de Establecimientos'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView( // Permite scroll si el contenido es grande en pantallas pequeñas
          padding: const EdgeInsets.all(20.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Limita el ancho del formulario en pantallas grandes
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min, // La columna ocupa solo el espacio necesario
                children: <Widget>[
                  Icon(
                    _isLoginMode ? Icons.store : Icons.app_registration,
                    size: 80,
                    color: Colors.teal,
                  ),
                  const SizedBox(height: 30),
                  Text(
                    _isLoginMode ? 'Inicia Sesión' : 'Crea tu Cuenta de Establecimiento',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email del Establecimiento',
                      hintText: 'ejemplo@tutienda.com',
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
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _submitAuthForm,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 5,
                    ),
                    child: Text(
                      _isLoginMode ? 'Iniciar Sesión' : 'Registrar Establecimiento',
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _isLoginMode = !_isLoginMode; // Cambia entre login y registro
                      });
                    },
                    child: Text(
                      _isLoginMode
                          ? '¿No tienes cuenta? Regístrate aquí'
                          : '¿Ya tienes cuenta? Inicia Sesión',
                      style: const TextStyle(color: Colors.teal, fontSize: 16),
                    ),
                  ),
                  if (_isLoginMode) // Solo muestra la opción de recuperar contraseña en modo login
                    TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Funcionalidad de Recuperar Contraseña (próximamente)')),
                        );
                        // TODO: Navegar a pantalla de recuperación de contraseña
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

// ====================================================================
// PANTALLA DE EJEMPLO PARA EL DASHBOARD DEL ESTABLECIMIENTO (Web)
// ====================================================================
class EstablecimientoDashboardScreen extends StatelessWidget {
  const EstablecimientoDashboardScreen({super.key});

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
            onPressed: () {
              // TODO: Lógica para cerrar sesión
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EstablecimientoAuthScreen()),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sesión cerrada')),
              );
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
              const Text(
                '¡Bienvenido al Dashboard de tu Establecimiento!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.teal),
                textAlign: TextAlign.center,
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
                  // TODO: Navegar a la sección de gestión de menú
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
                  // TODO: Navegar a la sección de pedidos
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