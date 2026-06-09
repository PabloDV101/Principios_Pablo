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

bool _cargando = true;
  @override
  void initState() {
    super.initState();
    // ¡ESTO ES LO QUE TE FALTABA!

    _cargarDeseos();
  }
  
  // ... resto de tu código
  
// 1. Declara esto al principio de tu clase _DeseosTabState
List<Curso> _listaDeseos = []; 

Future<void> _cargarDeseos() async {
  setState(() => _cargando = true);

  // 1. Obtenemos el catálogo completo
  final catalogo = await _apiService.obtenerCatalogo();
  
  // 2. Obtenemos los IDs marcados por el usuario
  final misDeseosIds = await _apiService.obtenerIdsDeseos(widget.usuarioActivo.id);

  if (!mounted) return;

  print("DEBUG: Catálogo recibido: ${catalogo.length}");
  print("DEBUG: IDs de deseos en BD: $misDeseosIds");

  setState(() {
    // AQUÍ ESTÁ EL TRUCO: 
    // Marcamos isFavorito comparando el ID del curso con la lista de IDs del servidor
    for (var curso in catalogo) {
      curso.isFavorito = misDeseosIds.contains(curso.id);
      print("Curso ${curso.titulo} (ID: ${curso.id}) -> ¿Es Favorito? ${curso.isFavorito}");
    }
    
    // Filtramos solo los deseados para la lista
    _listaDeseos = catalogo.where((c) => c.isFavorito).toList();
    _cargando = false;
  });
}
  Future<void> _handleToggleDeseo(Curso curso) async {
  // 1. Guardamos el estado original por si el servidor falla
  final estadoAnterior = curso.isFavorito;

  // 2. Optimismo: Cambiamos la UI al instante
  setState(() {
    curso.isFavorito = !estadoAnterior;
  });

  // 3. Llamada al backend
  final exito = await _apiService.toggleDeseos(widget.usuarioActivo.id, curso.id);
  
  if (!exito) {
    // 4. Si el servidor falla, revertimos
    setState(() {
      curso.isFavorito = estadoAnterior;
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al conectar con el servidor')));
  } else {
    // 5. IMPORTANTE: Refrescamos la lista local del usuarioActivo 
    // para que la próxima vez que entre, los datos estén ahí.
    if (curso.isFavorito) {
      widget.usuarioActivo.cursosDeseados?.add(curso.id);
    } else {
      widget.usuarioActivo.cursosDeseados?.remove(curso.id);
    }
  }
}

@override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lista de Deseos', 
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)
              ),
              const SizedBox(height: 24),
              
              // Verificamos si la lista está vacía o cargando
              // ... dentro de tu Column, en el Expanded
              Expanded(
                child: _cargando // <--- CAMBIA ESTO
                    ? const Center(child: CircularProgressIndicator()) // <--- MUESTRA EL SPINNER
                    : _listaDeseos.isEmpty // <--- SOLO SI NO CARGA Y ESTÁ VACÍO
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.favorite_border, size: 64, color: Colors.grey[300]),
                                const SizedBox(height: 16),
                                const Text('Tu lista está vacía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            // ... tu ListView igual que antes
                        itemCount: _listaDeseos.length,
                        itemBuilder: (context, index) {
                          final curso = _listaDeseos[index];
                          return Container(
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
                                  ).then((_) => _cargarDeseos()); // Recarga al volver
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80, height: 80,
                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
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
                                      // En tu widget de lista del Dashboard:
IconButton(
  icon: Icon(
    // ¡Aquí está la clave! Usar el valor que calculaste en _cargarDeseos
    curso.isFavorito ? Icons.favorite : Icons.favorite_border,
    color: curso.isFavorito ? Colors.red : Colors.grey,
  ),
  onPressed: () => _handleToggleDeseo(curso), // Usamos el método que ya creamos
),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}