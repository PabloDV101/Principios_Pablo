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

Future<void> _guardarCurso() async {
    // 1. Validación estricta: Nada puede estar vacío y la imagen es obligatoria
    if (_tituloController.text.trim().isEmpty || 
        _descripcionController.text.trim().isEmpty || 
        _imagenSeleccionada == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos y añade una portada.', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _cargando = true);

    // 2. Subida obligatoria a Cloudinary
    final urlCloudinary = await _cloudinaryService.subirImagen(_imagenSeleccionada!);

    // Si Cloudinary falla por algún motivo (ej. sin internet), detenemos la publicación
    if (urlCloudinary == null) {
      setState(() => _cargando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al subir la imagen. Verifica tu conexión.'), backgroundColor: Colors.red),
      );
      return;
    }

    // 3. Crear el objeto final con la URL real
    final nuevoCurso = Curso(
      id: '', 
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      autor: widget.usuarioActivo.nombre,
      urlImagen: urlCloudinary, 
      etiquetas: [_categoriaSeleccionada],
    );

    // 4. Guardar en PostgreSQL
    final cursoCreado = await _apiService.crearCurso(nuevoCurso, widget.usuarioActivo.id);

    setState(() => _cargando = false);

    if (cursoCreado != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Curso publicado exitosamente!'), backgroundColor: Colors.green)
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error en el servidor al guardar el curso.'), backgroundColor: Colors.red)
      );
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