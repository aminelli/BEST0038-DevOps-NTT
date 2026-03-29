# ============================================================================
# Multi-stage Dockerfile per applicazione Spring Boot
# ============================================================================

# ============================================================================
# Stage 1: Build
# ============================================================================
FROM eclipse-temurin:21-jdk-jammy AS builder

# Metadata
LABEL stage=builder
LABEL description="Build stage per compilare l'applicazione Spring Boot"

# Crea directory di lavoro
WORKDIR /app

# Copia i file Maven wrapper e pom.xml per il caching delle dipendenze
COPY .mvn/ .mvn/
COPY mvnw pom.xml ./

# Converti line endings per compatibilità (se necessario)
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw

# Scarica le dipendenze (layer separato per caching)
RUN ./mvnw dependency:go-offline -B

# Copia il codice sorgente
COPY src/ ./src/

# Compila l'applicazione (salta i test per velocizzare la build)
# Il JAR verrà creato in target/corsontt38-0.0.1-SNAPSHOT.jar
RUN ./mvnw clean package -DskipTests -B

# Verifica che il JAR sia stato creato
RUN ls -la target/ && \
    test -f target/corsontt38-0.0.1-SNAPSHOT.jar || \
    (echo "ERROR: JAR file not found!" && exit 1)

# ============================================================================
# Stage 2: Runtime
# ============================================================================
FROM eclipse-temurin:21-jre-jammy AS runtime

# Metadata
LABEL maintainer="Corso NTT DevOps"
LABEL description="Applicazione Spring Boot containerizzata"
LABEL version="0.0.1-SNAPSHOT"

# Crea utente non-root per sicurezza
RUN groupadd -r spring && useradd -r -g spring spring

# Crea directory di lavoro
WORKDIR /app

# Copia il JAR compilato dallo stage di build
COPY --from=builder /app/target/corsontt38-0.0.1-SNAPSHOT.jar app.jar

# Cambia ownership della directory
RUN chown -R spring:spring /app

RUN apt-get update && apt-get install -y htop net-tools iputils-ping

# Cambia all'utente non-root
USER spring:spring

# Esponi la porta dell'applicazione (default Spring Boot: 8080)
EXPOSE 8080

# Variabili d'ambiente di default (possono essere sovrascritte)
ENV JAVA_OPTS="-Xms256m -Xmx512m" \
    SPRING_PROFILES_ACTIVE="prod"

# Health check per Docker/Kubernetes
HEALTHCHECK --interval=30s --timeout=3s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Comando di avvio con parametri ottimizzati per container
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -Djava.security.egd=file:/dev/./urandom -jar /app/app.jar"]
