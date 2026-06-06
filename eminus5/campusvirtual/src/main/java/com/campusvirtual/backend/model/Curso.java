package com.campusvirtual.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonIgnore;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "cursos")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Curso {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String titulo;

    @Column(columnDefinition = "TEXT")
    private String descripcion;

    @Column(nullable = false)
    private String autor;

    @Column(name = "url_imagen", length = 1000, nullable = false)
    private String urlImagen;

    @Column(nullable = false)
    private double calificacion = 0.0;

    // Las etiquetas pueden ir en una tabla separada automática
    @ElementCollection
    @CollectionTable(name = "curso_etiquetas", joinColumns = @JoinColumn(name = "curso_id"))
    @Column(name = "etiqueta")
    private List<String> etiquetas = new ArrayList<>();

    // Relación N:M para Estudiantes
    @ManyToMany
    @JoinTable(name = "curso_estudiantes", joinColumns = @JoinColumn(name = "curso_id"), inverseJoinColumns = @JoinColumn(name = "usuario_id"))
    @JsonIgnoreProperties({"listaDeseos"}) // Evita el ciclo infinito hacia Usuario
    private List<Usuario> estudiantes = new ArrayList<>();

    // Relación N:M para Profesores
    @ManyToMany
    @JoinTable(name = "curso_profesores", joinColumns = @JoinColumn(name = "curso_id"), inverseJoinColumns = @JoinColumn(name = "usuario_id"))
    @JsonIgnoreProperties({"listaDeseos"})
    private List<Usuario> profesores = new ArrayList<>();

    // Relación 1:N con Actividades (Un curso tiene muchas actividades)
    @OneToMany(mappedBy = "curso", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Actividad> actividades = new ArrayList<>();
    @ElementCollection
    private List<String> usuariosQueCalificaron = new ArrayList<>();

    // Genera el Getter y Setter para esta lista si no usas Lombok
    // Relación 1:N con los mensajes del muro
    @OneToMany(mappedBy = "curso", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<MensajeMuro> mensajes = new ArrayList<>();
}