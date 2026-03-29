<#
.SYNOPSIS
    Esegue l'analisi del codice con SonarQube tramite Maven

.DESCRIPTION
    Script per automatizzare l'esecuzione dell'analisi statica del codice
    utilizzando SonarQube. Esegue test, genera report di coverage con JaCoCo
    e invia i risultati al server SonarQube.

.PARAMETER SonarHostUrl
    URL del server SonarQube (default: http://localhost:9000)

.PARAMETER SonarToken
    Token di autenticazione SonarQube (opzionale)

.PARAMETER ProjectKey
    Chiave del progetto SonarQube (default: corso-ntt-38)

.PARAMETER SkipTests
    Se presente, salta l'esecuzione dei test (non consigliato)

.PARAMETER Clean
    Se presente, esegue mvn clean prima dell'analisi

.PARAMETER Verbose
    Se presente, mostra output dettagliato

.EXAMPLE
    .\run-sonar-analysis.ps1
    
.EXAMPLE
    .\run-sonar-analysis.ps1 -SonarToken "sqp_123456789abcdef"
    
.EXAMPLE
    .\run-sonar-analysis.ps1 -SonarHostUrl "http://sonar.company.com:9000" -Clean

.NOTES
    Author: Corso NTT 38
    Requires: Maven, Java 21, SonarQube Server
    Version: 1.0
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$SonarHostUrl = "http://localhost:9000",
    
    [Parameter(Mandatory=$false)]
    [string]$SonarToken = "",
    
    [Parameter(Mandatory=$false)]
    [string]$ProjectKey = "corso-ntt-38",
    
    [Parameter(Mandatory=$false)]
    [switch]$SkipTests,
    
    [Parameter(Mandatory=$false)]
    [switch]$Clean
)

# ============================================================================
# CONFIGURAZIONE
# ============================================================================

$ErrorActionPreference = "Stop"
$ScriptName = "SonarQube Analysis Script"
$ScriptVersion = "1.0"
$LogDirectory = Join-Path $PSScriptRoot "logs"
$LogFileName = "sonar-analysis-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
$LogFilePath = Join-Path $LogDirectory $LogFileName

# Colori per output
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorWarning = "Yellow"
$ColorInfo = "Cyan"

# ============================================================================
# FUNZIONI HELPER
# ============================================================================

function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"
    
    # Scrivi su console con colori
    switch ($Level) {
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor $ColorSuccess }
        "ERROR"   { Write-Host $LogMessage -ForegroundColor $ColorError }
        "WARNING" { Write-Host $LogMessage -ForegroundColor $ColorWarning }
        "INFO"    { Write-Host $LogMessage -ForegroundColor $ColorInfo }
        default   { Write-Host $LogMessage }
    }
    
    # Scrivi su file di log
    if (Test-Path $LogDirectory) {
        Add-Content -Path $LogFilePath -Value $LogMessage
    }
}

function Write-Banner {
    $banner = @"

╔════════════════════════════════════════════════════════════════╗
║                                                                ║
║            $ScriptName v$ScriptVersion                         ║
║                                                                ║
║  Analisi statica del codice con SonarQube                     ║
║                                                                ║
╚════════════════════════════════════════════════════════════════╝

"@
    Write-Host $banner -ForegroundColor $ColorInfo
}

function Test-Command {
    param([string]$Command)
    
    try {
        $null = Get-Command $Command -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

function Invoke-MavenCommand {
    param(
        [string]$Command,
        [string]$Description
    )
    
    Write-Log "Esecuzione: $Description" "INFO"
    Write-Log "Comando: $Command" "INFO"
    
    try {
        if ($VerbosePreference -eq 'Continue') {
            Invoke-Expression $Command
            $exitCode = $LASTEXITCODE
        }
        else {
            Invoke-Expression "$Command 2>&1" | Tee-Object -Variable output | Out-Null
            $exitCode = $LASTEXITCODE
        }
        
        if ($exitCode -eq 0) {
            Write-Log "$Description completato con successo" "SUCCESS"
            return $true
        }
        else {
            if ($output) {
                Write-Log $output "ERROR"
            }
            Write-Log "$Description fallito con exit code $exitCode" "ERROR"
            return $false
        }
    }
    catch {
        Write-Log "Errore durante $Description`: $_" "ERROR"
        return $false
    }
}

function Test-SonarQubeServer {
    param([string]$Url)
    
    Write-Log "Verifica connettività a SonarQube: $Url" "INFO"
    
    try {
        $statusUrl = "$Url/api/system/status"
        $response = Invoke-RestMethod -Uri $statusUrl -Method Get -TimeoutSec 10
        
        if ($response.status -eq "UP") {
            Write-Log "SonarQube server raggiungibile (Status: UP, Version: $($response.version))" "SUCCESS"
            return $true
        }
        else {
            Write-Log "SonarQube server non operativo (Status: $($response.status))" "WARNING"
            return $false
        }
    }
    catch {
        Write-Log "Impossibile raggiungere SonarQube server: $_" "ERROR"
        Write-Log "Verifica che SonarQube sia in esecuzione su $Url" "WARNING"
        return $false
    }
}

function Remove-OldLogs {
    param([int]$KeepCount = 10)
    
    if (Test-Path $LogDirectory) {
        $logs = Get-ChildItem -Path $LogDirectory -Filter "sonar-analysis-*.log" | 
                Sort-Object LastWriteTime -Descending
        
        if ($logs.Count -gt $KeepCount) {
            $logsToDelete = $logs | Select-Object -Skip $KeepCount
            foreach ($log in $logsToDelete) {
                Remove-Item $log.FullName -Force
                Write-Log "Log obsoleto rimosso: $($log.Name)" "INFO"
            }
        }
    }
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

try {
    # Banner iniziale
    Write-Banner
    
    # Crea directory logs se non esiste
    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -Force | Out-Null
        Write-Log "Creata directory logs: $LogDirectory" "INFO"
    }
    
    Write-Log "=== INIZIO ANALISI SONARQUBE ===" "INFO"
    Write-Log "Parametri configurati:" "INFO"
    Write-Log "  - SonarQube URL: $SonarHostUrl" "INFO"
    Write-Log "  - Project Key: $ProjectKey" "INFO"
    Write-Log "  - Skip Tests: $SkipTests" "INFO"
    Write-Log "  - Clean Build: $Clean" "INFO"
    Write-Log "  - Token fornito: $(if ($SonarToken) { 'Si' } else { 'No' })" "INFO"
    
    # ========================================================================
    # STEP 1: VALIDAZIONE PREREQUISITI
    # ========================================================================
    
    Write-Host "`n[STEP 1/5] Validazione prerequisiti..." -ForegroundColor $ColorInfo
    
    # Verifica Maven
    if (-not (Test-Command "mvn")) {
        Write-Log "Maven non trovato nel PATH" "ERROR"
        Write-Log "Tentativo con wrapper Maven (mvnw)..." "WARNING"
        
        if (Test-Path ".\mvnw.cmd") {
            $MavenCommand = ".\mvnw.cmd"
            Write-Log "Trovato Maven wrapper: mvnw.cmd" "SUCCESS"
        }
        else {
            Write-Log "Maven wrapper non trovato. Installa Maven o usa mvnw" "ERROR"
            exit 1
        }
    }
    else {
        $MavenCommand = "mvn"
        $mavenVersion = & mvn --version | Select-Object -First 1
        Write-Log "Maven trovato: $mavenVersion" "SUCCESS"
    }
    
    # Verifica Java
    if (-not (Test-Command "java")) {
        Write-Log "Java non trovato nel PATH" "ERROR"
        exit 1
    }
    else {
        $javaVersion = & java -version 2>&1 | Select-Object -First 1
        Write-Log "Java trovato: $javaVersion" "SUCCESS"
    }
    
    # Verifica connettività SonarQube
    $sonarReachable = Test-SonarQubeServer -Url $SonarHostUrl
    if (-not $sonarReachable) {
        Write-Log "ATTENZIONE: SonarQube server non raggiungibile. L'analisi potrebbe fallire." "WARNING"
        $continue = Read-Host "Continuare comunque? (s/n)"
        if ($continue -ne "s") {
            Write-Log "Analisi annullata dall'utente" "WARNING"
            exit 0
        }
    }
    
    # ========================================================================
    # STEP 2: CLEAN (OPZIONALE)
    # ========================================================================
    
    if ($Clean) {
        Write-Host "`n[STEP 2/5] Pulizia progetto..." -ForegroundColor $ColorInfo
        $cleanCmd = "$MavenCommand clean"
        $success = Invoke-MavenCommand -Command $cleanCmd -Description "Maven clean"
        if (-not $success) {
            Write-Log "Clean fallito. Interrompo analisi." "ERROR"
            exit 2
        }
    }
    else {
        Write-Host "`n[STEP 2/5] Pulizia saltata (usa -Clean per abilitarla)" -ForegroundColor $ColorWarning
    }
    
    # ========================================================================
    # STEP 3: COMPILAZIONE E TEST
    # ========================================================================
    
    Write-Host "`n[STEP 3/5] Compilazione e test con coverage..." -ForegroundColor $ColorInfo
    
    if ($SkipTests) {
        Write-Log "Test saltati come richiesto (-SkipTests)" "WARNING"
        $buildCmd = "$MavenCommand compile"
    }
    else {
        $buildCmd = "$MavenCommand verify"
    }
    
    $success = Invoke-MavenCommand -Command $buildCmd -Description "Maven build"
    if (-not $success) {
        Write-Log "Build fallito. Interrompo analisi." "ERROR"
        exit 2
    }
    
    # Verifica report JaCoCo
    $jacocoReport = "target\site\jacoco\jacoco.xml"
    if ((Test-Path $jacocoReport) -and -not $SkipTests) {
        Write-Log "Report JaCoCo generato: $jacocoReport" "SUCCESS"
        $jacocoSize = (Get-Item $jacocoReport).Length
        Write-Log "Dimensione report: $jacocoSize bytes" "INFO"
    }
    elseif (-not $SkipTests) {
        Write-Log "Report JaCoCo non trovato. Coverage potrebbe non essere disponibile." "WARNING"
    }
    
    # ========================================================================
    # STEP 4: ANALISI SONARQUBE
    # ========================================================================
    
    Write-Host "`n[STEP 4/5] Analisi SonarQube..." -ForegroundColor $ColorInfo
    
    # Costruisci comando SonarQube
    $sonarCmd = "$MavenCommand sonar:sonar"
    $sonarCmd += " `"-Dsonar.host.url=$SonarHostUrl`""
    $sonarCmd += " `"-Dsonar.projectKey=$ProjectKey`""
    
    if ($SonarToken) {
        $sonarCmd += " `"-Dsonar.token=$SonarToken`""
        Write-Log "Token di autenticazione configurato" "INFO"
    }
    
    $success = Invoke-MavenCommand -Command $sonarCmd -Description "SonarQube analysis"
    if (-not $success) {
        Write-Log "Analisi SonarQube fallita" "ERROR"
        exit 3
    }
    
    # ========================================================================
    # STEP 5: RIEPILOGO FINALE
    # ========================================================================
    
    Write-Host "`n[STEP 5/5] Riepilogo analisi" -ForegroundColor $ColorInfo
    
    $dashboardUrl = "$SonarHostUrl/dashboard?id=$ProjectKey"
    
    Write-Host "`n╔════════════════════════════════════════════════════════════════╗" -ForegroundColor $ColorSuccess
    Write-Host "║  ✓ ANALISI SONARQUBE COMPLETATA CON SUCCESSO                  ║" -ForegroundColor $ColorSuccess
    Write-Host "╚════════════════════════════════════════════════════════════════╝" -ForegroundColor $ColorSuccess
    
    Write-Host "`nDettagli:" -ForegroundColor $ColorInfo
    Write-Host "  • Progetto: $ProjectKey" -ForegroundColor White
    Write-Host "  • Server: $SonarHostUrl" -ForegroundColor White
    Write-Host "  • Log salvato: $LogFilePath" -ForegroundColor White
    
    Write-Host "`nProssimi passi:" -ForegroundColor $ColorInfo
    Write-Host "  1. Apri il dashboard SonarQube:" -ForegroundColor White
    Write-Host "     $dashboardUrl" -ForegroundColor Cyan
    Write-Host "  2. Login (default: admin/admin)" -ForegroundColor White
    Write-Host "  3. Visualizza metriche, issues e coverage" -ForegroundColor White
    
    Write-Log "=== ANALISI COMPLETATA CON SUCCESSO ===" "SUCCESS"
    
    # Pulizia log vecchi
    Remove-OldLogs -KeepCount 10
    
    # Chiedi se aprire browser
    Write-Host ""
    $openBrowser = Read-Host "Aprire il dashboard SonarQube nel browser? (s/n)"
    if ($openBrowser -eq "s") {
        Start-Process $dashboardUrl
    }
    
    exit 0
}
catch {
    Write-Log "Errore fatale durante l'esecuzione dello script: $_" "ERROR"
    Write-Log "Stack trace: $($_.ScriptStackTrace)" "ERROR"
    exit 99
}
finally {
    Write-Host "`n" # Spazio finale per output pulito
}
