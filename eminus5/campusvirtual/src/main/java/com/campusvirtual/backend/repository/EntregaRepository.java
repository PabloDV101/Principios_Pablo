package com.campusvirtual.backend.repository;

import com.campusvirtual.backend.model.Entrega;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface EntregaRepository extends JpaRepository<Entrega, String> {

    // Para saber si un alumno específico ya entregó una actividad específica
    Optional<Entrega> findByActividadIdAndEstudianteId(String actividadId, String estudianteId);

    // Para que el profesor vea todas las entregas de una actividad
    List<Entrega> findByActividadId(String actividadId);
}