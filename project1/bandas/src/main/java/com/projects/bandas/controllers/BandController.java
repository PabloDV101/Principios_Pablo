package com.projects.bandas.controllers;

import com.projects.bandas.models.*;
import com.projects.bandas.repository.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@CrossOrigin(origins = "*", maxAge = 3600)
@RestController
@RequestMapping("/api/bands")
public class BandController {

    @Autowired
    private BandRepository bandRepository;

    @Autowired
    private UserRepository userRepository;

    @GetMapping
    public List<Band> getAllBands() {
        return bandRepository.findAll();
    }

    @PostMapping
    public Band createBand(@RequestBody Band band) {
        // Obtenemos el username del token actual
        String username = SecurityContextHolder.getContext().getAuthentication().getName();
        
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("Error: Usuario no encontrado"));

        band.setCreatedBy(user); // Asignamos el dueño de la banda
        return bandRepository.save(band);
    }

    @DeleteMapping("/{id}")
    public void deleteBand(@PathVariable Long id) {
        bandRepository.deleteById(id);
    }
}
