// Reemplaza lib/presentation/screens/curso_overview_screen.dart completo

import 'package:flutter/material.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/usuario.dart';
import 'login_screen.dart';
import 'curso_screen.dart'; // Para navegar adentro si ya se inscribió
import '../../data/services/api_service.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart'; // NUEVO IMPORT

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
  // --- BLOQUE PARA CARGAR RECOMENDACIONES ---
  late Future<List<Curso>> _futureRecomendados;

  // Método para filtrar los cursos que tengan etiquetas en común
  Future<List<Curso>> _cargarRecomendados() async {
    final todos = await _apiService.obtenerCatalogo();
    return todos.where((c) {
      // Excluimos el curso actual para no recomendarlo a sí mismo
      if (c.id == widget.curso.id) return false;
      
      // Verificamos si comparte al menos una etiqueta
      return c.etiquetas.any((e) => widget.curso.etiquetas.contains(e));
    }).toList();
  }
  // ------------------------------------------

@override
  void initState() {
    super.initState();
    _revisarInscripcion();
    // Inicializamos la búsqueda de recomendaciones
    _futureRecomendados = _cargarRecomendados();
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
    TextEditingController comentarioController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Calificar Curso', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('¿Cuántas estrellas le das?'),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(index < estrellasSeleccionadas ? Icons.star : Icons.star_border, color: Colors.amber, size: 36),
                        onPressed: () => setStateDialog(() => estrellasSeleccionadas = index + 1.0),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: comentarioController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Cuéntanos tu experiencia...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () async {
                    if (comentarioController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor escribe un comentario')));
                      return;
                    }
                    
                    final navigator = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    navigator.pop(); 

                    // CREAMOS LA RESEÑA
                    final hoy = DateTime.now();
                    final fechaFormateada = "${hoy.day}/${hoy.month}/${hoy.year}";

                    final nuevaResena = Resena(
                      usuarioId: widget.usuarioActivo!.id,
                      nombreUsuario: widget.usuarioActivo!.nombre,
                      fotoUrl: widget.usuarioActivo!.fotoUrl,
                      estrellas: estrellasSeleccionadas,
                      comentario: comentarioController.text.trim(),
                      fecha: fechaFormateada,
                    );
                    
                    final exito = await ApiService().calificarCurso(curso.id, nuevaResena);
                    
                    if (exito) {
                      setState(() { curso.resenas.add(nuevaResena); }); // Actualizamos la UI al instante
                      messenger.showSnackBar(const SnackBar(content: Text('¡Gracias por tu valoración!'), backgroundColor: Colors.green));
                    } else {
                      messenger.showSnackBar(const SnackBar(content: Text('Error o ya calificaste este curso'), backgroundColor: Colors.red));
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
  void _mostrarPerfilInstructor(BuildContext context, String nombre, ImageProvider imagen, String profesion, String descripcion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(radius: 50, backgroundImage: imagen, backgroundColor: Colors.grey[200]),
            const SizedBox(height: 16),
            Text(nombre, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text(profesion, style: const TextStyle(fontSize: 15, color: Color(0xFF0D47A1), fontWeight: FontWeight.w600), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            Text(descripcion, style: TextStyle(fontSize: 14, color: Colors.grey[800], height: 1.4), textAlign: TextAlign.center),
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
      )
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
            
            // --- BOTÓN DE CALIFICAR ---
            actions: [
              // Ahora validamos que esté inscrito O que sea el creador para que puedas probarlo
              if (estaInscrito || esCreador)
                IconButton(
                  icon: const Icon(Icons.star, color: Colors.amber, size: 28),
                  tooltip: 'Calificar este curso',
                  onPressed: () => _mostrarDialogoCalificacion(context, widget.curso),
                ),
              const SizedBox(width: 8),
            ],
            // --------------------------

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
                  const SizedBox(height: 16),
                  
                Text(
                    widget.curso.descripcion, 
                    style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5)
                  ),
                  const SizedBox(height: 32),

                  // 3. REPRODUCTOR DE VIDEO (CON BORDES REDONDEADOS)
                  if (widget.curso.videoUrl != null && widget.curso.videoUrl!.isNotEmpty) ...[
                    const Text('Presentación del curso', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _ReproductorVideoCurso(urlVideo: widget.curso.videoUrl!),
                    ),
                    const SizedBox(height: 32),
                  ],
                  
                  // --- NUEVA SECCIÓN: LO QUE APRENDERÁS ---
                  if (widget.curso.aprendizajes.isNotEmpty) ...[
                    const Text('Lo que aprenderás', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8), // Borde ligero estilo Udemy
                      ),
                      child: Column(
                        children: widget.curso.aprendizajes.map((aprendizaje) => Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.check, size: 20, color: Colors.black87), // Palomita negra o gris oscura
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  aprendizaje, 
                                  style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87)
                                ),
                              ),
                            ],
                          ),
                        )).toList(),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                  // -----------------------------------------

                  // (Aquí sigue tu código del Instructor...)
                  const Text('Instructor', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  
                  // --- NUEVA SECCIÓN DEL INSTRUCTOR DINÁMICA ---
                  FutureBuilder<Usuario?>(
                    future: widget.curso.profesoresIds.isNotEmpty 
                        ? _apiService.obtenerUsuario(widget.curso.profesoresIds.first) 
                        : Future.value(null),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const SizedBox(height: 60, child: Center(child: CircularProgressIndicator(strokeWidth: 2)));
                      }
                      
                      final instructor = snapshot.data;
                      
                      ImageProvider avatarImg = const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png');
                      String nombre = widget.curso.autor;
                      String profesion = 'Instructor del curso';
                      String descripcion = 'Este instructor aún no ha agregado una descripción a su perfil.';

                      if (instructor != null) {
                        nombre = instructor.nombre;
                        if (instructor.fotoUrl != null && instructor.fotoUrl!.isNotEmpty) avatarImg = NetworkImage(instructor.fotoUrl!);
                        if (instructor.profesion != null && instructor.profesion!.isNotEmpty) profesion = instructor.profesion!;
                        if (instructor.descripcion != null && instructor.descripcion!.isNotEmpty) descripcion = instructor.descripcion!;
                      }

                      return GestureDetector(
                        onTap: () => _mostrarPerfilInstructor(context, nombre, avatarImg, profesion, descripcion),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200)
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(backgroundColor: Colors.grey[300], backgroundImage: avatarImg, radius: 26),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                    const SizedBox(height: 4),
                                    Text(profesion, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
                                  ],
                                ),
                              ),
                              const Icon(Icons.visibility, size: 20, color: Colors.grey)
                            ],
                          ),
                        ),
                      );
                    }
                  ),
                  // ----------------------------------------------
               // (Aquí termina la sección del Instructor...)
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
          
          // ==========================================================
          // NUEVA SECCIÓN: CURSOS RECOMENDADOS (SCROLL HACIA ABAJO)
          // ==========================================================
          const SliverToBoxAdapter(
            child: Padding(
              padding:  EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'Cursos recomendados',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ),
          ),
          
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            sliver: FutureBuilder<List<Curso>>(
              future: _futureRecomendados,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(child: Padding(padding: EdgeInsets.all(24.0), child: CircularProgressIndicator(strokeWidth: 2))),
                  );
                }
                
                final recomendados = snapshot.data ?? [];
                
                if (recomendados.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40.0),
                      child: Text('No hay cursos similares recomendados por el momento.', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final cursoRec = recomendados[index];
                      return _TarjetaRecomendadoVertical(
                        curso: cursoRec,
                        usuarioActivo: widget.usuarioActivo,
                      );
                    },
                    childCount: recomendados.length,
                  ),
                );
              },
            ),
          ),
          // ==========================================================
          // NUEVA SECCIÓN: VALORACIONES DEL CURSO
          // ==========================================================
          if (widget.curso.resenas.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0, bottom: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 28),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.curso.calificacion.toStringAsFixed(1)} valoración del curso',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Text(
                      ' • ${widget.curso.resenas.length} reseñas',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
            
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final resena = widget.curso.resenas[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: Colors.grey[200],
                              backgroundImage: (resena.fotoUrl != null && resena.fotoUrl!.isNotEmpty) 
                                  ? NetworkImage(resena.fotoUrl!) 
                                  : const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png') as ImageProvider,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(resena.nombreUsuario, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Row(
                                      children: List.generate(5, (starIndex) => Icon(
                                        starIndex < resena.estrellas.floor() ? Icons.star : Icons.star_border, 
                                        color: Colors.amber, 
                                        size: 14
                                      )),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(resena.fecha, style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w600)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(resena.comentario, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87)),
                        const SizedBox(height: 16),
                        const Divider(),
                      ],
                    ),
                  );
                },
                childCount: widget.curso.resenas.length,
              ),
            ),
          ],
          // ==========================================================
          // Margen inferior final para que el botón de la barra de navegación no tape el contenido

          const SliverToBoxAdapter(child: SizedBox(height: 100)),
          // ==========================================================
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
// WIDGET: TARJETA DE RECOMENDACIÓN VERTICAL (ESTILO UDEMY RELACIONADOS)
class _TarjetaRecomendadoVertical extends StatelessWidget {
  final Curso curso;
  final Usuario? usuarioActivo;

  const _TarjetaRecomendadoVertical({required this.curso, this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Al tocar un recomendado, abre una nueva pantalla de detalle del curso seleccionado
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CursoOverviewScreen(curso: curso, usuarioActivo: usuarioActivo),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Mini Portada del curso recomendado
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                curso.urlImagen,
                width: 100,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 100,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey, size: 28),
                ),
              ),
            ),
            const SizedBox(width: 16),
            
            // 2. Información del curso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    curso.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    curso.autor,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                  const SizedBox(height: 6),
                  
                  // Calificación del recomendado
                  Row(
                    children: [
                      Text(
                        curso.calificacion.toStringAsFixed(1),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 6),
                      Text(
                        '(${curso.estudiantesIds.length})',
                        style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}




class _ReproductorVideoCurso extends StatefulWidget {
  final String urlVideo;
  const _ReproductorVideoCurso({required this.urlVideo});

  @override
  State<_ReproductorVideoCurso> createState() => _ReproductorVideoCursoState();
}

class _ReproductorVideoCursoState extends State<_ReproductorVideoCurso> {
  late VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    _inicializarReproductor();
  }

  Future<void> _inicializarReproductor() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.urlVideo));
    
    await _videoPlayerController.initialize();
    
    setState(() {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: false,
        // Colores personalizados para que combinen con tu app
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFF0D47A1),
          handleColor: const Color(0xFF0D47A1),
          backgroundColor: Colors.grey.shade300,
          bufferedColor: Colors.grey.shade500,
        ),
        placeholder: Container(color: Colors.black87),
        autoInitialize: true,
      );
    });
  }

  @override
  void dispose() {
    _videoPlayerController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
      return AspectRatio(
        aspectRatio: _videoPlayerController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      );
    } else {
      return const SizedBox(
        height: 200, 
        child: Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
      );
    }
  }
}