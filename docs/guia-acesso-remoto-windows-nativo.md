# Guia completo (Windows nativo, sem Linux): acesso remoto OpenKore

Este guia é para quem usa **Windows nativo** e quer rodar o Remote Gateway **sem WSL e sem Linux**.

> Recomendação deste guia: usar modo TCP (`--kore-host` + `--kore-port`) para conectar no OpenKore no Windows.

---

## 0) Cenário alvo deste guia

Este guia cobre:

- OpenKore e gateway rodando no próprio Windows.
- Sem `systemd`, sem `/etc`, sem `find` Linux.
- Configuração por arquivos e comandos PowerShell/Prompt.

Pré-requisito principal: seu OpenKore precisa estar acessível via host/porta TCP.

---

## 1) Visão geral (arquitetura no Windows nativo)

Fluxo recomendado:

1. Você abre o Windows normalmente.
2. OpenKore roda no Windows e expõe endpoint TCP.
3. Você acessa a UI no navegador do Windows em `http://127.0.0.1:18085/`.
4. Se quiser acesso externo, usa SSH túnel/VPN.

---

## 2) Pré-requisitos no Windows

1. Perl no Windows (ex.: Strawberry Perl).
2. OpenKore funcionando no Windows.
3. Endpoint TCP do OpenKore ativo (host/porta).
4. Repositório com `tools/remote_gateway.pl`.

---

## 3) Preparar pasta e arquivos no Windows

Exemplo de estrutura:

- `C:\openkore\` (repositório)
- `C:\openkore\config\gateway-users.json`
- `C:\openkore\logs\gateway_audit.jsonl`
- `C:\openkore\data\gateway_sessions.json`

---

## 4) Criar usuários RBAC (Windows)

Copie o exemplo:

```powershell
Copy-Item .\tools\gateway-users.example.json .\config\gateway-users.json
```

Exemplo de conteúdo:

```json
{
  "users": [
    {
      "username": "monitoramento",
      "password": "TroqueAgora#Viewer2026",
      "role": "viewer"
    },
    {
      "username": "operacao_bot",
      "password": "TroqueAgora#Operator2026",
      "role": "operator"
    },
    {
      "username": "admin_gateway",
      "password": "TroqueAgora#Admin2026",
      "role": "admin"
    }
  ]
}
```

### O que significa cada role

- `viewer`: só visualizar eventos/logs.
- `operator`: viewer + enviar comandos.
- `admin`: operator + acessar auditoria.

Validar JSON:

```powershell
python -m json.tool .\config\gateway-users.json | Out-Null; Write-Host "JSON OK"
```

---

## 5) Confirmar host/porta do OpenKore (TCP)

Você precisa saber host/porta do endpoint TCP.

### Pré-requisito crítico

O `remote_gateway.pl` só consegue falar com um endpoint que implemente o protocolo de console do OpenKore (`set active` / `input`).
Esse endpoint é nativo da **Interface Socket** (arquivo `console.socket`).

Em outras palavras: deixar apenas `XKore_port` configurado não abre automaticamente esse protocolo para o gateway.

⚠️ **Importante:** no OpenKore padrão, `XKore_port` (ex.: `2350`) **não é automaticamente** o endpoint de console remoto esperado pelo `remote_gateway.pl` (`set active/input`).

### Fluxo único (simples, recomendado)

Use **só** este arquivo:

```text
tools\run-remote.cmd UM_TOKEN_LONGO_E_ALEATORIO start.exe
```

Ele já:
- abre **uma janela separada** para OpenKore com `--interface=Socket` usando o launcher que **você** informar (`start.exe`, `tkstart.exe`, etc.);
- configura endpoint TCP de console em `127.0.0.1:2350`;
- abre **outra janela separada** para o gateway em `127.0.0.1:18085`.

Valide:

```powershell
Test-NetConnection 127.0.0.1 -Port 2350
```

Se `TcpTestSucceeded` for `False`, o gateway vai subir com `/health`, mas ficará com `connected=false` e retornará `503 core_unavailable` em `/commands`.

---

## 6) Subir gateway no Windows (modo TCP)

No PowerShell, dentro de `C:\openkore`:

```powershell
perl .\tools\remote_gateway.pl --kore-host 127.0.0.1 --kore-port 2350 --listen-host 127.0.0.1 --listen-port 18085 --command-token "UM_TOKEN_LONGO_E_ALEATORIO" --audit-file ".\\logs\\gateway_audit.jsonl" --command-rate-limit 30 --command-rate-window 60 --auth-enabled --users-file ".\\config\\gateway-users.json" --token-ttl 900 --session-file ".\\data\\gateway_sessions.json"
```

> Se quiser manter nativo no Windows, prefira abrir o endpoint com `OPENKORE_SOCKET_TCP_PORT` + `--interface=Socket` (bloco acima).

### Modo ultra simples (recomendado)

Sem digitar vários comandos: execute **um arquivo**:

```text
tools\run-remote.cmd UM_TOKEN_LONGO_E_ALEATORIO
```

Esse `.cmd`:
- abre OpenKore (launcher detectado automaticamente) com `--interface=Socket`;
- configura `OPENKORE_SOCKET_TCP_HOST=127.0.0.1` e `OPENKORE_SOCKET_TCP_PORT=2350`;
- inicia o gateway em `127.0.0.1:18085` **sem depender** de `start-gateway.ps1`.
- o OpenKore é aberto pelo launcher normal (`start.exe`/`tkstart.exe`/etc), como no fluxo de duplo clique.

> Se seu objetivo é simplicidade, use somente `tools\run-remote.cmd` e ignore os outros scripts auxiliares.

---

## 7) Testar pelo Windows (browser + PowerShell)

### 7.1 Browser (Windows)

Abra:

```text
http://127.0.0.1:18085/
```

### 7.2 Healthcheck (PowerShell)

```powershell
curl.exe -s http://127.0.0.1:18085/health
```

### 7.3 Login (PowerShell)

```powershell
curl.exe -s -X POST "http://127.0.0.1:18085/auth/login" -H "Content-Type: application/json" -d "{\"username\":\"operacao_bot\",\"password\":\"TroqueAgora#Operator2026\"}"
```

> No PowerShell, `curl` normalmente é alias de `Invoke-WebRequest`; por isso use `curl.exe`.

---

## 8) Acesso remoto de verdade (fora da sua máquina)

Mantenha gateway em `127.0.0.1` e publique com túnel/VPN.

### SSH Tunnel (de outra máquina)

```bash
ssh -L 18085:127.0.0.1:18085 usuario@host-windows-ou-jump-host
```

Se seu Windows não aceita SSH inbound, use VPN/Tailscale/ZeroTier e exponha apenas internamente.

---

## 9) Inicialização automática no Windows

Para manter simples, agende **um comando só**:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { cd 'C:\openkore'; .\tools\run-remote.cmd UM_TOKEN_LONGO_E_ALEATORIO }"
```

Depois crie uma tarefa no **Task Scheduler** chamando:

```powershell
powershell -NoProfile -ExecutionPolicy Bypass -Command "& { cd 'C:\openkore'; .\tools\run-remote.cmd UM_TOKEN_LONGO_E_ALEATORIO }"
```

---

## 10) Troubleshooting comum (Windows nativo)

- **Gateway não inicia com erro de conexão**: host/porta TCP do OpenKore incorretos.
- **`Status conectado ao OpenKore: False` + erro `core_unavailable (503)` na UI**:
  - O gateway está de pé, mas **não conseguiu abrir sessão com o endpoint do OpenKore**.
  - Confira no PowerShell se a porta realmente aceita TCP:
    ```powershell
    Test-NetConnection 127.0.0.1 -Port 2350
    ```
  - Se `TcpTestSucceeded` vier `False`, a porta configurada em `--kore-port` está incorreta/inativa.
  - Atenção: `XKore_port` pode existir no `config.txt` e **mesmo assim não ser** o endpoint que fala o protocolo de console (`set active/input`) esperado pelo `remote_gateway.pl`.
- **porta 18085 não abre no Windows**: confirme que gateway está rodando e bound em `127.0.0.1`.
- **401/403**: revisar usuário/senha/token/header.
- **sem eventos**: OpenKore não está acessível no endpoint TCP configurado.

---

## 11) Validação final

```powershell
perl .\src\test\unittests.pl RemoteGatewaySmokeTest
bash .\tools\check_gateway_release.sh
```
