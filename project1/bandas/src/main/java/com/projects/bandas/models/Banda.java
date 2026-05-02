package com.projects.bandas.models;

import jakarta.persistence.*;
import jakarta.validation.constraints.NotBlank;
import org.hibernate.annotations.Formula;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "bandas")
public class Banda {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @NotBlank
    private String nombre;

    private String descripcion;

    @Column(name = "fecha_creacion")
    private LocalDateTime fechaCreacion;

    @Column(name = "url_imagen") // Aquí guardaremos la URL de Cloudinary
    private String urlImagen;

    // Relación: Muchas bandas pueden ser publicadas por un mismo usuario
    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private User usuario;

    // Se ejecuta automáticamente antes de insertar en la DB
    @PrePersist
    protected void onCreate() {
        this.fechaCreacion = LocalDateTime.now();
    }

    public Banda() {}

    @OneToMany(mappedBy = "banda", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Comentario> comentarios = new ArrayList<>();

    @OneToMany(mappedBy = "banda", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Reaccion> reacciones = new ArrayList<>();

    @Formula("(SELECT count(*) FROM reacciones r WHERE r.banda_id = id AND r.tipo = 'LIKE')")
    private int likesCount;

    @Formula("(SELECT count(*) FROM reacciones r WHERE r.banda_id = id AND r.tipo = 'DISLIKE')")
    private int dislikesCount;

    // ¡Solo necesitas getters! (No setters)
    public int getLikesCount() { return likesCount; }
    public int getDislikesCount() { return dislikesCount; }

    // Getters y Setters
    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }
    public String getNombre() { return nombre; }
    public void setNombre(String nombre) { this.nombre = nombre; }
    public String getDescripcion() { return descripcion; }
    public void setDescripcion(String descripcion) { this.descripcion = descripcion; }
    public LocalDateTime getFechaCreacion() { return fechaCreacion; }
    public void setFechaCreacion(LocalDateTime fechaCreacion) { this.fechaCreacion = fechaCreacion; }
    public String getUrlImagen() { return urlImagen; }
    public void setUrlImagen(String urlImagen) { this.urlImagen = urlImagen; }
    public User getUsuario() { return usuario; }
    public void setUsuario(User usuario) { this.usuario = usuario; }
}