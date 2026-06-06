package com.campusvirtual.backend.controller;

import com.campusvirtual.backend.model.Usuario;
import com.campusvirtual.backend.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import com.campusvirtual.backend.model.AuthResponse;
import com.campusvirtual.backend.security.JwtService;

@RestController
@RequestMapping("/api/usuarios")
@CrossOrigin(origins = "*")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final JwtService jwtService; // Inyectamos el servicio JWT

    @PostMapping("/registro")
    public ResponseEntity<AuthResponse> registrar(@RequestBody Usuario usuario) {
        Usuario usuarioGuardado = usuarioService.registrarUsuario(usuario);
        String token = jwtService.generarToken(usuarioGuardado.getCorreo());
        return ResponseEntity.ok(new AuthResponse(usuarioGuardado, token));
    }

    @PostMapping("/login")
    public ResponseEntity<AuthResponse> login(@RequestParam String correo, @RequestParam String password) {
        Usuario usuarioValidado = usuarioService.login(correo, password);
        String token = jwtService.generarToken(usuarioValidado.getCorreo());
        return ResponseEntity.ok(new AuthResponse(usuarioValidado, token));
    }

    @PostMapping("/{usuarioId}/deseos/{cursoId}")
    public ResponseEntity<Usuario> toggleDeseos(@PathVariable String usuarioId, @PathVariable String cursoId) {
        return ResponseEntity.ok(usuarioService.toggleListaDeseos(usuarioId, cursoId));
    }
}