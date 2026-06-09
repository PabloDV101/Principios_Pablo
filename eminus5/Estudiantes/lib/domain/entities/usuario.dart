class Usuario {
  final String id;
  final String nombre;
  final String correo;
  final String? rol;
 List<String>? cursosDeseados;
  
  // NUEVOS CAMPOS DEL PERFIL
  final String? fotoUrl;
  final String? profesion;
  final String? descripcion;

  Usuario({
    required this.id,
    required this.nombre,
    required this.correo,
    this.rol,
    this.cursosDeseados,
    this.fotoUrl,
    this.profesion,
    this.descripcion,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      correo: json['correo'] ?? '',
      rol: json['rol'],
      cursosDeseados: json['cursosDeseados'] != null ? List<String>.from(json['cursosDeseados']) : [],
      fotoUrl: json['fotoUrl'],
      profesion: json['profesion'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'correo': correo,
      'rol': rol,
      'cursosDeseados': cursosDeseados,
      'fotoUrl': fotoUrl,
      'profesion': profesion,
      'descripcion': descripcion,
    };
  }
}