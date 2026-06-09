package com.projects.bandas.security;

import com.projects.bandas.models.ERole;
import com.projects.bandas.models.Role;
import com.projects.bandas.models.User;
import com.projects.bandas.repository.RoleRepository;
import com.projects.bandas.repository.UserRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

import java.util.HashSet;
import java.util.Set;

@Component
public class DataInitializer implements CommandLineRunner {

    @Autowired
    private RoleRepository roleRepository;
    @Autowired
    private UserRepository userRepository;
    @Autowired
    private PasswordEncoder encoder;

    @Override
    public void run(String... args) throws Exception {
        // 1. Crear roles si no existen
        Role userRole = roleRepository.findByName(ERole.ROLE_USER)
                .orElseGet(() -> roleRepository.save(new Role(ERole.ROLE_USER)));

        Role adminRole = roleRepository.findByName(ERole.ROLE_ADMIN)
                .orElseGet(() -> roleRepository.save(new Role(ERole.ROLE_ADMIN)));

        // 2. Crear un Admin por defecto si no existe
        if (!userRepository.existsByUsername("admin")) {
            User admin = new User("admin", "admin@tuapp.com", encoder.encode("12345678"));
            Set<Role> roles = new HashSet<>();
            roles.add(adminRole);
            admin.setRoles(roles);
            userRepository.save(admin);
            System.out.println("Usuario Administrador creado.");
        }
    }
}