import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomeScreen extends StatelessWidget {
  final _apiService = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Bandas"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await _apiService.logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _apiService.getBands(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text("Sesión expirada o error de red"));

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final band = snapshot.data![index];
              return ListTile(
                leading: Image.network(band['imageUrl'], width: 50, errorBuilder: (c, e, s) => Icon(Icons.music_note)),
                title: Text(band['name']),
                subtitle: Text(band['genre']),
              );
            },
          );
        },
      ),
    );
  }
}