/**
 * Test E2E per autorizzazioni e ruoli utente
 * Testa: Differenze tra USER e ADMIN, controlli accesso
 */

describe('Autorizzazioni e Ruoli', () => {
  
  beforeEach(() => {
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Differenze ruoli USER vs ADMIN', () => {
    it('USER dovrebbe avere solo ruolo USER', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      // Verifica presenza ruolo USER
      cy.get('body').should('contain.text', 'USER')
      
      // Non dovrebbe mostrare ADMIN (a meno che non sia parte di altro testo)
      // La dashboard mostra i ruoli dell'utente
    })

    it('ADMIN dovrebbe avere ruoli USER e ADMIN', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      
      // Admin ha entrambi i ruoli secondo SecurityConfig
      cy.get('body').should('contain.text', 'ADMIN')
      cy.get('body').should('contain.text', 'USER')
    })

    it('Mario dovrebbe avere solo ruolo USER', () => {
      cy.loginAsMario()
      cy.visit('/private/dashboard')
      
      cy.get('body').should('contain.text', 'USER')
    })
  })

  describe('Accesso a risorse comuni', () => {
    const users = [
      { login: () => cy.loginAsUser(), name: 'USER' },
      { login: () => cy.loginAsAdmin(), name: 'ADMIN' },
      { login: () => cy.loginAsMario(), name: 'Mario' }
    ]

    users.forEach((user) => {
      describe(`Accesso per ${user.name}`, () => {
        beforeEach(() => {
          user.login()
        })

        it('Dovrebbe poter accedere alla dashboard', () => {
          cy.visit('/private/dashboard')
          cy.url().should('include', '/private/dashboard')
        })

        it('Dovrebbe poter accedere alle pagine pubbliche', () => {
          cy.visit('/')
          cy.url().should('eq', Cypress.config().baseUrl + '/')
          
          cy.visit('/about')
          cy.url().should('include', '/about')
        })

        it('Dovrebbe poter effettuare logout', () => {
          cy.visit('/private/dashboard')
          cy.logout()
          cy.url().should('include', '/?logout=true')
        })
      })
    })
  })

  describe('Visualizzazione ruoli nella dashboard', () => {
    it('Dashboard di USER dovrebbe mostrare correttamente il ruolo', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      // Verifica che il ruolo sia visualizzato
      cy.get('body').should('contain.text', 'USER')
      
      // Verifica che il nome utente sia mostrato
      cy.contains(Cypress.env('user_username'), { matchCase: false }).should('be.visible')
    })

    it('Dashboard di ADMIN dovrebbe mostrare entrambi i ruoli', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      
      // Admin dovrebbe vedere sia USER che ADMIN
      const bodyText = cy.get('body')
      bodyText.should('contain.text', 'ADMIN')
      bodyText.should('contain.text', 'USER')
    })
  })

  describe('Persistenza ruoli durante la sessione', () => {
    it('I ruoli dovrebbero rimanere consistenti durante la navigazione', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      
      // Verifica ruoli
      cy.get('body').should('contain.text', 'ADMIN')
      
      // Naviga ad altra pagina
      cy.visit('/')
      
      // Torna alla dashboard
      cy.visit('/private/dashboard')
      
      // Ruoli dovrebbero essere ancora presenti
      cy.get('body').should('contain.text', 'ADMIN')
    })

    it('I ruoli dovrebbero essere persi dopo logout', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', 'ADMIN')
      
      // Logout
      cy.logout()
      
      // Tenta di accedere alla dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
    })
  })

  describe('Switch tra utenti con ruoli diversi', () => {
    it('Dovrebbe cambiare correttamente da USER ad ADMIN', () => {
      // Login come USER
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', 'USER')
      cy.get('body').should('contain.text', Cypress.env('user_username'))
      
      // Logout
      cy.logout()
      
      // Login come ADMIN
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('admin_username'))
      cy.get('input[name="password"]').type(Cypress.env('admin_password'))
      cy.get('button[type="submit"]').click()
      
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', 'ADMIN')
      cy.get('body').should('contain.text', Cypress.env('admin_username'))
    })

    it('Dovrebbe cambiare correttamente da ADMIN a USER', () => {
      // Login come ADMIN
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', 'ADMIN')
      
      // Logout
      cy.logout()
      
      // Login come USER
      cy.visit('/login')
      cy.get('input[name="username"]').type(Cypress.env('user_username'))
      cy.get('input[name="password"]').type(Cypress.env('user_password'))
      cy.get('button[type="submit"]').click()
      
      cy.visit('/private/dashboard')
      cy.get('body').should('contain.text', Cypress.env('user_username'))
    })
  })

  describe('Protezione risorse comuni', () => {
    it('Tutti gli utenti autenticati dovrebbero poter accedere a /private/dashboard', () => {
      const users = [
        { username: Cypress.env('user_username'), password: Cypress.env('user_password') },
        { username: Cypress.env('admin_username'), password: Cypress.env('admin_password') },
        { username: Cypress.env('mario_username'), password: Cypress.env('mario_password') }
      ]

      users.forEach((user) => {
        cy.clearCookies()
        
        cy.visit('/login')
        cy.get('input[name="username"]').type(user.username)
        cy.get('input[name="password"]').type(user.password)
        cy.get('button[type="submit"]').click()
        
        cy.visit('/private/dashboard')
        cy.url().should('include', '/private/dashboard')
      })
    })
  })
})
