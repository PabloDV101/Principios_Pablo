class Entrega {
  final String id;
  final String estudianteId;
  final String estudianteNombre;
  final DateTime fechaEntrega;
  final String comentariosEstudiante;
  double? calificacion; 
  String? retroalimentacionProfesor;
  final String? archivoUrl;
  final String? archivoNombre;

  Entrega({
    required this.id,
    required this.estudianteId,
    required this.estudianteNombre,
    required this.fechaEntrega,
    required this.comentariosEstudiante,
    this.calificacion,
    this.retroalimentacionProfesor,
    this.archivoUrl,
    this.archivoNombre,
  });

  factory Entrega.fromJson(Map<String, dynamic> json) {
    return Entrega(
      id: json['id'] ?? '',
      // Spring Boot devuelve el objeto "estudiante" anidado
      estudianteId: json['estudiante']?['id'] ?? '',
      estudianteNombre: json['estudiante']?['nombre'] ?? 'Anónimo',
      fechaEntrega: DateTime.parse(json['fechaEntrega']),
      comentariosEstudiante: json['comentariosEstudiante'] ?? '',
      calificacion: json['calificacion'] != null ? (json['calificacion']).toDouble() : null,
      retroalimentacionProfesor: json['retroalimentacionProfesor'],
      archivoUrl: json['archivoUrl'],
      archivoNombre: json['archivoNombre'],
    );
  }
}