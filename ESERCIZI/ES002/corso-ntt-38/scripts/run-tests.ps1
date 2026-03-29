<#
.SYNOPSIS
    Script per eseguire gli unit test del progetto Spring Boot con Maven

.DESCRIPTION
    Questo script esegue i test Maven utilizzando il wrapper mvnw.cmd
    e genera automaticamente il report di code coverage con JaCoCo.

.PARAMETER SkipCoverage
    Se specificato, salta la generazione del report JaCoCo

.PARAMETER OpenReport
    Se specificato, apre automaticamente il report HTML di JaCoCo nel browser

.EXAMPLE
    .\run-tests.ps1
    Esegue tutti i test e genera il report di coverage

.EXAMPLE
    .\run-tests.ps1 -OpenReport
    Esegue i test e apre il report HTML nel browser

.EXAMPLE
    .\run-tests.ps1 -SkipCoverage
    Esegue solo i test senza generare il report di coverage
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [switch]$SkipCoverage,

    [Parameter(Mandatory=$false)]
    [switch]$OpenReport
)

# Colori per output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Funzione per stampare messaggi colorati
function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

# Funzione per stampare separatori
function Write-Separator {
    Write-Host ("=" * 80) -ForegroundColor Gray
}

# Header
Clear-Host
Write-Separator
Write-ColorOutput "  Unit Test Runner - Spring Boot Project" $InfoColor
Write-Separator
Write-Host ""

# Ottieni la directory dello script
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir

Write-ColorOutput "Directory progetto: $ProjectRoot" $InfoColor
Write-Host ""

# Verifica che mvnw.cmd esista
$MavenWrapper = Join-Path $ProjectRoot "mvnw.cmd"
if (-not (Test-Path $MavenWrapper)) {
    Write-ColorOutput "ERRORE: Maven wrapper (mvnw.cmd) non trovato!" $ErrorColor
    Write-ColorOutput "Path cercato: $MavenWrapper" $ErrorColor
    exit 1
}

Write-ColorOutput "✓ Maven wrapper trovato" $SuccessColor
Write-Host ""

# Cambia directory al root del progetto
Push-Location $ProjectRoot

try {
    Write-Separator
    Write-ColorOutput "  Esecuzione Unit Test" $InfoColor
    Write-Separator
    Write-Host ""

    # Costruisci il comando Maven
    $MavenCommand = "test"
    
    if (-not $SkipCoverage) {
        Write-ColorOutput "Code coverage: ABILITATO (JaCoCo)" $InfoColor
    } else {
        Write-ColorOutput "Code coverage: DISABILITATO" $WarningColor
        $MavenCommand += " -DskipTests=false -Djacoco.skip=true"
    }
    Write-Host ""

    # Esegui i test
    Write-ColorOutput "Esecuzione comando: .\mvnw.cmd $MavenCommand" $InfoColor
    Write-Host ""

    $StartTime = Get-Date
    
    # Esegui Maven
    & $MavenWrapper $MavenCommand.Split()
    $ExitCode = $LASTEXITCODE
    
    $EndTime = Get-Date
    $Duration = $EndTime - $StartTime

    Write-Host ""
    Write-Separator

    if ($ExitCode -eq 0) {
        Write-ColorOutput "✓ TEST COMPLETATI CON SUCCESSO!" $SuccessColor
        Write-ColorOutput "  Durata: $([math]::Round($Duration.TotalSeconds, 2)) secondi" $InfoColor
        
        # Controlla se il report JaCoCo è stato generato
        if (-not $SkipCoverage) {
            $JacocoReport = Join-Path $ProjectRoot "target\site\jacoco\index.html"
            
            if (Test-Path $JacocoReport) {
                Write-Host ""
                Write-ColorOutput "✓ Report JaCoCo generato:" $SuccessColor
                Write-ColorOutput "  $JacocoReport" $InfoColor
                
                # Apri il report se richiesto
                if ($OpenReport) {
                    Write-Host ""
                    Write-ColorOutput "Apertura report nel browser..." $InfoColor
                    Start-Process $JacocoReport
                }
            } else {
                Write-ColorOutput "⚠ Report JaCoCo non trovato" $WarningColor
            }
        }

        # Mostra informazioni sui test da surefire-reports
        $SurefireDir = Join-Path $ProjectRoot "target\surefire-reports"
        if (Test-Path $SurefireDir) {
            $TestFiles = Get-ChildItem -Path $SurefireDir -Filter "TEST-*.xml"
            if ($TestFiles) {
                Write-Host ""
                Write-ColorOutput "Report test disponibili in:" $InfoColor
                Write-ColorOutput "  $SurefireDir" $InfoColor
            }
        }

    } else {
        Write-ColorOutput "✗ TEST FALLITI!" $ErrorColor
        Write-ColorOutput "  Codice di uscita: $ExitCode" $ErrorColor
        Write-ColorOutput "  Durata: $([math]::Round($Duration.TotalSeconds, 2)) secondi" $InfoColor
        
        Write-Host ""
        Write-ColorOutput "Controlla i log sopra per i dettagli degli errori." $WarningColor
    }

    Write-Separator
    Write-Host ""

} catch {
    Write-ColorOutput "ERRORE durante l'esecuzione dei test:" $ErrorColor
    Write-ColorOutput $_.Exception.Message $ErrorColor
    exit 1
} finally {
    # Torna alla directory originale
    Pop-Location
}

exit $ExitCode
