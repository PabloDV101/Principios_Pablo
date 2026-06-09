import 'actividad.dart';
import 'usuario.dart';

class MensajeMuro {
  final String? id; // Puede ser nulo antes de guardarse
  final String remitente; // Tu backend lo usa para el nombre
  final String usuarioId; // Para abrir el perfil
  final String? fotoUrl; 
  final String rol;
  final String mensaje; // Tu backend lo usa en vez de "texto"
  final DateTime fecha; // Cambiamos String por DateTime para manejar tu LocalDateTime
  final int reacciones;

  MensajeMuro({
    this.id,
    required this.remitente,
    required this.usuarioId,
    this.fotoUrl,
    required this.rol,
    required this.mensaje,
    required this.fecha,
    this.reacciones = 0,
  });

  factory MensajeMuro.fromJson(Map<String, dynamic> json) {
    return MensajeMuro(
      id: json['id']?.toString(),
      remitente: json['remitente'] ?? 'Usuario',
      usuarioId: json['usuarioId'] ?? '',
      fotoUrl: json['fotoUrl'],
      rol: json['rol'] ?? 'ESTUDIANTE',
      mensaje: json['mensaje'] ?? '',
      // Spring Boot envía el LocalDateTime como un texto ISO (Ej: "2026-06-06T15:25:00")
      fecha: json['fecha'] != null ? DateTime.parse(json['fecha']) : DateTime.now(),
      reacciones: json['reacciones'] ?? 0,
    );
  }

Map<String, dynamic> toJson() {
    final String idSeguro = usuarioId.isNotEmpty ? usuarioId : 'ID_DESCONOCIDO';
    return {
      'id': id,
      'remitente': remitente,
      // Mandamos doble llave para que Java lo entienda sí o sí
      'usuarioId': idSeguro,
      'usuario_id': idSeguro,
      'fotoUrl': fotoUrl,
      'foto_url': fotoUrl,
      'rol': rol,
      'mensaje': mensaje,
      'fecha': fecha.toIso8601String(), 
      'reacciones': reacciones,
    };
  }
}

class Resena {
  final String usuarioId;
  final String nombreUsuario;
  final String? fotoUrl;
  final double estrellas;
  final String comentario;
  final String fecha;

  Resena({required this.usuarioId, required this.nombreUsuario, this.fotoUrl, required this.estrellas, required this.comentario, required this.fecha});

  factory Resena.fromJson(Map<String, dynamic> json) => Resena(
    usuarioId: json['usuarioId'] ?? '', nombreUsuario: json['nombreUsuario'] ?? 'Usuario', fotoUrl: json['fotoUrl'],
    estrellas: (json['estrellas'] ?? 0.0).toDouble(), comentario: json['comentario'] ?? '', fecha: json['fecha'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'usuarioId': usuarioId, 'nombreUsuario': nombreUsuario, 'fotoUrl': fotoUrl,
    'estrellas': estrellas, 'comentario': comentario, 'fecha': fecha,
  };
}

class Curso {
  final String id;
  final String titulo;
  final String descripcion;
  final String autor;
  final String urlImagen;
  final String? videoUrl; 
  final double calificacion;
  final List<String> etiquetas;
  final List<String> aprendizajes; 
  final List<Resena> resenas; // NUEVO
  bool isFavorito;
  List<Seccion> secciones;
  
  List<String> profesoresIds;
  List<String> estudiantesIds;
  List<Actividad> actividades;
  List<MensajeMuro> mensajes; 
  List<Usuario> estudiantesLista;

  Curso({
    required this.id, required this.titulo, required this.descripcion, required this.autor, required this.urlImagen,
    this.videoUrl, this.calificacion = 0.0, List<String>? etiquetas, List<String>? aprendizajes, List<Resena>? resenas, this.isFavorito = false,
    List<String>? profesoresIds, List<String>? estudiantesIds, List<Actividad>? actividades, List<MensajeMuro>? mensajes, List<Usuario>? estudiantesLista,List<Seccion>? secciones,
  })  : etiquetas = etiquetas ?? [], aprendizajes = aprendizajes ?? [], resenas = resenas ?? [],
        profesoresIds = profesoresIds ?? [], estudiantesIds = estudiantesIds ?? [], actividades = actividades ?? [],
        mensajes = mensajes ?? [], estudiantesLista = estudiantesLista ?? [], secciones = secciones ?? [];

  factory Curso.fromJson(Map<String, dynamic> json) {
    return Curso(
      id: json['id'] ?? '', titulo: json['titulo'] ?? '', descripcion: json['descripcion'] ?? '', autor: json['autor'] ?? '',
      urlImagen: json['urlImagen'] ?? '', videoUrl: json['videoUrl'], calificacion: (json['calificacion'] ?? 0.0).toDouble(),
      etiquetas: json['etiquetas'] != null ? List<String>.from(json['etiquetas']) : [],
      aprendizajes: json['aprendizajes'] != null ? List<String>.from(json['aprendizajes']) : [],
      resenas: json['resenas'] != null ? (json['resenas'] as List).map((r) => Resena.fromJson(r)).toList() : [], // EXTRAEMOS RESEÑAS
      profesoresIds: json['profesores'] != null ? (json['profesores'] as List).map((p) => p['id'].toString()).toList() : [],
      estudiantesIds: json['estudiantes'] != null ? (json['estudiantes'] as List).map((e) => e['id'].toString()).toList() : [],
      actividades: json['actividades'] != null ? (json['actividades'] as List).map((a) => Actividad.fromJson(a)).toList() : [],
      mensajes: json['mensajes'] != null ? (json['mensajes'] as List).map((m) => MensajeMuro.fromJson(m)).toList() : [],
      estudiantesLista: json['estudiantes'] != null ? (json['estudiantes'] as List).map((e) => Usuario.fromJson(e)).toList() : [],
      isFavorito: json['isFavorito'] ?? false, secciones: json['secciones'] != null 
          ? (json['secciones'] as List).map((s) => Seccion.fromJson(s)).toList() 
          : [],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'titulo': titulo, 'descripcion': descripcion, 'autor': autor, 'urlImagen': urlImagen, 'videoUrl': videoUrl,
    'calificacion': calificacion, 'etiquetas': etiquetas, 'aprendizajes': aprendizajes,
  };
}

class Seccion {
  final String id;
  final String titulo;
  final int orden;
  final List<MaterialCurso> materiales;

  Seccion({
    required this.id,
    required this.titulo,
    required this.orden,
    required this.materiales,
  });

  factory Seccion.fromJson(Map<String, dynamic> json) {
    return Seccion(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      orden: json['orden'] ?? 0,
      materiales: json['materiales'] != null 
          ? (json['materiales'] as List).map((m) => MaterialCurso.fromJson(m)).toList() 
          : [],
    );
  }
}

class MaterialCurso {
  final String id;
  final String titulo;
  final String tipo;
  final String url;
  final int orden;

  MaterialCurso({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.url,
    required this.orden,
  });

  factory MaterialCurso.fromJson(Map<String, dynamic> json) {
    return MaterialCurso(
      id: json['id'] ?? '',
      titulo: json['titulo'] ?? '',
      tipo: json['tipo'] ?? 'DOCUMENTO',
      url: json['url'] ?? '',
      orden: json['orden'] ?? 0,
    );
  }
}