import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/band_model.dart';
import 'package:flutter/foundation.dart';

class ApiService {
  // NOTA: Si pruebas en Chrome, localhost es correcto. 
  // Si pruebas en Android físico, usa tu IP local (ej: 192.168.1.XX)
  final String baseUrl = "http://localhost:8080/api"; 
  final _storage = const FlutterSecureStorage();

  // --- AUTENTICACIÓN ---

  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _storage.write(key: 'jwt_token', value: data['accessToken']);
      return true;
    }
    return false;
  }

  Future<bool> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "role": ["user"]
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error de conexión: $e");
      return false;
    }
  }

  // --- GESTIÓN DE BANDAS ---

Future<void> createBanda(Band banda) async {
  final token = await _storage.read(key: 'jwt_token');
  
  // ¡Esto nos dirá la verdad!
  print("--- DEBUG TOKEN ---");
  print("Token recuperado: $token");
  print("URL: $baseUrl/bandas");
  print("Headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'}");
  print("-------------------");

  if (token == null) throw Exception("No hay sesión activa");
  
  // ... el resto de tu código

    final response = await http.post(
      Uri.parse('$baseUrl/bandas'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(banda.toJson()),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error al crear banda: ${response.statusCode} - ${response.body}');
    }
  }

  Future<List<Band>> getMyBands() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) throw Exception("No hay sesión activa");

    final response = await http.get(
      Uri.parse('$baseUrl/bandas/mis-bandas'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(response.body);
      return body.map((item) => Band.fromJson(item)).toList();
    } else {
      throw Exception("Error al cargar bandas: ${response.statusCode}");
    }
  }

  // --- UTILS ---

  Future<String?> uploadToCloudinary(dynamic imageFile) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dyzvoqcqs/image/upload");
    final request = http.MultipartRequest('POST', url);
    request.fields['upload_preset'] = 'm1_default';

    if (kIsWeb) {
      final bytes = await imageFile.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('file', bytes, filename: 'upload.jpg'));
    } else {
      request.files.add(await http.MultipartFile.fromPath('file', imageFile.path));
    }

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      return json.decode(responseData)['secure_url'];
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt_token');
  }
}