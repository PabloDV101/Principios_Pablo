package com.projects.bandas.repository;

import com.projects.bandas.models.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long> {
  Optional<User> findByUsername(String username);

  // Estos sirven para validar si el nombre o correo ya existen al registrarse
  Boolean existsByUsername(String username);
  Boolean existsByEmail(String email);
}