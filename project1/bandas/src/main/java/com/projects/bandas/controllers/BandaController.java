package com.projects.bandas.controllers;

import com.projects.bandas.models.Banda;
import com.projects.bandas.models.User;
import com.projects.bandas.repository.BandaRepository;
import com.projects.bandas.repository.UserRepository;
import com.projects.bandas.security.services.UserDetailsImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
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
}