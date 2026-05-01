class Band {
  final int? id;
  final String nombre;
  final String descripcion;
  final String urlImagen;
  final DateTime? fechaCreacion;

  Band({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.urlImagen,
    this.fechaCreacion,
  });

  // Convierte JSON del backend a Objeto Dart
  factory Band.fromJson(Map<String, dynamic> json) {
    return Band(
      id: json['id'],
      nombre: json['nombre'],
      descripcion: json['descripcion'],
      urlImagen: json['urlImagen'] ?? '',
      fechaCreacion: json['fechaCreacion'] != null 
          ? DateTime.parse(json['fechaCreacion']) 
          : null,
    );
  }

  // Convierte Objeto Dart a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'urlImagen': urlImagen,
    };
  }
}