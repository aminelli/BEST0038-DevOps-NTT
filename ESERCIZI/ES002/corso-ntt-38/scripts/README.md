# 📜 Scripts PowerShell - Documentazione

Questa cartella contiene tutti gli script PowerShell per l'automazione di build, test, analisi e deployment dell'applicazione Spring Boot.

## 📋 Indice

- [Script Disponibili](#script-disponibili)
- [Prerequisiti](#prerequisiti)
- [Guida Rapida](#guida-rapida)
- [Documentazione Dettagliata](#documentazione-dettagliata)
  - [run-tests.ps1](#run-testsps1)
  - [run-sonar-analysis.ps1](#run-sonar-analysisps1)
  - [run-cypress.ps1](#run-cypressps1)
  - [docker-build.ps1](#docker-buildps1)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

---

## 🚀 Script Disponibili

| Script | Descrizione | Documentazione |
|--------|-------------|----------------|
| `run-tests.ps1` | Esegue unit test con JaCoCo coverage | [📖](#run-testsps1) |
| `run-sonar-analysis.ps1` | Analisi statica con SonarQube | [📖](#run-sonar-analysisps1) |
| `run-cypress.ps1` | Test E2E con Cypress | [📖](#run-cypressps1) |
| `docker-build.ps1` | Build e gestione container Docker | [📖](#docker-buildps1) |
| `maven-docker-build.md` | Build Docker con Maven Plugin | [📖](maven-docker-build.md) |

---

## 🔧 Prerequisiti

### Requisiti Generali
- ✅ **PowerShell 5.1+** (incluso in Windows 10/11)
- ✅ **Java 21** (JDK)
- ✅ **Maven** (tramite wrapper `mvnw.cmd`)

### Requisiti Specifici per Script

#### run-tests.ps1
- Java 21
- Maven wrapper

#### run-sonar-analysis.ps1
- SonarQube Server in esecuzione (default: localhost:9000)
- Token di autenticazione SonarQube

#### run-cypress.ps1
- Node.js 16+
- npm 7+
- Applicazione Spring Boot in esecuzione (localhost:8080)

#### docker-build.ps1
- Docker Desktop installato e in esecuzione
- docker-compose (incluso in Docker Desktop)

#### maven-docker-build.md (Maven Plugin)
- Java 21
- Maven wrapper
- Docker Desktop installato e in esecuzione
- Plugin `dockerfile-maven-plugin` configurato nel pom.xml

### Verifica Prerequisiti

```powershell
# Java version
java -version

# Maven (via wrapper)
.\mvnw.cmd --version

# Node.js
node --version

# Docker
docker --version
docker-compose --version

# PowerShell version
$PSVersionTable.PSVersion
```

---

## ⚡ Guida Rapida

### Workflow Completo DevOps

```powershell
# 1. Esegui i test unitari
.\scripts\run-tests.ps1

# 2. Analisi SonarQube
.\scripts\run-sonar-analysis.ps1 -SonarToken "YOUR_TOKEN"

# 3a. Build Docker image con Maven (opzione integrata)
.\mvnw.cmd clean package  # Build JAR + Docker image automaticamente

# 3b. Build Docker image con script PowerShell (opzione standalone)
.\scripts\docker-build.ps1 -Action build

# 4. Avvia l'applicazione in Docker
.\scripts\docker-build.ps1 -Action run

# 5. Esegui test E2E (in altra finestra)
.\scripts\run-cypress.ps1 -Action install
.\scripts\run-cypress.ps1 -Action run

# 6. Stop container
.\scripts\docker-build.ps1 -Action stop
```

---

## 📖 Documentazione Dettagliata

---

## run-tests.ps1

### 📝 Descrizione
Esegue gli unit test Maven con JaCoCo per la code coverage. Genera report HTML navigabili.

### 🎯 Sintassi

```powershell
.\scripts\run-tests.ps1 [-SkipCoverage] [-OpenReport]
```

### 🔧 Parametri

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `-SkipCoverage` | Switch | `$false` | Salta la generazione del report JaCoCo |
| `-OpenReport` | Switch | `$false` | Apre automaticamente il report HTML nel browser |

### ✨ Esempi

```powershell
# Esegui test con coverage (default)
.\scripts\run-tests.ps1

# Esegui test senza coverage
.\scripts\run-tests.ps1 -SkipCoverage

# Esegui test e apri report nel browser
.\scripts\run-tests.ps1 -OpenReport

# Solo test, no coverage, no report
.\scripts\run-tests.ps1 -SkipCoverage
```

### 📊 Output

```
========================================
  🧪 Maven Test Runner
  Spring Boot Unit Tests with JaCoCo
========================================

📦 Esecuzione test Maven...
[INFO] Tests run: 42, Failures: 0, Errors: 0, Skipped: 0
✅ Test completati con successo!

📊 Generazione report JaCoCo...
✅ Report generato: target\site\jacoco\index.html

🌐 Apertura report nel browser...
✅ Report aperto!

✨ Completato!
```

### 📂 Artifact Generati

- `target/surefire-reports/` - Report XML dei test
- `target/site/jacoco/` - Report HTML JaCoCo
- `target/jacoco.exec` - File di esecuzione JaCoCo

### 🔍 Verifica Coverage

Il report HTML mostra:
- **Coverage per package** (com.corso.devops.corsontt38)
- **Coverage per classe** (SecurityConfig, Controllers, etc.)
- **Coverage per metodo** con linee coperte/non coperte
- **Statistiche**: Instruction, Branch, Line, Method, Class coverage

---

## run-sonar-analysis.ps1

### 📝 Descrizione
Esegue l'analisi statica del codice con SonarQube. Carica i risultati sul server SonarQube per analisi dettagliata di:
- Code smells
- Bugs
- Vulnerabilità di sicurezza
- Code coverage
- Duplicazioni

### 🎯 Sintassi

```powershell
.\scripts\run-sonar-analysis.ps1 
    -SonarToken <string>
    [-SonarHostUrl <string>]
    [-SonarProjectKey <string>]
    [-SkipTests]
```

### 🔧 Parametri

| Parametro | Tipo | Default | Obbligatorio | Descrizione |
|-----------|------|---------|--------------|-------------|
| `-SonarToken` | String | - | ✅ Sì | Token di autenticazione SonarQube |
| `-SonarHostUrl` | String | `http://localhost:9000` | ❌ No | URL del server SonarQube |
| `-SonarProjectKey` | String | `corso-ntt-38` | ❌ No | Chiave univoca del progetto |
| `-SkipTests` | Switch | `$false` | ❌ No | Salta l'esecuzione dei test |

### 🔑 Ottenere Token SonarQube

1. Accedi a SonarQube: http://localhost:9000
2. Vai a **My Account** > **Security**
3. Genera un nuovo token
4. Copia il token (non sarà più visibile)

### ✨ Esempi

```powershell
# Analisi completa con token
.\scripts\run-sonar-analysis.ps1 -SonarToken "squ_1234567890abcdef"

# Con server SonarQube custom
.\scripts\run-sonar-analysis.ps1 `
    -SonarToken "squ_1234567890abcdef" `
    -SonarHostUrl "http://sonarqube.company.com:9000"

# Salta i test (usa coverage esistente)
.\scripts\run-sonar-analysis.ps1 `
    -SonarToken "squ_1234567890abcdef" `
    -SkipTests

# Progetto custom
.\scripts\run-sonar-analysis.ps1 `
    -SonarToken "squ_1234567890abcdef" `
    -SonarProjectKey "my-custom-project"
```

### 📊 Output

```
========================================
  📊 SonarQube Analysis Runner
  Static Code Analysis & Quality Gate
========================================

🔍 Configurazione:
  Host: http://localhost:9000
  Project Key: corso-ntt-38
  Skip Tests: False

🧪 Esecuzione test e coverage...
[INFO] Tests run: 42, Failures: 0, Errors: 0
✅ Test completati

📊 Esecuzione analisi SonarQube...
[INFO] ANALYSIS SUCCESSFUL, you can browse http://localhost:9000/dashboard?id=corso-ntt-38
✅ Analisi completata con successo!

🌐 Dashboard: http://localhost:9000/dashboard?id=corso-ntt-38

✨ Completato!
```

### 🔍 Metriche SonarQube

La dashboard mostra:
- **Bugs**: Errori nel codice
- **Vulnerabilities**: Problemi di sicurezza
- **Code Smells**: Problemi di manutenibilità
- **Coverage**: Percentuale di codice testato
- **Duplications**: Codice duplicato
- **Technical Debt**: Tempo stimato per risolvere issues

---

## run-cypress.ps1

### 📝 Descrizione
Gestisce l'esecuzione dei test End-to-End (E2E) con Cypress. Supporta modalità interattiva (UI) per sviluppo e modalità headless per CI/CD.

### 🎯 Sintassi

```powershell
.\scripts\run-cypress.ps1 
    -Action <install|open|run|spec|clean|verify>
    [-TestSpec <string>]
    [-Browser <chrome|firefox|edge>]
```

### 🔧 Parametri

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `-Action` | String | - | Azione da eseguire (obbligatorio) |
| `-TestSpec` | String | - | Nome del test specifico (solo con `-Action spec`) |
| `-Browser` | String | `chrome` | Browser per eseguire i test |

### 📋 Azioni Disponibili

| Action | Descrizione |
|--------|-------------|
| `install` | Installa dipendenze npm e Cypress |
| `open` | Apre Cypress in modalità interattiva (UI) |
| `run` | Esegue tutti i test in modalità headless |
| `spec` | Esegue un singolo file di test |
| `clean` | Pulisce screenshots, video e cache |
| `verify` | Verifica che l'applicazione sia in esecuzione |

### ✨ Esempi

```powershell
# Prima installazione - installa Cypress
.\scripts\run-cypress.ps1 -Action install

# Verifica che l'app sia in esecuzione
.\scripts\run-cypress.ps1 -Action verify

# Apri Cypress UI (modalità sviluppo)
.\scripts\run-cypress.ps1 -Action open

# Esegui tutti i test (headless)
.\scripts\run-cypress.ps1 -Action run

# Esegui con browser specifico
.\scripts\run-cypress.ps1 -Action run -Browser firefox

# Esegui test specifico
.\scripts\run-cypress.ps1 -Action spec -TestSpec "02-login.cy.js"

# Esegui test specifico con Firefox
.\scripts\run-cypress.ps1 -Action spec -TestSpec "04-private-area.cy.js" -Browser firefox

# Pulisci screenshots e video
.\scripts\run-cypress.ps1 -Action clean
```

### 📊 Test Disponibili

```
01-public-pages.cy.js      - Test pagine pubbliche (Home, About)
02-login.cy.js             - Test funzionalità login
03-logout.cy.js            - Test funzionalità logout
04-private-area.cy.js      - Test area privata/dashboard
05-roles-authorization.cy.js - Test ruoli e autorizzazioni
06-complete-flow.cy.js     - Test flussi E2E completi
```

### 📂 Artifact Generati

- `Testing/Cypress/cypress/videos/` - Video delle esecuzioni test
- `Testing/Cypress/cypress/screenshots/` - Screenshot dei fallimenti

### ⚠️ Prerequisiti

```powershell
# 1. Installa dipendenze
.\scripts\run-cypress.ps1 -Action install

# 2. Avvia l'applicazione Spring Boot
.\mvnw.cmd spring-boot:run

# 3. In altra finestra PowerShell, esegui i test
.\scripts\run-cypress.ps1 -Action run
```

---

## docker-build.ps1

### 📝 Descrizione
Gestisce il ciclo di vita completo dei container Docker: build immagini, avvio/stop container, visualizzazione log, orchestrazione con docker-compose.

### 🎯 Sintassi

```powershell
.\scripts\docker-build.ps1 
    -Action <build|run|stop|logs|clean|compose-up|compose-down|test>
    [-ImageName <string>]
    [-ContainerName <string>]
    [-Port <int>]
    [-Follow]
```

### 🔧 Parametri

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `-Action` | String | - | Azione da eseguire (obbligatorio) |
| `-ImageName` | String | `corso-ntt-38` | Nome dell'immagine Docker |
| `-ContainerName` | String | `corso-ntt-38-app` | Nome del container |
| `-Port` | Int | `8080` | Porta esposta dall'applicazione |
| `-Follow` | Switch | `$false` | Segue i log in tempo reale (solo con `-Action logs`) |

### 📋 Azioni Disponibili

| Action | Descrizione |
|--------|-------------|
| `build` | Builda l'immagine Docker |
| `run` | Avvia un nuovo container |
| `stop` | Ferma il container in esecuzione |
| `logs` | Visualizza i log del container |
| `clean` | Rimuove container e immagini |
| `compose-up` | Avvia con docker-compose |
| `compose-down` | Ferma stack docker-compose |
| `test` | Testa la connessione HTTP al container |

### ✨ Esempi

```powershell
# Build immagine Docker
.\scripts\docker-build.ps1 -Action build

# Avvia container
.\scripts\docker-build.ps1 -Action run

# Visualizza log
.\scripts\docker-build.ps1 -Action logs

# Segui log in tempo reale
.\scripts\docker-build.ps1 -Action logs -Follow

# Ferma container
.\scripts\docker-build.ps1 -Action stop

# Test connessione
.\scripts\docker-build.ps1 -Action test

# Pulisci tutto
.\scripts\docker-build.ps1 -Action clean

# Docker Compose
.\scripts\docker-build.ps1 -Action compose-up
.\scripts\docker-build.ps1 -Action compose-down

# Custom configuration
.\scripts\docker-build.ps1 -Action run -Port 9090 -ContainerName "my-app"
```

### 🔄 Workflow Docker Completo

```powershell
# 1. Build immagine
.\scripts\docker-build.ps1 -Action build

# 2. Avvia container
.\scripts\docker-build.ps1 -Action run

# 3. Verifica che funzioni
.\scripts\docker-build.ps1 -Action test

# 4. Visualizza log
.\scripts\docker-build.ps1 -Action logs

# 5. Apri browser
start http://localhost:8080

# 6. Quando finito, ferma container
.\scripts\docker-build.ps1 -Action stop
```

### 🐳 Docker Compose

```powershell
# Avvia con compose (include networking, volumi, etc.)
.\scripts\docker-build.ps1 -Action compose-up

# Ferma e rimuovi stack
.\scripts\docker-build.ps1 -Action compose-down
```

### 📊 Output Build

```
========================================
  🐳 Docker Build & Management
  Spring Boot Containerization
========================================

🐳 Building Docker image: corso-ntt-38...
[+] Building 45.2s (15/15) FINISHED
✅ Immagine creata: corso-ntt-38:latest

🚀 Avvio container: corso-ntt-38-app...
✅ Container avviato su porta 8080

🧪 Test connessione HTTP...
✅ Applicazione risponde correttamente!

🌐 URL: http://localhost:8080

✨ Completato!
```

---

## 🛠️ Troubleshooting

### Errore: "Execution Policy"

```powershell
# Problema
.\scripts\run-tests.ps1 : File cannot be loaded because running scripts is disabled

# Soluzione (una volta)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Errore: Maven non trovato

```powershell
# Usa sempre il wrapper Maven
.\mvnw.cmd clean install

# Non usare 'mvn' direttamente
```

### Errore: Port già in uso (Docker)

```powershell
# Trova processo sulla porta 8080
netstat -ano | findstr :8080

# Termina processo
Stop-Process -Id <PID> -Force

# Oppure usa porta diversa
.\scripts\docker-build.ps1 -Action run -Port 9090
```

### Errore: SonarQube non raggiungibile

```powershell
# Verifica che SonarQube sia in esecuzione
curl http://localhost:9000

# Avvia SonarQube (se non in esecuzione)
# Dipende dalla tua installazione SonarQube
```

### Errore: Cypress - App non in esecuzione

```powershell
# Avvia l'applicazione
.\mvnw.cmd spring-boot:run

# Verifica porta
curl http://localhost:8080

# Poi esegui Cypress
.\scripts\run-cypress.ps1 -Action run
```

### Errore: Docker Desktop non avviato

```powershell
# Avvia Docker Desktop manualmente
# Verifica stato
docker ps

# Se non risponde, riavvia Docker Desktop
```

---

## 🏆 Best Practices

### 1. Workflow CI/CD Locale

```powershell
# Pipeline completa locale
.\scripts\run-tests.ps1                           # Unit tests
.\scripts\run-sonar-analysis.ps1 -SonarToken "..." # Code quality
.\scripts\docker-build.ps1 -Action build           # Containerize
.\scripts\docker-build.ps1 -Action run             # Deploy locally
.\scripts\run-cypress.ps1 -Action run              # E2E tests
.\scripts\docker-build.ps1 -Action stop            # Cleanup
```

### 2. Sviluppo con Hot Reload
 
```powershell
# Terminal 1: Run app
.\mvnw.cmd spring-boot:run

# Terminal 2: Watch tests
.\scripts\run-tests.ps1 -OpenReport

# Terminal 3: Cypress UI
.\scripts\run-cypress.ps1 -Action open
```

### 3. Debug Docker

```powershell
# Build e avvia
.\scripts\docker-build.ps1 -Action build
.\scripts\docker-build.ps1 -Action run

# Segui log in tempo reale
.\scripts\docker-build.ps1 -Action logs -Follow

# In caso di problemi
docker exec -it corso-ntt-38-app /bin/sh
```

### 4. Pulizia Periodica

```powershell
# Pulisci Cypress artifacts
.\scripts\run-cypress.ps1 -Action clean

# Pulisci Docker (attenzione: rimuove tutto!)
.\scripts\docker-build.ps1 -Action clean

# Pulisci Maven build
.\mvnw.cmd clean
```

### 5. Automazione con Task Scheduler

Crea un file `daily-analysis.ps1`:

```powershell
# Daily analysis task
$ErrorActionPreference = "Stop"

# Run tests
.\scripts\run-tests.ps1

# SonarQube analysis
.\scripts\run-sonar-analysis.ps1 -SonarToken $env:SONAR_TOKEN

# Send email report (custom logic)
# ...
```

---

## 📚 Risorse Aggiuntive

### Documentazione Scripts

- [DOCKER.md](../DOCKER.md) - Guida completa Docker
- [Testing/Cypress/README.md](../Testing/Cypress/README.md) - Guida Cypress

### Documentazione Esterna

- [Maven Documentation](https://maven.apache.org/guides/)
- [SonarQube Documentation](https://docs.sonarqube.org/)
- [Cypress Documentation](https://docs.cypress.io/)
- [Docker Documentation](https://docs.docker.com/)

### Cheat Sheets

```powershell
# Help script
Get-Help .\scripts\run-tests.ps1 -Full
Get-Help .\scripts\run-sonar-analysis.ps1 -Examples
Get-Help .\scripts\run-cypress.ps1 -Detailed
Get-Help .\scripts\docker-build.ps1 -Parameter Action
```

---

## 📊 Script Comparison

| Scenario | Script | Comando |
|----------|--------|---------|
| Test veloci | run-tests.ps1 | `.\scripts\run-tests.ps1 -SkipCoverage` |
| Test con report | run-tests.ps1 | `.\scripts\run-tests.ps1 -OpenReport` |
| Quality gate | run-sonar-analysis.ps1 | Con token SonarQube |
| E2E sviluppo | run-cypress.ps1 | `.\scripts\run-cypress.ps1 -Action open` |
| E2E CI/CD | run-cypress.ps1 | `.\scripts\run-cypress.ps1 -Action run` |
| Deploy locale | docker-build.ps1 | `.\scripts\docker-build.ps1 -Action run` |
| Debug container | docker-build.ps1 | `.\scripts\docker-build.ps1 -Action logs -Follow` |

---

**Ultima modifica:** 2026-03-25  
**Autore:** Corso NTT DevOps  
**Versione:** 1.1.0
