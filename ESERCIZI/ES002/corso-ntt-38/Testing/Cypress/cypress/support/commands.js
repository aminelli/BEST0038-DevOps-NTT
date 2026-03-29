// ***********************************************
// Custom commands for Cypress tests
// ***********************************************

/**
 * Custom command per effettuare il login
 * @param {string} username - Nome utente
 * @param {string} password - Password
 * @example cy.login('user', 'user123')
 */
Cypress.Commands.add('login', (username, password) => {
  cy.session([username, password], () => {
    cy.visit('/login')
    cy.get('input[name="username"]').type(username)
    cy.get('input[name="password"]').type(password)
    cy.get('button[type="submit"]').click()
    
    // Verifica che il login sia avvenuto con successo
    cy.url().should('include', '/private/dashboard')
  })
})

/**
 * Custom command per login come utente normale
 * @example cy.loginAsUser()
 */
Cypress.Commands.add('loginAsUser', () => {
  cy.login(Cypress.env('user_username'), Cypress.env('user_password'))
})

/**
 * Custom command per login come amministratore
 * @example cy.loginAsAdmin()
 */
Cypress.Commands.add('loginAsAdmin', () => {
  cy.login(Cypress.env('admin_username'), Cypress.env('admin_password'))
})

/**
 * Custom command per login come Mario
 * @example cy.loginAsMario()
 */
Cypress.Commands.add('loginAsMario', () => {
  cy.login(Cypress.env('mario_username'), Cypress.env('mario_password'))
})

/**
 * Custom command per logout
 * @example cy.logout()
 */
Cypress.Commands.add('logout', () => {
  cy.visit('/logout')
  cy.url().should('include', '/?logout=true')
})

/**
 * Custom command per verificare che la navbar contenga un elemento
 * @param {string} text - Testo da cercare nella navbar
 * @example cy.checkNavbar('Home')
 */
Cypress.Commands.add('checkNavbar', (text) => {
  cy.get('nav').should('contain', text)
})

/**
 * Custom command per verificare il footer
 * @example cy.checkFooter()
 */
Cypress.Commands.add('checkFooter', () => {
  cy.get('footer').should('be.visible')
})

/**
 * Custom command per verificare che sia presente un messaggio di errore
 * @param {string} message - Messaggio da verificare
 * @example cy.checkErrorMessage('Invalid credentials')
 */
Cypress.Commands.add('checkErrorMessage', (message) => {
  cy.get('.alert-danger, .error, [role="alert"]')
    .should('be.visible')
    .and('contain', message)
})

/**
 * Custom command per verificare che sia presente un messaggio di successo
 * @param {string} message - Messaggio da verificare
 * @example cy.checkSuccessMessage('Login successful')
 */
Cypress.Commands.add('checkSuccessMessage', (message) => {
  cy.get('.alert-success, .success, [role="alert"]')
    .should('be.visible')
    .and('contain', message)
})
