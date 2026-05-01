import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/band_model.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Band>> _bandsFuture;

  @override
  void initState() {
    super.initState();
    _bandsFuture = _apiService.getMyBands(); // Cargamos las bandas al iniciar
  }

  void _logout() async {
    await _apiService.logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context, 
      MaterialPageRoute(builder: (context) => const LoginScreen())
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mis Bandas"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: FutureBuilder<List<Band>>(
        future: _bandsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Aún no has agregado ninguna banda."));
          }

          final bands = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: bands.length,
            itemBuilder: (context, index) {
              final band = bands[index];
              return Card(
                elevation: 5,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Imagen de Cloudinary
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                      child: Image.network(
                        band.urlImagen.isNotEmpty 
                          ? band.urlImagen 
                          : 'https://via.placeholder.com/400x200?text=Sin+Imagen',
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => 
                          const SizedBox(height: 200, child: Center(child: Icon(Icons.broken_image, size: 50))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            band.nombre,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            band.descripcion,
                            style: TextStyle(color: Colors.grey[700]),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Agregada el: ${band.fechaCreacion?.day}/${band.fechaCreacion?.month}/${band.fechaCreacion?.year}",
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
  child: const Icon(Icons.add),
  onPressed: () async {
    // Navegamos y esperamos a que el usuario regrese
    await Navigator.pushNamed(context, '/add-band');
    
    // Al regresar, refrescamos la lista automáticamente
    setState(() {
      _bandsFuture = _apiService.getMyBands();
    });
  },
),
    );
  }
}