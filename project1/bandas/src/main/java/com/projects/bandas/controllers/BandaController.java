package com.projects.bandas.controllers;

import com.projects.bandas.models.Banda;
import com.projects.bandas.models.User;
import com.projects.bandas.repository.BandaRepository;
import com.projects.bandas.repository.UserRepository;
import com.projects.bandas.security.SecurityUtils;
import com.projects.bandas.security.services.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@CrossOrigin(origins = "*", allowedHeaders = "*", methods = {RequestMethod.POST, RequestMethod.GET, RequestMethod.OPTIONS})
@RestController
@RequestMapping("/api/bandas")
public class BandaController {

    @Autowired
    BandaRepository bandaRepository;
    @Autowired
    SecurityUtils securityUtils;

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

    @DeleteMapping("/eliminar/{id}")
    @PreAuthorize("hasAnyRole('USER', 'ADMIN')") // Usuarios y Admin pueden intentar borrar
    public ResponseEntity<?> eliminarBanda(@PathVariable Long id) {
        Banda banda = bandaRepository.findById(id).orElseThrow();
        User usuarioLogueado = securityUtils.getUsuarioLogueado();

        // El dueño O el administrador pueden eliminar
        boolean esDuenio = banda.getUsuario().getId().equals(usuarioLogueado.getId());
        boolean esAdmin = usuarioLogueado.getRoles().stream()
                .anyMatch(r -> r.getName().toString().equals("ROLE_ADMIN"));

        if (esDuenio || esAdmin) {
            bandaRepository.delete(banda);
            return ResponseEntity.ok("Banda eliminada exitosamente");
        }

        return ResponseEntity.status(HttpStatus.FORBIDDEN).body("No tienes permiso para eliminar esta banda");
    }
    // BandaController.java
    @GetMapping("/feed")
    public List<Banda> getAllBandas() {
        // Si usas un repositorio, simplemente findAll() debería bastar
        List<Banda> bandas = bandaRepository.findAll();
        return bandas;
    }

}