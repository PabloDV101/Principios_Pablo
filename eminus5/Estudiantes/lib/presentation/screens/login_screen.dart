import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../data/services/api_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  
  final ApiService _apiService = ApiService(); // Instancia de nuestro nuevo servicio
  
  bool _ocultarPassword = true;
  bool _esRegistro = false;
  String _mensajeError = '';
  bool _cargando = false; // Estado para mostrar indicador de carga

  // Ahora esta función es ASÍNCRONA (async)
  Future<void> _procesarFormulario() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      setState(() => _mensajeError = 'Por favor, completa todos los campos.');
      return;
    }

    // Encendemos el estado de carga
    setState(() {
      _cargando = true;
      _mensajeError = '';
    });

    if (_esRegistro) {
      final nombre = _nombreController.text.trim();
      if (nombre.isEmpty) {
        setState(() { _mensajeError = 'El nombre es obligatorio.'; _cargando = false; });
        return;
      }
      
      // Creamos el usuario sin ID (se lo dará Postgres)
      final usuarioARegistrar = Usuario(
        id: '', 
        nombre: nombre,
        correo: correo,
      );
      
      // Petición POST al Backend de Spring Boot
      final usuarioRegistrado = await _apiService.registrarUsuario(usuarioARegistrar);
      
      if (usuarioRegistrado != null) {
        _navegarAMain(usuarioRegistrado);
      } else {
        setState(() { _mensajeError = 'Error: Este correo ya está registrado.'; _cargando = false; });
      }
      
    } else {
      // Petición de Login al Backend
      final usuarioLogueado = await _apiService.login(correo, password);
      
      if (usuarioLogueado != null) {
        _navegarAMain(usuarioLogueado);
      } else {
        setState(() { _mensajeError = 'Correo o contraseña incorrectos.'; _cargando = false; });
      }
    }
  }

  void _navegarAMain(Usuario usuario) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(usuarioActivo: usuario)),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school, color: Color(0xFF0D47A1), size: 36),
                    SizedBox(width: 12),
                    Text('Campus', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5)),
                  ],
                ),
                const SizedBox(height: 40),

                Container(
                  constraints: const BoxConstraints(maxWidth: 400),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20, offset: const Offset(0, 10))]),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _TabOpcion(titulo: 'Iniciar Sesión', estaActivo: !_esRegistro, onTap: () => setState(() { _esRegistro = false; _mensajeError = ''; })),
                          _TabOpcion(titulo: 'Registrarse', estaActivo: _esRegistro, onTap: () => setState(() { _esRegistro = true; _mensajeError = ''; })),
                        ],
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (_esRegistro) ...[
                              const Text('Nombre completo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                              const SizedBox(height: 8),
                              _CustomTextField(controller: _nombreController, hint: 'Ej. Juan Pérez', icon: Icons.person_outline),
                              const SizedBox(height: 20),
                            ],

                            const Text('Correo electrónico', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 8),
                            _CustomTextField(controller: _correoController, hint: 'correo@ejemplo.com', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
                            const SizedBox(height: 20),
                            
                            const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            const SizedBox(height: 8),
                            _CustomTextField(controller: _passwordController, hint: '••••••••', icon: Icons.lock_outline, isPassword: true, obscureText: _ocultarPassword, onTogglePassword: () => setState(() => _ocultarPassword = !_ocultarPassword)),
                            
                            if (_mensajeError.isNotEmpty) ...[
                              const SizedBox(height: 16),
                              Container(padding: const EdgeInsets.all(12), width: double.infinity, decoration: BoxDecoration(color: Colors.red.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.shade200)), child: Text(_mensajeError, style: TextStyle(color: Colors.red.shade700, fontSize: 13))),
                            ],

                            const SizedBox(height: 24),
                            
                            // Botón o Indicador de Carga
                            SizedBox(
                              width: double.infinity,
                              child: _cargando 
                                ? const Center(child: CircularProgressIndicator(color: Color(0xFF0D47A1)))
                                : ElevatedButton(
                                    onPressed: _procesarFormulario,
                                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), elevation: 0),
                                    child: Text(_esRegistro ? 'Crear cuenta gratis' : 'Entrar', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// (Pega aquí los widgets _TabOpcion y _CustomTextField que ya tenías en este archivo al final)
class _TabOpcion extends StatelessWidget { /*... código intacto ...*/ 
  final String titulo; final bool estaActivo; final VoidCallback onTap;
  const _TabOpcion({required this.titulo, required this.estaActivo, required this.onTap});
  @override Widget build(BuildContext context) { return Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 16), decoration: BoxDecoration(color: estaActivo ? Colors.white : Colors.grey.shade50, border: Border(bottom: BorderSide(color: estaActivo ? const Color(0xFF0D47A1) : Colors.grey.shade200, width: estaActivo ? 2 : 1)), borderRadius: estaActivo ? null : const BorderRadius.only(topLeft: Radius.circular(16))), child: Text(titulo, textAlign: TextAlign.center, style: TextStyle(fontWeight: estaActivo ? FontWeight.bold : FontWeight.w500, color: estaActivo ? const Color(0xFF0D47A1) : Colors.grey[500]))))); }
}

class _CustomTextField extends StatelessWidget { /*... código intacto ...*/ 
  final TextEditingController controller; final String hint; final IconData icon; final bool isPassword; final bool obscureText; final VoidCallback? onTogglePassword; final TextInputType keyboardType;
  const _CustomTextField({required this.controller, required this.hint, required this.icon, this.isPassword = false, this.obscureText = false, this.onTogglePassword, this.keyboardType = TextInputType.text});
  @override Widget build(BuildContext context) { return TextField(controller: controller, obscureText: obscureText, keyboardType: keyboardType, decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[400]), prefixIcon: Icon(icon, color: Colors.grey[500], size: 20), suffixIcon: isPassword ? IconButton(icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility, color: Colors.grey[500], size: 20), onPressed: onTogglePassword) : null, filled: true, fillColor: Colors.grey.shade50, border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade200)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFF0D47A1))), contentPadding: const EdgeInsets.symmetric(vertical: 14))); }
}