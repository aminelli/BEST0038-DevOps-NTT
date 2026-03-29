# 📜 Scripts DevOps - Guida all'Uso

Questa cartella contiene script PowerShell per automatizzare operazioni comuni di sviluppo, testing, analisi e containerizzazione dell'applicazione Spring Boot.

## 📁 Script Disponibili

| Script | Descrizione | Uso Principale |
|--------|-------------|----------------|
| **run-tests.ps1** | Esegue unit test con JaCoCo coverage | Testing e code coverage |
| **run-sonar-analysis.ps1** | Analisi statica codice con SonarQube | Quality gate e metriche |
| **docker-build.ps1** | Gestione completa containerizzazione | Build, run, deploy Docker |

---

## 🧪 run-tests.ps1

### Descrizione
Script per eseguire gli unit test Maven con generazione automatica del report di code coverage JaCoCo.

### Sintassi
```powershell
.\run-tests.ps1 [-SkipCoverage] [-OpenReport]
```

### Parametri

| Parametro | Tipo | Descrizione | Default |
|-----------|------|-------------|---------|
| `-SkipCoverage` | Switch | Salta la generazione del report JaCoCo | `false` |
| `-OpenReport` | Switch | Apre automaticamente il report HTML nel browser | `false` |

### Esempi di Utilizzo

#### Esecuzione Standard
```powershell
# Esegue tutti i test e genera il report di coverage
.\run-tests.ps1
```

#### Con Apertura Automatica Report
```powershell
# Esegue i test e apre il report HTML nel browser
.\run-tests.ps1 -OpenReport
```

#### Solo Test (Senza Coverage)
```powershell
# Esegue solo i test senza generare il report di coverage
.\run-tests.ps1 -SkipCoverage
```

### Output
- **Console**: Risultati test in tempo reale
- **Report JaCoCo**: `target/site/jacoco/index.html`
- **Report Surefire**: `target/surefire-reports/`

### Codici di Uscita
- `0` - Tutti i test sono passati
- `1` - Errore o test falliti

---

## 📊 run-sonar-analysis.ps1

### Descrizione
Script completo per eseguire l'analisi del codice con SonarQube, includendo compilazione, test e upload delle metriche.

### Sintassi
```powershell
.\run-sonar-analysis.ps1 [-SonarHostUrl <URL>] [-SonarProjectKey <KEY>]
```

### Parametri

| Parametro | Tipo | Descrizione | Default |
|-----------|------|-------------|---------|
| `-SonarHostUrl` | String | URL del server SonarQube | `http://localhost:9000` |
| `-SonarProjectKey` | String | Chiave del progetto SonarQube | `corso-ntt-38` |

### Prerequisiti
- Server SonarQube in esecuzione
- Token di autenticazione configurato in `pom.xml`
- Java 21 e Maven installati

### Esempi di Utilizzo

#### Analisi Locale
```powershell
# Analisi con server SonarQube locale
.\run-sonar-analysis.ps1
```

#### Server Remoto
```powershell
# Analisi con server SonarQube remoto
.\run-sonar-analysis.ps1 -SonarHostUrl "https://sonarqube.company.com" -SonarProjectKey "my-project"
```

### Fasi di Esecuzione
1. ✅ Verifica prerequisiti (Maven, Java)
2. 🧹 Pulizia build precedente (`mvn clean`)
3. 🧪 Compilazione ed esecuzione test
4. 📊 Generazione report JaCoCo
5. 📤 Upload metriche a SonarQube
6. 🎯 Visualizzazione risultati

### Output
- **Dashboard SonarQube**: http://localhost:9000/dashboard?id=corso-ntt-38
- **Console**: Log dettagliato dell'analisi
- **Report Coverage**: `target/site/jacoco/`

### Codici di Uscita
- `0` - Analisi completata con successo
- `1` - Errore durante l'analisi

---

## 🐳 docker-build.ps1

### Descrizione
Script completo per la gestione del ciclo di vita Docker dell'applicazione: build, run, stop, logs, cleanup e Docker Compose.

### Sintassi
```powershell
.\docker-build.ps1 -Action <ACTION> [-Tag <TAG>] [-Port <PORT>] [-Follow]
```

### Parametri

| Parametro | Tipo | Obbligatorio | Descrizione | Default |
|-----------|------|--------------|-------------|---------|
| `-Action` | String | ✅ Sì | Azione da eseguire (vedi sotto) | - |
| `-Tag` | String | No | Tag per l'immagine Docker | `latest` |
| `-Port` | Int | No | Porta locale da mappare | `8080` |
| `-Follow` | Switch | No | Per logs, segue output in tempo reale | `false` |

### Azioni Disponibili

| Action | Descrizione |
|--------|-------------|
| `build` | Build dell'immagine Docker |
| `run` | Avvia il container |
| `stop` | Ferma il container |
| `logs` | Visualizza i logs del container |
| `clean` | Rimuove container e immagine |
| `compose-up` | Avvia servizi con Docker Compose |
| `compose-down` | Ferma servizi Docker Compose |
| `test` | Verifica che l'applicazione sia pronta |

### Esempi di Utilizzo

#### Build & Run (Workflow Base)
```powershell
# 1. Build dell'immagine
.\docker-build.ps1 -Action build

# 2. Avvia il container
.\docker-build.ps1 -Action run

# 3. Verifica che sia pronto
.\docker-build.ps1 -Action test
```

#### Build con Tag Personalizzato
```powershell
# Build con versione specifica
.\docker-build.ps1 -Action build -Tag v1.0.0

# Run con versione specifica
.\docker-build.ps1 -Action run -Tag v1.0.0
```

#### Run su Porta Personalizzata
```powershell
# Avvia su porta 9090
.\docker-build.ps1 -Action run -Port 9090
```

#### Logs in Tempo Reale
```powershell
# Visualizza logs (ultimi 100)
.\docker-build.ps1 -Action logs

# Segui logs in tempo reale (Ctrl+C per uscire)
.\docker-build.ps1 -Action logs -Follow
```

#### Docker Compose
```powershell
# Avvia con Docker Compose (orchestrazione completa)
.\docker-build.ps1 -Action compose-up

# Visualizza stato servizi
docker-compose ps

# Ferma tutti i servizi
.\docker-build.ps1 -Action compose-down
```

#### Pulizia Completa
```powershell
# Rimuove container e immagine
.\docker-build.ps1 -Action clean
```

### Output
- **Console**: Feedback colorato sullo stato delle operazioni
- **Container**: Applicazione su http://localhost:8080
- **Health Check**: Endpoint disponibili per monitoring

### Codici di Uscita
- `0` - Operazione completata con successo
- `1` - Errore durante l'operazione

---

## 🔄 Workflow DevOps Completo

### 1️⃣ Sviluppo e Testing Locale
```powershell
# Esegui i test
.\run-tests.ps1 -OpenReport

# Verifica coverage (target: > 80%)
# Apri target/site/jacoco/index.html
```

### 2️⃣ Analisi Qualità Codice
```powershell
# Analisi SonarQube
.\run-sonar-analysis.ps1

# Verifica quality gate su dashboard
# http://localhost:9000/dashboard?id=corso-ntt-38
```

### 3️⃣ Containerizzazione
```powershell
# Build immagine Docker
.\docker-build.ps1 -Action build

# Test locale del container
.\docker-build.ps1 -Action run
.\docker-build.ps1 -Action test

# Verifica applicazione
# http://localhost:8080
```

### 4️⃣ Deploy (Esempio)
```powershell
# Tag per registry
docker tag corsontt38:latest myregistry.azurecr.io/corsontt38:v1.0.0

# Push al registry
docker push myregistry.azurecr.io/corsontt38:v1.0.0
```

---

## 🛠️ Prerequisiti Comuni

### Software Richiesto
- ✅ **PowerShell 5.1+** o **PowerShell Core 7+**
- ✅ **Java 21** (JDK) - per build e test
- ✅ **Maven 3.8+** - gestione dipendenze
- ✅ **Docker Desktop** - per containerizzazione
- ✅ **SonarQube** (opzionale) - per analisi statica

### Verifica Prerequisiti
```powershell
# PowerShell version
$PSVersionTable.PSVersion

# Java version
java -version

# Maven version
mvn -version

# Docker version
docker --version

# Docker Compose version
docker-compose --version
```

---

## 📋 Variabili d'Ambiente

### Per SonarQube
```powershell
# Configura token SonarQube (alternativa a pom.xml)
$env:SONAR_TOKEN = "sqa_your_token_here"
```

### Per Docker
```powershell
# Configura registry Docker
$env:DOCKER_REGISTRY = "myregistry.azurecr.io"
$env:DOCKER_USERNAME = "myuser"
```

---

## 🐛 Troubleshooting

### Script Non Eseguibile
```powershell
# Abilita esecuzione script (una volta, come Administrator)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Maven Non Trovato
```powershell
# Usa Maven wrapper (incluso nel progetto)
# Gli script usano automaticamente .\mvnw.cmd
```

### Docker Non Disponibile
```powershell
# Verifica che Docker Desktop sia avviato
docker info

# Se non risponde, avvia Docker Desktop
```

### Porta 8080 Occupata
```powershell
# Usa porta diversa
.\docker-build.ps1 -Action run -Port 9090

# O trova processo che usa la porta
netstat -ano | findstr :8080
```

### SonarQube Non Raggiungibile
```powershell
# Verifica che SonarQube sia in esecuzione
curl http://localhost:9000

# Se necessario, avvia SonarQube
# (vedi documentazione SonarQube)
```

---

## 📚 Risorse Aggiuntive

### Documentazione Dettagliata
- **Docker**: Vedi [DOCKER.md](../DOCKER.md) per guida completa containerizzazione
- **Testing**: Report JaCoCo in `target/site/jacoco/index.html`
- **SonarQube**: Dashboard su http://localhost:9000

### Help Integrato
Tutti gli script includono help PowerShell integrato:

```powershell
# Mostra help dettagliato
Get-Help .\run-tests.ps1 -Detailed
Get-Help .\run-sonar-analysis.ps1 -Detailed
Get-Help .\docker-build.ps1 -Detailed

# Mostra solo esempi
Get-Help .\docker-build.ps1 -Examples
```

---

## 🤝 Best Practices

### 1. Testing
- ✅ Esegui i test **prima** di ogni commit
- ✅ Mantieni coverage > **80%**
- ✅ Verifica che non ci siano test skipped

### 2. Code Quality
- ✅ Esegui analisi SonarQube regolarmente
- ✅ Risolvi **blocker** e **critical** issues
- ✅ Mantieni **quality gate** passing

### 3. Docker
- ✅ **Non** committare immagini Docker nel repo
- ✅ Usa **tag semantici** (v1.0.0, v1.1.0, etc.)
- ✅ Testa il container **localmente** prima del push

### 4. Security
- ✅ **Non** committare token o credenziali negli script
- ✅ Usa variabili d'ambiente per secrets
- ✅ Esegui container con utente **non-root** (già configurato)

---

## 📞 Supporto

Per problemi o suggerimenti riguardo gli script:
1. Verifica i **prerequisiti** sopra
2. Consulta la sezione **Troubleshooting**
3. Controlla i **logs** per errori dettagliati
4. Usa `Get-Help` per documentazione integrata

---

## 📝 Change Log

### v1.0.0 (2026-03-25)
- ✅ Script iniziale `run-tests.ps1`
- ✅ Script `run-sonar-analysis.ps1`
- ✅ Script `docker-build.ps1`
- ✅ Documentazione completa

---

**Nota**: Tutti gli script sono progettati per essere eseguiti dalla directory `scripts/` del progetto.
