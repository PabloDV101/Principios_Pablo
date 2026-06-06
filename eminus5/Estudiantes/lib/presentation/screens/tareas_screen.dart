// lib/presentation/screens/tareas_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../data/mock/mock_database.dart';
import 'actividad_detalle_screen.dart';

class TareasScreen extends StatefulWidget {
  final Usuario usuarioActivo;

  const TareasScreen({super.key, required this.usuarioActivo});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  // Lista temporal para agrupar todas las tareas con su curso respectivo
  final List<Map<String, dynamic>> _todasLasTareas = [];

  @override
  void initState() {
    super.initState();
    _cargarTareasGlobales();
  }

  void _cargarTareasGlobales() {
    // Extraemos todos los cursos donde el estudiante está inscrito
    final misCursos = MockDatabase.instancia.cursos
        .where((c) => c.estudiantesIds.contains(widget.usuarioActivo.id))
        .toList();

    // Recorremos los cursos y extraemos sus actividades
    for (var curso in misCursos) {
      for (var actividad in curso.actividades) {
        _todasLasTareas.add({
          'curso': curso,
          'actividad': actividad,
        });
      }
    }
    
    // Opcional: Ordenar por fecha de entrega más próxima
    _todasLasTareas.sort((a, b) => 
      (a['actividad'].fechaTermino as DateTime).compareTo(b['actividad'].fechaTermino as DateTime)
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        centerTitle: false,
        title: const Text('Mis Tareas Pendientes', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: Colors.grey.shade200, height: 1.0),
        ),
      ),
      body: _todasLasTareas.isEmpty
          ? const Center(child: Text('No tienes tareas pendientes 🎉', style: TextStyle(fontSize: 16, color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: _todasLasTareas.length,
              itemBuilder: (context, index) {
                final curso = _todasLasTareas[index]['curso'];
                final actividad = _todasLasTareas[index]['actividad'];

                return _TareaCard(curso: curso, actividad: actividad, usuarioActivo: widget.usuarioActivo);
              },
            ),
    );
  }
}

// Tarjeta Minimalista de Tarea Global
class _TareaCard extends StatelessWidget {
  final dynamic curso;
  final dynamic actividad;
  final Usuario usuarioActivo;

  const _TareaCard({required this.curso, required this.actividad, required this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ActividadDetalleScreen(
                  actividad: actividad, 
                  usuarioActivo: usuarioActivo,
                  curso: curso,
                )
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Etiqueta del Curso al que pertenece la tarea
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(
                    curso.titulo.toUpperCase(),
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[800], letterSpacing: 0.5),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Título de la tarea
                Text(actividad.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 16),
                
                // Fechas
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[500]),
                    const SizedBox(width: 8),
                    Text(
                      'Inicia: ${actividad.fechaInicio.day}/${actividad.fechaInicio.month}/${actividad.fechaInicio.year}',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: Colors.black),
                    const SizedBox(width: 8),
                    Text(
                      'Vence: ${actividad.fechaTermino.day}/${actividad.fechaTermino.month}/${actividad.fechaTermino.year}',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Call to action sutil (UX para una sola mano)
                Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Abrir tarea', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey[800], fontSize: 14)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.grey[800]),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}