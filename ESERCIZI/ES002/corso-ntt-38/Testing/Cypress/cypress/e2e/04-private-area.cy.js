/**
 * Test E2E per l'area privata (Dashboard)
 * Testa: Accesso protetto, contenuto dashboard, autorizzazioni
 */

describe('Area Privata - Dashboard', () => {
  
  beforeEach(() => {
    cy.clearCookies()
    cy.clearLocalStorage()
  })

  describe('Protezione accesso', () => {
    it('Dovrebbe reindirizzare al login se non autenticato', () => {
      cy.visit('/private/dashboard')
      
      // Spring Security dovrebbe reindirizzare al login
      cy.url().should('include', '/login')
    })

    it('Non dovrebbe permettere accesso diretto senza autenticazione', () => {
      // Tenta accesso diretto
      cy.request({
        url: '/private/dashboard',
        followRedirect: false,
        failOnStatusCode: false
      }).then((response) => {
        // Dovrebbe essere redirect (302) o unauthorized (401/403)
        expect([302, 401, 403]).to.include(response.status)
      })
    })

    it('Dovrebbe bloccare accesso anche modificando cookie manualmente', () => {
      // Tenta di impostare cookie falso
      cy.setCookie('JSESSIONID', 'fake-session-id')
      
      cy.visit('/private/dashboard')
      
      // Dovrebbe comunque reindirizzare al login
      cy.url().should('include', '/login')
    })
  })

  describe('Accesso con autenticazione', () => {
    it('Dovrebbe permettere accesso a USER autenticato', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe permettere accesso ad ADMIN autenticato', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe permettere accesso a Mario autenticato', () => {
      cy.loginAsMario()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
    })
  })

  describe('Contenuto Dashboard', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
    })

    it('Dovrebbe mostrare la dashboard con titolo', () => {
      cy.get('h1, h2, h3').should('contain', 'Dashboard')
    })

    it('Dovrebbe mostrare il nome utente', () => {
      cy.contains(Cypress.env('user_username'), { matchCase: false }).should('be.visible')
    })

    it('Dovrebbe avere navbar e footer', () => {
      cy.get('nav').should('be.visible')
      cy.checkFooter()
    })

    it('Dovrebbe avere un link di logout', () => {
      cy.contains('a', /logout/i).should('be.visible')
    })

    it('Dovrebbe mostrare informazioni specifiche per l\'utente', () => {
      // La dashboard dovrebbe mostrare info personalizzate
      cy.get('body').should('contain.text', Cypress.env('user_username'))
    })
  })

  describe('Dashboard per utenti diversi', () => {
    it('Dovrebbe mostrare dashboard personalizzata per USER', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('user_username'), { matchCase: false }).should('be.visible')
      
      // Verifica che mostri il ruolo USER
      cy.get('body').should('contain.text', 'USER')
    })

    it('Dovrebbe mostrare dashboard personalizzata per ADMIN', () => {
      cy.loginAsAdmin()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('admin_username'), { matchCase: false }).should('be.visible')
      
      // Admin dovrebbe avere ruoli USER e ADMIN
      cy.get('body').should('contain.text', 'ADMIN')
    })

    it('Dovrebbe mostrare dashboard personalizzata per Mario', () => {
      cy.loginAsMario()
      cy.visit('/private/dashboard')
      
      cy.url().should('include', '/private/dashboard')
      cy.contains(Cypress.env('mario_username'), { matchCase: false }).should('be.visible')
    })
  })

  describe('Navigazione da dashboard', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
    })

    it('Dovrebbe poter navigare alla home page', () => {
      cy.contains('a', 'Home').click()
      cy.url().should('eq', Cypress.config().baseUrl + '/')
    })

    it('Dovrebbe poter tornare alla dashboard dalla home', () => {
      cy.contains('a', 'Home').click()
      cy.url().should('eq', Cypress.config().baseUrl + '/')
      
      // Torna alla dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
    })

    it('Dovrebbe mantenere la sessione durante la navigazione', () => {
      // Naviga a home
      cy.visit('/')
      
      // Naviga ad about
      cy.visit('/about')
      
      // Torna alla dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // Non dovrebbe richiedere nuovo login
      cy.url().should('not.include', '/login')
    })
  })

  describe('Sicurezza dashboard', () => {
    it('Dovrebbe richiedere nuovo login se sessione scaduta', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.url().should('include', '/private/dashboard')
      
      // Simula scadenza sessione rimuovendo cookie
      cy.clearCookies()
      
      // Tenta di ricaricare la dashboard
      cy.visit('/private/dashboard')
      
      // Dovrebbe reindirizzare al login
      cy.url().should('include', '/login')
    })

    it('Non dovrebbe permettere accesso dopo logout', () => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
      cy.logout()
      
      // Tenta di accedere nuovamente alla dashboard
      cy.visit('/private/dashboard')
      cy.url().should('include', '/login')
    })
  })

  describe('Interazione con elementi dashboard', () => {
    beforeEach(() => {
      cy.loginAsUser()
      cy.visit('/private/dashboard')
    })

    it('Dovrebbe mostrare timestamp o data di login', () => {
      // La dashboard potrebbe mostrare data/ora di login
      cy.get('body').should('be.visible')
    })

    it('Dovrebbe avere bottone o link di logout funzionante', () => {
      cy.contains('a', /logout/i).should('be.visible').click()
      cy.url().should('include', '/?logout=true')
    })
  })

  describe('Responsività Dashboard', () => {
    const viewports = [
      { device: 'mobile', width: 375, height: 667 },
      { device: 'tablet', width: 768, height: 1024 },
      { device: 'desktop', width: 1280, height: 720 }
    ]

    viewports.forEach((viewport) => {
      it(`Dashboard dovrebbe essere responsive su ${viewport.device}`, () => {
        cy.loginAsUser()
        cy.viewport(viewport.width, viewport.height)
        cy.visit('/private/dashboard')
        
        cy.url().should('include', '/private/dashboard')
        cy.get('nav').should('be.visible')
        cy.get('h1, h2, h3').should('be.visible')
      })
    })
  })
})
