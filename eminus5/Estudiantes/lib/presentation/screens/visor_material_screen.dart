import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../../../domain/entities/curso.dart'; // Asegúrate de que la ruta a tu modelo sea correcta
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:url_launcher/url_launcher.dart';

class VisorMaterialScreen extends StatefulWidget {
  final MaterialCurso material;

  const VisorMaterialScreen({super.key, required this.material});

  @override
  State<VisorMaterialScreen> createState() => _VisorMaterialScreenState();
}

class _VisorMaterialScreenState extends State<VisorMaterialScreen> {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  @override
  void initState() {
    super.initState();
    if (widget.material.tipo == 'VIDEO') {
      _inicializarVideo();
    }
  }

  Future<void> _inicializarVideo() async {
    _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(widget.material.url));
    await _videoPlayerController!.initialize();
    
    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController!,
      autoPlay: true,
      looping: false,
      aspectRatio: _videoPlayerController!.value.aspectRatio,
      errorBuilder: (context, errorMessage) {
        return Center(child: Text(errorMessage, style: const TextStyle(color: Colors.white)));
      },
    );
    setState(() {});
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

Widget _construirVisor() {
    switch (widget.material.tipo) {
      case 'PDF':
        // Si estamos en la Web, evitamos el error CORS y abrimos el PDF en una pestaña nativa de Chrome
        if (kIsWeb) {
          return Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0D47A1), padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
              icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
              label: const Text('Abrir PDF en nueva pestaña', style: TextStyle(color: Colors.white)),
              onPressed: () => launchUrl(Uri.parse(widget.material.url)),
            ),
          );
        }
        // Si estamos en el celular, usamos el visor nativo de Syncfusion sin problemas
        return SfPdfViewer.network(widget.material.url);
      
      case 'IMAGEN':
        return InteractiveViewer( // Permite hacer zoom a la imagen
          child: Center(
            child: Image.network(widget.material.url, fit: BoxFit.contain),
          ),
        );
      
      case 'VIDEO':
        if (_chewieController != null && _chewieController!.videoPlayerController.value.isInitialized) {
          return Chewie(controller: _chewieController!); // Reproductor de video
        } else {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
      
      default:
        return const Center(child: Text('Formato no soportado para vista previa. Usa la opción Descargar.'));
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si es video, el fondo negro se ve mejor. Si es documento, fondo blanco.
    final esVideo = widget.material.tipo == 'VIDEO';

    return Scaffold(
      backgroundColor: esVideo ? Colors.black : Colors.grey.shade100,
      appBar: AppBar(
        title: Text(widget.material.titulo, style: TextStyle(color: esVideo ? Colors.white : Colors.black, fontSize: 16)),
        backgroundColor: esVideo ? Colors.black : Colors.white,
        iconTheme: IconThemeData(color: esVideo ? Colors.white : Colors.black),
        elevation: 1,
      ),
      body: SafeArea(
        child: _construirVisor(),
      ),
    );
  }
}