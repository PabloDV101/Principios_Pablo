package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Actividad;
import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.Entrega;
import com.campusvirtual.backend.model.Usuario;
import com.campusvirtual.backend.repository.ActividadRepository;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.repository.EntregaRepository;
import com.campusvirtual.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class ActividadService {

    private final ActividadRepository actividadRepository;
    private final CursoRepository cursoRepository;
    private final EntregaRepository entregaRepository;
    private final UsuarioRepository usuarioRepository;

    @Transactional
    public Actividad crearActividad(String cursoId, Actividad actividad) {
        Curso curso = cursoRepository.findById(cursoId)
                .orElseThrow(() -> new IllegalArgumentException("Curso no encontrado"));

        actividad.setCurso(curso);
        return actividadRepository.save(actividad);
    }

    @Transactional
    public Entrega enviarTarea(String actividadId, Entrega datosEntrega) {

        Actividad actividad = actividadRepository.findById(actividadId)
                .orElseThrow(() -> new RuntimeException("Actividad no encontrada"));

        // 👇 2. BUSCAMOS AL USUARIO COMPLETO EN LA BD 👇
        Usuario estudianteReal = usuarioRepository.findById(datosEntrega.getEstudianteId())
                .orElseThrow(() -> new RuntimeException("Estudiante no encontrado"));

        Entrega nuevaEntrega = new Entrega();

        // Asignamos las relaciones completas y la fecha obligatoria
        nuevaEntrega.setActividad(actividad);
        nuevaEntrega.setEstudiante(estudianteReal);
        nuevaEntrega.setFechaEntrega(LocalDateTime.now()); // Para que no choque con tu nullable = false

        // Asignamos los textos y links
        nuevaEntrega.setComentariosEstudiante(datosEntrega.getComentariosEstudiante());
        nuevaEntrega.setArchivoUrl(datosEntrega.getArchivoUrl());
        nuevaEntrega.setArchivoNombre(datosEntrega.getArchivoNombre());

        return entregaRepository.save(nuevaEntrega);
    }
    @Transactional
    public Actividad actualizarActividad(String id, Actividad nuevosDatos) {
        Actividad act = actividadRepository.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("Actividad no encontrada"));
        act.setTitulo(nuevosDatos.getTitulo());
        act.setDescripcion(nuevosDatos.getDescripcion());
        act.setFechaInicio(nuevosDatos.getFechaInicio());
        act.setFechaTermino(nuevosDatos.getFechaTermino());
        return actividadRepository.save(act);
    }

    @Transactional
    public void eliminarActividad(String id) {
        actividadRepository.deleteById(id);
    }

    @Transactional
    public Entrega calificarTarea(String entregaId, Double calificacion, String retroalimentacion) {
        Entrega entrega = entregaRepository.findById(entregaId)
                .orElseThrow(() -> new IllegalArgumentException("Entrega no encontrada"));

        entrega.setCalificacion(calificacion);
        entrega.setRetroalimentacionProfesor(retroalimentacion);

        return entregaRepository.save(entrega);
    }
}