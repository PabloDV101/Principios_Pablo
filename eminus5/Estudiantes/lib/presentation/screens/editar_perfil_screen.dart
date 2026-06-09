import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/usuario.dart';
import '../../data/services/api_service.dart';
import '../../data/services/cloudinary_service.dart';

class EditarPerfilScreen extends StatefulWidget {
  final Usuario usuarioActual;

  const EditarPerfilScreen({super.key, required this.usuarioActual});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final ApiService _apiService = ApiService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  late TextEditingController _profesionController;
  late TextEditingController _descripcionController;
  
  XFile? _nuevaFoto;
  bool _cargando = false;

  @override
  void initState() {
    super.initState();
    _profesionController = TextEditingController(text: widget.usuarioActual.profesion ?? '');
    _descripcionController = TextEditingController(text: widget.usuarioActual.descripcion ?? '');
  }

  @override
  void dispose() {
    _profesionController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final XFile? imagen = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (imagen != null) {
      setState(() => _nuevaFoto = imagen);
    }
  }

  Future<void> _guardarPerfil() async {
    setState(() => _cargando = true);
    
    String? fotoFinalUrl = widget.usuarioActual.fotoUrl;

    // Si el usuario eligió una nueva foto, la subimos a Cloudinary primero
    if (_nuevaFoto != null) {
      final urlSubida = await _cloudinaryService.subirImagen(_nuevaFoto!);
      if (urlSubida != null) {
        fotoFinalUrl = urlSubida;
      } else {
        setState(() => _cargando = false);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir la imagen a Cloudinary')));
        return;
      }
    }

    // Preparamos el usuario actualizado
    final usuarioActualizado = Usuario(
      id: widget.usuarioActual.id,
      nombre: widget.usuarioActual.nombre,
      correo: widget.usuarioActual.correo,
      rol: widget.usuarioActual.rol,
      cursosDeseados: widget.usuarioActual.cursosDeseados,
      fotoUrl: fotoFinalUrl,
      profesion: _profesionController.text.trim(),
      descripcion: _descripcionController.text.trim(),
    );

    // Mandamos a Spring Boot
    final usuarioGuardado = await _apiService.actualizarPerfil(widget.usuarioActual.id, usuarioActualizado);

    setState(() => _cargando = false);

    if (usuarioGuardado != null) {
      // ACTUALIZAMOS LA MEMORIA LOCAL PARA QUE EL CAMBIO SEA PERMANENTE
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('usuario_data', json.encode(usuarioGuardado.toJson()));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado con éxito'), backgroundColor: Colors.green));
        // Regresamos el nuevo usuario a la pantalla anterior
        Navigator.pop(context, usuarioGuardado); 
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar el perfil'), backgroundColor: Colors.red));
    }
  }

  Widget _construirAvatar() {
    ImageProvider imagenFondo;
    
    if (_nuevaFoto != null) {
      imagenFondo = kIsWeb ? NetworkImage(_nuevaFoto!.path) as ImageProvider : FileImage(File(_nuevaFoto!.path));
    } else if (widget.usuarioActual.fotoUrl != null && widget.usuarioActual.fotoUrl!.isNotEmpty) {
      imagenFondo = NetworkImage(widget.usuarioActual.fotoUrl!);
    } else {
      imagenFondo = const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png'); // Imagen por defecto
    }

    return GestureDetector(
      onTap: _seleccionarImagen,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: imagenFondo,
          ),
          const Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor:  Color(0xFF0D47A1),
              radius: 18,
              child:  Icon(Icons.camera_alt, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Editar Perfil', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(child: _construirAvatar()),
            const SizedBox(height: 32),
            
            TextField(
              controller: _profesionController,
              decoration: InputDecoration(
                labelText: 'Profesión / Título',
                hintText: 'Ej. Desarrollador Full-Stack',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.work_outline),
              ),
            ),
            const SizedBox(height: 24),
            
            TextField(
              controller: _descripcionController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Sobre mí',
                hintText: 'Cuéntanos un poco sobre ti...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _cargando ? null : _guardarPerfil,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _cargando
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar Cambios', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}