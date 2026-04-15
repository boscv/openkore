# Guia completo (Windows + WSL2): acesso remoto OpenKore

Este guia é para quem usa **Windows** e quer rodar o Remote Gateway sem dor de cabeça.

> Recomendação prática: rode **OpenKore + Gateway dentro do WSL2 (Ubuntu)**.
> Evite rodar gateway em Perl nativo no Windows para esse fluxo.

---

## 0) WSL2 é máquina virtual?

Resumo simples:

- **Não é uma VM \"tradicional\"** igual VirtualBox/VMware com desktop separado.
- O WSL2 usa um kernel Linux leve integrado ao Windows.
- Você roda comandos Linux em terminal (Ubuntu) lado a lado com seu Windows.

Na prática, para você:

- continua usando Windows normalmente;
- abre um terminal Ubuntu quando precisar rodar OpenKore/Gateway;
- acessa a interface pelo navegador do Windows (`http://127.0.0.1:18085/`).

Se você **não quiser usar WSL2**, a alternativa é rodar OpenKore + gateway em um servidor Linux remoto (VPS) e acessar via SSH/VPN.

### Posso tentar Windows nativo agora?

Sim, agora existe modo de conexão TCP no gateway (`--kore-host` + `--kore-port`), que remove dependência obrigatória de socket Unix.

Mas atenção:

- você precisa ter um endpoint TCP do OpenKore disponível;
- continua recomendado validar bem auth/token/rate-limit antes de produção.

---

## 1) Visão geral (arquitetura no Windows)

Fluxo recomendado:

1. Você abre o Windows normalmente.
2. OpenKore + gateway rodam dentro do WSL2 (Linux).
3. Você acessa a UI no navegador do Windows em `http://127.0.0.1:18085/`.
4. Se quiser acesso externo, usa SSH túnel/VPN.

---

## 2) Pré-requisitos no Windows

No **PowerShell (Administrador)**:

```powershell
wsl --install -d Ubuntu
```

Depois reinicie o Windows (se solicitado), abra o Ubuntu e configure usuário/senha.

Valide no PowerShell:

```powershell
wsl -l -v
```

Esperado: distro Ubuntu com versão 2.

---

## 3) Preparar o ambiente dentro do WSL2

No terminal Ubuntu (WSL):

```bash
sudo apt update
sudo apt install -y perl git curl python3
```

Clonar repositório (exemplo):

```bash
cd ~
git clone https://github.com/<seu-user-ou-org>/openkore.git
cd openkore
```

> Se você já tem a pasta no Windows (ex.: `C:\...`), prefira copiar para o Linux do WSL (`~/openkore`) para melhor desempenho e menos problema de permissão.

---

## 4) Criar usuários RBAC (dentro do WSL)

```bash
sudo mkdir -p /etc/openkore
sudo cp tools/gateway-users.example.json /etc/openkore/gateway-users.json
sudo nano /etc/openkore/gateway-users.json
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

```bash
python3 -m json.tool /etc/openkore/gateway-users.json > /dev/null && echo "JSON OK"
```

---

## 5) Descobrir o socket do OpenKore

Dentro da pasta do projeto no WSL:

```bash
cd ~/openkore
find . -type s -name '*.socket'
```

Se aparecer `./console.socket`, use:

- `/home/<seu-usuario>/openkore/console.socket`

---

## 6) Subir gateway no WSL2

Exemplo completo:

```bash
cd ~/openkore
mkdir -p /var/log/openkore /var/lib/openkore

perl tools/remote_gateway.pl \
  --socket /home/<seu-usuario>/openkore/console.socket \
  --listen-host 127.0.0.1 \
  --listen-port 18085 \
  --command-token "UM_TOKEN_LONGO_E_ALEATORIO" \
  --audit-file /var/log/openkore/gateway_audit.jsonl \
  --command-rate-limit 30 \
  --command-rate-window 60 \
  --auth-enabled \
  --users-file /etc/openkore/gateway-users.json \
  --token-ttl 900 \
  --session-file /var/lib/openkore/gateway_sessions.json
```

### 6.1 Modo alternativo (Windows nativo via TCP)

Se você tiver OpenKore acessível em TCP, pode iniciar gateway usando:

```powershell
perl tools/remote_gateway.pl --kore-host 127.0.0.1 --kore-port 2350 --listen-host 127.0.0.1 --listen-port 18085 --command-token "UM_TOKEN_LONGO_E_ALEATORIO" --auth-enabled --users-file "C:\\caminho\\gateway-users.json"
```

> Esse modo depende do endpoint TCP do OpenKore já estar ativo.

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

Como systemd não é padrão para esse cenário, você pode:

1. Criar script WSL para subir OpenKore e gateway.
2. Criar tarefa no **Task Scheduler** do Windows chamando:

```powershell
wsl -d Ubuntu -- bash -lc "cd ~/openkore && perl tools/remote_gateway.pl ..."
```

---

## 10) Troubleshooting comum (Windows + WSL)

- **`find` no PowerShell não acha `.socket`**: rode `find` dentro do Ubuntu WSL, não no PowerShell.
- **porta 18085 não abre no Windows**: confirme que gateway está rodando no WSL e bound em `127.0.0.1`.
- **401/403**: revisar usuário/senha/token/header.
- **sem eventos**: OpenKore não está conectado no socket esperado.

---

## 11) Validação final

No WSL:

```bash
cd ~/openkore
perl src/test/unittests.pl RemoteGatewaySmokeTest
./tools/check_gateway_release.sh
```
