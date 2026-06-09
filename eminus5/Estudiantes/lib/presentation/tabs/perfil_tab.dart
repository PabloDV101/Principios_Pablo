import 'package:flutter/material.dart';
import '../../domain/entities/usuario.dart';
import '../../data/services/api_service.dart';
import '../screens/editar_perfil_screen.dart';

class PerfilTab extends StatefulWidget {
  final Usuario usuarioActivo;
  final VoidCallback onLogout; 

  const PerfilTab({super.key, required this.usuarioActivo, required this.onLogout});

  @override
  State<PerfilTab> createState() => _PerfilTabState();
}

class _PerfilTabState extends State<PerfilTab> {
  late Usuario _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuarioActivo;
  }

  void _navegarAEditarPerfil() async {
    final usuarioActualizado = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditarPerfilScreen(usuarioActual: _usuario)),
    );

    if (usuarioActualizado != null && usuarioActualizado is Usuario) {
      setState(() => _usuario = usuarioActualizado);
    }
  }

  // --- MENÚ DE AJUSTES ACTUALIZADO ---
  void _mostrarAjustes(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        bool modoOscuro = false; 
        
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
                  const SizedBox(height: 20),
                  const Text('Ajustes de Cuenta', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Botón de Modo Oscuro
                  SwitchListTile(
                    title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.w600)),
                    secondary: const Icon(Icons.dark_mode_outlined),
                    activeColor: const Color(0xFF0D47A1),
                    value: modoOscuro,
                    onChanged: (val) {
                      setModalState(() => modoOscuro = val);
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Nota: El modo oscuro requiere configurar el gestor de estado en tu main.dart')
                      ));
                    },
                  ),
                  
                  // Botón de Contraseña
                  ListTile(
                    leading: const Icon(Icons.lock_outline),
                    title: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.w600)),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.pop(context); 
                      _mostrarCambioPassword(context); 
                    },
                  ),
                  
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Divider(),
                  ),
                  
                  // NUEVO: BOTÓN DE CERRAR SESIÓN REUBICADO
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                    onTap: () async {
                      Navigator.pop(context); // Cierra el panel inferior primero
                      await ApiService().logout();
                      widget.onLogout(); // Llama a la función del MainScreen
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }
        );
      }
    );
  }

  void _mostrarCambioPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cambiar Contraseña', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              obscureText: true, 
              decoration: InputDecoration(labelText: 'Contraseña Actual', prefixIcon: const Icon(Icons.lock_open), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
            ),
            const SizedBox(height: 16),
            TextField(
              obscureText: true, 
              decoration: InputDecoration(labelText: 'Nueva Contraseña', prefixIcon: const Icon(Icons.lock), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), 
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey))
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La API para cambiar la contraseña está en construcción')));
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text('Guardar', style: TextStyle(color: Colors.white)),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Verificamos si tiene descripción para cambiar el estilo del texto
    final bool tieneDescripcion = _usuario.descripcion != null && _usuario.descripcion!.trim().isNotEmpty;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // FILA CON EL BOTÓN DE ENGRANAJE
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 28, color: Colors.black87),
                  onPressed: () => _mostrarAjustes(context),
                ),
              ],
            ),
            
            // FOTO DE PERFIL
            Hero(
              tag: 'avatar-perfil',
              child: CircleAvatar(
                radius: 65,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: (_usuario.fotoUrl != null && _usuario.fotoUrl!.isNotEmpty)
                    ? NetworkImage(_usuario.fotoUrl!)
                    : const NetworkImage('https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_1280.png') as ImageProvider,
              ),
            ),
            const SizedBox(height: 20),
            
            // NOMBRE Y PROFESIÓN
            Text(
              _usuario.nombre,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black, letterSpacing: -0.5),
            ),
            const SizedBox(height: 6),
            Text(
              _usuario.profesion != null && _usuario.profesion!.isNotEmpty 
                  ? _usuario.profesion! 
                  : 'Estudiante',
              style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            
            // CORREO
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0D47A1).withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                _usuario.correo,
                style: const TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold, fontSize: 13),
              ),
            ),
            const SizedBox(height: 32),
            
            // BOTÓN PARA EDITAR PERFIL
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _navegarAEditarPerfil,
                icon: const Icon(Icons.edit_outlined, color: Colors.white, size: 20),
                label: const Text('Editar Perfil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 2,
                  shadowColor: const Color(0xFF0D47A1).withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // NUEVO DISEÑO: SECCIÓN "SOBRE MÍ" CON TARJETA Y SOMBRA
            const Align(
              alignment: Alignment.centerLeft,
              child: Text('Sobre mí', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Text(
                tieneDescripcion 
                    ? _usuario.descripcion!
                    : 'Aún no has agregado una descripción. ¡Edita tu perfil para contarle a la comunidad sobre ti!',
                style: TextStyle(
                  fontSize: 15, 
                  color: tieneDescripcion ? Colors.grey[800] : Colors.grey[400], 
                  height: 1.6,
                  fontStyle: tieneDescripcion ? FontStyle.normal : FontStyle.italic,
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}