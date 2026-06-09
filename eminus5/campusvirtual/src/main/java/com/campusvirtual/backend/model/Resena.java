package com.campusvirtual.backend.model;

import jakarta.persistence.Embeddable;

@Embeddable
public class Resena {
    private String usuarioId;
    private String nombreUsuario;
    private String fotoUrl;
    private double estrellas;
    private String comentario;
    private String fecha;

    // Genera aquí tus Getters y Setters (o usa @Data de Lombok)
    public String getUsuarioId() { return usuarioId; }
    public void setUsuarioId(String usuarioId) { this.usuarioId = usuarioId; }
    public String getNombreUsuario() { return nombreUsuario; }
    public void setNombreUsuario(String nombreUsuario) { this.nombreUsuario = nombreUsuario; }
    public String getFotoUrl() { return fotoUrl; }
    public void setFotoUrl(String fotoUrl) { this.fotoUrl = fotoUrl; }
    public double getEstrellas() { return estrellas; }
    public void setEstrellas(double estrellas) { this.estrellas = estrellas; }
    public String getComentario() { return comentario; }
    public void setComentario(String comentario) { this.comentario = comentario; }
    public String getFecha() { return fecha; }
    public void setFecha(String fecha) { this.fecha = fecha; }
}
