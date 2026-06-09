package com.campusvirtual.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;
import java.util.ArrayList;
import java.util.List;

@Data
@Entity
@Table(name = "secciones")
public class Seccion {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String titulo;
    private Integer orden; // Para saber qué sección va primero

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curso_id")
    @JsonIgnore // Evita ciclos infinitos al serializar
    private Curso curso;

    @OneToMany(mappedBy = "seccion", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("orden ASC") // Ordena los materiales automáticamente
    private List<Material> materiales = new ArrayList<>();
}