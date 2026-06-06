// lib/presentation/screens/tabs/inicio_tab.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/curso.dart';
import '../screens/curso_overview_screen.dart';
import '../screens/login_screen.dart';
import '../screens/crear_curso_screen.dart';
import '../../../data/services/api_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';


class InicioTab extends StatefulWidget {
  final Usuario? usuarioActivo;

  const InicioTab({super.key, required this.usuarioActivo});

  @override
  State<InicioTab> createState() => _InicioTabState();
}

// En la parte superior añade la importación del servicio:


// ... (reemplaza la clase de estado)

class _InicioTabState extends State<InicioTab> {
  String _etiquetaSeleccionada = 'Todos';
  final ApiService _apiService = ApiService();
  late Future<List<Curso>> _futureCursos;

  // --- BLOQUE A PEGAR AL INICIO DE LA CLASE STATE ---
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
  // ----------------------------------------------------

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  void _cargarCursos() {
    setState(() {
      _futureCursos = _apiService.obtenerCatalogo();
    });
  }

@override
  Widget build(BuildContext context) {
    // ESTA ES LA LÍNEA QUE FALTABA PARA ARREGLAR EL ERROR 'esInvitado'
    final bool esInvitado = widget.usuarioActivo == null;

    return SafeArea(
      child: FutureBuilder<List<Curso>>(
        future: _futureCursos,
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)));
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  const Text('Error al conectar con el servidor.'),
                  TextButton(onPressed: _cargarCursos, child: const Text('Reintentar'))
                ],
              )
            );
          }

          final todosLosCursos = snapshot.data ?? [];
          
          final Set<String> etiquetasUnicas = {'Todos'};
          for (var curso in todosLosCursos) {
            etiquetasUnicas.addAll(curso.etiquetas);
          }
          final listaEtiquetas = etiquetasUnicas.toList();

          final cursosFiltrados = todosLosCursos.where((c) {
            final coincideEtiqueta = _etiquetaSeleccionada == 'Todos' || c.etiquetas.contains(_etiquetaSeleccionada);
            final coincideBusqueda = _searchQuery.isEmpty || 
                                     c.titulo.toLowerCase().contains(_searchQuery) || 
                                     c.autor.toLowerCase().contains(_searchQuery);
                                     
            return coincideEtiqueta && coincideBusqueda;
          }).toList();

          final Map<String, List<Curso>> cursosPorCategoria = {};
          for (var curso in cursosFiltrados) {
            final categorias = curso.etiquetas.isNotEmpty ? curso.etiquetas : ['General'];
            for (var categoria in categorias) {
              if (_etiquetaSeleccionada == 'Todos' || _etiquetaSeleccionada == categoria) {
                if (!cursosPorCategoria.containsKey(categoria)) {
                  cursosPorCategoria[categoria] = [];
                }
                cursosPorCategoria[categoria]!.add(curso);
              }
            }
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.school, color: Color(0xFF0D47A1), size: 28),
                              SizedBox(width: 8),
                              Text('Campus', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
                            ],
                          ),
                          if (esInvitado)
                            Row(
                              children: [
                                TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), style: TextButton.styleFrom(foregroundColor: Colors.black), child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold))),
                                OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), style: OutlinedButton.styleFrom(foregroundColor: const Color(0xFF0D47A1), side: const BorderSide(color: Color(0xFF0D47A1)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), padding: const EdgeInsets.symmetric(horizontal: 16)), child: const Text('Únete gratis', style: TextStyle(fontWeight: FontWeight.bold)))
                              ],
                            )
                          else
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 28),
                                  tooltip: 'Crear un nuevo curso',
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => CrearCursoScreen(usuarioActivo: widget.usuarioActivo!)))
                                      .then((_) => _cargarCursos());
                                  },
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, child: Text(widget.usuarioActivo!.nombre.substring(0, 1))),
                              ],
                            )
                        ],
                      ),
                      const SizedBox(height: 32),
                      const Text('Explorar', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 4),
                      Text('Descubre tu próximo curso', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                      const SizedBox(height: 24),
                      
                      TextField(
                        controller: _searchController,
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value.toLowerCase(); 
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Buscar cursos, habilidades...', 
                          prefixIcon: const Icon(Icons.search, color: Colors.grey),
                          suffixIcon: _searchQuery.isNotEmpty 
                              ? IconButton(
                                  icon: const Icon(Icons.clear, color: Colors.grey),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                ) 
                              : null,
                          filled: true, 
                          fillColor: Colors.white, 
                          contentPadding: EdgeInsets.zero, 
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)), 
                          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300))
                        )
                      ),
                      
                      const SizedBox(height: 24),
                      const Text('Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: listaEtiquetas.length,
                    itemBuilder: (context, index) {
                      final etiqueta = listaEtiquetas[index];
                      final estaSeleccionada = etiqueta == _etiquetaSeleccionada;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(etiqueta),
                          selected: estaSeleccionada,
                          onSelected: (selected) => setState(() => _etiquetaSeleccionada = etiqueta),
                          selectedColor: Colors.black, backgroundColor: Colors.white,
                          labelStyle: TextStyle(color: estaSeleccionada ? Colors.white : Colors.black87, fontWeight: estaSeleccionada ? FontWeight.bold : FontWeight.normal),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: estaSeleccionada ? Colors.black : Colors.grey.shade300)),
                        ),
                      );
                    },
                  ),
                ),
              ),
              
              SliverPadding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 20.0),
                sliver: cursosPorCategoria.isEmpty 
                  ? SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text('No se encontraron cursos con tu búsqueda.', style: TextStyle(color: Colors.grey[500], fontSize: 16)))))
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          String categoria = cursosPorCategoria.keys.elementAt(index);
                          List<Curso> cursosDeEstaCategoria = cursosPorCategoria[categoria]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                child: Text(
                                  categoria,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 260, 
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: cursosDeEstaCategoria.length,
                                  itemBuilder: (context, idx) {
                                    return _CursoMiniCard(
                                      curso: cursosDeEstaCategoria[idx],
                                      usuarioActivo: widget.usuarioActivo,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                        childCount: cursosPorCategoria.keys.length,
                      ),
                    ),
              ),
            ],
          );
        }
      ),
    );
  }
}

// Tarjeta interna actualizada para mostrar etiquetas
// En lib/presentation/screens/tabs/inicio_tab.dart
// Reemplaza la clase _CursoMoocCard completa por esta:

class _CursoMoocCard extends StatefulWidget {
  final Curso curso;
  final Usuario? usuarioActivo;

  const _CursoMoocCard({required this.curso, required this.usuarioActivo});

  @override
  State<_CursoMoocCard> createState() => _CursoMoocCardState();
}

class _CursoMoocCardState extends State<_CursoMoocCard> {
final ApiService _apiService = ApiService(); // Instancia arriba

  Future<void> _toggleFavorito() async {
    if (widget.usuarioActivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para guardar en Deseos')));
      return;
    }

    // Actualizamos la UI inmediatamente para que se sienta rápido
    setState(() {
      final lista = widget.usuarioActivo!.listaDeseosIds;
      if (lista.contains(widget.curso.id)) {
        lista.remove(widget.curso.id);
      } else {
        lista.add(widget.curso.id);
      }
    });

    // Lo guardamos en la base de datos de fondo
    await _apiService.toggleDeseos(widget.usuarioActivo!.id, widget.curso.id);
  }

  @override
  Widget build(BuildContext context) {
    final esFavorito = widget.usuarioActivo != null && widget.usuarioActivo!.listaDeseosIds.contains(widget.curso.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CursoOverviewScreen(curso: widget.curso, usuarioActivo: widget.usuarioActivo)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parte Superior con Imagen y Corazón
            Stack(
              children: [
                // Reemplaza el contenedor superior de _CursoMoocCard por esto:
Container(
  height: 160, // O la altura que tuvieras
  width: double.infinity,
  decoration: const BoxDecoration(
    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
  ),
  clipBehavior: Clip.antiAlias, // Obliga a la imagen a respetar el borde redondeado
  child: Image.network(
    widget.curso.urlImagen,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) {
      return Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
      );
    },
  ),
),
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: _toggleFavorito,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 16,
                      child: Icon(
                        esFavorito ? Icons.favorite : Icons.favorite_border,
                        color: esFavorito ? Colors.red : Colors.grey,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // ... (el resto del código de la tarjeta queda igual: Padding con titulo, autor, estrellas, etc)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.curso.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(widget.curso.autor, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 6, runSpacing: 6,
                    children: widget.curso.etiquetas.take(3).map((e) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                      child: Text(e, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: Colors.grey.shade800)),
                    )).toList(),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text('${widget.curso.calificacion}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const Spacer(),
                      const Text('Gratis', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1))),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
class _CursoMiniCard extends StatefulWidget {
  final Curso curso;
  final Usuario? usuarioActivo;

  const _CursoMiniCard({required this.curso, this.usuarioActivo});

  @override
  State<_CursoMiniCard> createState() => _CursoMiniCardState();
}

class _CursoMiniCardState extends State<_CursoMiniCard> {
  final ApiService _apiService = ApiService();
  bool _esFavorito = false;

  @override
  void initState() {
    super.initState();
    // Verificamos si el curso ya está en la lista de deseos del usuario
    if (widget.usuarioActivo != null) {
      _esFavorito = widget.usuarioActivo!.listaDeseosIds.contains(widget.curso.id);
    }
  }

void _toggleFavorito() async {
    if (widget.usuarioActivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para guardar cursos')));
      return;
    }

    setState(() => _esFavorito = !_esFavorito);

    // 1. ACTUALIZAMOS LA MEMORIA RAM (Evitando duplicados por seguridad)
    if (_esFavorito) {
      if (!(widget.usuarioActivo!.listaDeseosIds.contains(widget.curso.id))) {
        widget.usuarioActivo!.listaDeseosIds.add(widget.curso.id);
      }
    } else {
      widget.usuarioActivo!.listaDeseosIds.remove(widget.curso.id);
    }

    // 2. ACTUALIZAMOS EL DISCO LOCAL (SharedPreferences)
    // Esto asegura que al hacer Hot Restart se mantengan los cambios
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('usuario_data', json.encode(widget.usuarioActivo!.toJson()));

    // 3. ACTUALIZAMOS EL SERVIDOR
    final exito = await _apiService.toggleDeseos(widget.usuarioActivo!.id, widget.curso.id);
    
    if (!exito) {
      // Si el servidor falla, deshacemos todos los cambios (RAM, Pantalla y Disco)
      setState(() => _esFavorito = !_esFavorito);
      
      if (_esFavorito) {
        widget.usuarioActivo!.listaDeseosIds.add(widget.curso.id);
      } else {
        widget.usuarioActivo!.listaDeseosIds.remove(widget.curso.id);
      }
      
      // Revertimos el disco local
      await prefs.setString('usuario_data', json.encode(widget.usuarioActivo!.toJson())); 
      
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión con el servidor')));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ajusta 'estudiantes' según el nombre que tenga tu lista en la clase Curso (ej. inscritos, alumnosIds)
    final numEstudiantes = widget.curso.estudiantesLista.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CursoOverviewScreen(curso: widget.curso, usuarioActivo: widget.usuarioActivo),
        ));
      },
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 16, bottom: 8, top: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. STACK PARA LA IMAGEN Y EL CORAZÓN
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.network(
                    widget.curso.urlImagen,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                // Botón de Corazón (Favoritos) en la esquina superior derecha
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: Icon(
                        _esFavorito ? Icons.favorite : Icons.favorite_border,
                        color: _esFavorito ? Colors.red : Colors.grey[700],
                        size: 20,
                      ),
                      onPressed: _toggleFavorito,
                    ),
                  ),
                ),
              ],
            ),
            
            // 2. TEXTOS Y CALIFICACIÓN
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.curso.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2)),
                  const SizedBox(height: 6),
                  Text(widget.curso.autor, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
                  
                  // Fila de Calificación Estilo Udemy
                  Row(
                    children: [
                      Text(widget.curso.calificacion.toStringAsFixed(1), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.amber)),
                      const SizedBox(width: 4),
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text('($numEstudiantes)', style: TextStyle(fontSize: 12, color: Colors.grey[500])),
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