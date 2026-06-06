package com.campusvirtual.backend.security;

import io.jsonwebtoken.Claims;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureAlgorithm;
import io.jsonwebtoken.security.Keys;
import org.springframework.stereotype.Service;

import java.security.Key;
import java.util.Date;

@Service
public class JwtService {
    // La llave secreta debe ser larga y segura (mínimo 256 bits para HS256)
    private static final String SECRET_KEY = "EstaEsLaClaveSecretaSuperSeguraParaElCampusVirtual0123456789";

    private Key getSigningKey() {
        return Keys.hmacShaKeyFor(SECRET_KEY.getBytes());
    }

    public String generarToken(String correo) {
        return Jwts.builder()
                .setSubject(correo)
                .setIssuedAt(new Date(System.currentTimeMillis()))
                .setExpiration(new Date(System.currentTimeMillis() + 1000 * 60 * 60 * 24 * 7)) // Expira en 7 días
                .signWith(getSigningKey(), SignatureAlgorithm.HS256)
                .compact();
    }

    public String extraerCorreo(String token) {
        return extraerAllClaims(token).getSubject();
    }

    private Claims extraerAllClaims(String token) {
        return Jwts.parserBuilder()
                .setSigningKey(getSigningKey())
                .build()
                .parseClaimsJws(token)
                .getBody();
    }

    public boolean validarToken(String token, String correoUsuario) {
        final String correo = extraerCorreo(token);
        return (correo.equals(correoUsuario) && !isTokenExpirado(token));
    }

    private boolean isTokenExpirado(String token) {
        return extraerAllClaims(token).getExpiration().before(new Date());
    }
}