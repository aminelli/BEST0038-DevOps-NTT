/**
 * Test E2E per le pagine pubbliche dell'applicazione
 * Testa: Home page e About page
 */

describe('Pagine Pubbliche', () => {
  
  describe('Home Page', () => {
    beforeEach(() => {
      cy.visit('/')
    })

    it('Dovrebbe caricare la home page correttamente', () => {
      cy.url().should('eq', Cypress.config().baseUrl + '/')
      cy.get('h1, h2').should('be.visible')
    })

    it('Dovrebbe mostrare il titolo corretto', () => {
      cy.title().should('not.be.empty')
    })

    it('Dovrebbe contenere la navbar', () => {
      cy.get('nav').should('be.visible')
    })

    it('Dovrebbe avere link a Home, About e Login nella navbar', () => {
      cy.checkNavbar('Home')
      cy.checkNavbar('About')
      cy.checkNavbar('Login')
    })

    it('Dovrebbe mostrare il footer', () => {
      cy.checkFooter()
    })

    it('Dovrebbe navigare alla pagina About dal link nella navbar', () => {
      cy.contains('a', 'About').click()
      cy.url().should('include', '/about')
    })

    it('Dovrebbe navigare alla pagina Login dal link nella navbar', () => {
      cy.contains('a', 'Login').click()
      cy.url().should('include', '/login')
    })

    it('Dovrebbe avere CSS caricato correttamente', () => {
      cy.get('body').should('have.css', 'margin')
    })
  })

  describe('About Page', () => {
    beforeEach(() => {
      cy.visit('/about')
    })

    it('Dovrebbe caricare la pagina About correttamente', () => {
      cy.url().should('include', '/about')
      cy.get('h1, h2').should('be.visible')
    })

    it('Dovrebbe mostrare il titolo corretto', () => {
      cy.title().should('include', 'About')
    })

    it('Dovrebbe contenere informazioni sull\'applicazione', () => {
      // Verifica che ci sia del contenuto testuale
      cy.get('body').should('contain.text', 'Spring Boot')
        .or('contain.text', 'Java')
        .or('contain.text', 'DevOps')
    })

    it('Dovrebbe mostrare la navbar e il footer', () => {
      cy.get('nav').should('be.visible')
      cy.checkFooter()
    })

    it('Dovrebbe poter navigare alla Home page', () => {
      cy.contains('a', 'Home').click()
      cy.url().should('eq', Cypress.config().baseUrl + '/')
    })
  })

  describe('Navigazione tra pagine pubbliche', () => {
    it('Dovrebbe permettere la navigazione Home -> About -> Home', () => {
      cy.visit('/')
      cy.contains('a', 'About').click()
      cy.url().should('include', '/about')
      cy.contains('a', 'Home').click()
      cy.url().should('eq', Cypress.config().baseUrl + '/')
    })

    it('Dovrebbe mantenere la navbar consistente tra le pagine', () => {
      cy.visit('/')
      cy.get('nav').should('be.visible')
      
      cy.visit('/about')
      cy.get('nav').should('be.visible')
    })
  })

  describe('Responsività', () => {
    const viewports = [
      { device: 'mobile', width: 375, height: 667 },
      { device: 'tablet', width: 768, height: 1024 },
      { device: 'desktop', width: 1280, height: 720 }
    ]

    viewports.forEach((viewport) => {
      it(`Dovrebbe essere visibile su ${viewport.device} (${viewport.width}x${viewport.height})`, () => {
        cy.viewport(viewport.width, viewport.height)
        cy.visit('/')
        cy.get('nav').should('be.visible')
        cy.get('h1, h2').should('be.visible')
      })
    })
  })
})
