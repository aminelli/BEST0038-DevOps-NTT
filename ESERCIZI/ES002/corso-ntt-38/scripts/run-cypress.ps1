<#
.SYNOPSIS
    Script PowerShell per eseguire i test Cypress E2E

.DESCRIPTION
    Questo script facilita l'esecuzione dei test Cypress con diverse modalità:
    - Installazione dipendenze
    - Esecuzione test in modalità interattiva (UI)
    - Esecuzione test in modalità headless (CI/CD)
    - Esecuzione test specifici
    - Pulizia cache e artifact

.PARAMETER Action
    Azione da eseguire:
    - install: Installa le dipendenze npm
    - open: Apre Cypress in modalità interattiva
    - run: Esegue tutti i test in modalità headless
    - spec: Esegue un test specifico
    - clean: Pulisce cache, screenshots e video
    - verify: Verifica che l'applicazione sia in esecuzione

.PARAMETER TestSpec
    (Solo con -Action spec) Nome del file di test da eseguire
    Es: "01-public-pages.cy.js"

.PARAMETER Browser
    Browser da utilizzare (chrome, firefox, edge)
    Default: chrome

.EXAMPLE
    .\run-cypress.ps1 -Action install
    Installa le dipendenze npm

.EXAMPLE
    .\run-cypress.ps1 -Action open
    Apre Cypress in modalità interattiva

.EXAMPLE
    .\run-cypress.ps1 -Action run
    Esegue tutti i test in modalità headless

.EXAMPLE
    .\run-cypress.ps1 -Action spec -TestSpec "02-login.cy.js"
    Esegue solo i test di login

.EXAMPLE
    .\run-cypress.ps1 -Action run -Browser firefox
    Esegue i test con Firefox

.NOTES
    File Name  : run-cypress.ps1
    Author     : Corso NTT DevOps
    Requires   : PowerShell 5.1+, Node.js 16+, npm 7+
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateSet('install', 'open', 'run', 'spec', 'clean', 'verify')]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$TestSpec = "",

    [Parameter(Mandatory=$false)]
    [ValidateSet('chrome', 'firefox', 'edge')]
    [string]$Browser = "chrome"
)

# Colori per output
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Banner
function Show-Banner {
    Write-ColorOutput "`n========================================" "Cyan"
    Write-ColorOutput "  🧪 Cypress E2E Test Runner" "Cyan"
    Write-ColorOutput "  Spring Boot Application Testing" "Cyan"
    Write-ColorOutput "========================================`n" "Cyan"
}

# Verifica prerequisiti
function Test-Prerequisites {
    Write-ColorOutput "🔍 Verifica prerequisiti..." "Yellow"
    
    # Verifica Node.js
    try {
        $nodeVersion = node --version
        Write-ColorOutput "✅ Node.js: $nodeVersion" "Green"
    } catch {
        Write-ColorOutput "❌ Node.js non trovato! Installa Node.js 16+" "Red"
        exit 1
    }
    
    # Verifica npm
    try {
        $npmVersion = npm --version
        Write-ColorOutput "✅ npm: v$npmVersion" "Green"
    } catch {
        Write-ColorOutput "❌ npm non trovato!" "Red"
        exit 1
    }
    
    Write-ColorOutput ""
}

# Verifica applicazione in esecuzione
function Test-Application {
    Write-ColorOutput "🔍 Verifica applicazione Spring Boot..." "Yellow"
    
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080" -UseBasicParsing -TimeoutSec 5 -ErrorAction Stop
        Write-ColorOutput "✅ Applicazione in esecuzione su http://localhost:8080" "Green"
        return $true
    } catch {
        Write-ColorOutput "❌ Applicazione NON in esecuzione su http://localhost:8080" "Red"
        Write-ColorOutput "   Avvia l'applicazione con: .\mvnw.cmd spring-boot:run" "Yellow"
        return $false
    }
}

# Installa dipendenze
function Install-Dependencies {
    Write-ColorOutput "📦 Installazione dipendenze npm..." "Yellow"
    
    Push-Location -Path "Testing\Cypress"
    
    try {
        npm install
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "✅ Dipendenze installate con successo!" "Green"
        } else {
            Write-ColorOutput "❌ Errore durante l'installazione" "Red"
            exit 1
        }
    } finally {
        Pop-Location
    }
}

# Apri Cypress UI
function Open-CypressUI {
    Write-ColorOutput "🚀 Apertura Cypress in modalità interattiva..." "Yellow"
    
    # Verifica applicazione
    if (-not (Test-Application)) {
        $continue = Read-Host "Continuare comunque? (y/n)"
        if ($continue -ne 'y') {
            exit 0
        }
    }
    
    Push-Location -Path "Testing\Cypress"
    
    try {
        npm run cypress:open
    } finally {
        Pop-Location
    }
}

# Esegui tutti i test
function Invoke-AllTests {
    Write-ColorOutput "🧪 Esecuzione test in modalità headless..." "Yellow"
    
    # Verifica applicazione
    if (-not (Test-Application)) {
        Write-ColorOutput "⚠️  L'applicazione deve essere in esecuzione!" "Red"
        exit 1
    }
    
    Push-Location -Path "Testing\Cypress"
    
    try {
        Write-ColorOutput "Browser: $Browser" "Cyan"
        Write-ColorOutput "Starting tests...`n" "Cyan"
        
        if ($Browser -eq "chrome") {
            npm run cypress:run:chrome
        } elseif ($Browser -eq "firefox") {
            npm run cypress:run:firefox
        } elseif ($Browser -eq "edge") {
            npm run cypress:run:edge
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "`n✅ Tutti i test completati con successo!" "Green"
            Write-ColorOutput "📹 Video salvati in: cypress\videos\" "Cyan"
            Write-ColorOutput "📸 Screenshot in: cypress\screenshots\" "Cyan"
        } else {
            Write-ColorOutput "`n❌ Alcuni test sono falliti!" "Red"
            Write-ColorOutput "📹 Controlla i video in: cypress\videos\" "Yellow"
            Write-ColorOutput "📸 Controlla gli screenshot in: cypress\screenshots\" "Yellow"
            exit 1
        }
    } finally {
        Pop-Location
    }
}

# Esegui test specifico
function Invoke-SpecificTest {
    param([string]$Spec)
    
    if ([string]::IsNullOrEmpty($Spec)) {
        Write-ColorOutput "❌ Specificare il nome del test con -TestSpec" "Red"
        Write-ColorOutput "Esempio: -TestSpec '01-public-pages.cy.js'" "Yellow"
        exit 1
    }
    
    Write-ColorOutput "🧪 Esecuzione test: $Spec" "Yellow"
    
    # Verifica applicazione
    if (-not (Test-Application)) {
        Write-ColorOutput "⚠️  L'applicazione deve essere in esecuzione!" "Red"
        exit 1
    }
    
    Push-Location -Path "Testing\Cypress"
    
    try {
        $specPath = "cypress/e2e/$Spec"
        npx cypress run --spec $specPath --browser $Browser
        
        if ($LASTEXITCODE -eq 0) {
            Write-ColorOutput "`n✅ Test completato con successo!" "Green"
        } else {
            Write-ColorOutput "`n❌ Test fallito!" "Red"
            exit 1
        }
    } finally {
        Pop-Location
    }
}

# Pulisci artifacts
function Clear-Artifacts {
    Write-ColorOutput "🧹 Pulizia artifacts..." "Yellow"
    
    Push-Location -Path "Testing\Cypress"
    
    try {
        # Rimuovi screenshots
        if (Test-Path "cypress\screenshots") {
            Remove-Item -Recurse -Force "cypress\screenshots\*" -ErrorAction SilentlyContinue
            Write-ColorOutput "✅ Screenshots rimossi" "Green"
        }
        
        # Rimuovi video
        if (Test-Path "cypress\videos") {
            Remove-Item -Recurse -Force "cypress\videos\*" -ErrorAction SilentlyContinue
            Write-ColorOutput "✅ Video rimossi" "Green"
        }
        
        # Pulisci cache Cypress
        npx cypress cache clear
        Write-ColorOutput "✅ Cache Cypress pulita" "Green"
        
        Write-ColorOutput "`n🎉 Pulizia completata!" "Green"
    } finally {
        Pop-Location
    }
}

# Lista test disponibili
function Show-AvailableTests {
    Write-ColorOutput "`n📋 Test disponibili:" "Cyan"
    Write-ColorOutput "  01-public-pages.cy.js      - Test pagine pubbliche (Home, About)" "White"
    Write-ColorOutput "  02-login.cy.js             - Test funzionalità login" "White"
    Write-ColorOutput "  03-logout.cy.js            - Test funzionalità logout" "White"
    Write-ColorOutput "  04-private-area.cy.js      - Test area privata/dashboard" "White"
    Write-ColorOutput "  05-roles-authorization.cy.js - Test ruoli e autorizzazioni" "White"
    Write-ColorOutput "  06-complete-flow.cy.js     - Test flussi E2E completi`n" "White"
}

# Main script
Show-Banner
Test-Prerequisites

switch ($Action) {
    'install' {
        Install-Dependencies
    }
    'open' {
        Open-CypressUI
    }
    'run' {
        Invoke-AllTests
    }
    'spec' {
        Invoke-SpecificTest -Spec $TestSpec
        Show-AvailableTests
    }
    'clean' {
        Clear-Artifacts
    }
    'verify' {
        $isRunning = Test-Application
        if ($isRunning) {
            Write-ColorOutput "`n✅ Applicazione pronta per i test!" "Green"
        } else {
            Write-ColorOutput "`n❌ Applicazione non disponibile" "Red"
            Write-ColorOutput "Avvia con: .\mvnw.cmd spring-boot:run`n" "Yellow"
        }
    }
}

Write-ColorOutput "`n✨ Completato!`n" "Cyan"
