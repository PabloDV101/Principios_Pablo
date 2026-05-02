import 'package:bandasf/models/band_model.dart';
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import '../screens/edit_band_screen.dart';
import '../screens/comments_screen.dart'; 
import 'screens/add_band_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
  debugShowCheckedModeBanner: false,
  title: 'Bandas App',
  
  // 1. RUTA INICIAL (Asegúrate de que esta pantalla exista)
  initialRoute: '/login', 

  // 2. MAPA DE RUTAS (Solo para pantallas que NO reciben parámetros)
  routes: {
    '/login': (context) => const LoginScreen(),
    '/home': (context) => const HomeScreen(),
    '/add-band': (context) => const AddBandScreen(),
    // IMPORTANTE: Eliminamos '/comments' y '/edit-band' de aquí
  },

  // 3. GENERADOR DE RUTAS (Para pantallas que SÍ reciben parámetros)
  onGenerateRoute: (settings) {
    if (settings.name == '/comments') {
      final bandaId = settings.arguments as int;
      return MaterialPageRoute(builder: (context) => CommentsScreen(bandaId: bandaId));
    }
    
    if (settings.name == '/edit-band') {
      final banda = settings.arguments as Band;
      return MaterialPageRoute(builder: (context) => EditBandScreen(banda: banda));
    }
    
    return null; // O puedes manejar rutas desconocidas aquí
  },

  // 4. TEMA (Tu configuración actual es excelente)
  theme: ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
    useMaterial3: true,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey[50],
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
    ),
  ),
);
  }
}