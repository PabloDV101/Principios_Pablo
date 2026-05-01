package com.projects.bandas.repository;

import com.projects.bandas.models.Banda;
import com.projects.bandas.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BandaRepository extends JpaRepository<Banda, Long> {
    // Para buscar todas las bandas de un usuario específico
    List<Banda> findByUsuario(User usuario);
}