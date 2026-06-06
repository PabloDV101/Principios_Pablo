package com.campusvirtual.backend.service;

import com.campusvirtual.backend.model.Curso;
import com.campusvirtual.backend.model.Usuario;
import com.campusvirtual.backend.repository.CursoRepository;
import com.campusvirtual.backend.repository.UsuarioRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

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

    @Transactional
    public Usuario toggleListaDeseos(String usuarioId, String cursoId) {
        Usuario usuario = usuarioRepository.findById(usuarioId)
                .orElseThrow(() -> new IllegalArgumentException("Usuario no encontrado"));
        Curso curso = cursoRepository.findById(cursoId)
                .orElseThrow(() -> new IllegalArgumentException("Curso no encontrado"));

        // Si ya está en deseos, lo quitamos; si no, lo agregamos
        if (usuario.getListaDeseos().contains(curso)) {
            usuario.getListaDeseos().remove(curso);
        } else {
            usuario.getListaDeseos().add(curso);
        }

        return usuarioRepository.save(usuario);
    }
}