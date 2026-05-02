import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/comentario_model.dart';
import 'package:intl/intl.dart';

class CommentsScreen extends StatefulWidget {
  final int bandaId;
  const CommentsScreen({super.key, required this.bandaId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  final ApiService _apiService = ApiService();
  final TextEditingController _comentarioController = TextEditingController();
  // Usamos una variable para manejar el refresco manual
  late Future<List<Comentario>> _comentariosFuture;

  @override
  void initState() {
    super.initState();
    _cargarComentarios();
  }

  void _cargarComentarios() {
    setState(() {
      _comentariosFuture = _apiService.getComentarios(widget.bandaId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Comentarios")),
      body: Column(
        children: [
          // 1. Lista de comentarios
          Expanded(
            child: FutureBuilder<List<Comentario>>(
              future: _comentariosFuture,
              builder: (context, snapshot) {
                // En tu builder de FutureBuilder:
if (snapshot.connectionState == ConnectionState.waiting) {
  return const Center(child: CircularProgressIndicator());
}
if (snapshot.hasError) {
  return Center(child: Text("Error: ${snapshot.error}"));
}
// AGREGA ESTO: Validación estricta
if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
  return const Center(child: Text("Aún no hay comentarios"));
}

final comentarios = snapshot.data!;
return ListView.builder(
  itemCount: comentarios.length,
  itemBuilder: (context, index) {
    final c = comentarios[index];
    return // Dentro del itemBuilder de tu ListView
Container(
  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(15),
    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 4)],
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(c.username, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(
            DateFormat('HH:mm - dd/MM/yy').format(c.fechaCreacion ?? DateTime.now()),
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
        ],
      ),
      const SizedBox(height: 5),
      Text(c.texto),
    ],
  ),
);
  },
);
              },
            ),
          ),
          // 2. Input para nuevo comentario
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _comentarioController,
                    decoration: const InputDecoration(
                      hintText: "Escribe un comentario...",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.indigo),
                  onPressed: () async {
                    if (_comentarioController.text.isNotEmpty) {
                      await _apiService.publicarComentario(widget.bandaId, _comentarioController.text);
                      _comentarioController.clear();
                      _cargarComentarios(); // Recargamos la lista
                    }
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}