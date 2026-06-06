FROM eclipse-temurin:21-jdk-alpine
WORKDIR /app

# Asegúrate de cambiar "campusvirtual" por el nombre exacto que genera tu carpeta target/
COPY target/campusvirtual-0.0.1-SNAPSHOT.jar app.jar

ENTRYPOINT ["sh", "-c", "java -Dserver.port=${PORT:-8080} -jar app.jar"]
