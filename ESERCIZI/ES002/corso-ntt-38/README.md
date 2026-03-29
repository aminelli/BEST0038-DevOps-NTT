# Corso NTT 38 - Spring Boot Web Application

![Java](https://img.shields.io/badge/Java-21-orange)
![Spring Boot](https://img.shields.io/badge/Spring%20Boot-4.0.4-brightgreen)
![Bootstrap](https://img.shields.io/badge/Bootstrap-5-purple)
![License](https://img.shields.io/badge/License-MIT-blue)

Applicazione web dimostrativa realizzata con Spring Boot, Spring Security, Thymeleaf e Bootstrap 5. Include sistema di autenticazione, aree pubbliche e private, e un'interfaccia responsive.

## 📋 Indice

- [Caratteristiche](#caratteristiche)
- [Tecnologie Utilizzate](#tecnologie-utilizzate)
- [Prerequisiti](#prerequisiti)
- [Installazione](#installazione)
- [Esecuzione](#esecuzione)
- [Struttura del Progetto](#struttura-del-progetto)
- [Utenti di Test](#utenti-di-test)
- [Pagine](#pagine)
- [Screenshot](#screenshot)
- [Sviluppo](#sviluppo)
- [Build & Deploy](#build--deploy)
- [Analisi Qualità Codice](#analisi-qualità-codice)

## ✨ Caratteristiche

- ✅ **Autenticazione** - Sistema di login con Spring Security
- ✅ **Aree Pubbliche** - Home page e About accessibili senza login
- ✅ **Area Privata** - Dashboard protetta per utenti autenticati
- ✅ **Responsive Design** - Interfaccia ottimizzata per tutti i dispositivi
- ✅ **Template Modulari** - Thymeleaf fragments per header, navbar e footer riutilizzabili
- ✅ **Password Cifrate** - Utilizzo di BCrypt per la sicurezza
- ✅ **Gestione Ruoli** - Supporto per ruoli USER e ADMIN
- ✅ **UI Moderna** - Utilizzando Bootstrap 5 e Bootstrap Icons

## 🛠 Tecnologie Utilizzate

- **Java 21** - Linguaggio di programmazione
- **Spring Boot 4.0.4** - Framework principale
- **Spring Security 6** - Autenticazione e autorizzazione
- **Spring MVC** - Architettura Model-View-Controller
- **Thymeleaf** - Template engine server-side
- **Bootstrap 5** - Framework CSS responsive
- **Bootstrap Icons** - Libreria di icone
- **Maven** - Gestione dipendenze e build

## 📦 Prerequisiti

- **JDK 21** o superiore
- **Maven 3.6+** (opzionale, è incluso il wrapper Maven)
- Un IDE Java (IntelliJ IDEA, Eclipse, VS Code)

## 🚀 Installazione

1. **Clona il repository**
```bash
git clone https://gitlab.corso.local/gr38/corso-ntt-38.git
cd corso-ntt-38
```

2. **Verifica la versione di Java**
```bash
java -version
```

3. **Compila il progetto**
```bash
./mvnw clean install
```

## ▶️ Esecuzione

### Metodo 1: Usando Maven
```bash
./mvnw spring-boot:run
```

### Metodo 2: Usando il JAR
```bash
./mvnw clean package
java -jar target/corsontt38-0.0.1-SNAPSHOT.jar
```

### Metodo 3: Dalla IDE
Esegui la classe `Corsontt38Application.java` come Java Application

L'applicazione sarà disponibile su: **http://localhost:8080**

## 📁 Struttura del Progetto

```
corso-ntt-38/
├── src/
│   ├── main/
│   │   ├── java/com/corso/devops/corsontt38/
│   │   │   ├── config/
│   │   │   │   └── SecurityConfig.java          # Configurazione Spring Security
│   │   │   ├── controller/
│   │   │   │   ├── HomeController.java          # Controller pagine pubbliche
│   │   │   │   ├── AuthController.java          # Controller autenticazione
│   │   │   │   └── PrivateAreaController.java   # Controller area privata
│   │   │   └── Corsontt38Application.java       # Main class
│   │   └── resources/
│   │       ├── templates/
│   │       │   ├── fragments/
│   │       │   │   ├── header.html              # Meta tags e CSS
│   │       │   │   ├── navbar.html              # Navbar responsive
│   │       │   │   └── footer.html              # Footer e scripts
│   │       │   ├── private/
│   │       │   │   └── dashboard.html           # Dashboard privata
│   │       │   ├── index.html                   # Home page
│   │       │   ├── about.html                   # Pagina about
│   │       │   └── login.html                   # Pagina login
│   │       ├── static/
│   │       │   ├── css/
│   │       │   │   └── custom.css               # Stili personalizzati
│   │       │   └── js/
│   │       │       └── custom.js                # JavaScript custom
│   │       └── application.properties           # Configurazione applicazione
│   └── test/                                     # Test unitari
├── pom.xml                                       # Configurazione Maven
└── README.md
```

## 👥 Utenti di Test

L'applicazione include 3 utenti di test configurati in-memory:

| Username | Password  | Ruoli       |
|----------|-----------|-------------|
| `user`   | user123   | USER        |
| `admin`  | admin123  | USER, ADMIN |
| `mario`  | mario123  | USER        |

## 📄 Pagine

### Pagine Pubbliche (senza autenticazione)
- **/** o **/home** - Home page con presentazione applicazione
- **/about** - Informazioni sul progetto e tecnologie utilizzate
- **/login** - Pagina di login

### Pagine Private (richiede autenticazione)
- **/private/dashboard** - Dashboard utente con informazioni personali

## 🖼 Screenshot

### Home Page
- Hero section con descrizione applicazione
- Sezione features con card informative
- Design responsive e moderno

### Login Page
- Form di login stilizzato
- Messaggi di errore e successo
- Informazioni utenti di test

### Dashboard
- Benvenuto personalizzato con username
- Informazioni utente e ruoli
- Sezione speciale per amministratori
- Azioni rapide

## 💻 Sviluppo

### Hot Reload
Il progetto include Spring DevTools per il ricaricamento automatico durante lo sviluppo.

### Logging
I log sono configurati per mostrare:
- Livello INFO per messaggi generali
- Livello DEBUG per il package dell'applicazione
- Livello DEBUG per Spring Security

### Personalizzazione

#### Aggiungere nuovi utenti
Modifica il file `SecurityConfig.java`:
```java
UserDetails newUser = User.builder()
    .username("nome")
    .password(passwordEncoder().encode("password"))
    .roles("USER")
    .build();
```

#### Modificare stili
Edita il file `/static/css/custom.css`

#### Aggiungere nuove pagine
1. Crea un metodo nel controller appropriato
2. Crea il template HTML in `/templates`
3. Configura le regole di accesso in `SecurityConfig.java`

## 🏗 Build & Deploy

### Build per produzione
```bash
./mvnw clean package -DskipTests
```

### Docker (opzionale)
```dockerfile
FROM eclipse-temurin:21-jdk
WORKDIR /app
COPY target/corsontt38-0.0.1-SNAPSHOT.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

Build e run:
```bash
docker build -t corsontt38:latest .
docker run -p 8080:8080 corsontt38:latest
```

## 🔍 Analisi Qualità Codice

### Prerequisiti SonarQube

1. **SonarQube Server**: deve essere in esecuzione su `http://localhost:9000`
   - Download: https://www.sonarsource.com/products/sonarqube/downloads/
   - Quick Start con Docker:
   ```bash
   docker run -d --name sonarqube -p 9000:9000 sonarqube:latest
   ```

2. **Token Autenticazione** (opzionale per localhost):
   - Accedi a SonarQube: http://localhost:9000
   - User > My Account > Security > Generate Tokens
   - Salva il token come variabile d'ambiente:
   ```powershell
   $env:SONAR_TOKEN="your-token"
   ```

### Esecuzione Analisi

#### Metodo 1: Script PowerShell (Consigliato)

```powershell
# Analisi standard
.\scripts\run-sonar-analysis.ps1

# Con autenticazione
.\scripts\run-sonar-analysis.ps1 -SonarToken "sqp_your_token"

# Con pulizia completa
.\scripts\run-sonar-analysis.ps1 -Clean -Verbose
```

#### Metodo 2: Maven Diretto

```bash
# Compilazione, test e coverage
./mvnw clean verify

# Analisi SonarQube
./mvnw sonar:sonar
```

#### Metodo 3: Comando Completo

```bash
./mvnw clean verify sonar:sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.projectKey=corso-ntt-38
```

### Visualizzare Risultati

Dopo l'esecuzione dell'analisi:

1. Aprire browser su: http://localhost:9000
2. Login (default: admin/admin)
3. Cercare progetto "Corso NTT 38"
4. Visualizzare:
   - **Overview**: riepilogo metriche (Bugs, Vulnerabilities, Code Smells, Coverage, Duplications)
   - **Issues**: dettaglio problemi per severità (Blocker, Critical, Major, Minor, Info)
   - **Measures**: metriche dettagliate (complessità, dimensioni, documentazione)
   - **Code**: navigazione codice sorgente con annotazioni

### Metriche Monitorate

- **Reliability**: Bugs e Reliability Rating (A-E)
- **Security**: Vulnerabilities, Security Hotspots, Security Rating
- **Maintainability**: Code Smells, Technical Debt, Maintainability Rating
- **Coverage**: Line Coverage, Branch Coverage, Unit Tests
- **Duplications**: Duplicated Lines, Duplicated Blocks
- **Size**: Lines of Code, Functions, Classes, Files
- **Complexity**: Cyclomatic Complexity, Cognitive Complexity

### Quality Gate

Il progetto è configurato con Quality Gate personalizzato:

- ✅ Coverage > 50%
- ✅ Duplications < 3%
- ✅ Maintainability Rating ≥ A
- ✅ Reliability Rating ≥ A
- ✅ Security Rating ≥ A

### Troubleshooting

**Errore: "Sonar server can not be reached"**
- Verificare che SonarQube sia avviato: `docker ps`
- Navigare a http://localhost:9000 per confermare
- Provare con IP esplicito: `http://127.0.0.1:9000`

**Code Coverage = 0%**
- Eseguire `./mvnw test` prima di `./mvnw sonar:sonar`
- Usare comando completo: `./mvnw clean verify sonar:sonar`
- Verificare report JaCoCo: `target/site/jacoco/jacoco.xml`

**Errore: "401 Unauthorized"**
- Generare token SonarQube valido da UI
- Usare `-Dsonar.token=` nel comando Maven

### Configurazione

La configurazione SonarQube è definita in:
- **pom.xml**: Plugin Maven (sonar-maven-plugin, jacoco-maven-plugin)
- **Proprietà**: Endpoint server, project key, exclusions, coverage paths
- **Script**: `scripts/run-sonar-analysis.ps1` per automazione completa

Per personalizzare esclusioni o modificare Quality Gate, edita la sezione `<properties>` in `pom.xml`.

## �📝 Note

- Le password sono cifrate usando BCrypt
- CSRF protection è abilitato di default
- Le sessioni vengono invalidate al logout
- Bootstrap e le dipendenze CSS/JS sono caricate da CDN

## 🤝 Contribuire

1. Fork del progetto
2. Crea un branch per la feature (`git checkout -b feature/AmazingFeature`)
3. Commit dei cambiamenti (`git commit -m 'Add some AmazingFeature'`)
4. Push del branch (`git push origin feature/AmazingFeature`)
5. Apri una Pull Request

## 📄 Licenza

Questo progetto è stato realizzato per scopi didattici nell'ambito del Corso NTT 38.

## 👨‍💻 Autore

Corso DevOps NTT - Gruppo 38

## 📧 Supporto

Per domande o problemi, apri una issue su GitLab.

---

⭐️ Se questo progetto ti è stato utile, lascia una stella!


## Suggestions for a good README

Every project is different, so consider which of these sections apply to yours. The sections used in the template are suggestions for most open source projects. Also keep in mind that while a README can be too long and detailed, too long is better than too short. If you think your README is too long, consider utilizing another form of documentation rather than cutting out information.

## Name
Choose a self-explaining name for your project.

## Description
Let people know what your project can do specifically. Provide context and add a link to any reference visitors might be unfamiliar with. A list of Features or a Background subsection can also be added here. If there are alternatives to your project, this is a good place to list differentiating factors.

## Badges
On some READMEs, you may see small images that convey metadata, such as whether or not all the tests are passing for the project. You can use Shields to add some to your README. Many services also have instructions for adding a badge.

## Visuals
Depending on what you are making, it can be a good idea to include screenshots or even a video (you'll frequently see GIFs rather than actual videos). Tools like ttygif can help, but check out Asciinema for a more sophisticated method.

## Installation
Within a particular ecosystem, there may be a common way of installing things, such as using Yarn, NuGet, or Homebrew. However, consider the possibility that whoever is reading your README is a novice and would like more guidance. Listing specific steps helps remove ambiguity and gets people to using your project as quickly as possible. If it only runs in a specific context like a particular programming language version or operating system or has dependencies that have to be installed manually, also add a Requirements subsection.

## Usage
Use examples liberally, and show the expected output if you can. It's helpful to have inline the smallest example of usage that you can demonstrate, while providing links to more sophisticated examples if they are too long to reasonably include in the README.

## Support
Tell people where they can go to for help. It can be any combination of an issue tracker, a chat room, an email address, etc.

## Roadmap
If you have ideas for releases in the future, it is a good idea to list them in the README.

## Contributing
State if you are open to contributions and what your requirements are for accepting them.

For people who want to make changes to your project, it's helpful to have some documentation on how to get started. Perhaps there is a script that they should run or some environment variables that they need to set. Make these steps explicit. These instructions could also be useful to your future self.

You can also document commands to lint the code or run tests. These steps help to ensure high code quality and reduce the likelihood that the changes inadvertently break something. Having instructions for running tests is especially helpful if it requires external setup, such as starting a Selenium server for testing in a browser.

## Authors and acknowledgment
Show your appreciation to those who have contributed to the project.

## License
For open source projects, say how it is licensed.

## Project status
If you have run out of energy or time for your project, put a note at the top of the README saying that development has slowed down or stopped completely. Someone may choose to fork your project or volunteer to step in as a maintainer or owner, allowing your project to keep going. You can also make an explicit request for maintainers.
