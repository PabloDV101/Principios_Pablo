import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/band_model.dart'; // Asegúrate de que este archivo exista y tenga la clase Band con fromJson

class ApiService {
  final _storage = const FlutterSecureStorage();
  // Cambia esto por tu IP local (no uses localhost si pruebas en celular)
  final String baseUrl = "http://localhost:8080/api"; 

  // --- LOGIN ---
  Future<bool> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signin'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"username": username, "password": password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Guardamos el token de forma segura
      await _storage.write(key: 'token', value: data['token']);
      return true;
    }
    return false;
  }

  // --- OBTENER BANDAS (CON TOKEN) ---
  Future<List<Band>> getBands() async {
    String? token = await _storage.read(key: 'token');

    final response = await http.get(
      Uri.parse('$baseUrl/bands'),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token", // Aquí se envía el JWT
      },
    );

if (response.statusCode == 200) {
    List<dynamic> body = jsonDecode(response.body);
    
    // ESTA ES LA PARTE CLAVE: Convierte el JSON a objetos Banda
    List<Band> bandas = body.map((item) => Band.fromJson(item)).toList();
    return bandas;
  } else {
    throw Exception("Error al cargar bandas");
  }
}

  // --- LOGOUT ---
  Future<void> logout() async {
    await _storage.delete(key: 'token');
  }
}