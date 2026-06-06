import 'entrega.dart';

class Actividad {
  final String id;
  final String titulo;
  final String descripcion;
  final DateTime fechaInicio;
  final DateTime fechaTermino;
  final double valorMaximo;
  List<Entrega> entregas; 

  Actividad({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.fechaInicio,
    required this.fechaTermino,
    this.valorMaximo = 100, 
    List<Entrega>? entregas,
  }) : entregas = entregas ?? [];

  factory Actividad.fromJson(Map<String, dynamic> json) {
    return Actividad(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaTermino: DateTime.parse(json['fechaTermino']),
      valorMaximo: (json['valorMaximo'] ?? 100).toDouble(),
      entregas: json['entregas'] != null 
          ? (json['entregas'] as List).map((e) => Entrega.fromJson(e)).toList() 
          : [],
    );
  }
}