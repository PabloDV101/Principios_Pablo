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
              // Reemplaza el onPressed de tu ElevatedButton en EditBandScreen
              onPressed: () async {
                Band bandaEditada = Band(
                  id: widget.banda.id,
                  nombre: _nombreController.text,
                  descripcion: _descController.text,
                  urlImagen: widget.banda.urlImagen,
                  usernameAutor: widget.banda.usernameAutor,
                );

                try {
                  await _apiService.editarBanda(widget.banda.id!, bandaEditada);
                  if (!mounted) return;

                  // Solo un pop, enviando true
                  Navigator.pop(context, true);
                } catch (e) {
                  debugPrint("Error al editar: $e");
                  // Opcional: mostrar un SnackBar si falla
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
