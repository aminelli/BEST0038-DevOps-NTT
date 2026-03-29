<#
.SYNOPSIS
    Script per gestire la containerizzazione dell'applicazione Spring Boot

.DESCRIPTION
    Questo script fornisce comandi per:
    - Buildare l'immagine Docker
    - Eseguire il container
    - Fermare e rimuovere container
    - Visualizzare logs
    - Gestire l'applicazione con Docker Compose

.PARAMETER Action
    Azione da eseguire: build, run, stop, logs, clean, compose-up, compose-down

.PARAMETER Tag
    Tag per l'immagine Docker (default: latest)

.PARAMETER Port
    Porta locale da mappare (default: 8080)

.PARAMETER Follow
    Per il comando logs, segue l'output in tempo reale

.EXAMPLE
    .\docker-build.ps1 -Action build
    Builda l'immagine Docker

.EXAMPLE
    .\docker-build.ps1 -Action run
    Avvia il container

.EXAMPLE
    .\docker-build.ps1 -Action logs -Follow
    Mostra i logs in tempo reale

.EXAMPLE
    .\docker-build.ps1 -Action compose-up
    Avvia l'applicazione con Docker Compose
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("build", "run", "stop", "logs", "clean", "compose-up", "compose-down", "test")]
    [string]$Action,

    [Parameter(Mandatory=$false)]
    [string]$Tag = "latest",

    [Parameter(Mandatory=$false)]
    [int]$Port = 8080,

    [Parameter(Mandatory=$false)]
    [switch]$Follow
)

# Costanti
$ImageName = "corsontt38"
$ContainerName = "corsontt38-app"

# Colori per output
$ErrorColor = "Red"
$SuccessColor = "Green"
$InfoColor = "Cyan"
$WarningColor = "Yellow"

# Funzioni utility
function Write-ColorOutput {
    param([string]$Message, [string]$Color = "White")
    Write-Host $Message -ForegroundColor $Color
}

function Write-Separator {
    Write-Host ("=" * 80) -ForegroundColor Gray
}

function Test-DockerRunning {
    try {
        $null = docker info 2>&1
        return $LASTEXITCODE -eq 0
    } catch {
        return $false
    }
}

function Get-ContainerStatus {
    $container = docker ps -a --filter "name=^/${ContainerName}$" --format "{{.Status}}" 2>$null
    return $container
}

# Header
Clear-Host
Write-Separator
Write-ColorOutput "  Docker Management - Spring Boot Application" $InfoColor
Write-Separator
Write-Host ""

# Verifica che Docker sia in esecuzione
if (-not (Test-DockerRunning)) {
    Write-ColorOutput "ERRORE: Docker non è in esecuzione!" $ErrorColor
    Write-ColorOutput "Avvia Docker Desktop e riprova." $WarningColor
    exit 1
}

Write-ColorOutput "✓ Docker è in esecuzione" $SuccessColor
Write-Host ""

# Directory del progetto
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = Split-Path -Parent $ScriptDir
Push-Location $ProjectRoot

try {
    switch ($Action) {
        "build" {
            Write-Separator
            Write-ColorOutput "  BUILD DOCKER IMAGE" $InfoColor
            Write-Separator
            Write-Host ""

            Write-ColorOutput "Immagine: ${ImageName}:${Tag}" $InfoColor
            Write-ColorOutput "Context: $ProjectRoot" $InfoColor
            Write-Host ""

            Write-ColorOutput "Avvio build..." $InfoColor
            $StartTime = Get-Date

            docker build -t "${ImageName}:${Tag}" .
            
            if ($LASTEXITCODE -eq 0) {
                $EndTime = Get-Date
                $Duration = $EndTime - $StartTime
                
                Write-Host ""
                Write-ColorOutput "✓ BUILD COMPLETATA CON SUCCESSO!" $SuccessColor
                Write-ColorOutput "  Durata: $([math]::Round($Duration.TotalSeconds, 2)) secondi" $InfoColor
                
                # Mostra informazioni sull'immagine
                Write-Host ""
                Write-ColorOutput "Informazioni immagine:" $InfoColor
                docker images "${ImageName}:${Tag}"
            } else {
                Write-ColorOutput "✗ BUILD FALLITA!" $ErrorColor
                exit 1
            }
        }

        "run" {
            Write-Separator
            Write-ColorOutput "  AVVIO CONTAINER" $InfoColor
            Write-Separator
            Write-Host ""

            # Verifica se il container esiste già
            $status = Get-ContainerStatus
            if ($status) {
                Write-ColorOutput "Container esistente trovato: $status" $WarningColor
                Write-ColorOutput "Rimuovo il container esistente..." $InfoColor
                docker rm -f $ContainerName 2>$null
            }

            Write-ColorOutput "Avvio container..." $InfoColor
            Write-ColorOutput "  Nome: $ContainerName" $InfoColor
            Write-ColorOutput "  Porta: ${Port}:8080" $InfoColor
            Write-ColorOutput "  Immagine: ${ImageName}:${Tag}" $InfoColor
            Write-Host ""

            docker run -d `
                --name $ContainerName `
                -p "${Port}:8080" `
                -e JAVA_OPTS="-Xms256m -Xmx512m" `
                -e SPRING_PROFILES_ACTIVE="dev" `
                "${ImageName}:${Tag}"

            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ CONTAINER AVVIATO CON SUCCESSO!" $SuccessColor
                Write-Host ""
                Write-ColorOutput "Applicazione disponibile su: http://localhost:${Port}" $InfoColor
                Write-Host ""
                Write-ColorOutput "Comandi utili:" $InfoColor
                Write-Host "  - Logs:  docker logs -f $ContainerName"
                Write-Host "  - Stop:  docker stop $ContainerName"
                Write-Host "  - Shell: docker exec -it $ContainerName sh"
            } else {
                Write-ColorOutput "✗ AVVIO FALLITO!" $ErrorColor
                exit 1
            }
        }

        "stop" {
            Write-Separator
            Write-ColorOutput "  STOP CONTAINER" $InfoColor
            Write-Separator
            Write-Host ""

            $status = Get-ContainerStatus
            if (-not $status) {
                Write-ColorOutput "Container non trovato." $WarningColor
                exit 0
            }

            Write-ColorOutput "Arresto container..." $InfoColor
            docker stop $ContainerName

            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ CONTAINER ARRESTATO" $SuccessColor
            } else {
                Write-ColorOutput "✗ ERRORE DURANTE L'ARRESTO" $ErrorColor
                exit 1
            }
        }

        "logs" {
            Write-Separator
            Write-ColorOutput "  CONTAINER LOGS" $InfoColor
            Write-Separator
            Write-Host ""

            $status = Get-ContainerStatus
            if (-not $status) {
                Write-ColorOutput "Container non trovato." $ErrorColor
                exit 1
            }

            if ($Follow) {
                Write-ColorOutput "Visualizzazione logs in tempo reale (Ctrl+C per uscire)..." $InfoColor
                Write-Host ""
                docker logs -f $ContainerName
            } else {
                Write-ColorOutput "Ultimi logs:" $InfoColor
                Write-Host ""
                docker logs --tail 100 $ContainerName
            }
        }

        "clean" {
            Write-Separator
            Write-ColorOutput "  PULIZIA CONTAINER E IMMAGINI" $InfoColor
            Write-Separator
            Write-Host ""

            # Rimuovi container
            $status = Get-ContainerStatus
            if ($status) {
                Write-ColorOutput "Rimozione container..." $InfoColor
                docker rm -f $ContainerName 2>$null
            }

            # Rimuovi immagine
            Write-ColorOutput "Rimozione immagine ${ImageName}:${Tag}..." $InfoColor
            docker rmi "${ImageName}:${Tag}" 2>$null

            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ PULIZIA COMPLETATA" $SuccessColor
            } else {
                Write-ColorOutput "⚠ Alcuni elementi potrebbero non essere stati rimossi" $WarningColor
            }
        }

        "compose-up" {
            Write-Separator
            Write-ColorOutput "  DOCKER COMPOSE UP" $InfoColor
            Write-Separator
            Write-Host ""

            if (-not (Test-Path "docker-compose.yml")) {
                Write-ColorOutput "ERRORE: docker-compose.yml non trovato!" $ErrorColor
                exit 1
            }

            Write-ColorOutput "Avvio servizi con Docker Compose..." $InfoColor
            docker-compose up -d

            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-ColorOutput "✓ SERVIZI AVVIATI CON SUCCESSO!" $SuccessColor
                Write-Host ""
                docker-compose ps
            } else {
                Write-ColorOutput "✗ AVVIO FALLITO!" $ErrorColor
                exit 1
            }
        }

        "compose-down" {
            Write-Separator
            Write-ColorOutput "  DOCKER COMPOSE DOWN" $InfoColor
            Write-Separator
            Write-Host ""

            Write-ColorOutput "Arresto servizi Docker Compose..." $InfoColor
            docker-compose down

            if ($LASTEXITCODE -eq 0) {
                Write-ColorOutput "✓ SERVIZI ARRESTATI" $SuccessColor
            } else {
                Write-ColorOutput "✗ ERRORE DURANTE L'ARRESTO" $ErrorColor
                exit 1
            }
        }

        "test" {
            Write-Separator
            Write-ColorOutput "  TEST CONTAINER" $InfoColor
            Write-Separator
            Write-Host ""

            $status = Get-ContainerStatus
            if (-not $status) {
                Write-ColorOutput "Container non in esecuzione." $ErrorColor
                exit 1
            }

            Write-ColorOutput "Test connessione all'applicazione..." $InfoColor
            
            # Attendi che l'applicazione sia pronta
            $maxRetries = 30
            $retryCount = 0
            $ready = $false

            while (-not $ready -and $retryCount -lt $maxRetries) {
                try {
                    $response = Invoke-WebRequest -Uri "http://localhost:${Port}/actuator/health" -UseBasicParsing -TimeoutSec 2 2>$null
                    if ($response.StatusCode -eq 200) {
                        $ready = $true
                    }
                } catch {
                    $retryCount++
                    Write-Host "." -NoNewline
                    Start-Sleep -Seconds 2
                }
            }

            Write-Host ""
            if ($ready) {
                Write-ColorOutput "✓ APPLICAZIONE PRONTA E FUNZIONANTE!" $SuccessColor
                Write-ColorOutput "  URL: http://localhost:${Port}" $InfoColor
            } else {
                Write-ColorOutput "✗ TIMEOUT: Applicazione non risponde" $ErrorColor
                Write-ColorOutput "  Controlla i logs: .\docker-build.ps1 -Action logs" $WarningColor
                exit 1
            }
        }
    }

    Write-Host ""
    Write-Separator

} catch {
    Write-ColorOutput "ERRORE: $($_.Exception.Message)" $ErrorColor
    exit 1
} finally {
    Pop-Location
}
