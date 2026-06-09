package com.campusvirtual.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.Data;

@Data
@Entity
@Table(name = "materiales")
public class Material {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    private String titulo;
    private String tipo; // Puede ser: "VIDEO", "PDF", "DOCUMENTO", "IMAGEN"
    private String url;  // El enlace de Cloudinary o de YouTube
    private Integer orden;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seccion_id")
    @JsonIgnore
    private Seccion seccion;
}