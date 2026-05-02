// comentario_model.dart
class Comentario {
  final int id;
  final String texto;
  final String username;
  final DateTime fechaCreacion;

  Comentario({
    required this.id,
    required this.texto,
    required this.username,
    required this.fechaCreacion,
  });

  factory Comentario.fromJson(Map<String, dynamic> json) {
    return Comentario(
      id: json['id'],
      texto: json['texto'] ?? "Sin texto",
      username: json['username'],
      fechaCreacion: DateTime.parse(json['fechaCreacion']),
    );
  }

  
}