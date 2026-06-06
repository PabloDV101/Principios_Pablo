// Reemplaza lib/presentation/screens/curso_overview_screen.dart completo

import 'package:flutter/material.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/usuario.dart';
import 'login_screen.dart';
import 'curso_screen.dart'; // Para navegar adentro si ya se inscribió
import '../../data/services/api_service.dart';

class CursoOverviewScreen extends StatefulWidget {
  final Curso curso;
  final Usuario? usuarioActivo;
  
  
  
  
  

  const CursoOverviewScreen({super.key, required this.curso, required this.usuarioActivo});

  @override
  State<CursoOverviewScreen> createState() => _CursoOverviewScreenState();
}

class _CursoOverviewScreenState extends State<CursoOverviewScreen> {
  late bool estaInscrito;
  late bool esInvitado;
  late bool esCreador;

  final ApiService _apiService = ApiService();
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _revisarInscripcion();
  }

  void _revisarInscripcion() {
    esInvitado = widget.usuarioActivo == null;
    estaInscrito = !esInvitado && widget.curso.estudiantesIds.contains(widget.usuarioActivo!.id);
    esCreador = !esInvitado && widget.curso.profesoresIds.contains(widget.usuarioActivo!.id); 
  }

  Future<void> _accionBoton() async {
    if (esInvitado) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
      return;
    } 
    
    if (estaInscrito || esCreador) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => CursoScreen(curso: widget.curso, usuarioActivo: widget.usuarioActivo!)));
      return;
    } 
    
    setState(() => _procesando = true);
    
    bool exito = await _apiService.inscribirEstudiante(widget.curso.id, widget.usuarioActivo!.id);
    
    setState(() => _procesando = false);

    if (exito) {
      setState(() {
        widget.curso.estudiantesIds.add(widget.usuarioActivo!.id);
        estaInscrito = true; 
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Te has unido al curso con éxito!', style: TextStyle(color: Colors.white)), backgroundColor: Color(0xFF0D47A1))
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al unirse al curso'), backgroundColor: Colors.red)
      );
    }
  }

  void _mostrarDialogoCalificacion(BuildContext context, Curso curso) {
    double estrellasSeleccionadas = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text('Calificar Curso'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cuántas estrellas le das a este curso?'),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < estrellasSeleccionadas ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 36,
                        ),
                        onPressed: () {
                          setStateDialog(() {
                            estrellasSeleccionadas = index + 1.0;
                          });
                        },
                      );
                    }),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // 1. Guardamos las herramientas antes de destruir el popup
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    
                    navigator.pop(); // 2. Cerramos el popup inmediatamente
                    
                    // 3. Hacemos la petición a la API (Nota: Agregaremos el ID del usuario en el paso 3)
                    final exito = await ApiService().calificarCurso(curso.id, estrellasSeleccionadas, widget.usuarioActivo!.id);
                    
                    // 4. Usamos el mensajero guardado, que sigue vivo
                    if (exito) {
                      messenger.showSnackBar(const SnackBar(content: Text('¡Gracias por tu calificación!')));
                    } else {
                      messenger.showSnackBar(const SnackBar(content: Text('Error o ya calificaste este curso')));
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1)),
                  child: const Text('Enviar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0, 
            pinned: true,
            backgroundColor: const Color(0xFF0D47A1), 
            // AQUÍ ESTÁ EL BOTÓN DE CALIFICACIÓN INTEGRADo
            actions: [
              if (estaInscrito)
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber, size: 28),
                  tooltip: 'Calificar este curso',
                  onPressed: () => _mostrarDialogoCalificacion(context, widget.curso),
                ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.curso.urlImagen,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 50),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.curso.titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black, height: 1.2)),
                  const SizedBox(height: 12),
                  Text(widget.curso.descripcion, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)),
                  const SizedBox(height: 24),
                  
                  const Text('Instructor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(backgroundColor: Colors.grey[200], child: const Icon(Icons.person, color: Colors.grey)),
                      const SizedBox(width: 12),
                      Text(widget.curso.autor, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white, 
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))]
          ),
          child: ElevatedButton(
            onPressed: _accionBoton,
            style: ElevatedButton.styleFrom(
              backgroundColor: (estaInscrito || esCreador) ? Colors.black : const Color(0xFF0D47A1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: _procesando 
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text((estaInscrito || esCreador) ? 'Ir al curso' : 'Unirse ahora (Gratis)', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }
}