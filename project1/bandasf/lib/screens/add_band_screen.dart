import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../models/band_model.dart'; // Ajusta según tu estructura
import '../services/api_service.dart';


class AddBandScreen extends StatefulWidget {
  const AddBandScreen({super.key});

  @override
  State<AddBandScreen> createState() => _AddBandScreenState();
}

class _AddBandScreenState extends State<AddBandScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  
  XFile? _imageFile;
  bool _isSaving = false;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = pickedFile);
    }
  }

Future<void> _saveBanda() async {
  // 1. Validaciones básicas
  if (_imageFile == null || _nombreController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Por favor, rellena todos los campos")),
    );
    return;
  }

  setState(() => _isSaving = true);

  try {
    // 2. Leemos la imagen como bytes directamente (Universal para Web y Nativo)
    final bytes = await _imageFile!.readAsBytes();

    // 3. Preparamos el request para Cloudinary
    final cloudinaryUrl = Uri.parse("https://api.cloudinary.com/v1_1/dyzvoqcqs/image/upload");
    final request = http.MultipartRequest('POST', cloudinaryUrl);
    
    // Configuración de Cloudinary
    request.fields['upload_preset'] = 'm1_default';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file', 
        bytes, 
        filename: _imageFile!.name
      )
    );

    // 4. Enviamos la imagen y esperamos la respuesta
    final response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
      final imageUrl = json.decode(responseData)['secure_url'];

      // 5. Creamos el objeto Banda y lo enviamos a tu API Spring Boot
      Band newBand = Band(
        nombre: _nombreController.text,
        descripcion: _descController.text,
        urlImagen: imageUrl,
        usernameAutor: "UsuarioActual", // Aquí podrías usar el nombre de usuario real del autor
      );

      await _apiService.createBanda(newBand);
      
      if (!mounted) return;
      Navigator.pop(context); // Regresamos al home
    } else {
      throw Exception('Error al subir la imagen: ${response.statusCode}');
    }
  } catch (e) {
    debugPrint("Error al guardar la banda: $e");
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error al guardar: $e")),
      );
    }
  } finally {
    if (mounted) {
      setState(() => _isSaving = false);
    }
  }
}
// Este método solo se llama si NO estamos en la web
Widget _buildNativeImage(XFile imageFile) {
  // Si estamos en web, usamos la URL blob (imageFile.path)
  // Si estamos en nativo, le añadimos 'file://' para que Image.network lo lea
  final path = kIsWeb ? imageFile.path : 'file://${imageFile.path}';
  
  return Image.network(
    path, 
    fit: BoxFit.cover,
    errorBuilder: (context, error, stack) => const Icon(Icons.error),
  );
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Agregar Nueva Banda")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
           // ESTO FUNCIONA EN WEB Y EN ANDROID/LINUX
GestureDetector(
  onTap: _pickImage,
  child: Container(
    height: 200,
    width: double.infinity,
    decoration: BoxDecoration(
      color: Colors.grey[300], 
      borderRadius: BorderRadius.circular(15)
    ),
    child: _imageFile == null
        ? const Icon(Icons.add_a_photo, size: 50)
        : Image.network(
            _imageFile!.path, 
            fit: BoxFit.cover,
            // Esto ayuda a que Flutter no intente usar dart:io
            errorBuilder: (context, error, stackTrace) {
              return const Center(child: Text("Error al cargar imagen"));
            },
          ),
  ),
),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: 'Nombre de la Banda', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _descController,
              decoration: const InputDecoration(labelText: 'Descripción', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveBanda,
              child: _isSaving ? const CircularProgressIndicator() : const Text("Guardar Banda"),
            ),
          ],
        ),
      ),
    );
  }
}