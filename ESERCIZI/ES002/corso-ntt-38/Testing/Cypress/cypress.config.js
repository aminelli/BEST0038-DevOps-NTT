const { defineConfig } = require('cypress')

module.exports = defineConfig({
  e2e: {
    // Base URL dell'applicazione
    baseUrl: 'http://localhost:8080',
    
    // Configurazione viewport
    viewportWidth: 1280,
    viewportHeight: 720,
    
    // Timeout
    defaultCommandTimeout: 10000,
    pageLoadTimeout: 30000,
    requestTimeout: 10000,
    responseTimeout: 30000,
    
    // Video e screenshot
    video: true,
    videoCompression: 32,
    videosFolder: 'cypress/videos',
    screenshotsFolder: 'cypress/screenshots',
    screenshotOnRunFailure: true,
    
    // Retry dei test falliti
    retries: {
      runMode: 2,
      openMode: 0
    },
    
    // Setup degli hooks
    setupNodeEvents(on, config) {
      // implement node event listeners here
      
      // Task personalizzati (se necessario)
      on('task', {
        log(message) {
          console.log(message)
          return null
        }
      })
      
      return config
    },
    
    // Pattern per i file di test
    specPattern: 'cypress/e2e/**/*.cy.{js,jsx,ts,tsx}',
    
    // File di supporto
    supportFile: 'cypress/support/e2e.js',
    
    // Fixtures
    fixturesFolder: 'cypress/fixtures',
    
    // Esclusioni
    excludeSpecPattern: [
      '**/__snapshots__/*',
      '**/__image_snapshots__/*'
    ],
    
    // Configurazione browser
    chromeWebSecurity: false,
    
    // Environment variables
    env: {
      // Credenziali utenti di test
      user_username: 'user',
      user_password: 'user123',
      admin_username: 'admin',
      admin_password: 'admin123',
      mario_username: 'mario',
      mario_password: 'mario123'
    }
  }
})
