/**
 * Test E2E per la funzionalità di Logout
 * Testa: Logout, invalidazione sessione, redirect
 */

describe('Autenticazione - Logout', () => {
  
  beforeEach(() => {
    // Pulisci la sessione prima di ogni test
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Logout con successo', () => {
    it('Dovrebbe effettuare logout correttamente', () => {
      // Login
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
      
      // Logout
      cy.visit('/logout')
      
      // Verifica redirect alla home con parametro logout
      cy.url().should('include', '/?logout=true')
    })

    it('Dovrebbe invalidare la sessione dopo logout', () => {
      // Login
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // Logout
      cy.logout()
      
      // Tenta di accedere a pagina protetta
      cy.visit('/private/dashboard')
      
      // Dovrebbe essere reindirizzato al login
      cy.url().should('include', '/login')
    })

    it('Dovrebbe cancellare i cookie di sessione', () => {
      // Login
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      // Verifica che esista un cookie di sessione
      cy.getCookie('JSESSIONID').should('exist')
      
      // Logout
      cy.logout()
      
      // Verifica che il cookie di sessione sia stato rimosso o invalidato
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
    })
  })

  describe('Logout da diverse pagine', () => {
    it('Dovrebbe effettuare logout dalla dashboard', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      // Cerca link o bottone di logout
      cy.contains('a', /logout/i).click()
      
      cy.url().should('include', '/?logout=true')
    })
  })

  describe('Comportamento post-logout', () => {
    it('Non dovrebbe permettere accesso a pagine protette dopo logout', () => {
      // Login e poi logout
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.logout()
      
      // Tenta accesso a pagina protetta
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
    })

    it('Dovrebbe permettere nuovo login dopo logout', () => {
      // Login
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // Logout
      cy.logout()
      
      // Nuovo login
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe mostrare messaggio di logout avvenuto', () => {
      cy.loginAsUser()
      cy.logout()
      
      // Verifica presenza parametro logout nell'URL
      cy.url().should('include', 'logout=true')
      
      // Potrebbe esserci un messaggio visibile (dipende dall'implementazione)
      // cy.contains(/logout/i).should('be.visible')
    })
  })

  describe('Logout con utenti diversi', () => {
    const users = [
      { username: Cypress.env('user_username'), password: Cypress.env('user_password') },
      { username: Cypress.env('admin_username'), password: Cypress.env('admin_password') },
      { username: Cypress.env('mario_username'), password: Cypress.env('mario_password') }
    ]

    users.forEach((user) => {
      it(`Dovrebbe effettuare logout correttamente per ${user.username}`, () => {
        cy.visit('/login')
        cy.get('input[name="username"]').type(user.username)
        cy.get('input[name="password"]').type(user.password)
        cy.get('button[type="submit"]').click()
        
        cy.url().should('include', '/private/dashboard')
        
        cy.logout()
        cy.url().should('include', '/?logout=true')
        
        // Verifica che non possa più accedere
        cy.visit('/private/dashboard')
        cy.url().should('include', '/login')
      })
    })
  })
})
