FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app
# Copia el JAR principal (omitiendo el que termina en -plain.jar)
COPY target/bandas-0.0.1-SNAPSHOT.jar app.jar
# Usa un comando de shell para que la variable ${PORT} se expanda correctamente
ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8080} -jar app.jar"]
