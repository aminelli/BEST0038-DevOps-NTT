/**
 * Test E2E per la funzionalità di Login
 * Testa: Login con successo, errori, logout
 */

describe('Autenticazione - Login', () => {
  
  beforeEach(() => {
    // Pulisci la sessione prima di ogni test
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Pagina di Login', () => {
    beforeEach(() => {
      cy.visit('/login')
    })

    it('Dovrebbe mostrare il form di login', () => {
      cy.url().should('include', '/login')
      cy.get('form').should('be.visible')
    })

    it('Dovrebbe avere i campi username e password', () => {
      cy.get('input[name="username"]').should('be.visible')
      cy.get('input[name="password"]').should('be.visible')
    })

    it('Dovrebbe avere un pulsante di submit', () => {
      cy.get('button[type="submit"]').should('be.visible')
    })

    it('Dovrebbe mostrare il titolo Login', () => {
      cy.get('h1, h2, h3').should('contain', 'Login')
    })
  })

  describe('Login con successo', () => {
    it('Dovrebbe effettuare login con credenziali USER valide', () => {
      cy.visit('/login')
      
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // Verifica redirect alla dashboard
      cy.url().should('include', '/private/dashboard')
      
      // Verifica che sia visibile il nome utente
      cy.contains(Cypress.env('user_username'), { matchCase: false }).should('be.visible')
    })

    it('Dovrebbe effettuare login con credenziali ADMIN valide', () => {
      cy.visit('/login')
      
      cy.get('input[name="username"]').type(Cypress.env('admin_username'))
      cy.get('input[name="password"]').type(Cypress.env('admin_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('admin_username'), { matchCase: false }).should('be.visible')
    })

    it('Dovrebbe effettuare login con utente Mario', () => {
      cy.visit('/login')
      
      cy.get('input[name="username"]').type(Cypress.env('mario_username'))
      cy.get('input[name="password"]').type(Cypress.env('mario_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('mario_username'), { matchCase: false }).should('be.visible')
    })

    it('Dovrebbe mantenere la sessione dopo il login', () => {
      cy.visit('/login')
      
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
      
      // Naviga a home e verifica che la sessione sia ancora attiva
      cy.visit('/')
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Login con errori', () => {
    beforeEach(() => {
      cy.visit('/login')
    })

    it('Dovrebbe mostrare errore con username errato', () => {
      cy.get('input[name="username"]').type('wronguser')
      cy.get('input[name="password"]').type('wrongpass')
      cy.get('button[type="submit"]').click()
      
      // Verifica che rimanga sulla pagina di login
      cy.url().should('include', '/login')
      
      // Verifica presenza parametro error
      cy.url().should('include', 'error=true')
    })

    it('Dovrebbe mostrare errore con password errata', () => {
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type('wrongpassword')
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/login')
      cy.url().should('include', 'error=true')
    })

    it('Dovrebbe gestire campi vuoti', () => {
      // Tenta submit senza compilare i campi
      cy.get('button[type="submit"]').click()
      
      // HTML5 validation dovrebbe prevenire il submit
      cy.get('input[name="username"]:invalid').should('exist')
    })

    it('Dovrebbe permettere retry dopo errore', () => {
      // Primo tentativo con credenziali errate
      cy.get('input[name="username"]').type('wronguser')
      cy.get('input[name="password"]').type('wrongpass')
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', 'error=true')
      
      // Secondo tentativo con credenziali corrette
      cy.get('input[name="username"]').clear().type(Cypress.env('user_username'))
      cy.get('input[name="password"]').clear().type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Login con custom command', () => {
    it('Dovrebbe effettuare login usando cy.loginAsUser()', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe effettuare login usando cy.loginAsAdmin()', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe effettuare login usando cy.loginAsMario()', () => {
      cy.loginAsMario()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Redirect dopo login', () => {
    it('Dovrebbe reindirizzare alla dashboard dopo login riuscito', () => {
      cy.visit('/login')
      
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      // Verifica redirect automatico alla dashboard
      cy.url().should('include', '/private/dashboard')
    })
  })
})
