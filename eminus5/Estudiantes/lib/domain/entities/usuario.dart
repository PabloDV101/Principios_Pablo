enum RolGlobal { usuario, admin }

class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final RolGlobal rolGlobal;
  List<String> listaDeseosIds;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.rolGlobal = RolGlobal.usuario,
    List<String>? listaDeseosIds,
  }) : listaDeseosIds = listaDeseosIds ?? [];

  // Toma un JSON (Map) y construye el Objeto
  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      nombre: json['nombre'],
      correo: json['correo'],
      rolGlobal: json['rolGlobal'] == 'ADMIN' ? RolGlobal.admin : RolGlobal.usuario,
      // Mapeamos los cursos de la lista de deseos a solo sus IDs
      listaDeseosIds: json['listaDeseos'] != null 
          ? (json['listaDeseos'] as List).map((c) => c['id'].toString()).toList() 
          : [],
    );
  }

  // Toma el Objeto y lo convierte a JSON para enviarlo al Backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'correo': correo,
      'rolGlobal': rolGlobal == RolGlobal.admin ? 'ADMIN' : 'USUARIO',
      'listaDeseos': listaDeseosIds,
    };
  }
}