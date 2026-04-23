# Cambiamos de 17-jdk-alpine a 21-jdk-alpine
FROM eclipse-temurin:21-jdk-alpine

# El resto se queda igual
COPY target/*.jar app.jar
EXPOSE 8080
# Agregamos los límites de memoria que te sugerí antes para que no truene en el plan Free
ENTRYPOINT ["java", "-Xmx256m", "-Xss512k", "-jar", "/app.jar"]
