# 🐳 Maven Docker Build - Guida Completa

Script e guida per generare immagini Docker tramite Maven utilizzando il Dockerfile.

## 📋 Prerequisiti

- ✅ **Maven 3.8+** installato
- ✅ **Docker Desktop** in esecuzione
- ✅ **Java 21** installato
- ✅ Plugin `dockerfile-maven-plugin` configurato in `pom.xml`

## 🚀 Comandi Rapidi

### Build Completo (Maven + Docker)

```powershell
# Build del progetto + creazione immagine Docker
mvn clean package

# Oppure con wrapper Maven
.\mvnw.cmd clean package
```

Questo comando esegue:
1. ✅ Compilazione Java
2. ✅ Esecuzione test unitari
3. ✅ Generazione JAR con Spring Boot
4. ✅ **Build immagine Docker** usando il Dockerfile
5. ✅ Tag immagine come `corso-ntt-38:latest` e `corso-ntt-38:0.0.1-SNAPSHOT`

### Solo Build Docker (senza rebuild Java)

```powershell
# Se il JAR esiste già, rebuild solo Docker
mvn dockerfile:build

# Con wrapper
.\mvnw.cmd dockerfile:build
```

### Build + Push su Registry

```powershell
# Build e push su Docker registry
mvn clean package dockerfile:push -DskipTests

# Con wrapper
.\mvnw.cmd clean package dockerfile:push -DskipTests
```

### Tag Immagine

```powershell
# Tag con versione specifica
mvn dockerfile:tag -Ddockerfile.tag=1.0.0

# Tag custom
mvn dockerfile:tag -Ddockerfile.tag=production
```

## 🛠️ Configurazione Plugin

Il plugin è configurato in `pom.xml` con le seguenti impostazioni:

| Parametro | Valore | Descrizione |
|-----------|--------|-------------|
| `repository` | `corso-ntt-38` | Nome dell'immagine Docker |
| `tag` | `latest` | Tag di default |
| `dockerfile` | `Dockerfile` | Path del Dockerfile (root) |
| `contextDirectory` | `${project.basedir}` | Directory di build |
| `buildArgs` | `JAR_FILE=target/corsontt38-0.0.1-SNAPSHOT.jar` | Arguments per Dockerfile |

## 📦 Verifica Immagini Create

```powershell
# Lista immagini Docker
docker images | Select-String "corso-ntt-38"

# Dettagli immagine
docker inspect corso-ntt-38:latest

# Dimensione immagine
docker images corso-ntt-38 --format "{{.Repository}}:{{.Tag}} - {{.Size}}"
```

## 🏃 Esecuzione Container

```powershell
# Run container
docker run -d -p 8080:8080 --name corso-ntt-38-app corso-ntt-38:latest

# Run con variabili d'ambiente
docker run -d -p 8080:8080 `
  -e SPRING_PROFILES_ACTIVE=production `
  -e JAVA_OPTS="-Xms256m -Xmx512m" `
  --name corso-ntt-38-app `
  corso-ntt-38:latest

# Verifica log
docker logs -f corso-ntt-38-app

# Stop e remove
docker stop corso-ntt-38-app
docker rm corso-ntt-38-app
```

## 🔧 Configurazione Registry Privato

### Azure Container Registry (ACR)

```xml
<!-- In pom.xml, modifica la configurazione del plugin -->
<configuration>
    <repository>myregistry.azurecr.io/corso-ntt-38</repository>
    <tag>latest</tag>
    <useMavenSettingsForAuth>true</useMavenSettingsForAuth>
</configuration>
```

```powershell
# Login su ACR
az acr login --name myregistry

# Build e push
.\mvnw.cmd clean package dockerfile:push -DskipTests
```

### Docker Hub

```xml
<!-- In pom.xml -->
<configuration>
    <repository>docker.io/username/corso-ntt-38</repository>
    <tag>latest</tag>
    <useMavenSettingsForAuth>true</useMavenSettingsForAuth>
</configuration>
```

Aggiungi credenziali in `~/.m2/settings.xml`:

```xml
<settings>
  <servers>
    <server>
      <id>docker.io</id>
      <username>your-dockerhub-username</username>
      <password>your-dockerhub-password</password>
    </server>
  </servers>
</settings>
```

```powershell
# Login su Docker Hub
docker login

# Build e push
.\mvnw.cmd clean package dockerfile:push -DskipTests
```

### Google Container Registry (GCR)

```xml
<!-- In pom.xml -->
<configuration>
    <repository>gcr.io/project-id/corso-ntt-38</repository>
    <tag>latest</tag>
</configuration>
```

```powershell
# Autentica con GCR
gcloud auth configure-docker

# Build e push
.\mvnw.cmd clean package dockerfile:push -DskipTests
```

## 🎯 Maven Profiles per Ambienti

Aggiungi al `pom.xml` per gestire diversi ambienti:

```xml
<profiles>
    <!-- Profilo Development -->
    <profile>
        <id>dev</id>
        <activation>
            <activeByDefault>true</activeByDefault>
        </activation>
        <properties>
            <docker.image.tag>dev-${maven.build.timestamp}</docker.image.tag>
            <docker.repository>corso-ntt-38</docker.repository>
        </properties>
    </profile>
    
    <!-- Profilo Production -->
    <profile>
        <id>prod</id>
        <properties>
            <docker.image.tag>${project.version}</docker.image.tag>
            <docker.repository>myregistry.azurecr.io/corso-ntt-38</docker.repository>
        </properties>
    </profile>
    
    <!-- Profilo CI/CD -->
    <profile>
        <id>cicd</id>
        <properties>
            <docker.image.tag>${env.BUILD_NUMBER}</docker.image.tag>
            <docker.repository>${env.DOCKER_REGISTRY}/corso-ntt-38</docker.repository>
        </properties>
    </profile>
</profiles>
```

Uso:

```powershell
# Build per development
.\mvnw.cmd clean package -Pdev

# Build per production
.\mvnw.cmd clean package -Pprod dockerfile:push

# Build per CI/CD
.\mvnw.cmd clean package -Pcicd -DbuildNumber=$env:BUILD_NUMBER
```

## 🔐 Gestione Secrets

### Opzione 1: Variabili d'Ambiente

```powershell
# Imposta variabili
$env:DOCKER_USERNAME="your-username"
$env:DOCKER_PASSWORD="your-password"

# Build e push
.\mvnw.cmd clean package dockerfile:push -DskipTests
```

### Opzione 2: Maven Settings

Crea/modifica `~/.m2/settings.xml`:

```xml
<settings>
  <servers>
    <server>
      <id>docker-registry</id>
      <username>${env.DOCKER_USERNAME}</username>
      <password>${env.DOCKER_PASSWORD}</password>
    </server>
  </servers>
</settings>
```

### Opzione 3: Docker Credential Helper

```powershell
# Installa credential helper
choco install docker-credential-helper

# Configura in docker config.json
# Docker userà automaticamente il credential helper
```

## 📊 Parametri Plugin Avanzati

```powershell
# Build senza cache per rebuild completo
mvn dockerfile:build -Ddockerfile.noCache=true

# Pull immagine base più recente
mvn dockerfile:build -Ddockerfile.pullNewerImage=true

# Build con tag custom
mvn dockerfile:build -Ddockerfile.tag=v2.0.0

# Build con repository custom
mvn dockerfile:build -Ddockerfile.repository=myrepo/myapp

# Verbose output per debugging
mvn dockerfile:build -X

# Skip Docker build
mvn clean package -Ddockerfile.skip=true
```

## 🧪 Testing Immagine Generata

```powershell
# Scan vulnerabilità con Trivy
trivy image corso-ntt-38:latest

# Scan con Docker Scout
docker scout cves corso-ntt-38:latest

# Test container con health check
docker run -d -p 8080:8080 --name test-app corso-ntt-38:latest
Start-Sleep -Seconds 30
$response = Invoke-WebRequest -Uri "http://localhost:8080/actuator/health" -UseBasicParsing
Write-Host "Health Status: $($response.Content)"
docker stop test-app
docker rm test-app
```

## 🚨 Troubleshooting

### Errore: "Cannot connect to Docker daemon"

```powershell
# Verifica Docker in esecuzione
docker info

# Avvia Docker Desktop
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

# Verifica connessione
docker ps
```

### Errore: "No plugin found for prefix 'dockerfile'"

```powershell
# Rebuild progetto per scaricare plugin
.\mvnw.cmd clean install -U

# Pulizia cache Maven
Remove-Item -Recurse -Force ~/.m2/repository/com/spotify/dockerfile-maven-plugin
.\mvnw.cmd clean package
```

### Errore: "JAR file not found"

```powershell
# Verifica JAR generato
Get-ChildItem target/*.jar

# Build completo
.\mvnw.cmd clean package

# Verifica build args
.\mvnw.cmd dockerfile:build -X | Select-String "JAR_FILE"
```

### Build lento

```powershell
# Usa build cache
mvn dockerfile:build -Ddockerfile.noCache=false

# Skip test per velocizzare
mvn package dockerfile:build -DskipTests

# Usa Docker BuildKit per build parallelo
$env:DOCKER_BUILDKIT=1
mvn dockerfile:build
```

### Immagine troppo grande

```powershell
# Analizza layer
docker history corso-ntt-38:latest

# Usa dive per analisi approfondita
dive corso-ntt-38:latest

# Il Dockerfile usa già multi-stage build per ottimizzare dimensione
```

## 📘 Best Practices

1. **Tag Versioning**
   - Usa sempre tag semantici (`1.0.0`, `1.0.1`)
   - Evita solo `latest` in produzione
   - Usa `git commit SHA` per tracciabilità

2. **Security**
   - Mai committare credenziali nel pom.xml
   - Usa Maven settings o variabili d'ambiente
   - Scansiona immagini per vulnerabilità

3. **Performance**
   - Sfrutta Docker layer caching
   - Multi-stage builds (già nel Dockerfile)
   - .dockerignore per escludere file non necessari

4. **CI/CD Integration**
   - Automatizza build in pipeline
   - Tag immagini con build number
   - Push automatico su registry

## 🔗 Comandi Maven Utili

```powershell
# Info plugin
.\mvnw.cmd help:describe -Dplugin=com.spotify:dockerfile-maven-plugin -Ddetail

# Lista goal disponibili
.\mvnw.cmd dockerfile:help

# Dry-run (non esegue, mostra cosa farebbe)
.\mvnw.cmd dockerfile:build -DdryRun=true

# Build offline (usa cache locale)
.\mvnw.cmd clean package -o
```

## 📚 Riferimenti

- [Dockerfile Maven Plugin - GitHub](https://github.com/spotify/dockerfile-maven)
- [Docker Documentation](https://docs.docker.com/)
- [Maven Docker Best Practices](https://maven.apache.org/guides/mini/guide-docker.html)
- [Spring Boot Docker Guide](https://spring.io/guides/gs/spring-boot-docker/)

---

**Build automatizzato con Maven!** 🎉

Ora puoi generare l'immagine Docker con un semplice:
```powershell
.\mvnw.cmd clean package
```
