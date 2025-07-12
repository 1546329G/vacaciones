import 'address.dart'; // Asegúrate de importar el modelo de Address

class User {
  final int? id; // <-- CAMBIO CLAVE AQUÍ: Hacemos 'id' anulable (int?)
  final String email;
  final String rol;
  final String? nombre; // Puede ser nulo
  final String? telefono; // Puede ser nulo
  final bool? activo; // Puede ser nulo o booleano

  // Listado de direcciones asociadas al usuario
  final List<Address>? addresses;

  User({
    this.id, // <-- CAMBIO CLAVE AQUÍ: No es 'required' si es anulable
    required this.email,
    required this.rol,
    this.nombre,
    this.telefono,
    this.activo,
    this.addresses,
  });

  // Constructor factory para crear una instancia de User desde un JSON
  factory User.fromJson(Map<String, dynamic> json) {
    // Manejo de 'addresses'
    List<Address>? loadedAddresses;
    if (json['addresses'] != null && json['addresses'] is List) { // Añadimos verificación de tipo
      loadedAddresses = (json['addresses'] as List)
          .map((addressJson) => Address.fromJson(addressJson))
          .toList();
    }

    return User(
      id: json['id_usuario'] as int?, // <-- CAMBIO CLAVE AQUÍ: Usa 'as int?' para leerlo como int o null
      email: json['email'] as String,
      rol: json['rol'] as String,
      nombre: json['nombre'] as String?,
      telefono: json['telefono'] as String?,
      // Convertimos el valor 'activo' a bool de forma segura.
      // Puede venir como 0/1 (int) o true/false (bool), o incluso null.
      activo: json['activo'] == null
          ? null
          : (json['activo'] is int
              ? (json['activo'] == 1 ? true : false)
              : json['activo'] as bool?),
      addresses: loadedAddresses,
    );
  }

  // Método para convertir la instancia de User a JSON (útil para enviar al API)
  Map<String, dynamic> toJson() {
    return {
      // No incluimos 'id_usuario' aquí si el backend lo autogenera o no lo espera en PUT/POST
      // 'id_usuario': id, // Si lo incluyes, asegúrate de que el backend lo maneje correctamente
      'email': email,
      'rol': rol,
      'nombre': nombre,
      'telefono': telefono,
      'activo': activo,
      // No incluimos 'addresses' aquí si se manejan en endpoints separados
    };
  }

  // Opcional: Para facilitar la depuración
  @override
  String toString() {
    return 'User(id: $id, email: $email, rol: $rol, nombre: $nombre, telefono: $telefono, activo: $activo, addresses: $addresses)';
  }
}