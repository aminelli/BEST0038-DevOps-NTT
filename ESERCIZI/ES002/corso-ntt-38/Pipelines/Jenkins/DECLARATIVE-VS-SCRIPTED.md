# 🔄 Differenze tra Declarative e Scripted Pipeline

Guida rapida per scegliere e comprendere le differenze tra le due versioni della pipeline Jenkins.

---

## 📊 Confronto Rapido

| Aspetto | Declarative<br/>(Jenkinsfile) | Scripted<br/>(Jenkinsfile-scripted) |
|---------|-------------------------------|--------------------------------------|
| **Difficoltà** | 🟢 **Facile** | 🟡 **Media** |
| **Struttura** | Rigida e chiara | Flessibile |
| **Validazione** | ✅ Automatica | ❌ Manuale |
| **Groovy** | Limitato | Completo |
| **Errori** | Gestione automatica | Try-catch manuale |
| **Manutenibilità** | 🟢 **Alta** | 🟡 Media |
| **Jenkins Min** | 2.5+ | Tutte le versioni |
| **Blue Ocean** | ✅ Ottimizzato | ⚠️ Supportato |
| **Best for** | Team, Standard | Expert, Custom |

---

## 🎯 Quando Usare Quale

### ✅ Usa DECLARATIVE se...

- ✅ Stai iniziando un nuovo progetto
- ✅ Il team ha poca esperienza con Groovy
- ✅ Vuoi pipeline standardizzate e manutenibili
- ✅ Hai bisogno di validazione automatica
- ✅ Usi Blue Ocean per visualizzazione
- ✅ La pipeline segue un flusso lineare standard
- ✅ Preferisci sintassi dichiarativa (YAML-like)

**Esempio Use Case**:
- CI/CD standard per microservizi
- Pipeline aziendale con template comuni
- Progetti con junior developers
- Pipeline documentate e condivise

---

### ✅ Usa SCRIPTED se...

- ✅ Hai già pipeline esistenti in sintassi scripted
- ✅ Necessiti di logica complessa (loop, condizioni nidificate)
- ✅ Il team è esperto con Groovy
- ✅ Hai bisogno di massima flessibilità
- ✅ Devi integrare librerie Groovy custom
- ✅ Gestisci errori in modo molto specifico
- ✅ Hai requisiti che eccedono limiti declarative

**Esempio Use Case**:
- Pipeline legacy da mantenere
- Orchestrazione complessa multi-ambiente
- Deployment con logica condizionale avanzata
- Integrazione con sistemi custom

---

## 🔀 Esempi Comparativi

### 1. Definizione Agent

**Declarative** (Jenkinsfile):
```groovy
pipeline {
    agent any
    // oppure
    agent {
        docker {
            image 'maven:3.9-eclipse-temurin-21'
        }
    }
}
```

**Scripted** (Jenkinsfile-scripted):
```groovy
node {
    // Esegue su qualsiasi agent
}
// oppure
node('docker') {
    docker.image('maven:3.9-eclipse-temurin-21').inside {
        // ...
    }
}
```

---

### 2. Gestione Errori

**Declarative** (Jenkinsfile):
```groovy
pipeline {
    stages {
        stage('Build') {
            steps {
                bat 'mvnw.cmd clean package'
            }
        }
    }
    post {
        failure {
            echo 'Build failed!'
            emailext subject: 'Build Failed', body: '...'
        }
        always {
            cleanWs()
        }
    }
}
```

**Scripted** (Jenkinsfile-scripted):
```groovy
node {
    try {
        stage('Build') {
            bat 'mvnw.cmd clean package'
        }
    } catch (Exception e) {
        echo 'Build failed!'
        emailext subject: 'Build Failed', body: '...'
        throw e
    } finally {
        cleanWs()
    }
}
```

---

### 3. Condizioni

**Declarative** (Jenkinsfile):
```groovy
stage('Deploy') {
    when {
        branch 'main'
        expression { return params.DEPLOY_TO_K8S }
    }
    steps {
        bat 'kubectl apply -f deployment.yaml'
    }
}
```

**Scripted** (Jenkinsfile-scripted):
```groovy
if (env.BRANCH_NAME == 'main' && params.DEPLOY_TO_K8S) {
    stage('Deploy') {
        bat 'kubectl apply -f deployment.yaml'
    }
}
```

---

### 4. Loop Multipli

**Declarative** (Jenkinsfile) - Limitato:
```groovy
stage('Test Multiple Envs') {
    steps {
        script {
            // Devi usare script { } per loop
            def envs = ['dev', 'staging', 'prod']
            for (env in envs) {
                echo "Testing in ${env}"
                bat "run-tests.ps1 -Environment ${env}"
            }
        }
    }
}
```

**Scripted** (Jenkinsfile-scripted) - Nativo:
```groovy
def envs = ['dev', 'staging', 'prod']
for (env in envs) {
    stage("Test ${env}") {
        echo "Testing in ${env}"
        bat "run-tests.ps1 -Environment ${env}"
    }
}
```

---

### 5. Parallel Execution

**Declarative** (Jenkinsfile):
```groovy
stage('Parallel Tests') {
    parallel {
        stage('Unit Tests') {
            steps { bat 'mvnw.cmd test' }
        }
        stage('Integration Tests') {
            steps { bat 'mvnw.cmd verify' }
        }
        stage('E2E Tests') {
            steps { bat 'npx cypress run' }
        }
    }
}
```

**Scripted** (Jenkinsfile-scripted):
```groovy
parallel(
    'Unit Tests': {
        stage('Unit Tests') {
            bat 'mvnw.cmd test'
        }
    },
    'Integration Tests': {
        stage('Integration Tests') {
            bat 'mvnw.cmd verify'
        }
    },
    'E2E Tests': {
        stage('E2E Tests') {
            bat 'npx cypress run'
        }
    }
)
```

---

### 6. Input con Timeout

**Declarative** (Jenkinsfile):
```groovy
stage('Approval') {
    options {
        timeout(time: 10, unit: 'MINUTES')
    }
    input {
        message 'Deploy to production?'
        ok 'Deploy'
        submitter 'admin,ops-team'
    }
    steps {
        bat 'kubectl apply -f production/'
    }
}
```

**Scripted** (Jenkinsfile-scripted):
```groovy
timeout(time: 10, unit: 'MINUTES') {
    stage('Approval') {
        input message: 'Deploy to production?',
              ok: 'Deploy',
              submitter: 'admin,ops-team'
        
        bat 'kubectl apply -f production/'
    }
}
```

---

## 🔁 Migrazione da Scripted a Declarative

### Step-by-Step

1. **Crea struttura base**:
```groovy
pipeline {
    agent any
    stages {
        // Qui andranno gli stage
    }
}
```

2. **Converti node → pipeline**:
```groovy
// Prima (Scripted)
node {
    stage('Build') { ... }
}

// Dopo (Declarative)
pipeline {
    agent any
    stages {
        stage('Build') {
            steps { ... }
        }
    }
}
```

3. **Converti try-catch → post**:
```groovy
// Prima (Scripted)
try {
    stage('Build') { ... }
} catch (e) {
    echo 'Failed'
} finally {
    cleanWs()
}

// Dopo (Declarative)
stages {
    stage('Build') { ... }
}
post {
    failure { echo 'Failed' }
    always { cleanWs() }
}
```

4. **Converti if → when**:
```groovy
// Prima (Scripted)
if (env.BRANCH_NAME == 'main') {
    stage('Deploy') { ... }
}

// Dopo (Declarative)
stage('Deploy') {
    when { branch 'main' }
    steps { ... }
}
```

5. **Sposta logica complessa in script { }**:
```groovy
// Declarative con logica Groovy
stage('Complex Logic') {
    steps {
        script {
            // Qui puoi usare Groovy come in Scripted
            def result = calculateSomething()
            if (result > 10) {
                bat 'special-command'
            }
        }
    }
}
```

---

## 🚦 Decision Tree

```
┌─────────────────────────────────────────────────────┐
│ Stai iniziando da zero?                              │
└────────────────┬────────────────────────────────────┘
                 │
         ┌───────┴──────┐
         │ SÌ           │ NO (hai già pipeline)
         │              │
         v              v
    ┌────────┐      ┌────────┐
    │Declarative    │Scripted│
    │(Jenkinsfile)  │esistente?│
    └────────┘      └────┬───┘
                         │
                 ┌───────┴──────┐
                 │ SÌ           │ NO
                 │              │
                 v              v
            ┌────────┐      ┌────────┐
            │Mantieni│      │Logica  │
            │Scripted│      │complessa?│
            └────────┘      └────┬───┘
                                 │
                         ┌───────┴──────┐
                         │ SÌ           │ NO
                         │              │
                         v              v
                    ┌────────┐      ┌────────┐
                    │Scripted│      │Declarative
                    │        │      │(consigliata)│
                    └────────┘      └────────┘
```

---

## 📈 Performance

| Caratteristica | Declarative | Scripted |
|----------------|-------------|----------|
| **Startup time** | ~500ms più lento | Più veloce |
| **Parsing** | Validazione pre-run | Runtime |
| **Memoria** | Leggermente più alta | Più bassa |
| **Esecuzione** | Identica | Identica |

> **Conclusione**: Differenze trascurabili in production. Scegli in base a leggibilità e manutenibilità.

---

## ✅ Raccomandazioni Finali

### Per Questo Progetto (Corso NTT 38)

**✨ Raccomandazione: Usa DECLARATIVE** (`Jenkinsfile`)

**Motivi**:
1. ✅ Pipeline lineare standard (checkout → test → build → deploy)
2. ✅ Team education (sintassi più chiara)
3. ✅ Manutenibilità a lungo termine
4. ✅ Nessuna logica complessa che richieda scripted
5. ✅ Blue Ocean visualization migliore
6. ✅ Validazione automatica riduce errori

**Quando Passare a Scripted**:
Solo se in futuro serve:
- Logica di branching molto complessa
- Deployment condizionale multi-ambiente con calcoli
- Integrazione con librerie Groovy custom
- Orchestrazione avanzata di pipeline dinamiche

---

## 📚 Risorse

- [Declarative Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/)
- [Scripted Pipeline Syntax](https://www.jenkins.io/doc/book/pipeline/syntax/#scripted-pipeline)
- [Pipeline Best Practices](https://www.jenkins.io/doc/book/pipeline/pipeline-best-practices/)
- [Migrating to Declarative](https://www.jenkins.io/doc/book/pipeline/getting-started/#converting-from-scripted-to-declarative-pipeline)

---

**Consiglio**: Inizia con **Declarative** (`Jenkinsfile`). Se raggiungi dei limiti (improbabile per questo progetto), hai sempre **Scripted** come fallback.
