package com.projects.bandas.repository;

import com.projects.bandas.models.Banda;
import com.projects.bandas.models.Reaccion;
import com.projects.bandas.models.User;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface ReaccionRepository extends JpaRepository<Reaccion,Long> {
    Optional<Reaccion> findByUsuarioAndBanda(User usuario, Banda banda);
}
