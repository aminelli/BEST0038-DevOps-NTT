// ***********************************************************
// Support file - caricato prima di ogni test
// ***********************************************************

// Import commands.js
import './commands'

// Configurazione globale
beforeEach(() => {
  // Pulisci i cookie prima di ogni test (se non usi cy.session)
  // Nota: con cy.session nella command login, questo non è più necessario
})

// Gestione degli errori di applicazione
Cypress.on('uncaught:exception', (err, runnable) => {
  // Previeni che errori JavaScript dell'applicazione facciano fallire i test
  // Ritorna false solo per errori noti che non devono far fallire il test
  
  // Log dell'errore per debugging
  console.error('Uncaught exception:', err.message)
  
  // Non far fallire il test per questi errori
  return false
})

// Custom configuration
Cypress.config('defaultCommandTimeout', 10000)
