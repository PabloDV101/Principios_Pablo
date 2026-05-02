import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/band_model.dart';
import 'login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Si tu BandCard es un Widget simple:

class BandCard extends StatelessWidget {
  final Band banda;
  final String usuarioLogueado;
  final VoidCallback onLikePressed;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;
  final VoidCallback onCommentPressed;

  const BandCard({
    super.key,
    required this.banda,
    required this.onLikePressed,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.usuarioLogueado,
    required this.onCommentPressed,
  });

  @override
  Widget build(BuildContext context) {
    final bool esDuenio = (banda.usernameAutor == usuarioLogueado);
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Cabecera (Avatar, Nombre y Menú)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.indigo[100],
              child: Icon(Icons.person, color: Colors.indigo[800]),
            ),
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text(banda.nombre,
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                Text(
                  DateFormat('dd/MM/yy')
                      .format(banda.fechaCreacion ?? DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),

            subtitle: Text("Por: ${banda.usernameAutor}"),
            trailing: esDuenio
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'editar') onEditPressed();
                      if (value == 'eliminar') onDeletePressed();
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                          value: 'editar', child: Text("Editar")),
                      const PopupMenuItem(
                          value: 'eliminar', child: Text("Eliminar")),
                    ],
                  )
                : null, // Si no es dueño, no muestra nada
          ),

          // 2. Imagen de la Banda
          ClipRRect(
            child: Image.network(
              banda.urlImagen,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 200,
                color: Colors.grey[200],
                child: const Icon(Icons.broken_image, size: 50),
              ),
            ),
          ),

          // 3. Descripción (Ahora abajo de la imagen)
          Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Descripción:",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
                const SizedBox(height: 5),
                Text(
                  banda.descripcion,
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // 4. Barra de Acciones (Likes y Comentarios)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
                // Botón de Like
                IconButton(
                  icon:
                      const Icon(Icons.thumb_up_outlined, color: Colors.indigo),
                  onPressed: onLikePressed,
                ),
                Text(
                  "${banda.likesCount}",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                // Botón de Comentarios
                TextButton.icon(
                  icon: const Icon(Icons.mode_comment_outlined,
                      color: Colors.grey),
                  label: const Text(
                    "Ver Comentarios",
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: onCommentPressed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  final FlutterSecureStorage _storage =
      const FlutterSecureStorage(); // 1. Agrega esto para que _storage exista
  List<Band> misBandas = [];
  bool isLoading = true;
  String _nombreUsuarioLogueado = ""; // Variable de estado

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
    _cargarBandas(); // Ahora cargaremos el FEED (todas las bandas)
  }

  Future<void> _cargarUsuario() async {
    final nombre = await _storage.read(key: 'username');
    setState(() {
      _nombreUsuarioLogueado = nombre ?? "Desconocido";
    });
  }

  Future<void> _cargarBandas() async {
    try {
      // 2. Aquí llamas al nuevo endpoint /feed que creamos
      final data = await _apiService.getFeed();
      setState(() {
        misBandas = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint("Error al cargar feed: $e");
    }
  }

  // Método para actualizar la lista y reflejar los cambios en la UI
  Future<void> incrementarLike(int index) async {
    final banda = misBandas[index];
    try {
      await _apiService.reaccionar(banda.id!, "LIKE");
      setState(() {
        misBandas[index] = Band(
          id: banda.id,
          nombre: banda.nombre,
          descripcion: banda.descripcion,
          urlImagen: banda.urlImagen,
          likesCount: banda.likesCount + 1,
          dislikesCount: banda.dislikesCount,
          fechaCreacion: banda.fechaCreacion,
          usernameAutor: banda.usernameAutor,
        );
      });
    } catch (e) {
      debugPrint("Error al dar like: $e");
    }
  }

  void _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  Future<void> _eliminarBanda(int id) async {
    // Confirmación simple con un Dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirmar"),
        content: const Text("¿Estás seguro de eliminar esta banda?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancelar")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Eliminar")),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _apiService.eliminarBanda(id);
        _cargarBandas(); // Recargamos la lista desde el servidor
      } catch (e) {
        debugPrint("Error: $e");
      }
    }
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Feed de Bandas"),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout)
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : (misBandas.isEmpty
              ? const Center(child: Text("No hay bandas publicadas aún."))
              : ListView.builder(
                  padding: const EdgeInsets.all(10),
                  itemCount: misBandas.length,
                  itemBuilder: (context, index) {
                    final banda = misBandas[index];
                    return BandCard(
                      banda: banda,
                      usuarioLogueado: _nombreUsuarioLogueado,
                      onLikePressed: () => incrementarLike(index),
                      onCommentPressed: () => Navigator.pushNamed(
                          context, '/comments',
                          arguments: banda.id),
                      onEditPressed: () async {
                        final fueEditado = await Navigator.pushNamed(
                            context, '/edit-band',
                            arguments: banda);
                        if (fueEditado == true) _cargarBandas();
                      },
                      onDeletePressed: () => _eliminarBanda(banda.id!),
                    );
                  },
                )),
      // ESTA ES LA PARTE QUE FALTABA:
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navegamos a la pantalla de agregar banda
          await Navigator.pushNamed(context, '/add-band');
          // Al regresar, refrescamos los datos
          _cargarBandas();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}