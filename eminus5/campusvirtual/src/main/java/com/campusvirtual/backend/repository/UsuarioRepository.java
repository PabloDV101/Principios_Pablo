package com.campusvirtual.backend.repository;

import com.campusvirtual.backend.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface UsuarioRepository extends JpaRepository<Usuario, String> {

    // Spring infiere la consulta SQL: SELECT * FROM usuarios WHERE correo = ?
    Optional<Usuario> findByCorreo(String correo);

    boolean existsByCorreo(String correo);
}