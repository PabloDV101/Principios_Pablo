// lib/presentation/screens/tabs/inicio_tab.dart
import 'package:flutter/material.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/curso.dart';
import '../screens/curso_overview_screen.dart';
import '../screens/login_screen.dart';
import '../screens/crear_curso_screen.dart';
import '../../../data/services/api_service.dart';

import '../tabs/perfil_tab.dart';
import '../screens/main_screen.dart';



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

 // En tu InicioTab.dart
@override
void initState() {
  _futureCursos = _cargarCatalogoConFavoritos();
  _futureCursos = _apiService.obtenerCatalogo();
  super.initState();
  // Aquí es donde cargamos todo al abrir la app
  _sincronizarFavoritos();
}
Future<List<Curso>> _cargarCatalogoConFavoritos() async {
    // 1. Descargamos el catálogo completo
    final catalogo = await _apiService.obtenerCatalogo();

    // 2. Si es invitado, devolvemos el catálogo tal cual (todo gris)
    if (widget.usuarioActivo == null) return catalogo;

    // 3. Si hay usuario logueado, descargamos sus IDs favoritos de la base de datos
    final misDeseosIds = await _apiService.obtenerIdsDeseos(widget.usuarioActivo!.id);

    // 4. Actualizamos la memoria RAM del usuario con la verdad del servidor
    widget.usuarioActivo!.cursosDeseados = misDeseosIds;

    // 5. Cruzamos los datos: Marcamos los corazones correctos ANTES de que se dibuje la UI
    for (var curso in catalogo) {
      curso.isFavorito = misDeseosIds.contains(curso.id);
    }

    // 6. Devolvemos la lista perfectamente sincronizada al FutureBuilder
    return catalogo;
  }

Future<void> _sincronizarFavoritos() async {
    // 1. Protección inicial: Si el usuario es nulo, no hacemos nada y salimos.
    if (widget.usuarioActivo == null) return;

    final catalogo = await _apiService.obtenerCatalogo();
    
    // 2. LA CORRECCIÓN: Agregamos el "!" antes del ".id"
    // Esto le asegura a Dart que la variable tiene datos.
    final misDeseosIds = await _apiService.obtenerIdsDeseos(widget.usuarioActivo!.id);

    if (!mounted) return;

    setState(() {
      for (var curso in catalogo) {
        curso.isFavorito = misDeseosIds.contains(curso.id);
      }

    });
  }

  void _cargarCursos() {
    setState(() {
      _futureCursos = _apiService.obtenerCatalogo();
    });
  }
@override
  Widget build(BuildContext context) {
    final bool esInvitado = widget.usuarioActivo == null;
    // Variable para saber si estamos buscando (y así ocultar el carrusel)
    final bool estaBuscando = _searchQuery.isNotEmpty;

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
         
          
          // Tomamos los primeros 5 cursos (o los que quieras) para el carrusel
          final cursosDestacados = todosLosCursos.take(5).toList(); 

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
              // 1. NUEVA BARRA SUPERIOR COMPACTA
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0, bottom: 8.0),
                  child: Row(
                    children: [
                      // Logo y Nombre
                      const Icon(Icons.school, color: Color(0xFF0D47A1), size: 26),
                      const SizedBox(width: 4),
                      // Ocultamos la palabra 'Campus' si la pantalla es muy chica para que no choque
                      if (MediaQuery.of(context).size.width > 360)
                        const Text('Campus', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
                      const SizedBox(width: 12),
                      
                      // Barra de Búsqueda (Expanded para que tome el espacio del centro)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: TextField(
                            controller: _searchController,
                            onChanged: (value) => setState(() => _searchQuery = value.toLowerCase()),
                            decoration: InputDecoration(
                              hintText: 'Buscar...',
                              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              suffixIcon: _searchQuery.isNotEmpty 
                                  ? IconButton(icon: const Icon(Icons.clear, color: Colors.grey, size: 18), onPressed: () { _searchController.clear(); setState(() => _searchQuery = ''); }) 
                                  : null,
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Botones de Acción
                      if (esInvitado)
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())), 
                          style: TextButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8), minimumSize: Size.zero),
                          child: const Text('Entrar', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0D47A1)))
                        )
                      else
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.add_box_outlined, color: Colors.black, size: 26),
                              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CrearCursoScreen(usuarioActivo: widget.usuarioActivo!))).then((_) => _cargarCursos()),
                            ),
                            const SizedBox(width: 12),
                            PopupMenuButton<String>(
                              offset: const Offset(0, 45),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              onSelected: (value) async {
                                if (value == 'perfil') {
                                  // AHORA LLEVA A LA VISTA DEL PERFIL (PerfilTab)
                                  Navigator.push(context, MaterialPageRoute(
                                    builder: (_) => Scaffold(
                                      appBar: AppBar(
                                        backgroundColor: Colors.white, 
                                        foregroundColor: Colors.black, 
                                        elevation: 0
                                      ),
                                      body: PerfilTab(
                                        usuarioActivo: widget.usuarioActivo!,
                                        onLogout: () async {
                                          await ApiService().logout();
                                          if (context.mounted) {
                                            Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(usuarioActivo: null)), (route) => false);
                                          }
                                        }
                                      ),
                                    )
                                  )).then((_) => setState(() {})); 
                                  
                                } else if (value == 'logout') {
                                  await ApiService().logout();
                                  if (context.mounted) Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainScreen(usuarioActivo: null)), (route) => false);
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(value: 'perfil', child: Row(children: [Icon(Icons.person, color: Colors.black), SizedBox(width: 12), Text('Mi perfil', style: TextStyle(fontWeight: FontWeight.bold))])),
                                const PopupMenuDivider(),
                                const PopupMenuItem(value: 'logout', child: Row(children: [Icon(Icons.logout, color: Colors.red), SizedBox(width: 12), Text('Cerrar sesión', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))])),
                              ],
                              child: CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF0D47A1),
                                backgroundImage: (widget.usuarioActivo!.fotoUrl != null && widget.usuarioActivo!.fotoUrl!.isNotEmpty) ? NetworkImage(widget.usuarioActivo!.fotoUrl!) : null,
                                child: (widget.usuarioActivo!.fotoUrl == null || widget.usuarioActivo!.fotoUrl!.isEmpty) ? Text(widget.usuarioActivo!.nombre.substring(0, 1).toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)) : null,
                              ),
                            ),
                          ],
                        )
                    ],
                  ),
                ),
              ),
              
              // 2. SALUDO Y CARRUSEL (Se ocultan si el usuario está buscando algo)
              // 2. SALUDO Y CARRUSEL (Se ocultan si el usuario está buscando algo)
              if (!estaBuscando) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 16.0, bottom: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          esInvitado ? 'Hola, Invitado' : 'Hola, ${widget.usuarioActivo!.nombre.split(' ')[0]}', 
                          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black)
                        ),
                        const SizedBox(height: 4),
                        Text('Descubre tu próximo curso', style: TextStyle(fontSize: 15, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
                
                // AQUÍ MANDAMOS A LLAMAR TU NUEVO CARRUSEL INFINITO
                SliverToBoxAdapter(
                  child: _CarruselInfinito(
                    cursos: cursosDestacados, 
                    usuarioActivo: widget.usuarioActivo,
                  ),
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 32)), // Espaciador
              ],
              
              // 3. SECCIÓN DE CATEGORÍAS (Se mueve hacia arriba si hay búsqueda)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (estaBuscando) const SizedBox(height: 16),
                      const Text('Categorías', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
              
              // CHIPS DE ETIQUETAS
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
              
              // RESULTADOS DE LOS CURSOS (Mismo de antes)
              SliverPadding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 20.0),
                sliver: cursosPorCategoria.isEmpty 
                  ? SliverToBoxAdapter(child: Center(child: Padding(padding: const EdgeInsets.all(40.0), child: Text('No se encontraron cursos.', style: TextStyle(color: Colors.grey[500], fontSize: 16)))))
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
                                child: Text(categoria, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
                              ),
                              SizedBox(
                                height: 260, 
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  padding: const EdgeInsets.symmetric(horizontal: 16),
                                  itemCount: cursosDeEstaCategoria.length,
                                  itemBuilder: (context, idx) {
                                    return _CursoMiniCard(curso: cursosDeEstaCategoria[idx], usuarioActivo: widget.usuarioActivo);
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
      final lista = widget.usuarioActivo!.cursosDeseados;
      if (lista?.contains(widget.curso.id) == true) {
        lista?.remove(widget.curso.id);
      } else {
        lista?.add(widget.curso.id);
      }
    });

    // Lo guardamos en la base de datos de fondo
    await _apiService.toggleDeseos(widget.usuarioActivo!.id, widget.curso.id);
  }

  @override
  Widget build(BuildContext context) {
    final esFavorito = widget.usuarioActivo != null && widget.usuarioActivo!.cursosDeseados?.contains(widget.curso.id) == true;

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

  // 1. ESTO ES LO QUE OBLIGA AL CORAZÓN A SER ROJO
  bool get _esFavorito {
    if (widget.usuarioActivo != null && widget.usuarioActivo!.cursosDeseados != null) {
      // Si el ID del curso está en los deseos del usuario, es true sí o sí
      return widget.usuarioActivo!.cursosDeseados!.contains(widget.curso.id);
    }
    return widget.curso.isFavorito;
  }

  void _toggleFavorito() async {
    if (widget.usuarioActivo == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Inicia sesión para guardar cursos')));
      return;
    }

    // Guardamos el estado anterior por si hay error
    final bool eraFavorito = _esFavorito;

    // 2. CAMBIO INMEDIATO EN LA UI Y LA MEMORIA
    setState(() {
      if (eraFavorito) {
        widget.usuarioActivo!.cursosDeseados?.remove(widget.curso.id);
        widget.curso.isFavorito = false;
      } else {
        widget.usuarioActivo!.cursosDeseados?.add(widget.curso.id);
        widget.curso.isFavorito = true;
      }
    });

    // 3. Petición silenciosa al servidor
    final exito = await _apiService.toggleDeseos(widget.usuarioActivo!.id, widget.curso.id);
    
    // 4. Si el servidor falla, regresamos el corazón a su color anterior
    if (!exito) {
      setState(() {
        if (eraFavorito) {
          widget.usuarioActivo!.cursosDeseados?.add(widget.curso.id);
          widget.curso.isFavorito = true;
        } else {
          widget.usuarioActivo!.cursosDeseados?.remove(widget.curso.id);
          widget.curso.isFavorito = false;
        }
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al conectar')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final numEstudiantes = widget.curso.estudiantesLista.length;

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CursoOverviewScreen(curso: widget.curso, usuarioActivo: widget.usuarioActivo),
        )).then((_) {
          // Si el usuario cambia el corazón en la pantalla de detalles, recargamos la tarjeta al volver
          if (mounted) setState(() {}); 
        });
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
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    radius: 16,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      // USAMOS NUESTRO GETTER "A PRUEBA DE BALAS" AQUÍ
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
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.curso.titulo, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2)),
                  const SizedBox(height: 6),
                  Text(widget.curso.autor, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  const SizedBox(height: 8),
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
// NUEVA TARJETA GRANDE PARA EL CARRUSEL
class _CursoDestacadoCard extends StatelessWidget {
  final Curso curso;
  final Usuario? usuarioActivo;

  const _CursoDestacadoCard({required this.curso, this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => CursoOverviewScreen(curso: curso, usuarioActivo: usuarioActivo),
        ));
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Imagen de fondo con bordes redondeados
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.network(
                curso.urlImagen,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                ),
              ),
            ),
            
            // Gradiente oscuro para que resalten los textos
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                ),
              ),
            ),
            
            // Textos sobre la imagen
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFF0D47A1), borderRadius: BorderRadius.circular(4)),
                    child: const Text('DESTACADO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    curso.titulo,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    curso.autor,
                    style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
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
// NUEVO COMPONENTE: CARRUSEL INFINITO CON FLECHAS
class _CarruselInfinito extends StatefulWidget {
  final List<Curso> cursos;
  final Usuario? usuarioActivo;

  const _CarruselInfinito({required this.cursos, this.usuarioActivo});

  @override
  State<_CarruselInfinito> createState() => _CarruselInfinitoState();
}

class _CarruselInfinitoState extends State<_CarruselInfinito> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    
    // TRUCO MATEMÁTICO: Empezamos en una página artificialmente alta (múltiplo exacto) 
    // para que el usuario pueda scrollear hacia atrás desde el inicio indefinidamente.
    int paginaInicial = widget.cursos.isNotEmpty ? widget.cursos.length * 1000 : 0;
    
    // viewportFraction en 0.88 permite que se "asomen" las tarjetas de los lados
    _pageController = PageController(viewportFraction: 0.88, initialPage: paginaInicial);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _irAdelante() {
    _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  void _irAtras() {
    _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cursos.isEmpty) return const SizedBox();

    return SizedBox(
      height: 220, // Altura del carrusel aumentada para acomodar flechas
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 1. EL CARRUSEL
          PageView.builder(
            controller: _pageController,
            // Al omitir el "itemCount", le decimos a Flutter que la lista es infinita
            itemBuilder: (context, index) {
              // Calculamos el índice real usando el módulo (%)
              final cursoIndex = index % widget.cursos.length;
              return _CursoDestacadoCard(
                curso: widget.cursos[cursoIndex],
                usuarioActivo: widget.usuarioActivo,
              );
            },
          ),
          
          // 2. FLECHA IZQUIERDA
          Positioned(
            left: 12,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.85),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_back_ios_new, size: 16, color: Colors.black87),
                onPressed: _irAtras,
              ),
            ),
          ),
          
          // 3. FLECHA DERECHA
          Positioned(
            right: 12,
            child: CircleAvatar(
              radius: 18,
              backgroundColor: Colors.white.withOpacity(0.85),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black87),
                onPressed: _irAdelante,
              ),
            ),
          ),
        ],
      ),
    );
  }
}