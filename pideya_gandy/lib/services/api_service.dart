// lib/services/api_service.dart

import 'dart:convert'; // Para json.encode y json.decode
import 'package:http/http.dart' as http; // Para hacer peticiones HTTP
import 'package:shared_preferences/shared_preferences.dart'; // Para guardar el token
import '../models/user.dart'; // Importa tu modelo de User
import '../models/address.dart'; // Importa tu modelo de Address (si lo necesitas)

// --- CONFIGURACIÓN DE LA URL BASE ---
// Según tus archivos de backend, tu API Express está siendo expuesta
// a través del emulador de Firebase Functions como la función 'api'.
// Asegúrate de que 'pideya-7aacb' sea el ID de tu proyecto de Firebase.
const String _baseUrl = 'http://127.0.0.1:5001/pideya-7aacb/us-central1/api';

class ApiService {
  static String? _authToken; // Variable estática para guardar el token JWT

  // Método para inicializar el token al inicio de la app.
  // Debes llamarlo una vez al iniciar tu aplicación Flutter (ej. en main() o en el initState de tu MyApp).
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _authToken = prefs.getString('authToken');
    print('ApiService: Token inicializado: $_authToken');
  }

  // Método para guardar el token
  static Future<void> _saveToken(String token) async {
    _authToken = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('authToken', token);
    print('ApiService: Token guardado.');
  }

  // Método para limpiar el token (útil para cerrar sesión)
  static Future<void> clearToken() async {
    _authToken = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('authToken');
    print('ApiService: Token eliminado.');
  }

  // --- MÉTODOS DE AUTENTICACIÓN ---

  Future<User> registerUser(String email, String password, String rol) async {
    // La URL se construye concatenando la base con el endpoint específico: /auth/register
    final url = Uri.parse('$_baseUrl/auth/register');
    print('Enviando registro a: $url'); // Para depuración
    
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password, 'rol': rol}),
      );

      if (response.statusCode == 201) { // 201 Created es una respuesta estándar para registro exitoso
        final responseData = json.decode(response.body);
        print('Registro exitoso: ${responseData['message']}');
        
        // Asume que tu backend devuelve el usuario registrado y opcionalmente un token.
        final User newUser = User.fromJson(responseData['user'] ?? {}); // Asegúrate de que 'user' no sea nulo en la respuesta
        final String? token = responseData['token'];
        if (token != null && token.isNotEmpty) {
          await _saveToken(token);
        } else {
          print('Advertencia: El API de registro no retornó un token JWT.');
        }
        return newUser;
      } else {
        final errorData = json.decode(response.body);
        print('Error de registro (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al registrar usuario: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción durante el registro: $e');
      throw Exception('Error de conexión o inesperado durante el registro: $e');
    }
  }

  Future<User> loginUser(String email, String password) async {
    // La URL se construye concatenando la base con el endpoint específico: /auth/login
    final url = Uri.parse('$_baseUrl/auth/login');
    print('Enviando login a: $url'); // Para depuración

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) { // 200 OK es una respuesta estándar para login exitoso
        final responseData = json.decode(response.body);
        final User user = User.fromJson(responseData['user']); // Asegúrate de que 'user' no sea nulo
        final String? token = responseData['token'];

        if (token != null && token.isNotEmpty) {
          await _saveToken(token); // Guarda el token si lo recibes
        } else {
          print('Advertencia: El API de login no retornó un token JWT. Asegúrate de añadirlo en el backend.');
          // Si tu backend no devuelve un token, la sesión no se mantendrá persistente automáticamente.
        }
        print('Inicio de sesión exitoso. Usuario: ${user.email}, Rol: ${user.rol}');
        return user;
      } else {
        final errorData = json.decode(response.body);
        print('Error de login (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al iniciar sesión: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción durante el login: $e');
      throw Exception('Error de conexión o inesperado durante el inicio de sesión: $e');
    }
  }

  // Método auxiliar para obtener headers con autenticación
  // Útil para cualquier petición que requiera que el usuario esté logueado.
  Map<String, String> _getAuthHeaders() {
    if (_authToken == null) {
      // Si no hay token, significa que el usuario no está logueado o el token expiró.
      // Aquí podrías forzar una redirección a la pantalla de login o mostrar un mensaje.
      throw Exception('No hay token de autenticación disponible. Inicia sesión primero.');
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_authToken', // Envía el token en el header Authorization
    };
  }

  // --- MÉTODOS DE GESTIÓN DE PERFIL DE USUARIO (Requieren autenticación) ---

  Future<User> getOwnProfile() async {
    final url = Uri.parse('$_baseUrl/users/me'); // Ejemplo de endpoint para perfil
    print('Obteniendo perfil de: $url'); // Para depuración

    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Ajusta 'data' o 'user' según la estructura de tu respuesta API.
        // Algunos APIs envuelven el objeto en una clave 'data'.
        return User.fromJson(responseData['data'] ?? responseData['user']);
      } else {
        final errorData = json.decode(response.body);
        print('Error al obtener perfil (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al obtener perfil: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al obtener perfil: $e');
      throw Exception('Error de conexión o inesperado al obtener perfil: $e');
    }
  }

  Future<User> updateOwnProfile(String? nombre, String? telefono) async {
    final url = Uri.parse('$_baseUrl/users/me'); // Ejemplo de endpoint para actualizar perfil
    print('Actualizando perfil de: $url'); // Para depuración

    final Map<String, dynamic> body = {};
    if (nombre != null) body['nombre'] = nombre;
    if (telefono != null) body['telefono'] = telefono;

    try {
      final response = await http.put(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return User.fromJson(responseData['user']);
      } else {
        final errorData = json.decode(response.body);
        print('Error al actualizar perfil (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al actualizar perfil: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al actualizar perfil: $e');
      throw Exception('Error de conexión o inesperado al actualizar perfil: $e');
    }
  }

  // --- MÉTODOS DE GESTIÓN DE DIRECCIONES (Requieren autenticación) ---
  // (Asegúrate de que tus modelos Address tengan los métodos fromJson y toJson para que esto funcione)

  Future<Address> addAddress(Address address) async {
    final url = Uri.parse('$_baseUrl/users/me/addresses'); // Endpoint para añadir dirección
    print('Añadiendo dirección a: $url'); // Para depuración

    try {
      final response = await http.post(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(address.toJson()), // Convierte el objeto Address a JSON
      );

      if (response.statusCode == 201) { // 201 Created es común para añadir recursos
        final responseData = json.decode(response.body);
        return Address.fromJson(responseData['address']);
      } else {
        final errorData = json.decode(response.body);
        print('Error al añadir dirección (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al añadir dirección: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al añadir dirección: $e');
      throw Exception('Error de conexión o inesperado al añadir dirección: $e');
    }
  }

  Future<List<Address>> getAddresses() async {
    final url = Uri.parse('$_baseUrl/users/me/addresses'); // Endpoint para obtener direcciones
    print('Obteniendo direcciones de: $url'); // Para depuración

    try {
      final response = await http.get(
        url,
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Asume que las direcciones están en una clave 'data' o similar y es una lista.
        final List<dynamic> addressListJson = responseData['data'] ?? []; // Asegura que 'data' no sea nulo y sea una lista
        return addressListJson.map((json) => Address.fromJson(json)).toList();
      } else {
        final errorData = json.decode(response.body);
        print('Error al obtener direcciones (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al obtener direcciones: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al obtener direcciones: $e');
      throw Exception('Error de conexión o inesperado al obtener direcciones: $e');
    }
  }

  Future<Address> updateAddress(int addressId, Address address) async {
    final url = Uri.parse('$_baseUrl/users/me/addresses/$addressId'); // Endpoint para actualizar dirección por ID
    print('Actualizando dirección de: $url'); // Para depuración

    try {
      final response = await http.put(
        url,
        headers: _getAuthHeaders(),
        body: json.encode(address.toJson()),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return Address.fromJson(responseData['address']);
      } else {
        final errorData = json.decode(response.body);
        print('Error al actualizar dirección (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al actualizar dirección: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al actualizar dirección: $e');
      throw Exception('Error de conexión o inesperado al actualizar dirección: $e');
    }
  }

  Future<void> deleteAddress(int addressId) async {
    final url = Uri.parse('$_baseUrl/users/me/addresses/$addressId'); // Endpoint para eliminar dirección por ID
    print('Eliminando dirección de: $url'); // Para depuración

    try {
      final response = await http.delete(
        url,
        headers: _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        print('Dirección $addressId eliminada exitosamente.');
      } else {
        final errorData = json.decode(response.body);
        print('Error al eliminar dirección (Status ${response.statusCode}): ${errorData['error'] ?? response.reasonPhrase}');
        throw Exception('Error al eliminar dirección: ${errorData['error'] ?? response.reasonPhrase}');
      }
    } catch (e) {
      print('Excepción al eliminar dirección: $e');
      throw Exception('Error de conexión o inesperado al eliminar dirección: $e');
    }
  }
}