package com.campusvirtual.backend.model;

import com.fasterxml.jackson.annotation.JsonProperty;
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

    @Column(name = "usuario_id", nullable = false)
    private String usuarioId;

    @Column(name = "foto_url")
    private String fotoUrl;

    private int reacciones = 0;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "curso_id", nullable = false)
    @JsonIgnore
    private Curso curso;

    // ... tus otras variables y anotaciones ...

    // Pega esto al final de tu clase MensajeMuro:

    @com.fasterxml.jackson.annotation.JsonProperty("usuarioId")
    public void setUsuarioId(String usuarioId) {
        this.usuarioId = usuarioId;
    }

    @com.fasterxml.jackson.annotation.JsonProperty("fotoUrl")
    public void setFotoUrl(String fotoUrl) {
        this.fotoUrl = fotoUrl;
    }
}