package com.campusvirtual.backend.controller;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.MensajeMuro;
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
    public ResponseEntity<MensajeMuro> publicarMensaje(@PathVariable String cursoId, @RequestBody MensajeMuro mensaje) {
        return ResponseEntity.ok(cursoService.agregarMensaje(cursoId, mensaje));
    }
    @PutMapping("/{id}/calificar")
    public ResponseEntity<?> calificarCurso(@PathVariable String id, @RequestParam double estrellas, @RequestParam String usuarioId) {
        try {
            return ResponseEntity.ok(cursoService.calificarCurso(id, estrellas, usuarioId));
        } catch (RuntimeException e) {
            return ResponseEntity.badRequest().body(e.getMessage()); // Devuelve error si ya votó
        }
    }
}