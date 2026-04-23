package com.projects.bandas.repository;

import com.projects.bandas.models.Band;
import com.projects.bandas.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface BandRepository extends JpaRepository<Band, Long> {
    // Para obtener todas las bandas de un usuario específico
    List<Band> findByCreatedBy(User user);
    
    // Búsqueda rápida por nombre si la necesitas después
    List<Band> findByNameContainingIgnoreCase(String name);
}