import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'signup_screen.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); 
  final _userController = TextEditingController();
  final _passController = TextEditingController();
  final _apiService = ApiService();
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    String username = _userController.text.trim();
    String password = _passController.text.trim();
    
    // Asumimos que login retorna true si fue exitoso
    bool success = await _apiService.login(username, password);

    setState(() => _isLoading = false);

    if (success) {
      // AQUÍ GUARDAMOS EL USUARIO PARA PODER USARLO EN EL FEED
      await _storage.write(key: 'username', value: username);
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Error: Credenciales incorrectas"), 
          backgroundColor: Colors.red
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.music_video, size: 100, color: Colors.indigo),
              const SizedBox(height: 20),
              const Text("Bandas App", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              TextField(
                controller: _userController,
                decoration: const InputDecoration(hintText: "Usuario", prefixIcon: Icon(Icons.person_outline)),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(hintText: "Contraseña", prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 30),
              _isLoading 
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
                    child: const Text("ENTRAR"),
                  ),
              TextButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SignupScreen())),
                child: const Text("¿No tienes cuenta? Regístrate aquí"),
              )
            ],
          ),
        ),
      ),
    );
  }
}