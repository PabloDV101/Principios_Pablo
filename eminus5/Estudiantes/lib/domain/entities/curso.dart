import 'actividad.dart';
import 'usuario.dart';

class MensajeMuro {
  final String remitente;
  final String rol;
  final String mensaje;
  final DateTime fecha;
  int reacciones;
  List<Usuario> estudiantesLista;

  MensajeMuro({required this.remitente, required this.rol, required this.mensaje, required this.fecha, this.estudiantesLista = const [],this.reacciones = 0});

factory MensajeMuro.fromJson(Map<String, dynamic> json) {
    // Blindaje para leer la fecha sin importar cómo la envíe Spring Boot
    DateTime fechaParseada = DateTime.now();
    if (json['fecha'] != null) {
      if (json['fecha'] is List) {
        final l = json['fecha'] as List;
        // Año, Mes, Día, Hora, Minuto
        fechaParseada = DateTime(l[0], l[1], l[2], l.length > 3 ? l[3] : 0, l.length > 4 ? l[4] : 0);
      } else {
        fechaParseada = DateTime.tryParse(json['fecha'].toString()) ?? DateTime.now();
      }
    }

    return MensajeMuro(
      remitente: json['remitente'] ?? '',
      rol: json['rol'] ?? '',
      mensaje: json['mensaje'] ?? '',
      fecha: fechaParseada,
      estudiantesLista: json['estudiantes'] != null 
          ? (json['estudiantes'] as List).map((e) => Usuario.fromJson(e)).toList() 
          : [],
      reacciones: json['reacciones'] ?? 0,
      
    );
  }
}

class Curso {
  final String id;
  final String titulo;
  final String descripcion;
  final String autor;
  final String urlImagen;
  final double calificacion;
  final List<String> etiquetas;
  
  List<String> profesoresIds;
  List<String> estudiantesIds;
  List<Actividad> actividades;
  List<MensajeMuro> mensajes; 
  List<Usuario> estudiantesLista;

  Curso({
    required this.id,
    required this.titulo,
    required this.descripcion,
    required this.autor,
    required this.urlImagen,
    this.calificacion = 0.0,
    List<String>? etiquetas,
    List<String>? profesoresIds,
    List<String>? estudiantesIds,
    List<Actividad>? actividades,
    List<MensajeMuro>? mensajes,
    List<Usuario>? estudiantesLista,
  })  : etiquetas = etiquetas ?? [],
        profesoresIds = profesoresIds ?? [],
        estudiantesIds = estudiantesIds ?? [],
        actividades = actividades ?? [],
        mensajes = mensajes ?? [],
        estudiantesLista = estudiantesLista ?? [];

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      descripcion: json['descripcion'] ?? '',
      autor: json['autor'] ?? '',
      urlImagen: json['urlImagen'] ?? '0xFF0D47A1',
      calificacion: (json['calificacion'] ?? 0.0).toDouble(),
      etiquetas: json['etiquetas'] != null ? List<String>.from(json['etiquetas']) : [],
      // Extraemos solo los IDs de los objetos "Usuario" anidados
      profesoresIds: json['profesores'] != null ? (json['profesores'] as List).map((p) => p['id'].toString()).toList() : [],
      estudiantesIds: json['estudiantes'] != null ? (json['estudiantes'] as List).map((e) => e['id'].toString()).toList() : [],
      actividades: json['actividades'] != null ? (json['actividades'] as List).map((a) => Actividad.fromJson(a)).toList() : [],
      mensajes: json['mensajes'] != null ? (json['mensajes'] as List).map((m) => MensajeMuro.fromJson(m)).toList() : [],
      estudiantesLista: json['estudiantes'] != null 
          ? (json['estudiantes'] as List).map((e) => Usuario.fromJson(e)).toList() 
          : [],
    );
  }

Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'descripcion': descripcion,
      'autor': autor, 
      'urlImagen': urlImagen,
      'calificacion': calificacion, // ¡Esta es la línea clave que soluciona el error!
      'etiquetas': etiquetas,
    };
  }
}