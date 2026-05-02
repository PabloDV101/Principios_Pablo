package com.projects.bandas.controllers;

import com.projects.bandas.models.*;
import com.projects.bandas.repository.BandaRepository;
import com.projects.bandas.repository.UserRepository;
import com.projects.bandas.repository.ReaccionRepository;
import com.projects.bandas.security.SecurityUtils;
import com.projects.bandas.security.services.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;

@RestController
@RequestMapping("/api/bandas")
public class BandaController {

    @Autowired
    BandaRepository bandaRepository;
    @Autowired
    SecurityUtils securityUtils;
    @Autowired
    ReaccionRepository reaccionRepository;

    @Autowired
    UserRepository userRepository;

    @GetMapping("/mis-bandas")
    public List<Banda> getMisBandas() {
        // Obtenemos al usuario autenticado desde el contexto de seguridad
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();

        User user = userRepository.findById(userDetails.getId()).get();
        return bandaRepository.findByUsuario(user);
    }

    @PostMapping("")
    public Banda createBanda(@RequestBody Banda banda) {
        UserDetailsImpl userDetails = (UserDetailsImpl) SecurityContextHolder.getContext()
                .getAuthentication().getPrincipal();

        User user = userRepository.findById(userDetails.getId()).get();
        banda.setUsuario(user); // Vinculamos la banda al usuario logueado

        return bandaRepository.save(banda);
    }

    @GetMapping("/todas")
    public List<Banda> getTodas() {
        return bandaRepository.findAll();
    }

    @PostMapping("/editar/{id}")
    @PreAuthorize("hasRole('USER')") // Solo usuarios registrados
    public ResponseEntity<?> editarBanda(@PathVariable Long id, @RequestBody Banda nuevaBanda) {
        Banda bandaExistente = bandaRepository.findById(id).orElseThrow();
        User usuarioLogueado = securityUtils.getUsuarioLogueado();

        // Solo el dueño puede editar
        if (!bandaExistente.getUsuario().getId().equals(usuarioLogueado.getId())) {
            return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No puedes editar bandas ajenas");
        }

        bandaExistente.setNombre(nuevaBanda.getNombre());
        bandaExistente.setDescripcion(nuevaBanda.getDescripcion());
        bandaExistente.setUrlImagen(nuevaBanda.getUrlImagen());

        return ResponseEntity.ok(bandaRepository.save(bandaExistente));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('USER') or hasRole('ADMIN')")
    public ResponseEntity<?> eliminarBanda(@PathVariable Long id) {
        // ESTO VA A IMPRIMIR EN LA CONSOLA DE TU SERVIDOR JAVA
        var authentication = SecurityContextHolder.getContext().getAuthentication();
        System.out.println("--- DEBUG SEGURIDAD ---");
        System.out.println("Usuario: " + authentication.getName());
        System.out.println("Roles: " + authentication.getAuthorities());
        System.out.println("¿Es autenticado?: " + authentication.isAuthenticated());

        Banda banda = bandaRepository.findById(id).orElseThrow();
        User usuarioLogueado = securityUtils.getUsuarioLogueado();

        // NUEVA LÓGICA: Comprobamos si tiene el rol de ADMIN en la lista de roles
        boolean esAdmin = usuarioLogueado.getRoles().stream()
                .anyMatch(r -> r.getName() == ERole.ROLE_ADMIN);

        boolean esDuenio = banda.getUsuario().getId().equals(usuarioLogueado.getId());

        if (esDuenio || esAdmin) {
            bandaRepository.delete(banda);
            return ResponseEntity.ok().build();
        }
        return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
    }
    // BandaController.java
    @GetMapping("/feed")
    public List<Banda> getAllBandas() {
        List<Banda> bandas = bandaRepository.findAllWithReacciones();
        User usuarioLogueado = securityUtils.getUsuarioLogueado();

        for (Banda b : bandas) {
            // Importante: Asegúrate de que reaccionRepository esté funcionando bien
            b.setDioLike(reaccionRepository.existsByUsuarioAndBandaAndTipo(usuarioLogueado, b, TipoReaccion.LIKE));
            b.setDioDislike(reaccionRepository.existsByUsuarioAndBandaAndTipo(usuarioLogueado, b, TipoReaccion.DISLIKE));
        }
        return bandas;
    }

}