import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/band_model.dart';

class EditBandScreen extends StatefulWidget {
  final Band banda;
  const EditBandScreen({super.key, required this.banda});

  @override
  State<EditBandScreen> createState() => _EditBandScreenState();
}

class _EditBandScreenState extends State<EditBandScreen> {
  late TextEditingController _nombreController;
  late TextEditingController _descController;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController(text: widget.banda.nombre);
    _descController = TextEditingController(text: widget.banda.descripcion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Editar Banda")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
                controller: _nombreController,
                decoration: const InputDecoration(labelText: "Nombre")),
            TextField(
                controller: _descController,
                decoration: const InputDecoration(labelText: "Descripción")),
            ElevatedButton(
              onPressed: () async {
                // 1. Crear un objeto Band con los nuevos datos
                Band bandaEditada = Band(
                  id: widget.banda.id, // Importante mantener el ID
                  nombre: _nombreController.text,
                  descripcion: _descController.text,
                  urlImagen:
                      widget.banda.urlImagen, // Mantenemos la imagen original
                  usernameAutor: widget.banda.usernameAutor, // Mantenemos el autor original
                );

                try {
                  // 2. Llamar al servicio (asegúrate de tener este método en tu ApiService)
                  // Dentro del botón Guardar de EditBandScreen
await _apiService.editarBanda(widget.banda.id!, bandaEditada);
Navigator.pop(context, true); // Devuelves 'true' al HomeScreen

                  // 3. Regresar exitosamente
                  if (!mounted) return;
                  Navigator.pop(context,
                      true); // Enviamos 'true' para avisar que se editó
                      
                } catch (e) {
                  debugPrint("Error al editar: $e");
                }
              },
              child: const Text("Guardar Cambios"),
            )
          ],
        ),
      ),
    );
  }
}
