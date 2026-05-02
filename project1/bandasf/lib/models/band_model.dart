class Band {
  final int? id;
  final String nombre;
  final String descripcion;
  final String urlImagen;
  final int likesCount;    // Nuevo
  final int dislikesCount; // Nuevo
  final bool dioLike;       // Nuevo: si el usuario actual dio like
  final bool dioDislike;    // Nuevo: si el usuario actual dio dislike
  final DateTime? fechaCreacion;
  final String usernameAutor; // Opcional, si tu backend lo devuelve

  Band({
    this.id,
    required this.nombre,
    required this.descripcion,
    required this.urlImagen,
    this.likesCount = 0,
    this.dislikesCount = 0,
    this.dioLike = false,
    this.dioDislike = false,
    this.fechaCreacion,
    required this.usernameAutor,

  });

factory Band.fromJson(Map<String, dynamic> json) {
  return Band(
    id: json['id'],
    nombre: json['nombre'],
    descripcion: json['descripcion'],
    urlImagen: json['urlImagen'],
    likesCount: json['likesCount'] ?? 0,
    dislikesCount: json['dislikesCount'] ?? 0,
    dioLike: json['dioLike'] ?? false,
    dioDislike: json['dioDislike'] ?? false,
    // CAMBIO AQUÍ: Manejo seguro de la fecha
    fechaCreacion: json['fechaCreacion'] != null 
      ? DateTime.tryParse(json['fechaCreacion'].toString()) 
      : null,
    usernameAutor: json['usuario'] != null ? json['usuario']['username'] : 'Anónimo', // Valor por defecto si no viene del backend
  );
}

  // Convierte Objeto Dart a JSON para enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'urlImagen': urlImagen,
      'usuario': {
        'username': usernameAutor,
      },

    };
  }

  Band copyWith({bool? dioLike, bool? dioDislike, int? likesCount, int? dislikesCount}) {
  return Band(
    id: this.id,
    nombre: this.nombre,
    descripcion: this.descripcion,
    urlImagen: this.urlImagen,
    likesCount: likesCount ?? this.likesCount,
    dislikesCount: dislikesCount ?? this.dislikesCount,
    fechaCreacion: this.fechaCreacion,
    usernameAutor: this.usernameAutor,
    dioLike: dioLike ?? this.dioLike,
    dioDislike: dioDislike ?? this.dioDislike,
  );
}
}