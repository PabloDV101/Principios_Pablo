// lib/data/mock/mock_database.dart
import '../../domain/entities/usuario.dart';
import '../../domain/entities/curso.dart';

class MockDatabase {
  MockDatabase._privateConstructor();
  static final MockDatabase instancia = MockDatabase._privateConstructor();

  // Listas Dinámicas (ArrayLists) que inician vacías
  List<Usuario> usuarios = [];
  List<Curso> cursos = [];
  
  // Las categorías se quedan predefinidas como pediste
  final List<String> categoriasPredefinidas = [
    'Programación', 'Diseño', 'Negocios', 'Matemáticas', 'Ciencias', 'Idiomas'
  ];

  void inicializarDatos() {
    usuarios.clear();
    cursos.clear();
  }

  // Método para validar login
  Usuario? login(String correo, String password) {
    try {
      // Nota: En un sistema real se valida el password, aquí simulamos con el correo
      return usuarios.firstWhere((u) => u.correo == correo);
    } catch (e) {
      return null;
    }
  }

  // Método para registrar guardando en la lista
  bool registrarUsuario(Usuario nuevoUsuario) {
    bool existe = usuarios.any((u) => u.correo == nuevoUsuario.correo);
    if (existe) return false; // Falla si el correo ya está registrado
    
    usuarios.add(nuevoUsuario);
    return true;
  }
}