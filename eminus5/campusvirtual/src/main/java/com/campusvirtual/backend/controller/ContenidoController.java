package com.campusvirtual.backend.controller;

import com.campusvirtual.backend.model.Material;
import com.campusvirtual.backend.model.Seccion;
import com.campusvirtual.backend.service.ContenidoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/contenido")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class ContenidoController {

    private final ContenidoService contenidoService;

    // POST /api/contenido/curso/123/secciones
    @PostMapping("/curso/{cursoId}/secciones")
    public ResponseEntity<Seccion> crearSeccion(@PathVariable String cursoId, @RequestBody Seccion seccion) {
        return ResponseEntity.ok(contenidoService.crearSeccion(cursoId, seccion));
    }

    // POST /api/contenido/seccion/456/materiales
    @PostMapping("/seccion/{seccionId}/materiales")
    public ResponseEntity<Material> agregarMaterial(@PathVariable String seccionId, @RequestBody Material material) {
        return ResponseEntity.ok(contenidoService.agregarMaterial(seccionId, material));
    }
}