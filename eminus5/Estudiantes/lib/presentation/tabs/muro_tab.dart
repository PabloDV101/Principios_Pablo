// lib/presentation/screens/tabs/muro_tab.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/curso.dart';
import '../../../domain/entities/usuario.dart';
import '../../data/services/api_service.dart';

class MuroTab extends StatefulWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const MuroTab({super.key, required this.curso, required this.usuarioActivo});

  @override
  State<MuroTab> createState() => _MuroTabState();
}

class _MuroTabState extends State<MuroTab> {
  final TextEditingController _mensajeController = TextEditingController();

final ApiService _apiService = ApiService();
  bool _enviando = false;

  Future<void> _publicarMensaje() async {
    final texto = _mensajeController.text.trim();
    if (texto.isEmpty) return;

    setState(() => _enviando = true);

    final esProfesor = widget.curso.profesoresIds.contains(widget.usuarioActivo.id);
    final nuevoMensaje = MensajeMuro(
      remitente: widget.usuarioActivo.nombre,
      rol: esProfesor ? 'Profesor' : 'Estudiante',
      mensaje: texto,
      fecha: DateTime.now(),
    );

    // Mandamos a la base de datos PostgreSQL
    final mensajeGuardado = await _apiService.enviarMensajeMuro(widget.curso.id, nuevoMensaje);

    setState(() => _enviando = false);

    if (mensajeGuardado != null) {
      setState(() {
        widget.curso.mensajes.insert(0, mensajeGuardado);
      });
      _mensajeController.clear();
      FocusScope.of(context).unfocus(); 
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar mensaje')));
    }
  }

  // Opcional: En tu TextField del muro, puedes cambiar el ícono para que de vueltas si se está enviando
  // suffixIcon: _enviando ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(...)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Input de Publicación
          // Input de Publicación en muro_tab.dart
Container(
  padding: const EdgeInsets.all(20.0),
  decoration: BoxDecoration(color: Colors.white, border: Border(bottom: BorderSide(color: Colors.grey.shade200))),
  child: Row(
    children: [
      CircleAvatar(backgroundColor: const Color(0xFF0D47A1), radius: 20, child: Text(widget.usuarioActivo.nombre.substring(0, 1), style: const TextStyle(color: Colors.white))),
      const SizedBox(width: 16),
      Expanded(
        child: TextField(
          controller: _mensajeController,
          decoration: InputDecoration(
            hintText: 'Comparte algo con la clase...',
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            // AQUÍ ESTÁ EL BOTÓN DE ENVIAR BLINDADO
            suffixIcon: _enviando
                ? const Padding(padding: EdgeInsets.all(12.0), child: SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF0D47A1))))
                : IconButton(
                    icon: const Icon(Icons.send, color: Color(0xFF0D47A1)),
                    onPressed: _publicarMensaje,
                  ),
          ),
        ),
      ),
    ],
  ),
),
          
          // Feed de Discusión
          Expanded(
            child: widget.curso.mensajes.isEmpty 
              ? Center(child: Text('Aún no hay publicaciones.', style: TextStyle(color: Colors.grey[500])))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: widget.curso.mensajes.length,
                  itemBuilder: (context, index) {
                    final msg = widget.curso.mensajes[index];
                    return _PostCard(remitente: msg.remitente, rol: msg.rol, mensaje: msg.mensaje);
                  },
              ),
          ),
        ],
      ),
    );
  }
}

// (La clase _PostCard se mantiene igual, solo quítale los parámetros de tiempo y reacciones si no quieres calcularlos o déjalos fijos por ahora)
class _PostCard extends StatelessWidget {
  final String remitente;
  final String rol;
  final String mensaje;

  const _PostCard({required this.remitente, required this.rol, required this.mensaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: Colors.black, radius: 18, child: const Icon(Icons.person, color: Colors.white, size: 20)),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(remitente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  Text('$rol • Ahora', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(mensaje, style: TextStyle(color: Colors.grey.shade800, fontSize: 14)),
        ],
      ),
    );
  }
}