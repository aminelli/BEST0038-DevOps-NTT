# 🐳 Guida Docker - Containerizzazione Applicazione Spring Boot

Questa guida descrive come containerizzare e gestire l'applicazione Spring Boot utilizzando Docker.

## 📋 File Creati

- **`Dockerfile`** - Multi-stage build per ottimizzare l'immagine
- **`.dockerignore`** - File da escludere dalla build
- **`docker-compose.yml`** - Orchestrazione per sviluppo locale
- **`scripts/docker-build.ps1`** - Script PowerShell per gestire Docker

## 🚀 Quick Start

### Opzione 1: Usando lo Script PowerShell (Consigliato)

```powershell
# 1. Build dell'immagine Docker
.\scripts\docker-build.ps1 -Action build

# 2. Avvia il container
.\scripts\docker-build.ps1 -Action run

# 3. Verifica che l'applicazione sia pronta
.\scripts\docker-build.ps1 -Action test

# 4. Visualizza i logs
.\scripts\docker-build.ps1 -Action logs -Follow
```

### Opzione 2: Usando Docker Compose

```powershell
# Avvia tutti i servizi
.\scripts\docker-build.ps1 -Action compose-up

# Arresta tutti i servizi
.\scripts\docker-build.ps1 -Action compose-down
```

### Opzione 3: Comandi Docker Manuali

```powershell
# Build
docker build -t corsontt38:latest .

# Run
docker run -d --name corsontt38-app -p 8080:8080 corsontt38:latest

# Logs
docker logs -f corsontt38-app

# Stop
docker stop corsontt38-app

# Remove
docker rm corsontt38-app
```

## 📦 Dettagli del Dockerfile

### Stage 1: Build
- **Base Image**: `eclipse-temurin:21-jdk-jammy`
- **Funzione**: Compila l'applicazione usando Maven
- **Output**: JAR file in `/app/target/`

### Stage 2: Runtime
- **Base Image**: `eclipse-temurin:21-jre-jammy` (più leggero, solo JRE)
- **Funzione**: Esegue l'applicazione
- **Sicurezza**: Usa utente non-root (`spring:spring`)
- **Port**: 8080
- **Health Check**: Endpoint `/actuator/health`

## 🎛️ Comandi dello Script PowerShell

| Comando | Descrizione |
|---------|-------------|
| `build` | Builda l'immagine Docker |
| `run` | Avvia il container |
| `stop` | Ferma il container |
| `logs` | Mostra i logs (usa `-Follow` per tempo reale) |
| `clean` | Rimuove container e immagine |
| `compose-up` | Avvia con Docker Compose |
| `compose-down` | Ferma Docker Compose |
| `test` | Verifica che l'applicazione sia pronta |

### Esempi

```powershell
# Build con tag personalizzato
.\scripts\docker-build.ps1 -Action build -Tag v1.0.0

# Run con porta personalizzata
.\scripts\docker-build.ps1 -Action run -Port 9090

# Logs in tempo reale
.\scripts\docker-build.ps1 -Action logs -Follow

# Pulizia completa
.\scripts\docker-build.ps1 -Action clean
```

## 🌐 Accesso all'Applicazione

Dopo l'avvio del container, l'applicazione è disponibile su:

- **Home Page**: http://localhost:8080
- **Login**: http://localhost:8080/login
- **Health Check**: http://localhost:8080/actuator/health

### Credenziali di Test

| Username | Password | Ruolo |
|----------|----------|-------|
| user | user123 | USER |
| admin | admin123 | ADMIN |
| mario | mario123 | USER |

## ⚙️ Configurazione

### Variabili d'Ambiente

Puoi configurare l'applicazione tramite variabili d'ambiente:

```powershell
docker run -d \
  --name corsontt38-app \
  -p 8080:8080 \
  -e JAVA_OPTS="-Xms512m -Xmx1g" \
  -e SPRING_PROFILES_ACTIVE="prod" \
  -e LOGGING_LEVEL_ROOT="INFO" \
  corsontt38:latest
```

### Opzioni JVM Comuni

- **`-Xms256m`** - Heap minimo (default)
- **`-Xmx512m`** - Heap massimo (default)
- **`-XX:+UseG1GC`** - Garbage collector G1 (consigliato per container)
- **`-XX:MaxRAMPercentage=75.0`** - Limita memoria al 75% del container

### Spring Profiles

- **`dev`** - Sviluppo locale (logging verbose)
- **`prod`** - Produzione (ottimizzato)
- **`test`** - Testing

## 📊 Monitoraggio

### Health Check

Docker esegue automaticamente health check ogni 30 secondi:

```bash
docker inspect --format='{{json .State.Health}}' corsontt38-app
```

### Statistiche Container

```bash
# CPU e memoria in tempo reale
docker stats corsontt38-app

# Processi nel container
docker top corsontt38-app

# Informazioni dettagliate
docker inspect corsontt38-app
```

### Logs

```bash
# Ultimi 100 log
docker logs --tail 100 corsontt38-app

# Logs in tempo reale
docker logs -f corsontt38-app

# Logs da un timestamp specifico
docker logs --since 2026-03-25T10:00:00 corsontt38-app
```

## 🔧 Debug

### Accesso al Container

```bash
# Shell interattiva
docker exec -it corsontt38-app sh

# Esegui comando singolo
docker exec corsontt38-app ps aux

# Verifica file system
docker exec corsontt38-app ls -la /app
```

### Troubleshooting Comune

#### Container non si avvia

```bash
# Controlla i logs
docker logs corsontt38-app

# Verifica la configurazione
docker inspect corsontt38-app
```

#### Porta già in uso

```powershell
# Usa una porta diversa
.\scripts\docker-build.ps1 -Action run -Port 9090
```

#### Problemi di memoria

```bash
# Aumenta limiti di memoria
docker run -d --name corsontt38-app \
  -p 8080:8080 \
  -m 1g \
  -e JAVA_OPTS="-Xmx750m" \
  corsontt38:latest
```

## 🏗️ Ottimizzazioni

### Build Cache

Il Dockerfile è ottimizzato per il caching:
1. Layer per dipendenze Maven (raramente cambiano)
2. Layer separato per codice sorgente (cambia spesso)

### Immagine Multi-Stage

- **Stage Build**: ~800MB (con JDK e Maven)
- **Stage Runtime**: ~300MB (solo JRE + JAR)
- **Riduzione**: ~60% di spazio

### .dockerignore

Esclude dalla build:
- Directory `target/` (build artifacts)
- File IDE (`.idea/`, `.vscode/`)
- Logs e file temporanei
- Git history

## 🚢 Deploy in Produzione

### Registry

```bash
# Tag per registry
docker tag corsontt38:latest myregistry.azurecr.io/corsontt38:v1.0.0

# Push al registry
docker push myregistry.azurecr.io/corsontt38:v1.0.0
```

### Azure Container Instances

```bash
az container create \
  --resource-group myResourceGroup \
  --name corsontt38-app \
  --image myregistry.azurecr.io/corsontt38:v1.0.0 \
  --cpu 1 \
  --memory 1 \
  --ports 8080 \
  --dns-name-label corsontt38-app
```

### Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: corsontt38-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: corsontt38
  template:
    metadata:
      labels:
        app: corsontt38
    spec:
      containers:
      - name: app
        image: corsontt38:latest
        ports:
        - containerPort: 8080
        env:
        - name: JAVA_OPTS
          value: "-Xms512m -Xmx1g"
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
        resources:
          requests:
            memory: "512Mi"
            cpu: "500m"
          limits:
            memory: "1Gi"
            cpu: "1"
        livenessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 40
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /actuator/health
            port: 8080
          initialDelaySeconds: 20
          periodSeconds: 5
```

## 📚 Risorse Utili

- [Docker Documentation](https://docs.docker.com/)
- [Spring Boot Docker Guide](https://spring.io/guides/topicals/spring-boot-docker/)
- [Eclipse Temurin Images](https://hub.docker.com/_/eclipse-temurin)
- [Docker Compose Documentation](https://docs.docker.com/compose/)

## 🤝 Contributing

Per miglioramenti alla configurazione Docker:
1. Testa localmente con `docker build` e `docker run`
2. Verifica che l'health check funzioni
3. Controlla le dimensioni dell'immagine con `docker images`
4. Documenta le modifiche in questo README
