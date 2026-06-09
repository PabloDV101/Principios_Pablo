package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.MensajeMuro;
import com.campusvirtual.backend.model.Resena;
import com.campusvirtual.backend.model.Usuario;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class CursoService {

    private final CursoRepository cursoRepository;
    private final UsuarioRepository usuarioRepository;

    public List<Curso> obtenerCatalogoCompleto() {
        return cursoRepository.findAll();
    }

    public List<Curso> obtenerCursosAprendizaje(String estudianteId) {
        return cursoRepository.findByEstudiantesId(estudianteId);
    }

    public List<Curso> obtenerCursosEnsenanza(String profesorId) {
        return cursoRepository.findByProfesoresId(profesorId);
    }

    @Transactional
    public Curso crearCurso(Curso curso, String creadorId) {
        Usuario creador = usuarioRepository.findById(creadorId)
                .orElseThrow(() -> new IllegalArgumentException("Usuario creador no encontrado"));

        // ¡Validación de seguridad defensiva!
        // Si el JSON no incluyó la lista y llegó nula, la inicializamos vacía.
        if (curso.getProfesores() == null) {
            curso.setProfesores(new ArrayList<>());
        }

        // El que crea el curso se asigna automáticamente como profesor
        curso.getProfesores().add(creador);

        // El autor visible en la tarjeta será el nombre del creador
        curso.setAutor(creador.getNombre());

        return cursoRepository.save(curso);
    }

    @Transactional
    public Curso inscribirEstudiante(String cursoId, String estudianteId) {
        Curso curso = cursoRepository.findById(cursoId)
                .orElseThrow(() -> new IllegalArgumentException("Curso no encontrado"));
        Usuario estudiante = usuarioRepository.findById(estudianteId)
                .orElseThrow(() -> new IllegalArgumentException("Estudiante no encontrado"));

        // Evitar dobles inscripciones y evitar que el creador se inscriba como estudiante
        if (!curso.getEstudiantes().contains(estudiante) && !curso.getProfesores().contains(estudiante)) {
            curso.getEstudiantes().add(estudiante);
            cursoRepository.save(curso);
        }

        return curso;
    }

    public Curso agregarMensaje(String cursoId, MensajeMuro mensajeRecibido) {
        Curso curso = cursoRepository.findById(cursoId).orElseThrow();

        // Aquí es donde está el problema.
        // Seguramente estás copiando los datos, PERO te faltan los nuevos:
        MensajeMuro nuevoMensaje = new MensajeMuro();
        nuevoMensaje.setRemitente(mensajeRecibido.getRemitente());
        nuevoMensaje.setRol(mensajeRecibido.getRol());
        nuevoMensaje.setMensaje(mensajeRecibido.getMensaje());
        nuevoMensaje.setFecha(java.time.LocalDateTime.now());

        // 👉 ¡AÑADE ESTAS DOS LÍNEAS AQUÍ! 👈
        nuevoMensaje.setUsuarioId(mensajeRecibido.getUsuarioId());
        nuevoMensaje.setFotoUrl(mensajeRecibido.getFotoUrl());
        nuevoMensaje.setCurso(curso);

        // Esta es tu línea 83 que está fallando:
        curso.getMensajes().add(nuevoMensaje);
        return cursoRepository.save(curso);
    }
    public Curso calificarCurso(String id, Resena nuevaResena) {
        Curso curso = cursoRepository.findById(id).orElseThrow(() -> new RuntimeException("Curso no encontrado"));

        // 1. ELIMINAMOS la restricción de que el creador no pueda calificar (si quieres permitirlo)
        // Solo validamos que un mismo usuario no deje dos reseñas en el mismo curso
        if (curso.getUsuariosQueCalificaron().contains(nuevaResena.getUsuarioId())) {
            throw new RuntimeException("Ya has calificado este curso");
        }

        // 2. CORRECCIÓN DEL PROMEDIO:
        // Si es la primera, es la nota. Si ya hay notas, calculamos promedio ponderado.
        double totalResenas = curso.getResenas().size();
        if (totalResenas == 0) {
            curso.setCalificacion(nuevaResena.getEstrellas());
        } else {
            // Promedio ponderado real: (Suma actual + Nueva nota) / (Cantidad total de notas)
            double sumaActual = curso.getCalificacion() * totalResenas;
            double nuevoPromedio = (sumaActual + nuevaResena.getEstrellas()) / (totalResenas + 1);
            curso.setCalificacion(nuevoPromedio);
        }

        curso.getUsuariosQueCalificaron().add(nuevaResena.getUsuarioId());
        curso.getResenas().add(nuevaResena);

        return cursoRepository.save(curso);
    }
}