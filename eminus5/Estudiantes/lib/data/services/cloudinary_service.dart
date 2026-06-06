import 'dart:convert';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // REEMPLAZA ESTOS VALORES CON LOS DE TU CUENTA
  final String cloudName = 'dyzvoqcqs'; 
  final String uploadPreset = 'campus_preset'; // El preset Unsigned que creaste

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

}