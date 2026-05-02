package com.projects.bandas.controllers;


import com.projects.bandas.models.*;
import com.projects.bandas.repository.*;
import com.projects.bandas.security.SecurityUtils;
import com.projects.bandas.security.services.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/api/bandas/{bandaId}")
public class InteractionController {

    @Autowired
    private BandaRepository bandaRepository;
    @Autowired
    private ComentarioRepository comentarioRepository;
    @Autowired
    private ReaccionRepository reaccionRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private SecurityUtils securityUtils;

    // --- COMENTARIOS ---

    // 1. Crea esta clase DTO sencilla si no la tienes
    public record ComentarioRequest(String texto) {}

    // 2. Modifica el método para recibir el objeto, no un String
    @PostMapping("/comentar")
    public Comentario agregarComentario(@PathVariable Long bandaId, @RequestBody ComentarioRequest request) {
        Banda banda = bandaRepository.findById(bandaId).orElseThrow();
        User user = securityUtils.getUsuarioLogueado();

        Comentario comentario = new Comentario();
        // AQUÍ ESTÁ LA CLAVE: Accedes al valor limpio
        comentario.setTexto(request.texto());
        comentario.setUsuario(user);
        comentario.setBanda(banda);
        comentario.setFecha(LocalDateTime.now());

        return comentarioRepository.save(comentario);
    }

    // --- REACCIONES ---

    @PostMapping("/reaccionar")
    public Reaccion reaccionar(@PathVariable Long bandaId, @RequestParam TipoReaccion tipo) {
        Banda banda = bandaRepository.findById(bandaId).orElseThrow();
        User user = securityUtils.getUsuarioLogueado();

        Reaccion reaccion = reaccionRepository.findByUsuarioAndBanda(user, banda)
                .orElse(new Reaccion());

        reaccion.setUsuario(user);
        reaccion.setBanda(banda);
        reaccion.setTipo(tipo);

        return reaccionRepository.save(reaccion);
    }
    @GetMapping("/comentarios")
    public ResponseEntity<List<ComentarioDTO>> getComentarios(@PathVariable Long bandaId) {
        List<Comentario> comentarios = comentarioRepository.findByBandaId(bandaId);

        // Mapeamos a un DTO para no exponer campos sensibles o relaciones infinitas
        List<ComentarioDTO> comentariosDTO = comentarios.stream()
                .map(c -> new ComentarioDTO(c.getId(), c.getTexto(), c.getUsuario().getUsername(), c.getFechaCreacion()))
                .collect(Collectors.toList());

        return ResponseEntity.ok(comentariosDTO);
    }


}