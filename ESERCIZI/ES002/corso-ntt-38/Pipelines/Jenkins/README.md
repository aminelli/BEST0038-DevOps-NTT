# 🚀 Jenkins CI/CD Pipeline - Corso NTT 38

Pipeline completa di Continuous Integration e Continuous Deployment per l'applicazione Spring Boot.

## 📋 Indice

- [Panoramica](#panoramica)
- [Versioni Pipeline](#versioni-pipeline)
- [Prerequisiti](#prerequisiti)
- [Configurazione Jenkins](#configurazione-jenkins)
- [Stages della Pipeline](#stages-della-pipeline)
- [Parametri](#parametri)
- [Variabili d'Ambiente](#variabili-dambiente)
- [Credenziali](#credenziali)
- [Esecuzione](#esecuzione)
- [Troubleshooting](#troubleshooting)
- [Notifiche](#notifiche)

---

## 🎯 Panoramica

La pipeline Jenkins automatizza l'intero ciclo di vita del software:

```
┌───────────────────────────────────────────────────────────────┐
│                    JENKINS CI/CD PIPELINE                      │
├───────────────────────────────────────────────────────────────┤
│                                                                │
│  1. Git Checkout  →  Clone da GitLab                          │
│  2. Unit Tests    →  Maven + JaCoCo coverage                  │
│  3. SonarQube     →  Analisi statica codice                   │
│  4. Build JAR     →  Maven package                            │
│  5. Docker Build  →  Maven Dockerfile plugin                  │
│  6. Docker Push   →  Push su registry (ACR/Docker Hub)        │
│  7. Start App     →  Avvio per test E2E                       │
│  8. Cypress E2E   →  Test end-to-end                          │
│  9. K8s Deploy    →  Deployment su cluster                     │
│                                                                │
└───────────────────────────────────────────────────────────────┘
```

### Tempi di Esecuzione Stimati

| Stage | Durata Tipica |
|-------|---------------|
| Git Checkout | ~30s |
| Unit Tests | ~2m |
| SonarQube | ~3m |
| Build JAR | ~1m |
| Docker Build | ~2m |
| Docker Push | ~1m |
| Cypress E2E | ~5m |
| K8s Deploy | ~1m |
| **TOTALE** | **~15-20m** |

---

## � Versioni Pipeline

Sono disponibili **due versioni** della pipeline Jenkins con la stessa logica ma sintassi diversa:
> 📖 **Guida Dettagliata**: Vedi [DECLARATIVE-VS-SCRIPTED.md](DECLARATIVE-VS-SCRIPTED.md) per confronto completo, esempi e decision tree.
### 1. Declarative Pipeline (Consigliata)

**File**: `Jenkinsfile`

**Sintassi**:
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                // ...
            }
        }
    }
}
```

**Vantaggi**:
- ✅ Sintassi più semplice e leggibile
- ✅ Validazione automatica della struttura
- ✅ Supporto nativo per `post`, `when`, `options`, `triggers`
- ✅ Migliore integrazione con Blue Ocean UI
- ✅ **Raccomandata per nuovi progetti**

**Quando Usare**:
- Progetti nuovi o riscritture
- Team con poca esperienza Groovy
- Pipeline standardizzate
- Necessità di validazione automatica

---

### 2. Scripted Pipeline (Classica)

**File**: `Jenkinsfile-scripted`

**Sintassi**:
```groovy
node {
    stage('Build') {
        // ...
    }
}
```

**Vantaggi**:
- ✅ Massima flessibilità con Groovy nativo
- ✅ Controllo completo su logica condizionale
- ✅ Gestione errori custom con try-catch-finally
- ✅ Migliore per pipeline complesse con logica avanzata
- ✅ Compatibilità con vecchie versioni Jenkins

**Quando Usare**:
- Progetti legacy esistenti
- Pipeline con logica molto complessa
- Necessità di controllo granulare
- Team esperti con Groovy/Jenkins

---

### Confronto Sintassi

| Caratteristica | Declarative | Scripted |
|----------------|-------------|----------|
| **Struttura** | `pipeline { }` | `node { }` |
| **Agent** | `agent any` | `node { }` |
| **Post Actions** | `post { always { } }` | `try-catch-finally` |
**Per Declarative Pipeline** (consigliata):
```
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://gitlab.corso.local/gr38/corso-ntt-38.git
Credentials: gitlab-credentials (vedi sotto)
Branch Specifier: */main
Script Path: Pipelines/Jenkins/Jenkinsfile
```

**Per Scripted Pipeline** (alternativa):
```
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://gitlab.corso.local/gr38/corso-ntt-38.git
Credentials: gitlab-credentials (vedi sotto)
Branch Specifier: */main
Script Path: Pipelines/Jenkins/Jenkinsfile-scripted
```

> **Nota**: Usa una sola versione alla volta. Cambia solo `Script Path` per switchare tra versioni.

### Come Scegliere

```
┌─────────────────────────────────────────────┐
│  Nuovo progetto o team junior?              │
│  Pipeline standardizzata?                   │
│  → Usa DECLARATIVE (Jenkinsfile)            │
└─────────────────────────────────────────────┘

┌─────────────────────────────────────────────┐
│  Logica complessa con loop/condizioni?      │
│  Necessità di controllo granulare?          │
│  → Usa SCRIPTED (Jenkinsfile-scripted)      │
└─────────────────────────────────────────────┘
```

**Raccomandazione**: Inizia con **Declarative** (Jenkinsfile). Se raggiungi limiti di flessibilità, passa a **Scripted**.

---

## �🔧 Prerequisiti

### Software Richiesto su Jenkins Server

- ✅ **Jenkins 2.400+** (LTS)
- ✅ **Java 21** (JDK)
- ✅ **Maven 3.9+**
- ✅ **Docker Desktop** (o Docker Engine)
- ✅ **kubectl** (Kubernetes CLI)
- ✅ **Node.js 18+** e **npm** (per Cypress)
- ✅ **Git** (client)

### Plugin Jenkins Richiesti

```bash
# Plugin essenziali da installare
- Pipeline
- Git
- Docker Pipeline
- Kubernetes CLI
- JaCoCo
- SonarQube Scanner
- HTML Publisher
- Email Extension
- Slack Notification (opzionale)
- Blue Ocean (opzionale, per UI moderna)
```

Installa tramite: **Manage Jenkins → Plugin Manager → Available Plugins**

### Verifica Prerequisiti

```bash
# Su Jenkins server, esegui:
java -version        # Java 21
mvn -version         # Maven 3.9+
docker --version     # Docker 24+
kubectl version      # Kubernetes CLI
node --version       # Node.js 18+
npm --version        # npm 9+
git --version        # Git 2.40+
```

---

## ⚙️ Configurazione Jenkins

### 1. Creazione Job Pipeline

1. **New Item** → Nome: `corso-ntt-38-pipeline`
2. Tipo: **Pipeline**
3. **OK**

### 2. Configurazione General

```
Description: CI/CD Pipeline per Corso NTT 38 - Spring Boot Application
☑ GitHub project: https://gitlab.corso.local/gr38/corso-ntt-38
☑ This project is parameterized (vedi sezione Parametri)
☑ Do not allow concurrent builds
```

### 3. Build Triggers

```
☑ Poll SCM: H/5 * * * *          (ogni 5 minuti)
☑ Build periodically: 0 2 * * *   (ogni notte alle 2:00)
☑ GitHub hook trigger for GITScm polling (se configurato)
```

### 4. Pipeline Definition

```
Definition: Pipeline script from SCM
SCM: Git
Repository URL: https://gitlab.corso.local/gr38/corso-ntt-38.git
Credentials: gitlab-credentials (vedi sotto)
Branch Specifier: */main
Script Path: Pipelines/Jenkins/Jenkinsfile
```

### 5. Tools Configuration

**Manage Jenkins → Global Tool Configuration**

#### Java (JDK 21)
```
Name: JDK-21
Install automatically: ☑
Add Installer: Install from Adoptium
Version: jdk-21+35
```

#### Maven
```
Name: Maven-3.9
Install automatically: ☑
Version: 3.9.6
```

#### Docker
```
Name: Docker
Install automatically: ☐ (già installato sul sistema)
```

---

## 🔐 Credenziali

Crea le seguenti credenziali in **Manage Jenkins → Credentials → Global**:

### 1. GitLab Credentials
```
Kind: Username with password (o SSH Username with private key)
ID: gitlab-credentials
Username: <gitlab-username>
Password: <gitlab-token>
Description: GitLab Access Token
```

### 2. SonarQube Token
```
Kind: Secret text
ID: sonarqube-token
Secret: <sonarqube-token>
Description: SonarQube Authentication Token
```

Genera token: SonarQube → My Account → Security → Generate Token

### 3. Docker Registry Credentials
```
Kind: Username with password
ID: docker-registry-credentials
Username: <registry-username>
Password: <registry-password>
Description: Docker Registry (ACR/Docker Hub)
```

Per Azure Container Registry:
```bash
# Ottieni credenziali ACR
az acr credential show --name myregistry
```

### 4. Kubernetes Config
```
Kind: Secret file
ID: kubeconfig-credentials
File: <path-to-kubeconfig>
Description: Kubernetes Cluster Config
```

Ottieni kubeconfig:
```bash
# Kubernetes locale
kubectl config view --raw > kubeconfig.yaml

# Azure AKS
az aks get-credentials --resource-group myRG --name myCluster --file kubeconfig.yaml

# Upload in Jenkins
```

---

## 📊 Stages della Pipeline

### Stage 1: Git Checkout
**Scopo**: Clone del repository GitLab

```groovy
✅ Pulizia workspace
✅ Clone repository con depth=1 (shallow clone)
✅ Estrazione info commit (hash, autore, messaggio)
✅ Impostazione descrizione build
```

**Output**: Codice sorgente pronto in workspace

---

### Stage 2: Unit Tests
**Scopo**: Esecuzione test unitari con coverage

```groovy
✅ Esegue: mvnw.cmd clean test jacoco:report
✅ Pubblica report JUnit
✅ Pubblica coverage JaCoCo
✅ Genera report HTML navigabile
```

**Artifact**: 
- `target/surefire-reports/*.xml` (JUnit)
- `target/site/jacoco/index.html` (Coverage)

**Skip**: Usa parametro `SKIP_TESTS=true`

---

### Stage 3: SonarQube Analysis
**Scopo**: Analisi statica del codice

```groovy
✅ Esegue: mvnw.cmd sonar:sonar
✅ Carica risultati su SonarQube server
✅ Attende Quality Gate (qualitygate.wait=true)
✅ Fallisce se QG non superato
```

**Metriche Analizzate**:
- Code smells
- Bugs
- Vulnerabilità
- Code coverage
- Duplicazioni
- Complessità ciclomatica

**Quality Gate**: Deve essere PASSED per proseguire

**Skip**: Usa parametro `SKIP_SONAR=true`

---

### Stage 4: Build Application
**Scopo**: Compilazione e packaging JAR

```groovy
✅ Esegue: mvnw.cmd clean package -DskipTests
✅ Genera: target/corsontt38-0.0.1-SNAPSHOT.jar
✅ Archivia JAR come artifact Jenkins
```

**Artifact**: `corsontt38-0.0.1-SNAPSHOT.jar` (~50 MB)

---

### Stage 5: Build Docker Image
**Scopo**: Creazione immagine Docker con Maven

```groovy
✅ Esegue: mvnw.cmd dockerfile:build
✅ Usa Dockerfile nella root del progetto
✅ Multi-stage build (JDK → JRE)
✅ Tag: corso-ntt-38:<build-number>
✅ Tag: corso-ntt-38:latest
```

**Output**: Immagine Docker locale con 2 tag

---

### Stage 6: Push Docker Image
**Scopo**: Push immagine su registry

```groovy
✅ Login su Docker registry (ACR/Docker Hub)
✅ Re-tag immagine per registry
✅ Push: <registry>/corso-ntt-38:<build-number>
✅ Push: <registry>/corso-ntt-38:latest
✅ Logout sicuro
```

**Condizione**: Solo se `DEPLOY_TO_K8S=true`

---

### Stage 7: Start Application
**Scopo**: Avvio app per test E2E

```groovy
✅ Start: mvnw.cmd spring-boot:run (background)
✅ Wait: 60s per startup completo
✅ Health check: curl /actuator/health
✅ Pronta per Cypress
```

**Skip**: Se `SKIP_CYPRESS=true`

---

### Stage 8: Cypress E2E Tests
**Scopo**: Test end-to-end completi

```groovy
✅ Install Cypress (se necessario): npm install
✅ Run tests: npx cypress run --headless
✅ Genera report HTML
✅ Archivia screenshot/video se falliti
✅ Stop applicazione (always)
```

**Test Eseguiti**: 79 test in 6 spec files

**Report**: Pubblicato come HTML in Jenkins

**Skip**: Usa parametro `SKIP_CYPRESS=true`

---

### Stage 9: Deploy to Kubernetes
**Scopo**: Deployment su cluster K8s

```groovy
✅ Create namespace (se non esiste)
✅ Apply: configmap.yaml
✅ Apply: secret.yaml
✅ Update: deployment image
✅ Apply: deployment.yaml
✅ Apply: service.yaml
✅ Apply: ingress.yaml
✅ Apply: hpa.yaml
✅ Wait: rollout status (timeout 5m)
✅ Verify: kubectl get all
```

**Rollback Automatico**: Se deployment fallisce

**Skip**: Se `DEPLOY_TO_K8S=false`

---

## 🎛️ Parametri

La pipeline supporta i seguenti parametri configurabili:

| Parametro | Tipo | Default | Descrizione |
|-----------|------|---------|-------------|
| `GIT_BRANCH_PARAM` | String | `main` | Branch Git da buildare |
| `SKIP_TESTS` | Boolean | `false` | Skip unit tests |
| `SKIP_SONAR` | Boolean | `false` | Skip analisi SonarQube |
| `SKIP_CYPRESS` | Boolean | `false` | Skip test Cypress E2E |
| `DEPLOY_TO_K8S` | Boolean | `true` | Deploy su Kubernetes |
| `ENVIRONMENT` | Choice | `dev` | Target environment (dev/staging/production) |

### Utilizzo Parametri

**Build con Parametri**:
1. Click su **Build with Parameters**
2. Imposta i parametri desiderati
3. Click **Build**

**Esempi**:

```bash
# Build completo (default)
GIT_BRANCH_PARAM: main
SKIP_TESTS: false
SKIP_SONAR: false
SKIP_CYPRESS: false
DEPLOY_TO_K8S: true
ENVIRONMENT: dev

# Build veloce (solo packaging + deploy)
GIT_BRANCH_PARAM: develop
SKIP_TESTS: true
SKIP_SONAR: true
SKIP_CYPRESS: true
DEPLOY_TO_K8S: true
ENVIRONMENT: dev

# Build completo per produzione
GIT_BRANCH_PARAM: main
SKIP_TESTS: false
SKIP_SONAR: false
SKIP_CYPRESS: false
DEPLOY_TO_K8S: true
ENVIRONMENT: production
```

---

## 🌍 Variabili d'Ambiente

Configura queste variabili nel Jenkinsfile o in **Manage Jenkins → System → Global properties → Environment variables**:

```groovy
// Git
GIT_REPO = 'https://gitlab.corso.local/gr38/corso-ntt-38.git'
GIT_BRANCH = 'main'

// SonarQube
SONAR_HOST_URL = 'http://localhost:9000'
SONAR_PROJECT_KEY = 'corso-ntt-38'

// Docker
DOCKER_IMAGE_NAME = 'corso-ntt-38'
DOCKER_REGISTRY = 'myregistry.azurecr.io'

// Kubernetes
K8S_NAMESPACE = 'corso-ntt-38'
K8S_DEPLOYMENT = 'corso-ntt-38-app'
```

---

## 📤 Artifact Generati

La pipeline genera e archivia i seguenti artifact:

| Artifact | Path | Dimensione | Descrizione |
|----------|------|------------|-------------|
| JAR | `target/*.jar` | ~50 MB | Applicazione Spring Boot |
| JUnit Reports | `target/surefire-reports/*.xml` | ~100 KB | Report test unitari |
| JaCoCo Report | `target/site/jacoco/` | ~500 KB | Coverage HTML |
| Cypress Screenshots | `cypress/screenshots/` | Variabile | Screenshot test falliti |
| Cypress Videos | `cypress/videos/` | Variabile | Registrazioni test |
| Pipeline Summary | `pipeline-summary.txt` | ~2 KB | Summary esecuzione |
| Deployment Info | `deployment-info.txt` | ~1 KB | Info deployment K8s |

---

## 🎯 Triggers Automatici

### Poll SCM
```groovy
triggers {
    pollSCM('H/5 * * * *')  // Ogni 5 minuti
}
```

Verifica cambiamenti su GitLab ogni 5 minuti e avvia build se ci sono nuovi commit.

### Build Periodico
```groovy
cron('0 2 * * *')  // Alle 2:00 ogni giorno
```

Build notturno per verifica codebase (utile per rilevare problemi di integrazione).

### Webhook GitLab (Opzionale)

Configura webhook in GitLab per trigger immediato:

1. **GitLab**: Project → Settings → Webhooks
2. **URL**: `http://jenkins.corso.local/project/corso-ntt-38-pipeline`
3. **Trigger**: Push events, Merge request events
4. **Add webhook**

---

## 🔍 Monitoring e Report

### Jenkins UI

**Dashboard** → `corso-ntt-38-pipeline`:
- **Build History**: Ultime 10 build
- **Stage View**: Visualizzazione stages con tempi
- **Test Result Trend**: Grafico trend test
- **Coverage Trend**: Grafico trend coverage

### Report Accessibili

| Report | URL | Descrizione |
|--------|-----|-------------|
| JUnit Tests | `<build-url>/testReport` | Report test unitari |
| JaCoCo Coverage | `<build-url>/jacoco` | Coverage report |
| Cypress E2E | `<build-url>/Cypress_E2E_Test_Report` | Report E2E |
| Console Output | `<build-url>/console` | Log completo |
| SonarQube | `http://localhost:9000/dashboard?id=corso-ntt-38` | Analisi codice |
**Per Declarative Pipeline**:
```bash
# Valida sintassi Jenkinsfile
curl -X POST -F "jenkinsfile=<Pipelines/Jenkins/Jenkinsfile" \
  http://jenkins.corso.local/pipeline-model-converter/validate
```

**Per Scripted Pipeline**:
```bash
# Nessuna validazione automatica disponibile
# Usa Replay per test iterativi (vedi sotto)
```

> **Nota**: Solo Declarative Pipeline supporta validazione pre-run.Installa plugin **Blue Ocean**
2. Accedi: `http://jenkins.corso.local/blue/organizations/jenkins/corso-ntt-38-pipeline`

---

## 🧪 Testing della Pipeline

### Test Locale del Jenkinsfile

```bash
# Valida sintassi Jenkinsfile
curl -X POST -F "jenkinsfile=<Pipelines/Jenkins/Jenkinsfile" \
  http://jenkins.corso.local/pipeline-model-converter/validate
```

### Test Singoli Stage

Comenta stage non necessari nel Jenkinsfile per test rapidi:

```groovy
// Commenta stage per test
/*
stage('Cypress E2E Tests') {
    // ...
}
*/
```

### Replay con Modifiche

1. Click su build completata
2. **Replay**
3. Modifica Jenkinsfile inline
4. **Run**

---

## 🚨 Troubleshooting

### Build Fallisce: Git Checkout

**Problema**: `fatal: could not read Username`

**Soluzione**:
```bash
# Verifica credenziali GitLab
Manage Jenkins → Credentials → gitlab-credentials
# Verifica URL repository
echo $GIT_REPO
```

---

### Build Fallisce: Unit Tests

**Problema**: Test falliti

**Soluzione**:
1. Controlla console output
2. Scarica `target/surefire-reports/*.xml`
3. Esegui localmente: `mvnw.cmd test`
4. Fix test e commit

---

### Build Fallisce: SonarQube

**Problema**: `Quality Gate failed`

**Soluzione**:
```bash
# Accedi SonarQube dashboard
http://localhost:9000/dashboard?id=corso-ntt-38

# Analizza issues
- Code Smells
- Bugs
- Vulnerabilities

# Fix codice e ri-build
```

---

### Build Fallisce: Docker Build

**Problema**: `Cannot connect to Docker daemon`

**Soluzione**:
```bash
# Su Jenkins server
docker info

# Verifica Docker in esecuzione
systemctl status docker  # Linux
Get-Service docker       # Windows

# Restart Docker
systemctl restart docker
```

---

### Build Fallisce: Cypress

**Problema**: Cypress tests timeout

**Soluzione**:
```bash
# Verifica applicazione avviata
curl http://localhost:8080/actuator/health

# Aumenta timeout startup
timeout /t 90 /nobreak  # da 60s a 90s

# Controlla log applicazione
type app.log
```

---

### Build Fallisce: Kubernetes Deploy

**Problema**: `Unable to connect to the server`

**Soluzione**:
```bash
# Verifica kubeconfig
kubectl cluster-info

# Verifica credenziali in Jenkins
Manage Jenkins → Credentials → kubeconfig-credentials

# Testa connessione
kubectl get nodes
```

**Problema**: `ImagePullBackOff`

**Soluzione**:
```bash
# Verifica immagine su registry
docker pull myregistry.azurecr.io/corso-ntt-38:latest

# Verifica secret per pull
kubectl get secret regcred -n corso-ntt-38

# Crea secret se mancante
kubectl create secret docker-registry regcred \
  --docker-server=myregistry.azurecr.io \
  --docker-username=<username> \
  --docker-password=<password> \
  -n corso-ntt-38
```

---

## 📧 Notifiche

### Email Notifications

**Configura SMTP** in **Manage Jenkins → System**:

```
SMTP server: smtp.gmail.com
SMTP port: 587
Use SSL: ☑
Credentials: <email-credentials>
```

**Decomenta nel Jenkinsfile**:

```groovy
post {
    success {
        emailext (
            subject: "✅ Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}",
            body: "...",
            to: 'team@corso.local'
        )
    }
}
```

### 0. Scelta Versione Pipeline

**Per la maggior parte dei progetti**:
```groovy
// Usa Declarative (Jenkinsfile)
pipeline {
    agent any
    stages { ... }
}
```

**Solo se necessario (logica molto complessa)**:
```groovy
// Usa Scripted (Jenkinsfile-scripted)
node {
    try {
        stage('Build') { ... }
    } catch (e) { ... }
}
```

### Slack Notifications (Opzionale)

1. Installa plugin **Slack Notification**
2. **Manage Jenkins → System → Slack**
3. Configure: Workspace, Channel, Token
4. Aggiungi in Jenkinsfile:

```groovy
post {
    success {
        slackSend(
            color: 'good',
            message: "✅ Build SUCCESS: ${env.JOB_NAME} #${env.BUILD_NUMBER}"
        )
    }
}
```

---

## 📚 Best Practices

### 1. Branch Strategy
```
main        → Production (deployment automatico)
develop     → Development (deployment su dev environment)
feature/*   → Feature branches (no auto-deploy)
hotfix/*    → Hotfix (deployment urgente)
```

### 2. Versioning
```groovy
// Usa build number per versioning
DOCKER_IMAGE_TAG = "${env.BUILD_NUMBER}"
// Oppure usa git commit SHA
DOCKER_IMAGE_TAG = sh(returnStdout: true, script: 'git rev-parse --short HEAD').trim()
```

### 3. Rollback Strategy
```bash
# Rollback automatico in caso di fallimento (già implementato)
kubectl rollout undo deployment/corso-ntt-38-app -n corso-ntt-38

# Rollback manuale a versione specifica
kubectl rollout history deployment/corso-ntt-38-app -n corso-ntt-38
kubectl rollout undo deployment/corso-ntt-38-app --to-revision=2 -n corso-ntt-38
```

### 4. Secrets Management
- ✅ Non committare secrets nel Jenkinsfile
- ✅ Usa Jenkins Credentials
- ✅ Usa Kubernetes Secrets
- ✅ Considera HashiCorp Vault per secrets avanzati

### 5. Performance
```groovy
// Usa shallow clone
[$class: 'CloneOption', depth: 1, shallow: true]

// Cache Docker layers
docker build --cache-from corso-ntt-38:latest

// Parallelizza stage indipendenti
parallel {
    stage('Unit Tests') { ... }
    stage('SonarQube') { ... }
}
```

---

## 📊 Metriche Pipeline

### KPI da Monitorare

| Metrica | Target | Descrizione |
|---------|--------|-------------|
| **Build Success Rate** | >95% | % build completate con successo |
| **Build Duration** | <20m | Tempo medio esecuzione |
| **Test Pass Rate** | 100% | % test unitari passati |
| **Code Coverage** | >80% | Coverage test unitari |
| **SonarQube QG** | PASSED | Quality Gate status |
| **Deployment Success** | >98% | % deployment K8s riusciti |
| **MTTR** | <1h | Mean Time To Recovery |

### Dashboard Grafana (Opzionale)

Integra Jenkins con Prometheus + Grafana per monitoring avanzato:
- Build metrics
- Test trends
- Deployment frequency
- Lead time
- Failure rate

---

## 🔗 Risorse Utili

### Documentazione Progetto
- [DECLARATIVE-VS-SCRIPTED.md](DECLARATIVE-VS-SCRIPTED.md) - Confronto dettagliato tra le due versioni pipeline
- [../scripts/README.md](../../scripts/README.md) - Documentazione script PowerShell
- [../../DOCKER.md](../../DOCKER.md) - Guida containerizzazione
- [../../Infra/README.md](../../Infra/README.md) - Guida deployment Kubernetes

### Documentazione Jenkins
- [Jenkins Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Jenkinsfile Best Practices](https://www.jenkins.io/doc/book/pipeline/jenkinsfile/)
- [Docker in Pipeline](https://www.jenkins.io/doc/book/pipeline/docker/)
- [Kubernetes Plugin](https://plugins.jenkins.io/kubernetes/)
- [Blue Ocean Documentation](https://www.jenkins.io/doc/book/blueocean/)

---

## 🎓 Comandi Utili

```bash
# Restart Jenkins (Linux)
sudo systemctl restart jenkins

# Restart Jenkins (Windows)
Restart-Service jenkins

# View Jenkins logs
tail -f /var/log/jenkins/jenkins.log  # Linux
Get-Content C:\Jenkins\jenkins.log -Tail 50 -Wait  # Windows

# Jenkins CLI
java -jar jenkins-cli.jar -s http://localhost:8080/ build corso-ntt-38-pipeline

# Backup Jenkins
tar -czf jenkins-backup.tar.gz /var/lib/jenkins/

# List all credentials
curl -u admin:password http://localhost:8080/credentials/
```

---

**Pipeline pronta per l'uso!** 🎉

Per avviare la prima build:
1. Verifica prerequisiti e credenziali
2. Click su **Build Now** o **Build with Parameters**
3. Monitora esecuzione in **Stage View**
4. Controlla report e artifact generati

Per supporto: Consulta troubleshooting o contatta il team DevOps.
