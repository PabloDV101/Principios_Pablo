// lib/presentation/screens/tabs/actividades_tab.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/curso.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/actividad.dart';
import '../screens/actividad_detalle_screen.dart';
import '../screens/crear_actividad_screen.dart'; // Nueva pantalla para crear actividades
import '../../data/services/api_service.dart'; // Para eliminar actividades desde la UI

class ActividadesTab extends StatefulWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const ActividadesTab({super.key, required this.curso, required this.usuarioActivo});

  @override
  State<ActividadesTab> createState() => _ActividadesTabState();
}

class _ActividadesTabState extends State<ActividadesTab> {
  
  void _crearTareaDialog(BuildContext context) {
    final tituloCtrl = TextEditingController();
    final descripcionCtrl = TextEditingController(); // Nuevo controlador para descripción
    
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Nueva Tarea', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min, // Importante para que no ocupe toda la pantalla
          children: [
            TextField(
              controller: tituloCtrl, 
              decoration: const InputDecoration(
                labelText: 'Título de la tarea',
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              )
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descripcionCtrl,
              maxLines: 3, 
              decoration: const InputDecoration(
                labelText: 'Instrucciones / Descripción',
                labelStyle: TextStyle(color: Colors.grey),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black)),
              )
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx), 
            style: TextButton.styleFrom(foregroundColor: Colors.grey),
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            onPressed: () {
              // Validamos que ambos campos tengan texto
              if (tituloCtrl.text.trim().isEmpty || descripcionCtrl.text.trim().isEmpty) return;
              
              setState(() {
                widget.curso.actividades.add(Actividad(
                  id: 'a_${DateTime.now().millisecondsSinceEpoch}',
                  titulo: tituloCtrl.text.trim(),
                  descripcion: descripcionCtrl.text.trim(), // Asignamos la descripción ingresada
                  fechaInicio: DateTime.now(),
                  fechaTermino: DateTime.now().add(const Duration(days: 7)),
                  valorMaximo: 100,
                ));
              });
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D47A1), // Azul cobalto
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Publicar', style: TextStyle(fontWeight: FontWeight.bold)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    final esProfesor = widget.curso.profesoresIds.contains(widget.usuarioActivo.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: widget.curso.actividades.isEmpty
          ? const Center(child: Text('No hay tareas asignadas aún.', style: TextStyle(color: Colors.grey)))
          : ListView.builder(
              padding: const EdgeInsets.all(24.0),
              itemCount: widget.curso.actividades.length,
              itemBuilder: (context, index) {
                final actividad = widget.curso.actividades[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
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
                              usuarioActivo: widget.usuarioActivo,
                              curso: widget.curso,
                            ),
                          ),
                        ).then((_) => setState(() {}));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                widget.curso.titulo.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey[800], letterSpacing: 0.5),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(height: 12),
                            
                            Text(actividad.titulo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined, size: 16, color: Colors.grey[500]),
                                const SizedBox(width: 8),
                                Text('Inicia: ${actividad.fechaInicio.day}/${actividad.fechaInicio.month}', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.timer_outlined, size: 16, color: Colors.black),
                                const SizedBox(width: 8),
                                Text('Vence: ${actividad.fechaTermino.day}/${actividad.fechaTermino.month}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13)),
                              ],
                            ),
                            
                            // NUEVOS BOTONES DE GESTIÓN PARA EL PROFESOR
                            if (esProfesor) ...[
                              const SizedBox(height: 16),
                              const Divider(),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Editar'),
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (_) => CrearActividadScreen(curso: widget.curso, actividadAEditar: actividad)))
                                        .then((_) => setState((){})); // Refresca al volver
                                    },
                                  ),
                                  TextButton.icon(
                                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                    label: const Text('Eliminar', style: TextStyle(color: Colors.red)),
                                    onPressed: () async {
                                      bool exito = await ApiService().eliminarActividad(actividad.id);
                                      if (exito) {
                                        setState(() => widget.curso.actividades.removeWhere((a) => a.id == actividad.id));
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tarea eliminada')));
                                      }
                                    },
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            
      floatingActionButton: esProfesor
          ? FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CrearActividadScreen(curso: widget.curso)),
                ).then((_) => setState(() {})); // Refresca la lista al volver
              },
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Crear Tarea'),
            )
          : null,
    );
  }
}