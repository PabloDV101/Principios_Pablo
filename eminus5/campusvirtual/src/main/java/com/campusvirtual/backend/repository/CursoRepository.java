package com.campusvirtual.backend.repository;

import com.campusvirtual.backend.model.Curso;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface CursoRepository extends JpaRepository<Curso, String> {

    // Para la pestaña "Mis Cursos -> Aprendizaje"
    List<Curso> findByEstudiantesId(String estudianteId);

    // Para la pestaña "Mis Cursos -> Enseñanza"
    List<Curso> findByProfesoresId(String profesorId);
}