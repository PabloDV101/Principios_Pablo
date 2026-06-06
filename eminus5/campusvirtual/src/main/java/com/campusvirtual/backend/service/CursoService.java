package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.MensajeMuro;
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

    @Transactional
    public MensajeMuro agregarMensaje(String cursoId, MensajeMuro mensaje) {
        Curso curso = cursoRepository.findById(cursoId)
                .orElseThrow(() -> new IllegalArgumentException("Curso no encontrado"));

        mensaje.setCurso(curso);
        mensaje.setFecha(LocalDateTime.now());
        curso.getMensajes().add(mensaje); // Lo añadimos a la lista del curso

        cursoRepository.save(curso);
        return mensaje;
    }
    public Curso calificarCurso(String id, double estrellas, String usuarioId) {
        Curso curso = cursoRepository.findById(id).orElseThrow(() -> new RuntimeException("Curso no encontrado"));

        // Validamos que no haya votado antes
        if (curso.getUsuariosQueCalificaron().contains(usuarioId)) {
            throw new RuntimeException("El usuario ya calificó este curso");
        }

        if (curso.getCalificacion() == 0.0) {
            curso.setCalificacion(estrellas);
        } else {
            curso.setCalificacion((curso.getCalificacion() + estrellas) / 2.0);
        }

        // Registramos al usuario
        curso.getUsuariosQueCalificaron().add(usuarioId);
        return cursoRepository.save(curso);
    }
}