package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.Usuario;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UsuarioService {

    private final UsuarioRepository usuarioRepository;
    private final CursoRepository cursoRepository;

    @Transactional
    public Usuario registrarUsuario(Usuario usuario) {
        if (usuarioRepository.existsByCorreo(usuario.getCorreo())) {
            throw new IllegalArgumentException("El correo ya se encuentra registrado.");
        }
        return usuarioRepository.save(usuario);
    }

    public Usuario login(String correo, String password) {
        // En la Etapa 2 real se validaría el hash de la contraseña con Spring Security
        Optional<Usuario> usuario = usuarioRepository.findByCorreo(correo);
        if (usuario.isPresent()) {
            return usuario.get();
        }
        throw new IllegalArgumentException("Usuario no encontrado.");
    }

    // En tu UsuarioService.java
    @Transactional
    public Usuario toggleListaDeseos(String usuarioId, String cursoId) {
        Usuario usuario = usuarioRepository.findById(usuarioId).orElseThrow();
        Curso curso = cursoRepository.findById(cursoId).orElseThrow();

        if (usuario.getListaDeseos().contains(curso)) {
            usuario.getListaDeseos().remove(curso); // Quita
        } else {
            usuario.getListaDeseos().add(curso);    // Agrega
        }
        return usuarioRepository.save(usuario);
    }
    public Usuario actualizarPerfil(String id, Usuario datosNuevos) {
        Usuario usuario = usuarioRepository.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuario.setFotoUrl(datosNuevos.getFotoUrl());
        usuario.setProfesion(datosNuevos.getProfesion());
        usuario.setDescripcion(datosNuevos.getDescripcion());

        return usuarioRepository.save(usuario);
    }

    public List<String> obtenerIdsDeseos(String usuarioId) {
        Usuario usuario = usuarioRepository.findById(usuarioId).orElseThrow();
        System.out.println("Usuario encontrado: " + usuario.getNombre());
        System.out.println("Cursos en lista de deseos: " + usuario.getListaDeseos().size());
        return usuario.getListaDeseos().stream().map(Curso::getId).collect(Collectors.toList());
    }
}