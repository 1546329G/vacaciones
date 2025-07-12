// lib/models/address.dart

class Address {
  final int id; // ID de la dirección
  final int userId; // ID del usuario al que pertenece
  final String alias;
  final String calle;
  final String numero;
  final String? referencia; // Puede ser nulo
  final String distrito;
  final String ciudad;
  final String? codigoPostal; // Puede ser nulo
  final double latitud;
  final double longitud;
  final bool isDefault;

  Address({
    required this.id,
    required this.userId,
    required this.alias,
    required this.calle,
    required this.numero,
    this.referencia,
    required this.distrito,
    required this.ciudad,
    this.codigoPostal,
    required this.latitud,
    required this.longitud,
    required this.isDefault,
  });

  // Constructor factory para crear una instancia de Address desde un JSON
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id_direccion'] as int, // Asegúrate que el nombre de la clave coincida con tu API
      userId: json['id_usuario'] as int, // Asegúrate que el nombre de la clave coincida con tu API
      alias: json['alias'] as String,
      calle: json['calle'] as String,
      numero: json['numero'] as String,
      referencia: json['referencia'] as String?,
      distrito: json['distrito'] as String,
      ciudad: json['ciudad'] as String,
      codigoPostal: json['codigo_postal'] as String?,
      latitud: (json['latitud'] as num).toDouble(), // json puede devolver int, num o double
      longitud: (json['longitud'] as num).toDouble(),
      isDefault: json['is_default'] == 1 || json['is_default'] == true, // DB puede devolver 1/0 o true/false
    );
  }

  // Método para convertir la instancia de Address a JSON (útil para enviar al API)
  Map<String, dynamic> toJson() {
    return {
      'alias': alias,
      'calle': calle,
      'numero': numero,
      'referencia': referencia,
      'distrito': distrito,
      'ciudad': ciudad,
      'codigo_postal': codigoPostal,
      'latitud': latitud,
      'longitud': longitud,
      'is_default': isDefault ? 1 : 0, // Convierte booleano a 1 o 0 para la DB
    };
  }

  // Opcional: Para facilitar la depuración
  @override
  String toString() {
    return 'Address(id: $id, alias: $alias, calle: $calle, ciudad: $ciudad, isDefault: $isDefault)';
  }
}