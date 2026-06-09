package com.campusvirtual.backend.controller;

import com.campusvirtual.backend.model.Actividad;
import com.campusvirtual.backend.model.Entrega;
import com.campusvirtual.backend.service.ActividadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/actividades")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ActividadController {

    private final ActividadService actividadService;

    // POST /api/actividades/curso/123 -> El profesor crea una nueva tarea en un curso
    @PostMapping("/curso/{cursoId}")
    public ResponseEntity<Actividad> crearActividad(@PathVariable String cursoId, @RequestBody Actividad actividad) {
        return ResponseEntity.ok(actividadService.crearActividad(cursoId, actividad));
    }

    @PostMapping("/{actividadId}/entregas")
    public ResponseEntity<Entrega> enviarTarea(
            @PathVariable String actividadId,
            @RequestBody Entrega entregaRequest) {

        // En lugar de pasar variables sueltas, le pasamos el objeto completo al servicio
        return ResponseEntity.ok(actividadService.enviarTarea(actividadId, entregaRequest));
    }


    @PutMapping("/{id}")
    public ResponseEntity<Actividad> actualizarActividad(@PathVariable String id, @RequestBody Actividad actividad) {
        return ResponseEntity.ok(actividadService.actualizarActividad(id, actividad));
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminarActividad(@PathVariable String id) {
        actividadService.eliminarActividad(id);
        return ResponseEntity.ok().build();
    }

    // PUT /api/actividades/entrega/789/calificar -> El profesor evalúa la entrega
    @PutMapping("/entrega/{entregaId}/calificar")
    public ResponseEntity<Entrega> calificarTarea(
            @PathVariable String entregaId,
            @RequestParam Double calificacion,
            @RequestParam String retroalimentacion) {

        return ResponseEntity.ok(actividadService.calificarTarea(entregaId, calificacion, retroalimentacion));
    }
}