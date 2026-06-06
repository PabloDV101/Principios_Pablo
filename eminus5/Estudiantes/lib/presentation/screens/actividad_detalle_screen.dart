// lib/presentation/screens/actividad_detalle_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/actividad.dart';
import '../../domain/entities/usuario.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/entrega.dart';
import '../../data/services/api_service.dart';

class ActividadDetalleScreen extends StatefulWidget {
  final Actividad actividad;
  final Usuario usuarioActivo;
  final Curso curso;

  const ActividadDetalleScreen({super.key, required this.actividad, required this.usuarioActivo, required this.curso});

  @override
  State<ActividadDetalleScreen> createState() => _ActividadDetalleScreenState();
}

class _ActividadDetalleScreenState extends State<ActividadDetalleScreen> {
  
  @override
  Widget build(BuildContext context) {
    final esProfesor = widget.curso.profesoresIds.contains(widget.usuarioActivo.id);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.white, foregroundColor: Colors.black, elevation: 0,
        title: const Text('Detalles de la Tarea', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(preferredSize: const Size.fromHeight(1.0), child: Container(color: Colors.grey.shade200, height: 1.0)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.actividad.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2)),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Fecha límite', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${widget.actividad.fechaTermino.day}/${widget.actividad.fechaTermino.month}/${widget.actividad.fechaTermino.year}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    ],
                  ),
                  Container(width: 1, height: 30, color: Colors.grey.shade200),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('Valor máximo', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                      const SizedBox(height: 4),
                      Text('${widget.actividad.valorMaximo.toInt()} puntos', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0D47A1))),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            const Text('Instrucciones', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Text(widget.actividad.descripcion, style: TextStyle(fontSize: 15, color: Colors.grey[800], height: 1.6)),
            const SizedBox(height: 32),

            // Componentes Interactivos según el Rol
            if (esProfesor) 
              _VistaProfesor(actividad: widget.actividad, onCalificada: () => setState((){})) 
            else 
              _VistaEstudiante(actividad: widget.actividad, usuarioActivo: widget.usuarioActivo, onEntregada: () => setState((){})),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// VISTA ESTUDIANTE: Formulario de envío
// ============================================================================
class _VistaEstudiante extends StatefulWidget {
  final Actividad actividad;
  final Usuario usuarioActivo;
  final VoidCallback onEntregada;

  const _VistaEstudiante({required this.actividad, required this.usuarioActivo, required this.onEntregada});

  @override
  State<_VistaEstudiante> createState() => _VistaEstudianteState();
}

// Reemplaza SÓLO esta clase dentro de lib/presentation/screens/actividad_detalle_screen.dart

class _VistaEstudianteState extends State<_VistaEstudiante> {
  final ApiService _apiService = ApiService();
bool _enviando = false;
  final _comentarioCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final entregaExistente = widget.actividad.entregas.where((e) => e.estudianteId == widget.usuarioActivo.id).firstOrNull;

    if (entregaExistente != null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.green.shade200)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 8),
                Text('Tarea Enviada', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              ],
            ),
            const SizedBox(height: 16),
            Text('Tu respuesta:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green.shade900)),
            const SizedBox(height: 4),
            Text(entregaExistente.comentariosEstudiante),
            const SizedBox(height: 16),
            const Divider(),
            if (entregaExistente.calificacion != null) ...[
              Text('Calificación: ${entregaExistente.calificacion} / 100', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              if (entregaExistente.retroalimentacionProfesor != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text('Feedback: ${entregaExistente.retroalimentacionProfesor}', style: const TextStyle(fontStyle: FontStyle.italic)),
                ),
            ] else
              const Text('Aún no ha sido calificada por el profesor.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Tu Entrega', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Respuesta / Comentarios', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: _comentarioCtrl, maxLines: 4,
                decoration: InputDecoration(hintText: 'Escribe tu respuesta aquí...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black))),
              ),
              const SizedBox(height: 16),
              
              // NUEVO: Botón de Adjuntar (Deshabilitado temporalmente)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: null, // Al ser null, Flutter lo deshabilita visualmente automático
                  icon: const Icon(Icons.attach_file),
                  label: const Text('Adjuntar archivo (Próximamente)'),
                  style: OutlinedButton.styleFrom(
                    disabledForegroundColor: Colors.grey.shade500,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              SizedBox(
  width: double.infinity,
  child: _enviando 
    ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
    : ElevatedButton(
        onPressed: () async {
          if (_comentarioCtrl.text.isEmpty) return;
          
          setState(() => _enviando = true);
          
          final entregaRegistrada = await _apiService.enviarTarea(
            widget.actividad.id, 
            widget.usuarioActivo.id, 
            _comentarioCtrl.text
          );
          
          setState(() => _enviando = false);

          if (entregaRegistrada != null) {
            // Actualizamos la lista local
            widget.actividad.entregas.add(entregaRegistrada);
            widget.onEntregada(); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar tarea')));
          }
        },
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        child: const Text('Enviar Tarea', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
      ),
)
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// VISTA PROFESOR: Lista de entregas y Modal para calificar
// ============================================================================
class _VistaProfesor extends StatelessWidget {
  final Actividad actividad;
  final VoidCallback onCalificada;

  const _VistaProfesor({required this.actividad, required this.onCalificada});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Entregas Recibidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
        const SizedBox(height: 16),
        
        if (actividad.entregas.isEmpty)
          const Text('Ningún alumno ha enviado esta tarea aún.', style: TextStyle(color: Colors.grey))
        else
          ...actividad.entregas.map((entrega) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade300)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              leading: CircleAvatar(backgroundColor: Colors.black, child: Text(entrega.estudianteNombre.substring(0, 1), style: const TextStyle(color: Colors.white))),
              title: Text(entrega.estudianteNombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              subtitle: Text(entrega.calificacion != null ? 'Calificado: ${entrega.calificacion}' : 'Sin calificar', style: TextStyle(color: entrega.calificacion != null ? Colors.green : Colors.orange, fontWeight: FontWeight.bold)),
              trailing: OutlinedButton(
                onPressed: () => _mostrarPanelCalificacion(context, entrega),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.black, side: BorderSide(color: Colors.grey.shade300)),
                child: Text(entrega.calificacion != null ? 'Editar' : 'Evaluar'),
              ),
            ),
          ))
      ],
    );
  }

  void _mostrarPanelCalificacion(BuildContext context, Entrega entrega) {
    final califCtrl = TextEditingController(text: entrega.calificacion?.toString() ?? '');
    final retroCtrl = TextEditingController(text: entrega.retroalimentacionProfesor ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 24, right: 24, top: 24),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Respuesta del alumno:', style: TextStyle(fontWeight: FontWeight.bold)),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8), padding: const EdgeInsets.all(12),
              width: double.infinity, decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
              child: Text(entrega.comentariosEstudiante, style: const TextStyle(fontStyle: FontStyle.italic)),
            ),
            const SizedBox(height: 16),
            const Text('Puntuación (0 - 100)', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: califCtrl, keyboardType: TextInputType.number, decoration: InputDecoration(hintText: 'Ej. 95', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)))),
            const SizedBox(height: 16),
            const Text('Retroalimentación', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(controller: retroCtrl, maxLines: 2, decoration: InputDecoration(hintText: 'Buen trabajo en...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Colors.black)))),
            const SizedBox(height: 32),
            SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {
      if (califCtrl.text.isEmpty) return;
      
      final califDouble = double.tryParse(califCtrl.text);
      if (califDouble == null) return;

      // Cerramos el panel inferior inmediatamente para mejor UX
      Navigator.pop(context);
      
      // Llamamos a la API
      final ApiService apiService = ApiService();
      final entregaActualizada = await apiService.calificarTarea(
        entrega.id, 
        califDouble, 
        retroCtrl.text
      );

      if (entregaActualizada != null) {
        // Actualizamos los datos en memoria para que se reflejen en la UI
        entrega.calificacion = entregaActualizada.calificacion;
        entrega.retroalimentacionProfesor = entregaActualizada.retroalimentacionProfesor;
        onCalificada(); // Llama al SetState del Widget padre
      }
    },
    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16)),
    child: const Text('Asignar Calificación', style: TextStyle(fontWeight: FontWeight.bold)),
  ),
),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}