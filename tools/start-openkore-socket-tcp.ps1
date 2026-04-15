param(
    [string]$OpenKoreRoot = "",
    [string]$LauncherPath = "",
    [string]$SocketHost = "127.0.0.1",
    [int]$SocketPort = 2350,
    [switch]$LaunchOpenKore = $false,
    [switch]$StartGateway = $false,
    [string]$GatewayListenHost = "127.0.0.1",
    [int]$GatewayListenPort = 18085,
    [string]$CommandToken = "CHANGE_ME"
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
    if (-not $scriptPath) { $scriptPath = (Join-Path (Get-Location).Path "tools\start-openkore-socket-tcp.ps1") }
    $scriptDir = Split-Path -Parent $scriptPath
    $candidates = @()
    $candidates += $scriptDir
    try { $candidates += (Resolve-Path (Join-Path $scriptDir "..")).Path } catch {}
    try { $candidates += (Resolve-Path (Join-Path $scriptDir "..\..")).Path } catch {}
    $candidates += (Get-Location).Path

    foreach ($cand in ($candidates | Select-Object -Unique)) {
        if (Test-Path -LiteralPath (Join-Path $cand "openkore.pl")) {
            return $cand
        }
    }

    throw "Não foi possível detectar a raiz do OpenKore automaticamente. Use -OpenKoreRoot `"C:\caminho\openkore`"."
}

function Ensure-Dir {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) {
        New-Item -ItemType Directory -Path $Path -Force | Out-Null
    }
}

function Wait-TcpOpen {
    param(
        [string]$TargetHost,
        [int]$Port,
        [int]$TimeoutMs = 8000
    )

    $start = Get-Date
    while (((Get-Date) - $start).TotalMilliseconds -lt $TimeoutMs) {
        $client = New-Object System.Net.Sockets.TcpClient
        try {
            $iar = $client.BeginConnect($TargetHost, $Port, $null, $null)
            if ($iar.AsyncWaitHandle.WaitOne(250, $false)) {
                $client.EndConnect($iar)
                return $true
            }
        }
        catch {}
        finally {
            try { $client.Close() } catch {}
        }
        Start-Sleep -Milliseconds 200
    }
    return $false
}

function Resolve-Launcher {
    param(
        [string]$Root,
        [string]$UserLauncherPath
    )

    if ($UserLauncherPath -and $UserLauncherPath.Trim() -ne "") {
        if (-not (Test-Path -LiteralPath $UserLauncherPath)) {
            throw "LauncherPath não encontrado: $UserLauncherPath"
        }
        return (Resolve-Path -LiteralPath $UserLauncherPath).Path
    }

    $candidates = @(
        (Join-Path $Root "start.exe"),
        (Join-Path $Root "wxstart.exe"),
        (Join-Path $Root "winguistart.exe"),
        (Join-Path $Root "tkstart.exe"),
        (Join-Path $Root "vxstart.exe"),
        (Join-Path $Root "openkore.pl")
    )

    foreach ($candidate in $candidates) {
        if (Test-Path -LiteralPath $candidate) {
            return (Resolve-Path -LiteralPath $candidate).Path
        }
    }

    throw "Nenhum launcher encontrado (start.exe/wxstart.exe/winguistart.exe/tkstart.exe/vxstart.exe/openkore.pl)."
}

function Write-EnvLauncherCmd {
    param(
        [string]$Root,
        [string]$TargetHost,
        [int]$Port
    )

    $cmdPath = Join-Path $Root "tools\openkore-socket-env.cmd"
    @(
        "@echo off",
        "setlocal",
        "set `"OPENKORE_SOCKET_TCP_HOST=$TargetHost`"",
        "set `"OPENKORE_SOCKET_TCP_PORT=$Port`"",
        "if `"%~1`"==`"`" goto :done",
        "start `"`" %*",
        ":done"
    ) | Set-Content -LiteralPath $cmdPath -Encoding ASCII

    return $cmdPath
}

if ($SocketPort -le 0 -or $SocketPort -gt 65535) {
    throw "SocketPort inválida: $SocketPort"
}

$OpenKoreRoot = Resolve-OpenKoreRoot -UserPath $OpenKoreRoot

$logsDir = Join-Path $OpenKoreRoot "logs"
$dataDir = Join-Path $OpenKoreRoot "data"
$openkorePidFile = Join-Path $dataDir "openkore_socket_tcp.pid"
$openkoreOut = Join-Path $logsDir "openkore_socket_tcp_stdout.log"
$openkoreErr = Join-Path $logsDir "openkore_socket_tcp_stderr.log"
$gatewayScript = Join-Path $OpenKoreRoot "tools\start-gateway.ps1"
$alreadyRunning = $false

Ensure-Dir -Path $logsDir
Ensure-Dir -Path $dataDir

$envCmdPath = Write-EnvLauncherCmd -Root $OpenKoreRoot -TargetHost $SocketHost -Port $SocketPort
Write-Host "Arquivo atualizado: $envCmdPath"
Write-Host "Use assim: tools\\openkore-socket-env.cmd start.exe --interface=Socket (abre em nova janela)"

if (Test-Path -LiteralPath $openkorePidFile) {
    $existingPid = (Get-Content -LiteralPath $openkorePidFile -ErrorAction SilentlyContinue | Select-Object -First 1)
    if ($existingPid) {
        $existingProc = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($existingProc) {
            Write-Host "OpenKore já está em execução (PID=$existingPid)."
            $alreadyRunning = $true
        }
    }
}

if (-not $LaunchOpenKore) {
    if ($StartGateway) {
        Write-Warning "-StartGateway foi ignorado porque -LaunchOpenKore não foi usado."
    }
    Write-Host "Configuração pronta. O script não iniciou OpenKore automaticamente."
    return
}

$launcher = Resolve-Launcher -Root $OpenKoreRoot -UserLauncherPath $LauncherPath

Push-Location $OpenKoreRoot
try {
    $env:OPENKORE_SOCKET_TCP_HOST = $SocketHost
    $env:OPENKORE_SOCKET_TCP_PORT = "$SocketPort"
    if (-not $alreadyRunning) {
        $launcherName = [System.IO.Path]::GetFileName($launcher).ToLowerInvariant()
        $openkoreArgs = @("--interface=Socket")
        $openkoreFile = $launcher

        if ($launcherName -eq "openkore.pl") {
            $openkoreFile = "perl"
            $openkoreArgs = @(".\openkore.pl", "--interface=Socket")
        }

        $openkoreProc = Start-Process -FilePath $openkoreFile -ArgumentList $openkoreArgs -WorkingDirectory $OpenKoreRoot -RedirectStandardOutput $openkoreOut -RedirectStandardError $openkoreErr -PassThru
        Set-Content -LiteralPath $openkorePidFile -Value $openkoreProc.Id -Encoding ASCII

        if (Wait-TcpOpen -TargetHost $SocketHost -Port $SocketPort -TimeoutMs 10000) {
            Write-Host "OpenKore iniciado com '$launcherName' e endpoint TCP de console em $SocketHost`:$SocketPort (PID=$($openkoreProc.Id))."
        } else {
            Write-Warning "OpenKore iniciou (PID=$($openkoreProc.Id)), mas a porta $SocketHost`:$SocketPort não abriu a tempo."
            Write-Warning "Confira logs: $openkoreOut e $openkoreErr"
        }
    } else {
        if (Wait-TcpOpen -TargetHost $SocketHost -Port $SocketPort -TimeoutMs 2000) {
            Write-Host "Endpoint TCP já estava ativo em $SocketHost`:$SocketPort. Reutilizando instância existente."
        } else {
            Write-Warning "OpenKore já estava aberto, mas a porta $SocketHost`:$SocketPort não está ativa."
            Write-Warning "Feche e inicie pelo script para aplicar OPENKORE_SOCKET_TCP_* e --interface=Socket."
        }
    }

    if ($StartGateway) {
        if (-not (Test-Path -LiteralPath $gatewayScript)) {
            throw "Script do gateway não encontrado: $gatewayScript"
        }
        & $gatewayScript -OpenKoreRoot $OpenKoreRoot -KoreHost $SocketHost -KorePort $SocketPort -ListenHost $GatewayListenHost -ListenPort $GatewayListenPort -CommandToken $CommandToken
    } else {
        Write-Host "Gateway não iniciado (-StartGateway:`$false)."
    }
}
finally {
    Pop-Location
}
