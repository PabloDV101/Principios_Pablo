package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.Material;
import com.campusvirtual.backend.model.Seccion;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.repository.MaterialRepository;
import com.campusvirtual.backend.repository.SeccionRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class ContenidoService {

    private final CursoRepository cursoRepository;
    private final SeccionRepository seccionRepository;
    private final MaterialRepository materialRepository;

    @Transactional
    public Seccion crearSeccion(String cursoId, Seccion nuevaSeccion) {
        Curso curso = cursoRepository.findById(cursoId)
                .orElseThrow(() -> new RuntimeException("Curso no encontrado"));

        // Asignamos el curso a la sección para mantener la relación
        nuevaSeccion.setCurso(curso);

        // Calculamos el orden automáticamente (al final de la lista)
        int orden = curso.getSecciones() != null ? curso.getSecciones().size() + 1 : 1;
        nuevaSeccion.setOrden(orden);

        return seccionRepository.save(nuevaSeccion);
    }

    @Transactional
    public Material agregarMaterial(String seccionId, Material nuevoMaterial) {
        Seccion seccion = seccionRepository.findById(seccionId)
                .orElseThrow(() -> new RuntimeException("Sección no encontrada"));

        // Asignamos la sección al material
        nuevoMaterial.setSeccion(seccion);

        // Orden automático
        int orden = seccion.getMateriales() != null ? seccion.getMateriales().size() + 1 : 1;
        nuevoMaterial.setOrden(orden);

        return materialRepository.save(nuevoMaterial);
    }
}