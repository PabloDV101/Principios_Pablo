import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;


class CloudinaryService {
  // REEMPLAZA ESTOS VALORES CON LOS DE TU CUENTA
  final String cloudName = 'dyzvoqcqs'; 
  final String uploadPreset = 'campus_preset'; // El preset Unsigned que creaste


// ... tus otros imports


Future<String?> subirImagen(XFile imagen) async { 
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset;

      // Magia multiplataforma: Leemos los bytes en lugar de la ruta del disco
      final bytes = await imagen.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes,
        filename: imagen.name, // image_picker nos da el nombre original
      ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.toBytes();
        final String resultString = String.fromCharCodes(responseData);
        final Map<String, dynamic> jsonResult = json.decode(resultString);
        return jsonResult['secure_url'];
      } else {
        print('Error Cloudinary: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Excepción Cloudinary: $e');
      return null;
    }
  }
  // Nuevo método para subir videos
// Nuevo método para subir videos optimizado y con depuración
  Future<String?> subirVideo(XFile video) async {
    try {
      final url = Uri.parse('https://api.cloudinary.com/v1_1/$cloudName/video/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset;

      // 1. Usamos la misma magia multiplataforma (bytes en lugar de path)
      final bytes = await video.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes(
        'file', 
        bytes,
        filename: video.name, // image_picker nos da el nombre original
      ));

      final response = await request.send();

      // 2. Leemos la respuesta completa del servidor
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        return data['secure_url']; // URL pública del video
      } else {
        // 3. SI FALLA, AQUÍ VEREMOS EL MOTIVO EXACTO
        return null;
      }
    } catch (e) {
      return null;
    }
  }

}