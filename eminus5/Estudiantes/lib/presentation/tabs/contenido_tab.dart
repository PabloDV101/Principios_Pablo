import 'package:flutter/material.dart';
import '../../../domain/entities/curso.dart';
import '../../../domain/entities/usuario.dart';
import '../../../data/services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import '../screens/visor_material_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;


class ContenidoTab extends StatefulWidget {
  final Curso curso;
  final Usuario usuarioActivo;

  const ContenidoTab({super.key, required this.curso, required this.usuarioActivo});

  @override
  State<ContenidoTab> createState() => _ContenidoTabState();
}

class _ContenidoTabState extends State<ContenidoTab> {
  final ApiService _apiService = ApiService();
  final TextEditingController _tituloController = TextEditingController();
  bool _estaCargando = false;
  
  // Icono dinámico según el tipo de archivo
  IconData _obtenerIcono(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'VIDEO': return Icons.play_circle_outline;
      case 'PDF': return Icons.picture_as_pdf;
      case 'IMAGEN': return Icons.image;
      default: return Icons.insert_drive_file;
    }
  }
void _descargarMaterial(MaterialCurso material) {
    // Si estamos en Chrome/Web, dejamos que el navegador maneje la descarga
    if (kIsWeb) {
      launchUrl(Uri.parse(material.url));
      return;
    }

    // Si estamos en el celular, usamos el paquete nativo
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Iniciando descarga de ${material.titulo}...'))
    );

    FileDownloader.downloadFile(
      url: material.url,
      name: material.titulo, 
      onDownloadCompleted: (path) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Guardado en Descargas: $path'), backgroundColor: Colors.green));
      },
      onDownloadError: (error) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al descargar el archivo'), backgroundColor: Colors.red));
      }
    );
  }

  // 2. Método para mostrar el menú flotante
  void _mostrarOpcionesMaterial(MaterialCurso material) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('¿Qué deseas hacer?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListTile(
                leading: const Icon(Icons.visibility, color: Color(0xFF0D47A1)),
                title: const Text('Vista previa'),
                subtitle: const Text('Ver dentro de la aplicación'),
                onTap: () {
                  Navigator.pop(context); // Cierra el menú
                  // Navegamos a la nueva pantalla de visor
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) => VisorMaterialScreen(material: material)
                  ));
                },
              ),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text('Descargar'),
                subtitle: const Text('Guardar en el dispositivo'),
                onTap: () {
                  Navigator.pop(context); // Cierra el menú
                  _descargarMaterial(material); // Llama a la descarga
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      }
    );
  }
  // Función maestra para abrir cualquier link
  Future<void> _abrirMaterial(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      // Intentamos abrir la URL en el navegador externo o visor nativo
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No se pudo abrir el enlace')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al intentar abrir el archivo')));
    }
  }
  void _mostrarDialogoNuevaSeccion() {
    _tituloController.clear(); // Limpiamos el texto anterior

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Nueva Sección', style: TextStyle(fontWeight: FontWeight.bold)),
          content: TextField(
            controller: _tituloController,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: 'Ej. Módulo 1: Introducción',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              onPressed: () async {
                final titulo = _tituloController.text.trim();
                if (titulo.isEmpty) return;

                Navigator.pop(context); // Cerramos el modal
                _guardarNuevaSeccion(titulo); // Llamamos al backend
              },
              child: const Text('Crear', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
// Ayudante para clasificar para tu base de datos (Spring Boot)
  String _determinarTipoBD(String extension) {
    if (['mp4', 'mov', 'avi', 'mkv'].contains(extension)) return 'VIDEO';
    if (['pdf'].contains(extension)) return 'PDF';
    if (['jpg', 'jpeg', 'png', 'gif', 'webp'].contains(extension)) return 'IMAGEN';
    return 'DOCUMENTO';
  }

  void _mostrarDialogoNuevoMaterial(Seccion seccion) {
    final tituloCtrl = TextEditingController();
    PlatformFile? archivoSeleccionado;
    bool subiendo = false;

    showDialog(
      context: context,
      barrierDismissible: false, // Evita que se cierre por accidente mientras sube
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Subir Material', style: TextStyle(fontWeight: FontWeight.bold)),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: tituloCtrl,
                      decoration: InputDecoration(
                        hintText: 'Título (ej. Clase 1: Variables)', 
                        filled: true, fillColor: Colors.grey.shade100, 
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Botón para seleccionar archivo
                    InkWell(
                      onTap: subiendo ? null : () async {
                        FilePickerResult? result = await FilePicker.platform.pickFiles(
                          type: FileType.any, // Permite cualquier archivo
                          withData: true, // Importante para la web
                        );
                        if (result != null) {
                          setStateModal(() => archivoSeleccionado = result.files.first);
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: archivoSeleccionado == null ? Colors.blue.shade50 : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: archivoSeleccionado == null ? Colors.blue.shade200 : Colors.green.shade400, style: BorderStyle.solid),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              archivoSeleccionado == null ? Icons.upload_file : Icons.check_circle, 
                              color: archivoSeleccionado == null ? const Color(0xFF0D47A1) : Colors.green, 
                              size: 32
                            ),
                            const SizedBox(height: 8),
                            Text(
                              archivoSeleccionado == null ? 'Haz clic para seleccionar un archivo' : archivoSeleccionado!.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: archivoSeleccionado == null ? const Color(0xFF0D47A1) : Colors.green, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Indicador de subida
                    if (subiendo) ...[
                      const SizedBox(height: 24),
                      const CircularProgressIndicator(color: Color(0xFF0D47A1)),
                      const SizedBox(height: 8),
                      const Text('Subiendo archivo y guardando...', style: TextStyle(color: Colors.grey)),
                    ]
                  ],
                ),
              ),
              actions: subiendo ? [] : [ // Oculta los botones mientras sube
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  onPressed: () async {
                    final titulo = tituloCtrl.text.trim();
                    if (titulo.isEmpty || archivoSeleccionado == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Agrega un título y un archivo')));
                      return;
                    }

                    // 1. Iniciamos estado de carga en el modal
                    setStateModal(() => subiendo = true);

                    // 2. Subimos a Cloudinary
                    final urlCloudinary = await _apiService.subirArchivoCloudinary(archivoSeleccionado!);

                    if (urlCloudinary == null) {
                      setStateModal(() => subiendo = false);
                      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al subir el archivo'), backgroundColor: Colors.red));
                      return;
                    }

                    // 3. Detectamos el tipo para guardarlo en la Base de Datos
                    final extension = archivoSeleccionado!.extension?.toLowerCase() ?? '';
                    final tipoBD = _determinarTipoBD(extension);

                    // 4. Guardamos en Spring Boot
                    if (context.mounted) Navigator.pop(context); // Cerramos el modal
                    _guardarNuevoMaterial(seccion, titulo, tipoBD, urlCloudinary);
                  },
                  child: const Text('Subir y Guardar', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _guardarNuevoMaterial(Seccion seccion, String titulo, String tipo, String url) async {
    setState(() => _estaCargando = true);

    final nuevoMaterial = await _apiService.agregarMaterial(seccion.id, titulo, tipo, url);

    if (!mounted) return;

    if (nuevoMaterial != null) {
      setState(() {
        seccion.materiales.add(nuevoMaterial);
        _estaCargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Material agregado con éxito')));
    } else {
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al agregar el material'), backgroundColor: Colors.red));
    }
  }

  // Método para enviar al backend y refrescar la pantalla
  Future<void> _guardarNuevaSeccion(String titulo) async {
    setState(() => _estaCargando = true);

    final nuevaSeccion = await _apiService.crearSeccion(widget.curso.id, titulo);

    if (!mounted) return;

    if (nuevaSeccion != null) {
      setState(() {
        // Agregamos la sección recién creada a la lista en memoria
        widget.curso.secciones.add(nuevaSeccion);
        _estaCargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sección creada con éxito')));
    } else {
      setState(() => _estaCargando = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al crear la sección'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    final esProfesor = widget.curso.profesoresIds.contains(widget.usuarioActivo.id);
    final secciones = widget.curso.secciones ?? []; // Asegúrate de tener esto en tu modelo Curso

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: esProfesor 
        ? FloatingActionButton.extended(
            onPressed: _mostrarDialogoNuevaSeccion, // <--- CONECTADO AQUÍ
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Nueva Sección', style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF0D47A1),
          ) 
        : null,
      // ... tu código anterior (Scaffold, floatingActionButton, etc.)
      body: Stack(
        children: [
          // CAPA 1: Tu contenido actual (Lista vacía o ListView)
          secciones.isEmpty
              ? Center(
                  child: Text(
                    'Aún no hay contenido disponible.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: secciones.length,
                  itemBuilder: (context, index) {
                    final seccion = secciones[index];
                    
                    return Card(
                      elevation: 0,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: ExpansionTile(
                    title: Text(
                      seccion.titulo,
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    // AQUÍ ESTÁ EL CAMBIO: Combinamos los materiales existentes con un botón extra al final
                    children: [
                      ...seccion.materiales.map((material) {
                        // ... dentro del ExpansionTile > children > map ...
                        return ListTile(
                          leading: Icon(_obtenerIcono(material.tipo), color: Colors.grey[700]),
                          title: Text(material.titulo, style: const TextStyle(fontSize: 14)),
                          trailing: esProfesor 
                            ? IconButton(icon: const Icon(Icons.delete_outline, size: 18, color: Colors.red), onPressed: () { /* TODO: Eliminar */ })
                            : const SizedBox.shrink(),
                          
                          // 👇 AQUÍ CONECTAMOS EL GATILLO 👇
                          onTap: () => _mostrarOpcionesMaterial(material),
                        );
                      }),
                      
                      // BOTÓN EXTRA SOLO PARA PROFESORES AL FINAL DE LA SECCIÓN
                      if (esProfesor)
                        InkWell(
                          onTap: () => _mostrarDialogoNuevoMaterial(seccion),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_circle_outline, size: 20, color: Color(0xFF0D47A1)),
                                SizedBox(width: 8),
                                Text('Agregar material', style: TextStyle(color: Color(0xFF0D47A1), fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        )
                    ],
                  ),
                    );
                  },
                ),

          // CAPA 2: El Spinner de carga (Solo se muestra si _estaCargando es true)
          if (_estaCargando)
            Container(
              color: Colors.black.withOpacity(0.3), // Fondo semitransparente para oscurecer la pantalla
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF0D47A1)),
              ),
            ),
        ],
      ),
    );
  }
}