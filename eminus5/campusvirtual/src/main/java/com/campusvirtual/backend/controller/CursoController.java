package com.campusvirtual.backend.controller;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.MensajeMuro;
import com.campusvirtual.backend.model.Resena;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.service.CursoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/cursos")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class CursoController {

    private final CursoService cursoService;


    // GET /api/cursos -> Retorna el catálogo completo
    @GetMapping
    public ResponseEntity<List<Curso>> obtenerCatalogo() {
        return ResponseEntity.ok(cursoService.obtenerCatalogoCompleto());
    }

    // GET /api/cursos/aprendizaje/123 -> Retorna los cursos donde es alumno
    @GetMapping("/aprendizaje/{estudianteId}")
    public ResponseEntity<List<Curso>> obtenerCursosAprendizaje(@PathVariable String estudianteId) {
        return ResponseEntity.ok(cursoService.obtenerCursosAprendizaje(estudianteId));
    }

    // GET /api/cursos/ensenanza/123 -> Retorna los cursos donde es profesor
    @GetMapping("/ensenanza/{profesorId}")
    public ResponseEntity<List<Curso>> obtenerCursosEnsenanza(@PathVariable String profesorId) {
        return ResponseEntity.ok(cursoService.obtenerCursosEnsenanza(profesorId));
    }

    // POST /api/cursos/crear/123 -> Crea el curso y asigna al usuario 123 como profesor
    @PostMapping("/crear/{creadorId}")
    public ResponseEntity<Curso> crearCurso(@RequestBody Curso curso, @PathVariable String creadorId) {
        return ResponseEntity.ok(cursoService.crearCurso(curso, creadorId));
    }

    // POST /api/cursos/123/inscribir/456 -> Inscribe al usuario 456 en el curso 123
    @PostMapping("/{cursoId}/inscribir/{estudianteId}")
    public ResponseEntity<Curso> inscribirEstudiante(@PathVariable String cursoId, @PathVariable String estudianteId) {
        return ResponseEntity.ok(cursoService.inscribirEstudiante(cursoId, estudianteId));
    }
    @PostMapping("/{cursoId}/mensajes")
    public ResponseEntity<Curso> publicarMensaje(@PathVariable String cursoId, @RequestBody java.util.Map<String, Object> payload) {
        System.out.println("=== PAYLOAD CRUDO RECIBIDO DESDE FLUTTER ===");
        System.out.println(payload); // Esto nos mostrará la verdad absoluta en la consola

        // 1. Creamos el mensaje manualmente
        MensajeMuro mensaje = new MensajeMuro();
        mensaje.setRemitente((String) payload.get("remitente"));
        mensaje.setRol((String) payload.get("rol"));
        mensaje.setMensaje((String) payload.get("mensaje"));

        // 2. Extraemos el ID y la Foto buscando cualquier variante del nombre que haya mandado Flutter
        String uid = (String) payload.getOrDefault("usuarioId", payload.get("usuario_id"));
        String foto = (String) payload.getOrDefault("fotoUrl", payload.get("foto_url"));

        // 3. Blindaje de seguridad: Si por alguna razón Flutter no lo mandó, ponemos un ID por defecto
        mensaje.setUsuarioId(uid != null ? uid : "ID_DESCONOCIDO");
        mensaje.setFotoUrl(foto);

        // 4. Se lo pasamos a tu Service para que lo guarde en PostgreSQL
        return ResponseEntity.ok(cursoService.agregarMensaje(cursoId, mensaje));
    }

    @PostMapping("/{id}/calificar")
    public ResponseEntity<?> calificarCurso(@PathVariable String id, @RequestBody Resena resena) {
        try {
            return ResponseEntity.ok(cursoService.calificarCurso(id, resena));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage());
        }
    }
}