// lib/presentation/screens/main_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../tabs/inicio_tab.dart';
import '../tabs/mis_cursos_tab.dart';
import '../tabs/deseos_tab.dart';
import '../tabs/perfil_tab.dart';
import 'login_screen.dart';

class MainScreen extends StatefulWidget {
  final Usuario? usuarioActivo; // Acepta null para modo invitado

  const MainScreen({super.key, required this.usuarioActivo});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _indiceActual = 0;

  @override
  Widget build(BuildContext context) {
    final esInvitado = widget.usuarioActivo == null;

    // Vistas dinámicas según el estado de autenticación
   // Vistas dinámicas según el estado de autenticación
    final List<Widget> pantallas = [
      InicioTab(usuarioActivo: widget.usuarioActivo),
      
      esInvitado 
          ? const _PantallaBloqueada(titulo: 'Mis Cursos', icono: Icons.play_circle_outline) 
          : MisCursosTab(usuarioActivo: widget.usuarioActivo!), // Mantenlo como lo tenías si se llama diferente
          
      esInvitado 
          ? const _PantallaBloqueada(titulo: 'Lista de Deseos', icono: Icons.favorite_border) 
          : DeseosTab(usuarioActivo: widget.usuarioActivo!), // Mantenlo como lo tenías si se llama diferente
          
      esInvitado 
          ? const _PantallaBloqueada(titulo: 'Mi Perfil', icono: Icons.person_outline) 
          : PerfilTab(
              usuarioActivo: widget.usuarioActivo!,
              // AQUÍ AGREGAMOS LA FUNCIÓN QUE FALTABA
              onLogout: () {
                // Borramos todo el historial de navegación y recargamos la app como invitado
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const MainScreen(usuarioActivo: null)),
                  (route) => false,
                );
              },
            ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: pantallas[_indiceActual],
      
      // UX de una sola mano: Menú Inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceActual,
        onTap: (index) => setState(() => _indiceActual = index),
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF0D47A1), // Azul fuerte
        unselectedItemColor: Colors.grey[400],
        type: BottomNavigationBarType.fixed,
        elevation: 16,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.play_circle_outline), activeIcon: Icon(Icons.play_circle_fill), label: 'Mis Cursos'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_outline), activeIcon: Icon(Icons.favorite), label: 'Deseos'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Widget elegante para las pestañas bloqueadas en modo invitado
class _PantallaBloqueada extends StatelessWidget {
  final String titulo;
  final IconData icono;

  const _PantallaBloqueada({required this.titulo, required this.icono});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 24),
            Text(titulo, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black)),
            const SizedBox(height: 12),
            Text(
              'Inicia sesión o regístrate para acceder a esta sección y gestionar tu aprendizaje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 15, height: 1.5),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1), // Azul fuerte
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Iniciar sesión / Registrarse', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}