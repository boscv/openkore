@echo off
setlocal

REM One-shot launcher: opens OpenKore console TCP endpoint + starts gateway.
REM Usage:
REM   tools\run-remote.cmd YOUR_LONG_RANDOM_TOKEN

cd /d "%~dp0.."
set "ROOT=%CD%"

set "OPENKORE_SOCKET_TCP_HOST=127.0.0.1"
set "OPENKORE_SOCKET_TCP_PORT=2350"

set "COMMAND_TOKEN=%~1"
if "%COMMAND_TOKEN%"=="" set "COMMAND_TOKEN=CHANGE_ME"

set "LAUNCHER="
if exist "%ROOT%\start.exe" set "LAUNCHER=%ROOT%\start.exe"
if "%LAUNCHER%"=="" if exist "%ROOT%\tkstart.exe" set "LAUNCHER=%ROOT%\tkstart.exe"
if "%LAUNCHER%"=="" if exist "%ROOT%\wxstart.exe" set "LAUNCHER=%ROOT%\wxstart.exe"
if "%LAUNCHER%"=="" if exist "%ROOT%\winguistart.exe" set "LAUNCHER=%ROOT%\winguistart.exe"
if "%LAUNCHER%"=="" if exist "%ROOT%\vxstart.exe" set "LAUNCHER=%ROOT%\vxstart.exe"

if "%LAUNCHER%"=="" (
  echo [ERRO] Nenhum launcher encontrado (start.exe/tkstart.exe/wxstart.exe/winguistart.exe/vxstart.exe).
  exit /b 1
)

echo [1/3] Iniciando OpenKore com interface Socket em nova janela...
start "OpenKore Socket" "%LAUNCHER%" --interface=Socket

echo [2/3] Aguardando 3s...
timeout /t 3 /nobreak >nul

echo [3/3] Iniciando gateway...
powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\tools\start-gateway.ps1" -OpenKoreRoot "%ROOT%" -KoreHost "127.0.0.1" -KorePort 2350 -ListenHost "127.0.0.1" -ListenPort 18085 -CommandToken "%COMMAND_TOKEN%"

echo.
echo Pronto. Abra: http://127.0.0.1:18085/
