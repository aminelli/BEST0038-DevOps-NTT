# Prompt per Applicazione Web Java Spring Boot

## Contesto
Sei un esperto in:
- DevOps e DevOps Toolchains
- Java 21
- Spring Boot 4.0.x e Spring MVC
- Spring Security
- Thymeleaf Template Engine
- CSS/HTML/JavaScript
- Bootstrap 5
- Docker e containerizzazione
- Kubernetes
- Jenkins CI/CD

## Obiettivo
Modifica il progetto Java corrente per realizzare un'applicazione web completa con gestione dell'autenticazione e aree pubbliche/private.

## Requisiti Funzionali

### 1. Sistema di Autenticazione
- Implementare un sistema di login con Spring Security
- Utilizzare autenticazione in-memory con utenti hardcoded
- Definire almeno 2-3 utenti di test con:
  - Username
  - Password (encoded con BCrypt)
  - Ruoli (USER, ADMIN)

### 2. Aree Pubbliche
- **Home Page Pubblica** (`/` o `/home`)
  - Accessibile senza autenticazione
  - Breve descrizione dell'applicazione
  - Link alla pagina About e al Login
  
- **About Page** (`/about`)
  - Accessibile senza autenticazione
  - Informazioni sul progetto
  - Tecnologie utilizzate

### 3. Area Privata
- **Dashboard/Home Privata** (`/private/dashboard`)
  - Accessibile solo dopo login
  - Messaggio di benvenuto personalizzato con username
  - Informazioni sull'utente loggato
  - Pulsante di logout

### 4. Gestione Navigazione
- Redirect automatico a `/private/dashboard` dopo login riuscito
- Redirect a `/login` quando si tenta di accedere ad aree private senza autenticazione
- Redirect a home page pubblica dopo logout

## Requisiti Tecnici

### Backend
- **Framework**: Spring Boot 4.0.x
- **Security**: Spring Security per gestione autenticazione/autorizzazione
- **Template Engine**: Thymeleaf per rendering lato server
- **Structure**: Architettura MVC con separazione Controller/Service/Model

### Frontend
- **Framework CSS**: Bootstrap 5.x
- **Layout**: Responsive design
- **Componenti**:
  - Navbar con logo e menu di navigazione (presente in tutte le pagine)
  - Form di login stilizzato
  - Footer (opzionale)

### Navbar/Header
- Logo o titolo applicazione
- Link alle pagine pubbliche (Home, About)
- Link dinamico: "Login" (se non autenticato) o "Dashboard" + "Logout" (se autenticato)
- Responsive con menu hamburger su mobile

## Struttura File Consigliata
```
src/main/
├── java/com/corso/devops/corsontt38/
│   ├── config/
│   │   └── SecurityConfig.java
│   ├── controller/
│   │   ├── HomeController.java
│   │   ├── AuthController.java
│   │   └── PrivateAreaController.java
│   └── Corsontt38Application.java
├── resources/
│   ├── templates/
│   │   ├── index.html
│   │   ├── about.html
│   │   ├── login.html
│   │   ├── private/
│   │   │   └── dashboard.html
│   │   └── fragments/
│   │       ├── header.html
│   │       └── footer.html
│   ├── static/
│   │   ├── css/
│   │   │   └── custom.css
│   │   └── js/
│   │       └── custom.js
│   └── application.properties
```

## Best Practices
1. Utilizzare Thymeleaf fragments per header/footer condivisi
2. Usare Spring Security annotations (`@PreAuthorize`, `@Secured`)
3. Implementare CSRF protection (abilitato di default in Spring Security)
4. Usare BCryptPasswordEncoder per le password
5. Gestire correttamente gli errori (404, 403, 500)
6. Aggiungere logging appropriato

## Note Aggiuntive
- Assicurati che il codice sia ben commentato
- Le classi devono seguire le convenzioni Java (CamelCase, nomi significativi)
- I template Thymeleaf devono essere validi HTML5
- Testare tutti i flussi di autenticazione e autorizzazione 