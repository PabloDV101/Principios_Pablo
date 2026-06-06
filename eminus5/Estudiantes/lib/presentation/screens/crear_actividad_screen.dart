// lib/presentation/screens/crear_actividad_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/actividad.dart';
import '../../data/services/api_service.dart';

class CrearActividadScreen extends StatefulWidget {
  final Curso curso;
  final Actividad? actividadAEditar;

  const CrearActividadScreen({super.key, required this.curso, this.actividadAEditar});

  @override
  State<CrearActividadScreen> createState() => _CrearActividadScreenState();
}

class _CrearActividadScreenState extends State<CrearActividadScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  DateTime _fechaInicio = DateTime.now();
  DateTime _fechaTermino = DateTime.now().add(const Duration(days: 7)); // Por defecto una semana
@override
  void initState() {
    super.initState();
    // Si viene una actividad, llenamos el formulario automáticamente
    if (widget.actividadAEditar != null) {
      _tituloController.text = widget.actividadAEditar!.titulo;
      _descripcionController.text = widget.actividadAEditar!.descripcion;
      _fechaInicio = widget.actividadAEditar!.fechaInicio;
      _fechaTermino = widget.actividadAEditar!.fechaTermino;
    }
  }
  Future<void> _seleccionarFecha(BuildContext context, bool esInicio) async {
    final DateTime? seleccionada = await showDatePicker(
      context: context,
      initialDate: esInicio ? _fechaInicio : _fechaTermino,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: Colors.black, onPrimary: Colors.white, onSurface: Colors.black),
          ),
          child: child!,
        );
      },
    );
    if (seleccionada != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = seleccionada;
        } else {
          _fechaTermino = seleccionada;
        }
      });
    }
  }

final ApiService _apiService = ApiService();
  bool _cargando = false;

Future<void> _guardarActividad() async {
    if (_tituloController.text.isEmpty || _descripcionController.text.isEmpty) return;
    setState(() => _cargando = true);

    final datosTemp = Actividad(id: '', titulo: _tituloController.text.trim(), descripcion: _descripcionController.text.trim(), fechaInicio: _fechaInicio, fechaTermino: _fechaTermino);

    if (widget.actividadAEditar != null) {
      // ESTAMOS EDITANDO
      final actualizada = await _apiService.actualizarActividad(widget.actividadAEditar!.id, datosTemp);
      if (actualizada != null) {
        final index = widget.curso.actividades.indexWhere((a) => a.id == actualizada.id);
        if (index != -1) widget.curso.actividades[index] = actualizada;
        Navigator.pop(context);
      }
    } else {
      // ESTAMOS CREANDO (Tu código existente)
      final creada = await _apiService.crearActividad(widget.curso.id, datosTemp);
      if (creada != null) {
        widget.curso.actividades.add(creada);
        Navigator.pop(context);
      }
    }
    setState(() => _cargando = false);
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Crear nueva tarea', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey.shade200, height: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Título de la tarea', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _tituloController, decoration: InputDecoration(hintText: 'Ej. Ensayo de Arquitectura', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)))),
            const SizedBox(height: 24),

            const Text('Instrucciones / Descripción', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            const SizedBox(height: 8),
            TextField(controller: _descripcionController, maxLines: 4, decoration: InputDecoration(hintText: 'Describe qué deben hacer los estudiantes...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)))),
            const SizedBox(height: 24),

            // Selectores de Fechas
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => _seleccionarFecha(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha Inicio', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${_fechaInicio.day}/${_fechaInicio.month}/${_fechaInicio.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: () => _seleccionarFecha(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Fecha Límite', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 4),
                          Text('${_fechaTermino.day}/${_fechaTermino.month}/${_fechaTermino.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 48),

            SizedBox(
  width: double.infinity,
  child: _cargando
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
    : ElevatedButton(
        onPressed: _guardarActividad,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Publicar Tarea', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
)
          ],
        ),
      ),
    );
  }
}