@echo off
setlocal ENABLEEXTENSIONS

REM One-shot launcher: OpenKore Socket TCP + Remote Gateway (Windows).
REM Usage:
REM   tools\run-remote.cmd YOUR_LONG_RANDOM_TOKEN

cd /d "%~dp0.."
set "ROOT=%CD%"
set "COMMAND_TOKEN=%~1"
if "%COMMAND_TOKEN%"=="" set "COMMAND_TOKEN=CHANGE_ME"

set "OPENKORE_SOCKET_TCP_HOST=127.0.0.1"
set "OPENKORE_SOCKET_TCP_PORT=2350"

if not exist "%ROOT%\logs" mkdir "%ROOT%\logs" >nul 2>&1
if not exist "%ROOT%\data" mkdir "%ROOT%\data" >nul 2>&1
if not exist "%ROOT%\config" mkdir "%ROOT%\config" >nul 2>&1

if not exist "%ROOT%\config\gateway-users.json" (
  if exist "%ROOT%\tools\gateway-users.example.json" (
    copy /Y "%ROOT%\tools\gateway-users.example.json" "%ROOT%\config\gateway-users.json" >nul
  )
)

set "LAUNCHER="
if exist "%ROOT%\start.exe" set "LAUNCHER=%ROOT%\start.exe"
if not defined LAUNCHER if exist "%ROOT%\tkstart.exe" set "LAUNCHER=%ROOT%\tkstart.exe"
if not defined LAUNCHER if exist "%ROOT%\wxstart.exe" set "LAUNCHER=%ROOT%\wxstart.exe"
if not defined LAUNCHER if exist "%ROOT%\winguistart.exe" set "LAUNCHER=%ROOT%\winguistart.exe"
if not defined LAUNCHER if exist "%ROOT%\vxstart.exe" set "LAUNCHER=%ROOT%\vxstart.exe"

if not defined LAUNCHER goto :launcher_missing

echo [1/3] Iniciando OpenKore com interface Socket em nova janela...
start "OpenKore Socket" "%LAUNCHER%" --interface=Socket

echo [2/3] Aguardando 3s...
timeout /t 3 /nobreak >nul

echo [3/3] Iniciando gateway em nova janela...
start "OpenKore Remote Gateway" perl "%ROOT%\tools\remote_gateway.pl" --kore-host 127.0.0.1 --kore-port 2350 --listen-host 127.0.0.1 --listen-port 18085 --command-token "%COMMAND_TOKEN%" --audit-file "%ROOT%\logs\gateway_audit.jsonl" --command-rate-limit 30 --command-rate-window 60 --auth-enabled --users-file "%ROOT%\config\gateway-users.json" --token-ttl 900 --session-file "%ROOT%\data\gateway_sessions.json"

echo.
echo Pronto. Abra: http://127.0.0.1:18085/
exit /b 0

:launcher_missing
echo [ERRO] Nenhum launcher encontrado.
echo        Esperado: start.exe, tkstart.exe, wxstart.exe, winguistart.exe ou vxstart.exe na raiz.
exit /b 1
