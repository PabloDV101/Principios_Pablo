// lib/presentation/screens/crear_curso_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/curso.dart';
import '../../data/services/api_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../data/services/cloudinary_service.dart';
import '../../data/mock/mock_database.dart';  
import 'package:flutter/foundation.dart';

class CrearCursoScreen extends StatefulWidget {
  final Usuario usuarioActivo;
  

  const CrearCursoScreen({super.key, required this.usuarioActivo});

  @override
  State<CrearCursoScreen> createState() => _CrearCursoScreenState();
}

class _CrearCursoScreenState extends State<CrearCursoScreen> {
  XFile? _videoSeleccionado;
  // Añade esto debajo de tus otros controladores
  final List<TextEditingController> _aprendizajesControllers = [TextEditingController()];
  
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  String _categoriaSeleccionada = 'Programación';

final ApiService _apiService = ApiService();
  bool _cargando = false;
  final CloudinaryService _cloudinaryService = CloudinaryService();
  XFile? _imagenSeleccionada; 
  final ImagePicker _picker = ImagePicker();

 Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (imagen != null) {
      setState(() {
        _imagenSeleccionada = imagen; // Lo guardamos directo como XFile
      });
    }
  }
  Future<void> _seleccionarVideo() async {
    final XFile? video = await ImagePicker().pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() => _videoSeleccionado = video);
    }
  }

Future<void> _guardarCurso() async {
    if (_tituloController.text.trim().isEmpty || _descripcionController.text.trim().isEmpty || _imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, completa todos los campos y añade una portada.'), backgroundColor: Colors.red));
      return;
    }

    List<String> aprendizajesFinales = _aprendizajesControllers.map((c) => c.text.trim()).where((t) => t.isNotEmpty).toList();
    if (aprendizajesFinales.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Debes agregar al menos un objetivo'), backgroundColor: Colors.red));
      return;
    }

    setState(() => _cargando = true);

    // 1. Subir Portada
    final urlCloudinary = await _cloudinaryService.subirImagen(_imagenSeleccionada!);
    
    // 2. Subir Video (Si eligió uno)
    String? videoUrlCloudinary;
    if (_videoSeleccionado != null) {
      videoUrlCloudinary = await _cloudinaryService.subirVideo(_videoSeleccionado!);
    }
    print("===== URL DEL VIDEO DESDE CLOUDINARY: $videoUrlCloudinary =====");

    if (urlCloudinary == null) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir la imagen.'), backgroundColor: Colors.red));
      return;
    }

    final nuevoCurso = Curso(
      id: '', 
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      autor: widget.usuarioActivo.nombre,
      urlImagen: urlCloudinary, 
      videoUrl: videoUrlCloudinary, // ASIGNAMOS EL VIDEO AQUÍ
      etiquetas: [_categoriaSeleccionada],
      aprendizajes: aprendizajesFinales, 
    );

    final cursoCreado = await _apiService.crearCurso(nuevoCurso, widget.usuarioActivo.id);
    setState(() => _cargando = false);

    if (cursoCreado != null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('¡Curso publicado exitosamente!'), backgroundColor: Colors.green));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al guardar el curso.'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categorias = MockDatabase.instancia.categoriasPredefinidas;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Crear nuevo curso', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Selector de Imagen
          GestureDetector(
            onTap: _seleccionarImagen,
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
                image: _imagenSeleccionada != null
                    ? DecorationImage(
                        // Si estamos en web, usamos NetworkImage para leer el "blob:"
                        // Si estamos en móvil, usamos FileImage normal
                        image: kIsWeb 
                            ? NetworkImage(_imagenSeleccionada!.path) as ImageProvider
                            : FileImage(File(_imagenSeleccionada!.path)),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: _imagenSeleccionada == null
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                        SizedBox(height: 8),
                        Text('Añadir portada del curso', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold))
                      ],
                    )
                  : Align(
                      alignment: Alignment.topRight,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircleAvatar(
                          backgroundColor: Colors.black54,
                          child: IconButton(
                            icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                            onPressed: _seleccionarImagen,
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          ListTile(
              leading: const Icon(Icons.video_library, color: Color(0xFF0D47A1)),
              title: const Text('Video de presentación (Opcional)'),
              subtitle: Text(_videoSeleccionado == null ? 'Ningún video seleccionado' : 'Video listo para subir', style: TextStyle(color: _videoSeleccionado == null ? Colors.grey : Colors.green)),
              trailing: ElevatedButton(
                onPressed: _seleccionarVideo,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade200, foregroundColor: Colors.black),
                child: const Text('Seleccionar'),
              ),
            ),
          const SizedBox(height: 24),
          // ... aquí sigue tu TextField del Título ...
            const Text('Título del curso', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _tituloController,
              decoration: InputDecoration(
                hintText: 'Ej. Introducción a la Arquitectura Limpia',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Descripción', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Describe qué aprenderán los estudiantes...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)),
              ),
            ),
            const SizedBox(height: 24),

            const Text('Categoría principal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categorias.map((cat) {
                final seleccionada = cat == _categoriaSeleccionada;
                return ChoiceChip(
                  label: Text(cat),
                  selected: seleccionada,
                  selectedColor: Colors.black,
                  backgroundColor: Colors.grey.shade100,
                  labelStyle: TextStyle(color: seleccionada ? Colors.white : Colors.black87),
                  onSelected: (bool selected) {
                    setState(() => _categoriaSeleccionada = cat);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 48),
            const Text('Lo que aprenderás (Mínimo 1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...List.generate(_aprendizajesControllers.length, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _aprendizajesControllers[index],
                        decoration: InputDecoration(
                          hintText: 'Ej. Desarrollar una API REST...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                      ),
                    ),
                    if (_aprendizajesControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                        onPressed: () => setState(() => _aprendizajesControllers.removeAt(index)),
                      )
                  ],
                ),
              );
            }),
            TextButton.icon(
              onPressed: () => setState(() => _aprendizajesControllers.add(TextEditingController())),
              icon: const Icon(Icons.add),
              label: const Text('Añadir otro objetivo'),
            ),
            const SizedBox(height: 24),
            SizedBox(
  width: double.infinity,
  child: _cargando 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
    : ElevatedButton(
        onPressed: _guardarCurso,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Publicar Curso', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
)
          ],
        ),
      ),
    );
  }
}