package com.campusvirtual.backend.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import com.fasterxml.jackson.annotation.JsonIgnore;
import java.time.LocalDateTime;

@Entity
@Table(name = "mensajes_muro")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class MensajeMuro {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private String remitente;

    @Column(nullable = false)
    private String rol;

    @Column(columnDefinition = "TEXT", nullable = false)
    private String mensaje;

    @Column(nullable = false)
    private LocalDateTime fecha;

    private int reacciones = 0;



    // (En ambas clases, ve a la relación de "Curso" y añade @JsonIgnore)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curso_id", nullable = false)
    @JsonIgnore // Un mensaje o actividad no necesita imprimir todo el curso de vuelta
    private Curso curso;
}