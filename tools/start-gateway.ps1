param(
    [string]$OpenKoreRoot = "",
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

function Resolve-OpenKoreRoot {
    param([string]$UserPath)

    if ($UserPath -and $UserPath.Trim() -ne "") {
        if (Test-Path -LiteralPath $UserPath) {
            return (Resolve-Path -LiteralPath $UserPath).Path
        }
        throw "OpenKoreRoot inválido (não encontrado): $UserPath"
    }

    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.PSCommandPath }
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Path }
    if (-not $scriptPath) { $scriptPath = (Join-Path (Get-Location).Path "tools\start-gateway.ps1") }
    $scriptDir = Split-Path -Parent $scriptPath
    $candidates = @()
    $candidates += $scriptDir
    try { $candidates += (Resolve-Path (Join-Path $scriptDir "..")).Path } catch {}
    try { $candidates += (Resolve-Path (Join-Path $scriptDir "..\..")).Path } catch {}
    $candidates += (Get-Location).Path

    foreach ($cand in ($candidates | Select-Object -Unique)) {
        if (Test-Path -LiteralPath (Join-Path $cand "tools\remote_gateway.pl")) {
            return $cand
        }
    }

    throw "Não foi possível detectar a raiz do OpenKore automaticamente. Use -OpenKoreRoot `"C:\caminho\openkore`"."
}

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

function Test-TcpEndpoint {
    param(
        [string]$Host,
        [int]$Port,
        [int]$TimeoutMs = 800
    )

    $client = New-Object System.Net.Sockets.TcpClient
    try {
        $iar = $client.BeginConnect($Host, $Port, $null, $null)
        if (-not $iar.AsyncWaitHandle.WaitOne($TimeoutMs, $false)) {
            return $false
        }
        $client.EndConnect($iar)
        return $true
    }
    catch {
        return $false
    }
    finally {
        try { $client.Close() } catch {}
    }
}

$OpenKoreRoot = Resolve-OpenKoreRoot -UserPath $OpenKoreRoot
$gatewayScript = Join-Path $OpenKoreRoot "tools\remote_gateway.pl"
$configDir = Join-Path $OpenKoreRoot "config"
$logsDir = Join-Path $OpenKoreRoot "logs"
$dataDir = Join-Path $OpenKoreRoot "data"
$usersFile = Join-Path $configDir "gateway-users.json"
$usersTemplate = Join-Path $OpenKoreRoot "tools\gateway-users.example.json"
$auditFile = Join-Path $logsDir "gateway_audit.jsonl"
$sessionFile = Join-Path $dataDir "gateway_sessions.json"
$pidFile = Join-Path $dataDir "gateway.pid"
$stdoutLog = Join-Path $logsDir "gateway_stdout.log"
$stderrLog = Join-Path $logsDir "gateway_stderr.log"

Ensure-Dir -Path $configDir
Ensure-Dir -Path $logsDir
Ensure-Dir -Path $dataDir

Assert-FileExists -Path $gatewayScript

if (-not (Test-Path -LiteralPath $usersFile)) {
    if (Test-Path -LiteralPath $usersTemplate) {
        Copy-Item -LiteralPath $usersTemplate -Destination $usersFile -Force
        Write-Warning "Arquivo $usersFile não existia. Copiado do template gateway-users.example.json. Troque as senhas padrão."
    } else {
        @'
{
  "users": [
    { "username": "viewer_user", "password": "change_me_viewer", "role": "viewer" },
    { "username": "operator_user", "password": "change_me_operator", "role": "operator" },
    { "username": "admin_user", "password": "change_me_admin", "role": "admin" }
  ]
}
'@ | Set-Content -LiteralPath $usersFile -Encoding UTF8
        Write-Warning "Arquivo $usersFile criado automaticamente. Troque as senhas padrão."
    }
}

if ($KorePort -le 0 -or $KorePort -gt 65535) {
    throw "KorePort inválida: $KorePort"
}

if ($ListenPort -le 0 -or $ListenPort -gt 65535) {
    throw "ListenPort inválida: $ListenPort"
}

if ($CommandToken -eq "CHANGE_ME") {
    Write-Warning "Você ainda está usando token padrão CHANGE_ME. Troque antes de produção."
}

$koreEndpointReachable = Test-TcpEndpoint -Host $KoreHost -Port $KorePort
if (-not $koreEndpointReachable) {
    Write-Warning "Não foi possível conectar em $KoreHost`:$KorePort antes de iniciar o gateway."
    Write-Warning "Se o /health mostrar connected=false, inicie o OpenKore com endpoint compatível: `$env:OPENKORE_SOCKET_TCP_PORT=`"$KorePort`"` + `--interface=Socket`."
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
