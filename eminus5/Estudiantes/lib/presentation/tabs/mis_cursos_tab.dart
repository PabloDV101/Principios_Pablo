import 'package:flutter/material.dart';
import '../../../domain/entities/usuario.dart';
import '../../../domain/entities/curso.dart';
import '../../../data/services/api_service.dart';
import '../screens/curso_screen.dart';

class MisCursosTab extends StatefulWidget {
  final Usuario usuarioActivo;

  const MisCursosTab({super.key, required this.usuarioActivo});

  @override
  State<MisCursosTab> createState() => _MisCursosTabState();
}

class _MisCursosTabState extends State<MisCursosTab> {
  final ApiService _apiService = ApiService();
  late Future<List<Curso>> _futureAprendizaje;
  late Future<List<Curso>> _futureEnsenanza;

  @override
  void initState() {
    super.initState();
    _cargarCursos();
  }

  void _cargarCursos() {
    setState(() {
      _futureAprendizaje = _apiService.obtenerCursosAprendizaje(widget.usuarioActivo.id);
      _futureEnsenanza = _apiService.obtenerCursosEnsenanza(widget.usuarioActivo.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mis Cursos', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text('Gestiona tu aprendizaje y enseñanza', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            ),
            TabBar(
              labelColor: const Color(0xFF0D47A1), unselectedLabelColor: Colors.grey[500], indicatorColor: const Color(0xFF0D47A1), indicatorWeight: 3, labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              tabs: const [Tab(text: 'Aprendizaje'), Tab(text: 'Enseñanza')],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  // Pestaña de Aprendizaje
                  FutureBuilder<List<Curso>>(
                    future: _futureAprendizaje,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('Error al cargar cursos'));
                      return _ListaCursosView(cursos: snapshot.data ?? [], usuarioActivo: widget.usuarioActivo, esProfesor: false);
                    }
                  ),
                  // Pestaña de Enseñanza
                  FutureBuilder<List<Curso>>(
                    future: _futureEnsenanza,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                      if (snapshot.hasError) return const Center(child: Text('Error al cargar cursos'));
                      return _ListaCursosView(cursos: snapshot.data ?? [], usuarioActivo: widget.usuarioActivo, esProfesor: true);
                    }
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
// Pega esto al final de mis_cursos_tab.dart

class _ListaCursosView extends StatelessWidget {
  final List<Curso> cursos;
  final Usuario usuarioActivo;
  final bool esProfesor;

  const _ListaCursosView({required this.cursos, required this.usuarioActivo, required this.esProfesor});

  @override
  Widget build(BuildContext context) {
    if (cursos.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(esProfesor ? Icons.assignment_ind_outlined : Icons.menu_book, size: 64, color: Colors.grey[300]),
              const SizedBox(height: 16),
              Text(
                esProfesor ? 'No estás impartiendo cursos' : 'Aún no tienes cursos', 
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 8),
              Text(
                esProfesor ? 'Crea un curso desde la pestaña Inicio.' : 'Ve a la pestaña de Inicio para explorar.', 
                style: TextStyle(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20.0),
      itemCount: cursos.length,
      itemBuilder: (context, index) {
        return _CursoGestionCard(
          curso: cursos[index], 
          usuarioActivo: usuarioActivo, 
          esVistaProfesor: esProfesor
        );
      },
    );
  }
}

class _CursoGestionCard extends StatelessWidget {
  final Curso curso;
  final Usuario usuarioActivo;
  final bool esVistaProfesor;

  const _CursoGestionCard({required this.curso, required this.usuarioActivo, required this.esVistaProfesor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CursoScreen(curso: curso, usuarioActivo: usuarioActivo)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Reemplaza el Container de 50x50 por esto:
Container(
  width: 50,
  height: 50,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(8),
  ),
  clipBehavior: Clip.antiAlias,
  child: Image.network(
    curso.urlImagen,
    fit: BoxFit.cover,
    errorBuilder: (context, error, stackTrace) => Container(
      color: Colors.grey[300], 
      child: const Icon(Icons.school, color: Colors.grey)
    ),
  ),
),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(curso.titulo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black)),
                          const SizedBox(height: 4),
                          Text(esVistaProfesor ? 'Panel de Instructor' : curso.autor, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(esVistaProfesor ? Icons.people_outline : Icons.menu_book, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 6),
                        Text(
                          esVistaProfesor ? '${curso.estudiantesIds.length} Estudiantes' : 'Curso Activo', 
                          style: TextStyle(color: Colors.grey[700], fontSize: 13, fontWeight: FontWeight.w500)
                        ),
                      ],
                    ),
                    Text(
                      esVistaProfesor ? 'Gestionar' : 'Continuar', 
                      style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 13)
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// (La clase _ListaCursosView y _CursoGestionCard quedan igual a como las teníamos)