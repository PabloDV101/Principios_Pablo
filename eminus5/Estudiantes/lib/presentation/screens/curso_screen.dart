// lib/presentation/screens/curso_screen.dart
import 'package:flutter/material.dart';
import '../../domain/entities/curso.dart';
import '../../domain/entities/usuario.dart';
import '../tabs/muro_tab.dart';
import '../tabs/actividades_tab.dart';
import '../tabs/seguimiento_tab.dart';
import '../tabs/contenido_tab.dart';

class CursoScreen extends StatelessWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const CursoScreen({super.key, required this.curso, required this.usuarioActivo});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAFAFA),
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
          centerTitle: false,
          title: Text(
            curso.titulo, 
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          bottom: TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey[500],
            indicatorColor: Colors.black,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: const [
              Tab(text: 'Contenido'),
              Tab(text: 'Muro'),
              Tab(text: 'Tareas'),
              Tab(text: 'Progreso'),
            ],
          ),
        ),
        body: Column(
          children: [
            // Pequeña línea divisoria sutil debajo de las pestañas
            Container(height: 1, color: Colors.grey.shade200),
            
            // Contenido dinámico de las pestañas
            Expanded(
              child: TabBarView(
                children: [
                  ContenidoTab(curso: curso, usuarioActivo: usuarioActivo),
                  MuroTab(curso: curso, usuarioActivo: usuarioActivo),
                  ActividadesTab(curso: curso, usuarioActivo: usuarioActivo),
                  SeguimientoTab(curso: curso, usuarioActivo: usuarioActivo),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}