import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/band_model.dart';
import 'login_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Si tu BandCard es un Widget simple:

class BandCard extends StatelessWidget {
  final Band banda;
  final String usuarioLogueado;
  final bool esAdmin;
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
    required this.esAdmin,
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
            // En tu BandCard.dart, ajusta esta parte:
            // En BandCard.dart
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    banda.nombre,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // Pequeño espacio
                Text(
                  DateFormat('dd/MM/yy')
                      .format(banda.fechaCreacion ?? DateTime.now()),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            subtitle: Text("Por: ${banda.usernameAutor}"),
            // 1. Definimos las reglas de negocio

// Pásale este booleano desde HomeScreen

            trailing: (esDuenio ||
                    esAdmin) // Usas la variable pasada por el constructor
                ? PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'editar') onEditPressed();
                      if (value == 'eliminar') onDeletePressed();
                    },
                    itemBuilder: (context) => [
                      if (esDuenio) // Solo el dueño ve Editar
                        const PopupMenuItem(
                            value: 'editar', child: Text("Editar")),
                      const PopupMenuItem(
                          value: 'eliminar', child: Text("Eliminar")),
                    ],
                  )
                : null,
          ),

          // 2. Imagen de la Banda
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(0)),
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

          // 3. Descripción
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

          // 4. Barra de Acciones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Row(
              children: [
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
  bool _esAdmin = false;
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
    _verificarPermisos(); // Verificamos los permisos del usuario
    _cargarBandas(); // Ahora cargaremos el FEED (todas las bandas)
  }

  Future<void> _cargarUsuario() async {
    final nombre = await _storage.read(key: 'username');
    setState(() {
      _nombreUsuarioLogueado = nombre ?? "Desconocido";
    });
  }

  Future<void> _verificarPermisos() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token != null) {
      Map<String, dynamic> decodedToken = JwtDecoder.decode(token);

      List<dynamic> rolesDinamicos = decodedToken['roles'] ?? [];
      List<String> roles = rolesDinamicos.cast<String>();

      setState(() {
        _esAdmin = roles.contains("ROLE_ADMIN");
      });
    }
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
      // En tu Scaffold -> AppBar:
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Feed de Bandas"),
            Text(
              _esAdmin ? "Rol: Administrador" : "Rol: Usuario",
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.white70),
            ),
          ],
        ),
        // En los actions del AppBar, puedes agregar este Chip
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(
                _nombreUsuarioLogueado.isNotEmpty
                    ? _nombreUsuarioLogueado
                    : _esAdmin
                        ? "Admin"
                        : "Usuario",
                style: const TextStyle(fontSize: 10, color: Colors.white),
              ),
              backgroundColor:
                  _esAdmin ? Colors.redAccent : Colors.indigoAccent,
            ),
          ),
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
                      esAdmin:
                          _esAdmin, // <--- Usa directamente la variable de estado
                      onLikePressed: () => incrementarLike(index),
                      onCommentPressed: () => Navigator.pushNamed(
                          context, '/comments',
                          arguments: banda.id),
                      onEditPressed: () async {
                        // 1. Navegamos y esperamos el resultado
                        final fueEditado = await Navigator.pushNamed(
                            context, '/edit-band',
                            arguments: banda);

                        // 2. IMPORTANTE: Validamos que el widget aún exista antes de usar el contexto
                        if (!mounted) return;

                        // 3. Si se editó con éxito, recargamos
                        if (fueEditado == true) {
                          _cargarBandas();
                        }
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
