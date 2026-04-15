param(
    [string]$OpenKoreRoot = "C:\openkore",
    [string]$KoreHost = "127.0.0.1",
    [int]$KorePort = 2350,
    [string]$ListenHost = "127.0.0.1",
    [int]$ListenPort = 18085,
    [string]$CommandToken = "CHANGE_ME",
    [int]$CommandRateLimit = 30,
    [int]$CommandRateWindow = 60,
    [int]$TokenTtl = 900,
    [switch]$AuthEnabled = $true
)

$ErrorActionPreference = "Stop"

function Assert-FileExists {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        throw "Arquivo obrigatório não encontrado: $Path"
    }
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

$gatewayScript = Join-Path $OpenKoreRoot "tools\remote_gateway.pl"
$configDir = Join-Path $OpenKoreRoot "config"
$logsDir = Join-Path $OpenKoreRoot "logs"
$dataDir = Join-Path $OpenKoreRoot "data"
$usersFile = Join-Path $configDir "gateway-users.json"
$auditFile = Join-Path $logsDir "gateway_audit.jsonl"
$sessionFile = Join-Path $dataDir "gateway_sessions.json"
$pidFile = Join-Path $dataDir "gateway.pid"
$stdoutLog = Join-Path $logsDir "gateway_stdout.log"
$stderrLog = Join-Path $logsDir "gateway_stderr.log"

Ensure-Dir -Path $configDir
Ensure-Dir -Path $logsDir
Ensure-Dir -Path $dataDir

Assert-FileExists -Path $gatewayScript
Assert-FileExists -Path $usersFile

if ($KorePort -le 0 -or $KorePort -gt 65535) {
    throw "KorePort inválida: $KorePort"
}

if ($ListenPort -le 0 -or $ListenPort -gt 65535) {
    throw "ListenPort inválida: $ListenPort"
}

if ($CommandToken -eq "CHANGE_ME") {
    Write-Warning "Você ainda está usando token padrão CHANGE_ME. Troque antes de produção."
}

$existingPid = $null
if (Test-Path -LiteralPath $pidFile) {
    $existingPid = (Get-Content -LiteralPath $pidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
}

if ($existingPid) {
    $existingProc = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
    if ($existingProc) {
        Write-Host "Gateway já está em execução (PID=$existingPid)."
        exit 0
    }
}

$argList = @(
    ".\tools\remote_gateway.pl",
    "--kore-host", $KoreHost,
    "--kore-port", "$KorePort",
    "--listen-host", $ListenHost,
    "--listen-port", "$ListenPort",
    "--command-token", $CommandToken,
    "--audit-file", $auditFile,
    "--command-rate-limit", "$CommandRateLimit",
    "--command-rate-window", "$CommandRateWindow",
    "--users-file", $usersFile,
    "--token-ttl", "$TokenTtl",
    "--session-file", $sessionFile
)

if ($AuthEnabled) {
    $argList += "--auth-enabled"
} else {
    $argList += "--no-auth-enabled"
}

Push-Location $OpenKoreRoot
try {
    $proc = Start-Process -FilePath "perl" -ArgumentList $argList -WorkingDirectory $OpenKoreRoot -RedirectStandardOutput $stdoutLog -RedirectStandardError $stderrLog -PassThru
    Set-Content -LiteralPath $pidFile -Value $proc.Id -Encoding ASCII
    Start-Sleep -Milliseconds 600

    $healthUrl = "http://$ListenHost`:$ListenPort/health"
    try {
        $response = Invoke-RestMethod -Uri $healthUrl -Method Get -TimeoutSec 3
        Write-Host "Gateway iniciado com sucesso (PID=$($proc.Id))."
        Write-Host "Health: $healthUrl"
        Write-Host "Status conectado ao OpenKore: $($response.status.connected)"
    }
    catch {
        Write-Warning "Gateway iniciado (PID=$($proc.Id)), mas healthcheck falhou: $($_.Exception.Message)"
        Write-Warning "Confira logs: $stdoutLog e $stderrLog"
    }
}
finally {
    Pop-Location
}
