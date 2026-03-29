/**
 * Test E2E per il flusso completo dell'applicazione
 * Simula scenari realistici di utilizzo dell'app
 */

describe('Flusso End-to-End Completo', () => {
  
  beforeEach(() => {
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Scenario 1: Nuovo visitatore', () => {
    it('Un nuovo utente dovrebbe esplorare il sito pubblico e poi effettuare login', () => {
      // 1. Visita la home page
      cy.visit('/')
      cy.get('h1, h2').should('be.visible')
      
      // 2. Naviga alla pagina About
      cy.contains('a', 'About').click()
      cy.url().should('include', '/about')
      
      // 3. Tenta di accedere all'area privata (viene reindirizzato)
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
      
      // 4. Effettua il login
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // 5. Accede alla dashboard
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('user_username'), { matchCase: false }).should('be.visible')
      
      // 6. Naviga alle pagine pubbliche mentre è loggato
      cy.visit('/')
      cy.url().should('eq', Cypress.config().baseUrl + '/')
      
      // 7. Torna alla dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // 8. Effettua logout
      cy.contains('a', /logout/i).click()
      cy.url().should('include', '/?logout=true')
    })
  })

  describe('Scenario 2: Utente che ritorna', () => {
    it('Un utente esistente effettua login diretto', () => {
      // 1. Va direttamente al login
      cy.visit('/login')
      
      // 2. Compila le credenziali
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // 3. Viene reindirizzato alla dashboard
      cy.url().should('include', '/private/dashboard')
      
      // 4. Lavora nella dashboard
      cy.get('body').should('contain.text', Cypress.env('user_username'))
      
      // 5. Effettua logout quando finito
      cy.logout()
      cy.url().should('include', '/?logout=true')
    })
  })

  describe('Scenario 3: Errore di login e recupero', () => {
    it('Un utente sbaglia password e poi corregge', () => {
      // 1. Va al login
      cy.visit('/login')
      
      // 2. Inserisce password errata
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type('passwordErrata')
      cy.get('button[type="submit"]').click()
      
      // 3. Vede errore
      cy.url().should('include', '/login')
      cy.url().should('include', 'error=true')
      
      // 4. Corregge la password
      cy.get('input[name="username"]').clear().type(Cypress.env('user_username'))
      cy.get('input[name="password"]').clear().type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // 5. Login riuscito
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Scenario 4: Amministratore', () => {
    it('Un admin effettua login e accede alla dashboard', () => {
      // 1. Login come admin
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('admin_username'))
      cy.get('input[name="password"]').type(Cypress.env('admin_password'))
      cy.get('button[type="submit"]').click()
      
      // 2. Accede alla dashboard
      cy.url().should('include', '/private/dashboard')
      
      // 3. Verifica ruolo ADMIN
      cy.get('body').should('contain.text', 'ADMIN')
      cy.get('body').should('contain.text', Cypress.env('admin_username'))
      
      // 4. Naviga nel sito
      cy.visit('/')
      cy.visit('/about')
      cy.visit('/private/dashboard')
      
      // 5. Logout
      cy.logout()
    })
  })

  describe('Scenario 5: Sessione attiva', () => {
    it('Un utente mantiene la sessione attraverso la navigazione', () => {
      // 1. Login
      cy.loginAsUser()
      
      // 2. Visita dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // 3. Naviga a home
      cy.visit('/')
      
      // 4. Naviga ad about
      cy.visit('/about')
      
      // 5. Torna alla dashboard (senza re-login)
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      cy.url().should('not.include', '/login')
    })
  })

  describe('Scenario 6: Tentativo accesso non autorizzato', () => {
    it('Un visitatore non autenticato tenta di accedere direttamente alla dashboard', () => {
      // 1. Tenta accesso diretto
      cy.visit('/private/dashboard')
      
      // 2. Viene reindirizzato al login
      cy.url().should('include', '/login')
      
      // 3. Vede il form di login
      cy.get('input[name="username"]').should('be.visible')
      cy.get('input[name="password"]').should('be.visible')
    })
  })

  describe('Scenario 7: Logout e nuovo login', () => {
    it('Un utente effettua logout e poi login nuovamente', () => {
      // 1. Primo login
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // 2. Logout
      cy.logout()
      cy.url().should('include', '/?logout=true')
      
      // 3. Verifica che la sessione sia terminata
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
      
      // 4. Nuovo login
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // 5. Accesso riuscito
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Scenario 8: Navigazione completa', () => {
    it('Un utente esplora tutto il sito in modo sistematico', () => {
      // 1. Inizia dalla home
      cy.visit('/')
      cy.checkNavbar('Home')
      cy.checkNavbar('About')
      cy.checkFooter()
      
      // 2. Va ad About
      cy.contains('a', 'About').click()
      cy.url().should('include', '/about')
      
      // 3. Va al Login
      cy.contains('a', 'Login').click()
      cy.url().should('include', '/login')
      
      // 4. Effettua login
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // 5. Dashboard
      cy.url().should('include', '/private/dashboard')
      cy.get('body').should('contain.text', Cypress.env('user_username'))
      
      // 6. Torna alla home (loggato)
      cy.contains('a', 'Home').click()
      cy.url().should('match', /\/$/)
      
      // 7. Logout dalla home
      cy.visit('/logout')
      cy.url().should('include', '/?logout=true')
    })
  })

  describe('Scenario 9: Utenti multipli in sequenza', () => {
    it('Dovrebbe gestire correttamente il cambio di sessione tra utenti diversi', () => {
      // 1. Login utente normale
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', Cypress.env('user_username'))
      
      // 2. Logout
      cy.logout()
      
      // 3. Login admin
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('admin_username'))
      cy.get('input[name="password"]').type(Cypress.env('admin_password'))
      cy.get('button[type="submit"]').click()
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', Cypress.env('admin_username'))
      cy.get('body').should('contain.text', 'ADMIN')
      
      // 4. Logout
      cy.logout()
      
      // 5. Login Mario
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('mario_username'))
      cy.get('input[name="password"]').type(Cypress.env('mario_password'))
      cy.get('button[type="submit"]').click()
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', Cypress.env('mario_username'))
      
      // 6. Logout finale
      cy.logout()
    })
  })
})
