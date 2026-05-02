package com.projects.bandas.models;

import java.time.LocalDateTime;

// ComentarioDTO.java
public record ComentarioDTO(Long id, String texto, String username, LocalDateTime fechaCreacion) {
}
