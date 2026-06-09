package com.campusvirtual.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "usuarios")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Usuario {

    @Id
    // Generación de ID automático (UUID o secuencia, aquí usaremos UUID por seguridad)
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String nombre;

    @Column(nullable = false, unique = true)
    private String correo;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private RolGlobal rolGlobal = RolGlobal.USUARIO;

    // Añade esto debajo de tus otras variables (nombre, correo, rol, etc.)
    @Column(name = "foto_url", length = 1000)
    private String fotoUrl;

    @Column(length = 100)
    private String profesion;

    @Column(length = 500)
    private String descripcion;

    // Relación para la lista de deseos
    @ManyToMany
    @JoinTable(name = "lista_deseos", joinColumns = @JoinColumn(name = "usuario_id"), inverseJoinColumns = @JoinColumn(name = "curso_id"))
    @JsonIgnoreProperties({"estudiantes", "profesores", "actividades", "mensajes"})
    private List<Curso> listaDeseos = new ArrayList<>();
}