import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _userController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _apiService = ApiService();

  bool _isLoading = false;

void _register() async {
  if (_formKey.currentState!.validate()) {
    setState(() => _isLoading = true); // Si añadiste un loading spinner

    bool success = await _apiService.register(
      _userController.text.trim(),
      _emailController.text.trim(),
      _passController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Registro exitoso! Ya puedes iniciar sesión"), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Regresa al Login
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al registrar. ¿Quizás el usuario ya existe?"), backgroundColor: Colors.red),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Crear Cuenta")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _userController,
                decoration: const InputDecoration(labelText: "Usuario", prefixIcon: Icon(Icons.person)),
                validator: (value) => value!.isEmpty ? "Ingresa un usuario" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email)),
                validator: (value) => !value!.contains("@") ? "Email inválido" : null,
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: _passController,
                obscureText: true,
                decoration: const InputDecoration(labelText: "Contraseña", prefixIcon: Icon(Icons.lock)),
                validator: (value) => value!.length < 6 ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                child: const Text("Registrarse"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}