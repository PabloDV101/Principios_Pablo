import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/usuario.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/actividad.dart';
import '../../domain/entities/entrega.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:file_picker/file_picker.dart';


class ApiService {
  static const String baseUrl = 'https://campus-api-2vct.onrender.com/api';
  String? _tokenLocal;

Future<String?> subirArchivoCloudinary(PlatformFile archivo) async {
    // 1. Detectar la extensión
    final extension = archivo.extension?.toLowerCase() ?? '';
    
    // 2. Determinar el "resource_type" para Cloudinary
    String resourceType = 'raw'; // Por defecto para PDFs, DOCX, ZIP, etc.
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) {
      resourceType = 'image';
    } else if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) {
      resourceType = 'video';
    }

    // Reemplaza con tus datos reales de Cloudinary
  const  String cloudName = 'dyzvoqcqs'; 
  const String uploadPreset = 'campus_preset';
    final uri = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/$resourceType/upload');

    try {
      final request = http.MultipartRequest('POST', uri)
        ..fields['upload_preset'] = uploadPreset;

      // Soporte multiplataforma (Web vs Móvil)
      if (archivo.bytes != null) {
        request.files.add(http.MultipartFile.fromBytes('file', archivo.bytes!, filename: archivo.name));
      } else if (archivo.path != null) {
        request.files.add(await http.MultipartFile.fromPath('file', archivo.path!));
      } else {
        return null;
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final data = json.decode(responseData);
        return data['secure_url']; // Retorna el enlace público del archivo
      } else {
        print('Error en Cloudinary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al subir a Cloudinary: $e');
      return null;
    }
  }

  // ACTUALIZACIÓN: Ahora permite cambiar el Content-Type para cuando enviamos texto plano
  Future<Map<String, String>> _getHeaders({String contentType = 'application/json; charset=UTF-8'}) async {
    if (_tokenLocal == null) {
      final prefs = await SharedPreferences.getInstance();
      _tokenLocal = prefs.getString('jwt_token');
    }
    
    return {
      'Content-Type': contentType,
      if (_tokenLocal != null) 'Authorization': 'Bearer $_tokenLocal',
    };
  }

  // Cerrar Sesión
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    await prefs.remove('usuario_data');
    _tokenLocal = null;
  }

  // ==========================================
  // USUARIOS
  // ==========================================

  // Iniciar Sesión con JWT
  Future<Usuario?> login(String correo, String password) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/login?correo=$correo&password=$password');
      final response = await http.post(url);

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        final token = data['token'];
        final usuarioJson = data['usuario'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('usuario_data', json.encode(usuarioJson));
        
        _tokenLocal = token;
        return Usuario.fromJson(usuarioJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // Obtener perfil público de cualquier usuario (Ej. el instructor)
  Future<Usuario?> obtenerUsuario(String id) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/$id');
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        return Usuario.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Registrar Usuario con JWT
  Future<Usuario?> registrarUsuario(Usuario usuario) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/registro');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json; charset=UTF-8'}, // Registro es público
        body: json.encode(usuario.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        
        final token = data['token'];
        final usuarioJson = data['usuario'];
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token);
        await prefs.setString('usuario_data', json.encode(usuarioJson));
        
        _tokenLocal = token;
        return Usuario.fromJson(usuarioJson);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
  // Actualizar perfil de usuario
  Future<Usuario?> actualizarPerfil(String id, Usuario usuarioActualizado) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/$id/perfil');
      final response = await http.put(
        url,
        headers: await _getHeaders(),
        body: json.encode(usuarioActualizado.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Usuario.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // ==========================================
  // GESTIÓN DE CURSOS
  // ==========================================

  Future<List<Curso>> obtenerCatalogo() async {
    try {
      final url = Uri.parse('$baseUrl/cursos');
      // El catálogo lo configuramos como público en Spring Boot
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final String responseBody = utf8.decode(response.bodyBytes);
        final List<dynamic> data = json.decode(responseBody);
        return data.map((json) => Curso.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error al obtener el catálogo: $e');
      return [];
    }
  }
  // --- MÉTODOS PARA CONTENIDO (Secciones y Materiales) ---

  Future<Seccion?> crearSeccion(String cursoId, String titulo) async {
    try {
      final url = Uri.parse('$baseUrl/contenido/curso/$cursoId/secciones');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({'titulo': titulo}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Decodificamos la respuesta usando utf8 para evitar problemas con acentos
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Seccion.fromJson(data);
      } else {
        print('Error al crear sección: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al crear sección: $e');
      return null;
    }
  }
  Future<MaterialCurso?> agregarMaterial(String seccionId, String titulo, String tipo, String url) async {
    try {
      final uri = Uri.parse('$baseUrl/contenido/seccion/$seccionId/materiales');
      final response = await http.post(
        uri,
        headers: await _getHeaders(),
        body: json.encode({
          'titulo': titulo,
          'tipo': tipo,
          'url': url
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return MaterialCurso.fromJson(data);
      } else {
        print('Error al agregar material: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción al agregar material: $e');
      return null;
    }
  }
  

  Future<Curso?> crearCurso(Curso curso, String creadorId) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/crear/$creadorId');
      final response = await http.post(
        url,
        headers: await _getHeaders(), 
        body: json.encode(curso.toJson()), 
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Curso.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> inscribirEstudiante(String cursoId, String estudianteId) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/$cursoId/inscribir/$estudianteId');
      final response = await http.post(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<List<Curso>> obtenerCursosAprendizaje(String estudianteId) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/aprendizaje/$estudianteId');
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Curso.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  Future<List<Curso>> obtenerCursosEnsenanza(String profesorId) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/ensenanza/$profesorId');
      final response = await http.get(url, headers: await _getHeaders());
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        return data.map((json) => Curso.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
  
Future<bool> calificarCurso(String cursoId, Resena resena) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/$cursoId/calificar');
      final response = await http.post(
        url, 
        headers: await _getHeaders(),
        body: json.encode(resena.toJson()), // Mandamos el objeto completo
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  // ==========================================
  // ACTIVIDADES Y TAREAS
  // ==========================================

  Future<Actividad?> crearActividad(String cursoId, Actividad actividad) async {
    try {
      final url = Uri.parse('$baseUrl/actividades/curso/$cursoId');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'titulo': actividad.titulo,
          'descripcion': actividad.descripcion,
          'fechaInicio': actividad.fechaInicio.toIso8601String(),
          'fechaTermino': actividad.fechaTermino.toIso8601String(),
          'valorMaximo': actividad.valorMaximo,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Actividad.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

// Actualiza tu método existente con estos parámetros y el body:
  Future<Entrega?> enviarTarea(
    String actividadId, 
    String estudianteId, 
    String comentarios, {
    String? archivoUrl,       // <--- Parámetro opcional
    String? archivoNombre,    // <--- Parámetro opcional
  }) async {
    try {
      // Ojo: Asegúrate de que esta URL coincida con tu endpoint real
      final url = Uri.parse('$baseUrl/actividades/$actividadId/entregas'); 
      
      // Armamos el JSON incluyendo los archivos solo si existen
      final body = {
        'estudianteId': estudianteId,
        'comentariosEstudiante': comentarios,
        if (archivoUrl != null) 'archivoUrl': archivoUrl,
        if (archivoNombre != null) 'archivoNombre': archivoNombre,
      };

      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(body),
      );

     if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Entrega.fromJson(data);
      } else {
        // 👇 MODIFICA ESTOS PRINTS 👇
        print('Error al enviar tarea. Status: ${response.statusCode}');
        print('Motivo del backend: ${response.body}'); // Esto nos dirá la verdad
        return null;
      }
    } catch (e) {
      print('Excepción al enviar tarea: $e');
      return null;
    }
  }

  Future<Entrega?> calificarTarea(String entregaId, double calificacion, String retroalimentacion) async {
    try {
      final url = Uri.parse('$baseUrl/actividades/entrega/$entregaId/calificar?calificacion=$calificacion&retroalimentacion=$retroalimentacion');
      final response = await http.put(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Entrega.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<Actividad?> actualizarActividad(String id, Actividad actividad) async {
    try {
      final url = Uri.parse('$baseUrl/actividades/$id');
      final response = await http.put(
        url, 
        headers: await _getHeaders(), 
        body: json.encode({
          'titulo': actividad.titulo, 
          'descripcion': actividad.descripcion,
          'fechaInicio': actividad.fechaInicio.toIso8601String(), 
          'fechaTermino': actividad.fechaTermino.toIso8601String(),
        })
      );
      if (response.statusCode == 200) return Actividad.fromJson(json.decode(utf8.decode(response.bodyBytes)));
      return null;
    } catch (e) { 
      return null; 
    }
  }

  Future<bool> eliminarActividad(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/actividades/$id'), headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) { 
      return false; 
    }
  }

  // ==========================================
  // FAVORITOS Y MURO
  // ==========================================

  Future<bool> toggleDeseos(String usuarioId, String cursoId) async {
    try {
      final url = Uri.parse('$baseUrl/usuarios/$usuarioId/deseos/$cursoId');
      final response = await http.post(url, headers: await _getHeaders());
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
Future<List<String>> obtenerIdsDeseos(String usuarioId) async {
  try {
   final response = await http.get(
  Uri.parse('$baseUrl/usuarios/$usuarioId/ids-deseos'),
  headers: await _getHeaders(), // ¡Aquí está el secreto!
);
    
    // --- ESTO ES LO IMPORTANTE ---
    print("Respuesta del servidor para deseos: ${response.statusCode}");
    print("Cuerpo: ${response.body}"); 
    
    if (response.statusCode == 200) {
      return List<String>.from(json.decode(response.body));
    }
  } catch (e) {
    print('Error en API: $e');
  }
  return [];
}

// AHORA DEVOLVEMOS EL CURSO COMPLETO ACTUALIZADO
  Future<Curso?> enviarMensajeMuro(String cursoId, MensajeMuro mensaje) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/$cursoId/mensajes'); // Verifica que esta sea tu ruta real
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(mensaje.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Leemos la respuesta (que es el JSON del curso con el nuevo mensaje ya incluido)
        final String responseBody = utf8.decode(response.bodyBytes);
        return Curso.fromJson(json.decode(responseBody));
      } else {
        print('Error del servidor: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción en enviarMensajeMuro: $e');
      return null;
    }
  }
}