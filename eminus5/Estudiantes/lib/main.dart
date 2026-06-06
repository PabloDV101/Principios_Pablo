import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'domain/entities/usuario.dart';
import 'presentation/screens/main_screen.dart';

void main() {
  runApp(const CampusVirtualApp());
}

class CampusVirtualApp extends StatelessWidget {
  const CampusVirtualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Campus Virtual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D47A1)),
        useMaterial3: true,
      ),
      // Usamos un FutureBuilder para decidir qué pantalla mostrar al arrancar
      // Usamos un FutureBuilder para buscar la sesión
      home: FutureBuilder<Usuario?>(
        future: _verificarSesionGuardada(),
        builder: (context, snapshot) {
          
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1))));
          }
          
          // Magia aquí: Si hay datos, le pasa el usuario. Si no hay datos (snapshot.data es null), 
          // entra como invitado automáticamente al MainScreen. ¡Adiós redirección forzada al Login!
          return MainScreen(usuarioActivo: snapshot.data);
        },
      ),
    );
  }

  // Esta función lee el disco local antes de pintar la app
  Future<Usuario?> _verificarSesionGuardada() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token');
      final usuarioString = prefs.getString('usuario_data');

      if (token != null && usuarioString != null) {
        final Map<String, dynamic> usuarioJson = json.decode(usuarioString);
        return Usuario.fromJson(usuarioJson);
      }
    } catch (e) {
      print('Error al leer sesión: $e');
    }
    return null;
  }
}