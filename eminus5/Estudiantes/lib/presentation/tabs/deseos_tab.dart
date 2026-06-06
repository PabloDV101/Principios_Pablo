import 'package:flutter/material.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/curso.dart';
import '../../../data/services/api_service.dart';
import '../screens/curso_overview_screen.dart';

class DeseosTab extends StatefulWidget {
  final Usuario usuarioActivo;

  const DeseosTab({super.key, required this.usuarioActivo});

  @override
  State<DeseosTab> createState() => _DeseosTabState();
}

class _DeseosTabState extends State<DeseosTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Curso>> _futureCursos;

  @override
  void initState() {
    super.initState();
    _cargarDeseos();
  }

  void _cargarDeseos() {
    setState(() {
      _futureCursos = _apiService.obtenerCatalogo();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<List<Curso>>(
        future: _futureCursos,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Error al cargar la lista de deseos.'));
          }

          final todosLosCursos = snapshot.data ?? [];
          
          // Filtramos cruzando los IDs del backend con la lista local del usuario
          final cursosDeseados = todosLosCursos
              .where((c) => widget.usuarioActivo.listaDeseosIds.contains(c.id))
              .toList();

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
            children: [
              const Text(
                'Lista de Deseos', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
              ),
              const SizedBox(height: 24),

              if (cursosDeseados.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40.0),
                    child: Column(
                      children: [
                        Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        const Text('Tu lista está vacía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Explora cursos y guárdalos para más tarde.', style: TextStyle(color: Colors.grey[600])),
                      ],
                    ),
                  ),
                )
              else
                ...cursosDeseados.map((curso) => Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CursoOverviewScreen(
                              curso: curso,
                              usuarioActivo: widget.usuarioActivo,
                            ),
                          ),
                        ).then((_) => _cargarDeseos()); // Recarga al volver si quitó el corazón
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Reemplaza el Container de 80x80 por esto:
Container(
  width: 80, 
  height: 80,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
  ),
  clipBehavior: Clip.antiAlias,
  child: Image.network(
    curso.urlImagen,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      color: Colors.grey[300], 
      child: const Icon(Icons.broken_image, color: Colors.grey)
    ),
  ),
),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    curso.titulo,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                                    maxLines: 2, overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(curso.autor, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.favorite, color: Colors.red),
                              onPressed: () async {
                                // Quitar de favoritos directo desde esta pantalla
                                setState(() {
                                  widget.usuarioActivo.listaDeseosIds.remove(curso.id);
                                });
                                await _apiService.toggleDeseos(widget.usuarioActivo.id, curso.id);
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                )),
            ],
          );
        }
      ),
    );
  }
}