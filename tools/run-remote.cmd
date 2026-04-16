@echo off
setlocal ENABLEEXTENSIONS

REM One-shot launcher: OpenKore Socket TCP + Remote Gateway (Windows).
REM Usage:
REM   tools\run-remote.cmd YOUR_LONG_RANDOM_TOKEN start.exe
REM If launcher is omitted, defaults to start.exe.

cd /d "%~dp0.."
set "ROOT=%CD%"
set "COMMAND_TOKEN=%~1"
if "%COMMAND_TOKEN%"=="" set "COMMAND_TOKEN=CHANGE_ME"
set "LAUNCHER_NAME=%~2"
if "%LAUNCHER_NAME%"=="" set "LAUNCHER_NAME=start.exe"

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

set "LAUNCHER=%ROOT%\%LAUNCHER_NAME%"
if not exist "%LAUNCHER%" goto :launcher_missing

echo [1/3] Abrindo OpenKore em janela separada (interface do launcher)...
start "OpenKore Socket" cmd /k "cd /d \"%ROOT%\" && set OPENKORE_SOCKET_TCP_HOST=%OPENKORE_SOCKET_TCP_HOST% && set OPENKORE_SOCKET_TCP_PORT=%OPENKORE_SOCKET_TCP_PORT% && \"%LAUNCHER%\" --interface=Socket"

echo [2/3] Aguardando 3s...
timeout /t 3 /nobreak >nul

echo [3/3] Abrindo gateway em outra janela separada...
start "OpenKore Remote Gateway" cmd /k "cd /d \"%ROOT%\" && perl \"%ROOT%\tools\remote_gateway.pl\" --kore-host 127.0.0.1 --kore-port 2350 --listen-host 127.0.0.1 --listen-port 18085 --command-token \"%COMMAND_TOKEN%\" --audit-file \"%ROOT%\logs\gateway_audit.jsonl\" --command-rate-limit 30 --command-rate-window 60 --auth-enabled --users-file \"%ROOT%\config\gateway-users.json\" --token-ttl 900 --session-file \"%ROOT%\data\gateway_sessions.json\""

echo.
echo Pronto. Janelas abertas separadamente:
echo  - OpenKore (launcher/interface)
echo  - Remote Gateway
echo UI Web: http://127.0.0.1:18085/
exit /b 0

:launcher_missing
echo [ERRO] Launcher nao encontrado: %LAUNCHER_NAME%
echo        Informe explicitamente no comando, por exemplo:
echo        tools\run-remote.cmd SEU_TOKEN start.exe
echo        tools\run-remote.cmd SEU_TOKEN tkstart.exe
exit /b 1
