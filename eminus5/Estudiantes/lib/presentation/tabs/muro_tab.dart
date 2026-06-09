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
  // 1. BLINDAJE: Si ya hay un envío en curso, salimos inmediatamente
  if (_enviando) {
    return;
  }

  final texto = _mensajeController.text.trim();
  if (texto.isEmpty) return;

  // 2. BLOQUEO: Activamos el estado de envío para deshabilitar el botón visualmente
  setState(() => _enviando = true);

  try {
    final esProfesor = widget.curso.profesoresIds.contains(widget.usuarioActivo.id);
    final nuevoMensaje = MensajeMuro(
      remitente: widget.usuarioActivo.nombre,
      usuarioId: widget.usuarioActivo.id,
      fotoUrl: widget.usuarioActivo.fotoUrl,
      rol: esProfesor ? 'Profesor' : 'Estudiante',
      mensaje: texto,
      fecha: DateTime.now(),
    );

    final cursoActualizado = await _apiService.enviarMensajeMuro(widget.curso.id, nuevoMensaje);

    if (cursoActualizado != null) {
      setState(() {
        // Actualizamos con la lista limpia que viene del servidor
        widget.curso.mensajes = cursoActualizado.mensajes;
      });
      _mensajeController.clear();
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al enviar mensaje')));
    }
  } finally {
    // 3. LIBERACIÓN: Siempre desbloqueamos el botón, pase lo que pase
    if (mounted) {
      setState(() => _enviando = false);
    }
  }
}
void _mostrarVistaPreviaPerfil(BuildContext context, String usuarioId) {
    showDialog(
      context: context,
      builder: (context) => FutureBuilder<Usuario?>(
        // Usamos tu ApiService para buscar al usuario por su ID
        future: ApiService().obtenerUsuario(usuarioId),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const AlertDialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              content: Center(child: CircularProgressIndicator(color: Colors.white)),
            );
          }

          final usuario = snapshot.data;
          
          if (usuario == null) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              content: const Text('No se pudo cargar el perfil del usuario.'),
              actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cerrar'))],
            );
          }

          // Preparamos los datos del perfil
          ImageProvider avatarImg = (usuario.fotoUrl != null && usuario.fotoUrl!.isNotEmpty)
              ? NetworkImage(usuario.fotoUrl!)
              : const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png') as ImageProvider;

          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(radius: 50, backgroundImage: avatarImg, backgroundColor: Colors.grey[200]),
                const SizedBox(height: 16),
                Text(usuario.nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                const SizedBox(height: 8),
                Text(
                  usuario.profesion != null && usuario.profesion!.isNotEmpty ? usuario.profesion! : 'Estudiante', 
                  style: const TextStyle(fontSize: 15, color: Color(0xFF0D47A1), fontWeight: FontWeight.w600), 
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 12),
                Text(
                  usuario.descripcion != null && usuario.descripcion!.isNotEmpty ? usuario.descripcion! : 'Este usuario aún no ha agregado una descripción.', 
                  style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4), 
                  textAlign: TextAlign.center
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            )
          );
        }
      )
    );
  }
  // Opcional: En tu TextField del muro, puedes cambiar el ícono para que de vueltas si se está enviando
  // suffixIcon: _enviando ? const Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2)) : IconButton(...)

@override
  Widget build(BuildContext context) {
    // 1. Preparamos la lista ordenada fuera del ListView para mayor rendimiento
    final mensajesOrdenados = widget.curso.mensajes.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Column(
        children: [
          // Input de Publicación (Fijo arriba)
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Colors.white, 
              border: Border(bottom: BorderSide(color: Colors.grey.shade200))
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0D47A1), 
                  radius: 20, 
                  child: Text(
                    widget.usuarioActivo.nombre.isNotEmpty ? widget.usuarioActivo.nombre.substring(0, 1) : '?', 
                    style: const TextStyle(color: Colors.white)
                  )
                ),
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
          
          // Feed de Discusión (Ocupa todo el espacio restante sin errores de altura)
          Expanded(
            child: widget.curso.mensajes.isEmpty 
              ? Center(child: Text('Aún no hay publicaciones.', style: TextStyle(color: Colors.grey[500])))
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: mensajesOrdenados.length,
                  itemBuilder: (context, index) {
                    final msg = mensajesOrdenados[index];
                    return _PostCard(
                      mensaje: msg, 
                      onTapPerfil: () => _mostrarVistaPreviaPerfil(context, msg.usuarioId),
                    );
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
  final MensajeMuro mensaje;
  final VoidCallback onTapPerfil; // Función que abrirá el popup

  const _PostCard({required this.mensaje, required this.onTapPerfil});

  @override
  Widget build(BuildContext context) {
    // Calculamos cómo mostrar la fecha (Ej: "6/6/2026 a las 15:30")
    final String fechaBonita = "${mensaje.fecha.day}/${mensaje.fecha.month}/${mensaje.fecha.year} a las ${mensaje.fecha.hour}:${mensaje.fecha.minute.toString().padLeft(2, '0')}";

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white, 
        borderRadius: BorderRadius.circular(12), 
        border: Border.all(color: Colors.grey.shade200)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Envolvemos en GestureDetector para que reaccione al toque
          GestureDetector(
            onTap: onTapPerfil,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                // FOTO DE PERFIL REAL
                CircleAvatar(
                  backgroundColor: Colors.grey[200], 
                  radius: 18, 
                  backgroundImage: (mensaje.fotoUrl != null && mensaje.fotoUrl!.isNotEmpty)
                      ? NetworkImage(mensaje.fotoUrl!)
                      : const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png') as ImageProvider,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(mensaje.remitente, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      // FECHA DINÁMICA DE SPRING BOOT
                      Text('${mensaje.rol} • $fechaBonita', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                    ],
                  ),
                ),
                // Flechita indicando que se puede tocar
                const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Divider(),
          ),
          Text(mensaje.mensaje, style: TextStyle(color: Colors.grey.shade800, fontSize: 14, height: 1.4)),
        ],
      ),
    );
  }
}