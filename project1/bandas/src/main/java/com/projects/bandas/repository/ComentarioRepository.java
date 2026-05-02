package com.projects.bandas.repository;

import com.projects.bandas.models.Banda;
import com.projects.bandas.models.Comentario;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ComentarioRepository extends JpaRepository<Comentario,Long> {
    List<Comentario> findByBandaId(Long bandaId);
}
