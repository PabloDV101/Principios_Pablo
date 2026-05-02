package com.projects.bandas.security.jwt;

import com.projects.bandas.security.services.UserDetailsImpl;
import io.jsonwebtoken.*;
import io.jsonwebtoken.security.Keys;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.stereotype.Component;

import java.security.Key;
import java.util.Date;
import java.util.List;
import java.util.stream.Collectors;

@Component
public class JwtUtils {
  private static final Logger logger = LoggerFactory.getLogger(JwtUtils.class);

  @Value("${pablo.app.jwtSecret}")
  private String jwtSecret;

  @Value("${pablo.app.jwtExpirationMs}")
  private int jwtExpirationMs;

  // Creamos la llave de firma a partir del string secreto
  private Key getSigningKey() {
    return Keys.hmacShaKeyFor(jwtSecret.getBytes());
  }

  // 1. Generar el Token
  public String generateJwtToken(Authentication authentication) {
    UserDetailsImpl userPrincipal = (UserDetailsImpl) authentication.getPrincipal();

    // 1. EXTRAER ROLES: Aquí obtenemos la lista de roles del usuario logueado
    List<String> roles = userPrincipal.getAuthorities().stream()
            .map(GrantedAuthority::getAuthority)
            .collect(Collectors.toList());

    // 2. CONSTRUIR TOKEN CON ROLES: Aquí incluimos la lista en el payload del JWT
    return Jwts.builder()
            .setSubject(userPrincipal.getUsername())
            .claim("roles", roles) // <--- ¡Esta línea es la que falta en tu backend!
            .setIssuedAt(new Date())
            .setExpiration(new Date((new Date()).getTime() + jwtExpirationMs))
            .signWith(getSigningKey(), SignatureAlgorithm.HS256)
            .compact();
  }

  // 2. Extraer el nombre de usuario del Token
  public String getUserNameFromJwtToken(String token) {
    return Jwts.parserBuilder()
            .setSigningKey(getSigningKey())
            .build()
            .parseClaimsJws(token)
            .getBody()
            .getSubject();
  }

  // 3. Validar si el Token es legítimo
  public boolean validateJwtToken(String authToken) {
    try {
      Jwts.parserBuilder().setSigningKey(getSigningKey()).build().parseClaimsJws(authToken);
      return true;
    } catch (SecurityException e) {
      logger.error("Firma JWT inválida: {}", e.getMessage());
    } catch (MalformedJwtException e) {
      logger.error("Token JWT mal formado: {}", e.getMessage());
    } catch (ExpiredJwtException e) {
      logger.error("El token JWT ha expirado: {}", e.getMessage());
    } catch (UnsupportedJwtException e) {
      logger.error("Token JWT no soportado: {}", e.getMessage());
    } catch (IllegalArgumentException e) {
      logger.error("La cadena claims de JWT está vacía: {}", e.getMessage());
    }
    return false;
  }
}