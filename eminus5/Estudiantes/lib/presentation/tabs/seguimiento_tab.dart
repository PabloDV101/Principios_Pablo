// lib/presentation/screens/tabs/seguimiento_tab.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/curso.dart';
import '../../../domain/entities/usuario.dart';// Necesario para buscar los datos de los estudiantes

class SeguimientoTab extends StatelessWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const SeguimientoTab({super.key, required this.curso, required this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    final esProfesor = curso.profesoresIds.contains(usuarioActivo.id);

    if (esProfesor) {
      return _VistaProgresoProfesor(curso: curso);
    } else {
      return _VistaProgresoEstudiante(curso: curso, usuarioActivo: usuarioActivo);
    }
  }
}

// ============================================================================
// VISTA ESTUDIANTE: Su progreso individual (Mantenemos lo que ya funcionaba)
// ============================================================================
class _VistaProgresoEstudiante extends StatelessWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const _VistaProgresoEstudiante({required this.curso, required this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    double sumaCalificaciones = 0;
    int tareasCalificadas = 0;

    for (var act in curso.actividades) {
      final entrega = act.entregas.where((e) => e.estudianteId == usuarioActivo.id).firstOrNull;
      if (entrega != null && entrega.calificacion != null) {
        sumaCalificaciones += entrega.calificacion!;
        tareasCalificadas++;
      }
    }

    double promedioGeneral = tareasCalificadas == 0 ? 0 : (sumaCalificaciones / tareasCalificadas);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: curso.actividades.isEmpty 
        ? Center(child: Text('El profesor no ha asignado actividades.', style: TextStyle(color: Colors.grey[500])))
        : ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const Text('Mi Progreso', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 8),
              Text('Promedio basado en las tareas calificadas', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
              const SizedBox(height: 24),
              
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Promedio actual', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black)),
                        Text('${promedioGeneral.toStringAsFixed(1)} / 100', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(value: promedioGeneral / 100, backgroundColor: Colors.grey[200], valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D47A1)), minHeight: 8, borderRadius: BorderRadius.circular(4)),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              const Text('Desglose de Calificaciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
              const SizedBox(height: 16),

              ...curso.actividades.map((actividad) {
                final entrega = actividad.entregas.where((e) => e.estudianteId == usuarioActivo.id).firstOrNull;
                
                String estado; Color colorEstado;
                if (entrega == null) { estado = 'Sin entregar'; colorEstado = Colors.red.shade600; } 
                else if (entrega.calificacion == null) { estado = 'En revisión'; colorEstado = Colors.orange.shade600; } 
                else { estado = '${entrega.calificacion} pts'; colorEstado = Colors.green.shade700; }

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    title: Text(actividad.titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(6)), child: Text(estado, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: colorEstado))),
                  ),
                );
              }),
            ],
          ),
    );
  }
}

// ============================================================================
// NUEVA VISTA PROFESOR: Lista de alumnos con acordeón desplegable
// ============================================================================
class _VistaProgresoProfesor extends StatelessWidget {
  final Curso curso;

  const _VistaProgresoProfesor({required this.curso});

  @override
  Widget build(BuildContext context) {
    // Obtenemos los objetos completos de los estudiantes inscritos
   final estudiantes = curso.estudiantesLista;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: estudiantes.isEmpty
          ? Center(child: Text('Aún no hay alumnos inscritos.', style: TextStyle(color: Colors.grey[500])))
          : ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                const Text('Rendimiento del Grupo', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
                const SizedBox(height: 8),
                Text('Despliega a cada alumno para ver sus tareas', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                const SizedBox(height: 24),

                ...estudiantes.map((estudiante) {
                  // Calculamos el promedio de este estudiante en particular
                  double suma = 0;
                  int evaluadas = 0;

                  for (var act in curso.actividades) {
                    final entrega = act.entregas.where((e) => e.estudianteId == estudiante.id).firstOrNull;
                    if (entrega != null && entrega.calificacion != null) {
                      suma += entrega.calificacion!;
                      evaluadas++;
                    }
                  }
                  
                  double promedio = evaluadas == 0 ? 0 : (suma / evaluadas);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4, offset: const Offset(0, 2))]
                    ),
                    child: Theme(
                      data: Theme.of(context).copyWith(dividerColor: Colors.transparent), // Quita las líneas feas del ExpansionTile
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFF0D47A1).withOpacity(0.1),
                          foregroundColor: const Color(0xFF0D47A1),
                          child: Text(estudiante.nombre.substring(0, 1).toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        title: Text(estudiante.nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        subtitle: Text('Promedio: ${promedio.toStringAsFixed(1)}', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500)),
                        childrenPadding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
                        
                        // Generamos la lista de tareas específicas de este estudiante
                        children: curso.actividades.isEmpty 
                          ? [const Padding(padding: EdgeInsets.all(8.0), child: Text('No hay actividades asignadas.'))]
                          : curso.actividades.map((actividad) {
                              
                              final entrega = actividad.entregas.where((e) => e.estudianteId == estudiante.id).firstOrNull;
                              
                              String estado; Color colorEstado;
                              if (entrega == null) { estado = 'Sin entregar'; colorEstado = Colors.red.shade600; } 
                              else if (entrega.calificacion == null) { estado = 'Por calificar'; colorEstado = Colors.orange.shade600; } 
                              else { estado = '${entrega.calificacion} / 100'; colorEstado = Colors.green.shade700; }

                              return Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text('• ${actividad.titulo}', style: TextStyle(color: Colors.grey[800], fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(color: colorEstado.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                                      child: Text(estado, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: colorEstado)),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}