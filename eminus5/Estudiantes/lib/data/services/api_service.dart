import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/usuario.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/actividad.dart';
import '../../domain/entities/entrega.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  String? _tokenLocal;

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
Future<bool> calificarCurso(String cursoId, double estrellas, String usuarioId) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/$cursoId/calificar?estrellas=$estrellas&usuarioId=$usuarioId');
      final response = await http.put(url, headers: await _getHeaders());
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

  Future<Entrega?> enviarTarea(String actividadId, String estudianteId, String comentarios) async {
    try {
      final url = Uri.parse('$baseUrl/actividades/$actividadId/entregar/$estudianteId');
      final response = await http.post(
        url,
        // Usamos texto plano pero inyectamos el JWT
        headers: await _getHeaders(contentType: 'text/plain; charset=UTF-8'), 
        body: comentarios,
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return Entrega.fromJson(data);
      }
      return null;
    } catch (e) {
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

  Future<MensajeMuro?> enviarMensajeMuro(String cursoId, MensajeMuro mensaje) async {
    try {
      final url = Uri.parse('$baseUrl/cursos/$cursoId/mensajes');
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({
          'remitente': mensaje.remitente,
          'rol': mensaje.rol,
          'mensaje': mensaje.mensaje,
          'reacciones': 0, 
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(utf8.decode(response.bodyBytes));
        return MensajeMuro.fromJson(data);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}