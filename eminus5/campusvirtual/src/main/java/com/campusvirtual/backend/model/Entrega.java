package com.campusvirtual.backend.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Entity
@Table(name = "entregas")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Entrega {

    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private String id;

    @Column(nullable = false)
    private LocalDateTime fechaEntrega;

    @Column(columnDefinition = "TEXT")
    private String comentariosEstudiante;

    private Double calificacion;

    @Column(columnDefinition = "TEXT")
    private String retroalimentacionProfesor;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "actividad_id", nullable = false)
    @JsonIgnore
    private Actividad actividad;

    // N:1 Una entrega pertenece a un Estudiante (Usuario)
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "usuario_id", nullable = false)
    private Usuario estudiante;
}