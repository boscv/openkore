# Guia passo a passo (PT-BR): configurar e usar o acesso remoto do OpenKore

Este guia explica de forma **bem detalhada** como configurar e usar o Remote Gateway do OpenKore.
A ideia é você sair daqui sabendo exatamente:

- o que preencher em cada campo;
- que usuário cria para cada perfil;
- como testar login/comando;
- como acessar remotamente com segurança.

> Recomendação oficial do projeto: **VPN first** (não expor o gateway diretamente na internet).

---

## 0) Compatibilidade real: Linux x Windows

Resposta curta para sua pergunta: **Linux continua sendo o caminho mais seguro/suportado**, mas agora o gateway também aceita conexão TCP com OpenKore.

Por quê:

- O gateway conecta no OpenKore via socket Unix (`--socket`) **ou** via TCP (`--kore-host` + `--kore-port`).
- O fluxo padrão do projeto usa caminhos Unix (`/etc/...`) e serviço `systemd`.

> Importante: para funcionar, o endpoint precisa falar o protocolo de console do OpenKore (`set active/input`). Nem toda porta TCP do OpenKore (ex.: `XKore_port`) é compatível com esse protocolo.
> No Windows nativo, você pode expor endpoint compatível iniciando com `OPENKORE_SOCKET_TCP_PORT` e `--interface=Socket`.
> Atalho no Windows: `tools/start-openkore-socket-tcp.ps1` sobe OpenKore + gateway com um comando.

Isso significa:

- **Linux nativo**: cenário recomendado e documentado.
- **Windows nativo (PowerShell + Perl direto no Windows)**: possível via modo TCP, desde que OpenKore esteja acessível por host/porta.
- **Windows com WSL2**: funciona melhor se **OpenKore + gateway rodarem juntos dentro da mesma distro WSL** (onde existe socket Unix).

Se você usa Windows e quer evitar dor de cabeça, escolha uma destas opções:

1. Rodar OpenKore + gateway em um VPS Linux (e acessar via SSH/VPN).
2. Rodar ambos dentro do WSL2 (Ubuntu, por exemplo).

Para passo a passo focado em Windows nativo, veja: `docs/guia-acesso-remoto-windows-nativo.md`.

---

## 1) Pré-requisitos (com validação)

Você precisa de:

1. OpenKore rodando no servidor/host.
2. Perl instalado no mesmo host.
3. Acesso shell (SSH) ao host.
4. Repositório do OpenKore com:
   - `tools/remote_gateway.pl`
   - `tools/gateway-users.example.json`

Valide rapidamente:

```bash
perl -v
ls tools/remote_gateway.pl tools/gateway-users.example.json
```

Se esses dois comandos funcionarem, pode seguir.

> No Windows, execute esses comandos **no ambiente Linux alvo** (VPS/WSL), não no PowerShell local puro.

---

## 2) Conceitos rápidos (o que é cada coisa)

### 2.1 O que é o gateway

O `remote_gateway.pl` é um "tradutor" entre:

- OpenKore (socket local Unix), e
- cliente remoto (browser/app via HTTP/WebSocket).

### 2.2 Endpoints disponíveis

- `GET /health`: status do gateway.
- `GET /`: interface web embutida.
- `GET /ws/events`: stream de eventos em tempo real.
- `POST /commands`: envia comando para o OpenKore.
- `POST /auth/login`: login com usuário/senha.
- `GET /auth/me`: mostra sessão atual.
- `POST /auth/refresh`: renova token.
- `POST /auth/revoke`: revoga sessão.
- `GET /audit`: consulta auditoria (**somente admin**).

### 2.3 O que é RBAC

RBAC = controle de acesso por papel (role).

- `viewer`: só vê eventos/tela (não envia comando).
- `operator`: viewer + pode enviar comandos em `/commands`.
- `admin`: operator + pode consultar `/audit`.

---

## 3) Criando usuários: o que preencher em `username`, `password`, `role`

### 3.1 Copiar arquivo base

```bash
sudo mkdir -p /etc/openkore
sudo cp tools/gateway-users.example.json /etc/openkore/gateway-users.json
```

> Esse caminho (`/etc/openkore/...`) é do **servidor Linux**.  
> Se você estiver no Windows, edite o arquivo via SSH/SFTP no servidor, não no `C:\` local (a menos que seu gateway também rode localmente no Windows).

### 3.2 Estrutura exata do JSON

Cada usuário tem 3 campos:

- `username`: nome de login (sem espaço; use algo claro).
- `password`: senha em texto (troque por senha forte).
- `role`: nível de permissão (`viewer`, `operator` ou `admin`).

Exemplo **pronto para uso**:

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

### 3.3 Como escolher cada role na prática

- Use **viewer** para quem só precisa acompanhar logs/eventos (ex.: celular secundário, observador).
- Use **operator** para quem pode executar comandos do bot (ex.: operador principal).
- Use **admin** só para manutenção/auditoria (mínimo de pessoas possível).

### 3.4 Erros comuns nessa etapa

- Deixar `change_me_*` sem trocar.
- Inventar role diferente (ex.: `superadmin`) — não vai funcionar.
- Esquecer vírgula ou quebrar JSON.

Valide JSON com o comando correto para o seu terminal:

**Linux/macOS (bash):**

```bash
python -m json.tool /etc/openkore/gateway-users.json > /dev/null && echo "JSON OK"
```

**Windows PowerShell:**

```powershell
ssh usuario@ip-do-servidor "python -m json.tool /etc/openkore/gateway-users.json > /dev/null && echo JSON OK"
```

> No PowerShell, `&&` pode não funcionar dependendo da versão/configuração. Use `;`.

---

## 4) Descobrir o socket do OpenKore (campo `--socket`)

Você **precisa** passar o caminho correto do socket do OpenKore.

Procure o socket no **host Linux onde o OpenKore está rodando**:

```bash
find . -type s -name '*.socket'
```

Se você estiver no **Windows PowerShell local**, esse `find` não é o mesmo comando do Linux.
Nesse caso, entre no servidor primeiro (SSH) e rode o `find` lá:

```powershell
ssh usuario@ip-do-servidor
# depois, no shell Linux remoto:
cd /workspace/openkore
find . -type s -name '*.socket'
```

Se aparecer, por exemplo, `./console.socket`, então no comando você usa:

```text
--socket /workspace/openkore/console.socket
```

> Se o caminho estiver errado, o gateway sobe, mas não consegue enviar/receber do OpenKore.

---

## 5) Subir o gateway (com explicação de cada flag)

Comando recomendado (com auth, rate-limit e auditoria):

```bash
perl tools/remote_gateway.pl \
  --socket /workspace/openkore/console.socket \
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

### 5.1 O que cada flag significa (sem pular nada)

- `--socket`: caminho do socket do OpenKore.
- `--listen-host 127.0.0.1`: só aceita conexão local (mais seguro).
- `--listen-port 18085`: porta do gateway.
- `--command-token`: "segunda trava" para rota de comando.
- `--audit-file`: grava histórico de tentativas/comandos.
- `--command-rate-limit 30`: máximo de 30 comandos...
- `--command-rate-window 60`: ...a cada 60 segundos por origem.
- `--auth-enabled`: obriga login por usuário/senha.
- `--users-file`: caminho do JSON de usuários.
- `--token-ttl 900`: access token dura 900s (15 min).
- `--session-file`: arquivo para persistir sessões/tokens.

### 5.2 O que você deve trocar obrigatoriamente

- `--socket`: para o caminho real do seu socket.
- `--command-token`: para um token forte (não usar `CHANGE_ME`).
- senhas do JSON (`/etc/openkore/gateway-users.json`).

### 5.3 Alternativa compatível (TCP em vez de socket Unix)

Se seu OpenKore estiver exposto por host/porta, você pode usar:

```bash
perl tools/remote_gateway.pl \
  --kore-host 127.0.0.1 \
  --kore-port 2350 \
  --listen-host 127.0.0.1 \
  --listen-port 18085 \
  --command-token "UM_TOKEN_LONGO_E_ALEATORIO" \
  --auth-enabled \
  --users-file /etc/openkore/gateway-users.json
```

> Nesse modo, use `--kore-host` + `--kore-port` juntos.
> Importante: `XKore_port` no `config.txt` não garante compatibilidade com o protocolo de console (`set active/input`) usado pelo gateway.
> Se a porta não for compatível, o `/health` ficará com `connected=false` e `/commands` retornará `503 core_unavailable`.

---

## 6) Teste completo (login -> sessão -> comando)

### 6.1 Testar saúde

```bash
curl -s http://127.0.0.1:18085/health
```

Se vier JSON, gateway está de pé.

### 6.2 Fazer login (operator)

```bash
curl -s -X POST "http://127.0.0.1:18085/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"username":"operacao_bot","password":"TroqueAgora#Operator2026"}'
```

Resposta deve conter `access_token` e `refresh_token`.

### 6.3 Validar token

```bash
curl -s "http://127.0.0.1:18085/auth/me" \
  -H "Authorization: Bearer <ACCESS_TOKEN>"
```

### 6.4 Enviar comando real ao OpenKore

```bash
curl -s -X POST "http://127.0.0.1:18085/commands" \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <ACCESS_TOKEN>" \
  -H "X-Command-Token: UM_TOKEN_LONGO_E_ALEATORIO" \
  -d '{"command":"status"}'
```

> Sem `Authorization` ou sem `X-Command-Token`, a chamada deve ser negada.

### 6.5 Testar UI local

No navegador do host:

```text
http://127.0.0.1:18085/
```

---

## 7) Acesso remoto seguro (SSH tunnel e VPN)

Como o bind está em `127.0.0.1`, você **não** acessa direto de fora. Isso é intencional.

### Opção A: SSH Tunnel (rápido e simples)

No seu PC:

```bash
ssh -L 18085:127.0.0.1:18085 usuario@ip-do-servidor
```

No Windows PowerShell é o mesmo comando acima.

Com essa sessão aberta, no mesmo PC abra:

```text
http://127.0.0.1:18085/
```

### Opção B: VPN (produção)

- Coloque servidor e cliente na mesma VPN.
- Mantenha gateway local (`127.0.0.1`) e publique por túnel/proxy interno.
- Não abra a porta 18085 no firewall público.

---

## 8) Subir automaticamente com systemd

> Esta seção é **somente Linux** (systemd não é padrão no Windows nativo).

Exemplo de unit (`/etc/systemd/system/openkore-gateway.service`):

```ini
[Unit]
Description=OpenKore Remote Gateway
After=network.target

[Service]
Type=simple
WorkingDirectory=/workspace/openkore
ExecStart=/usr/bin/perl /workspace/openkore/tools/remote_gateway.pl --socket /workspace/openkore/console.socket --listen-host 127.0.0.1 --listen-port 18085 --command-token UM_TOKEN_LONGO_E_ALEATORIO --audit-file /var/log/openkore/gateway_audit.jsonl --auth-enabled --users-file /etc/openkore/gateway-users.json --token-ttl 900 --session-file /var/lib/openkore/gateway_sessions.json
Restart=always
RestartSec=2
User=openkore
Group=openkore

[Install]
WantedBy=multi-user.target
```

Aplicar:

```bash
sudo systemctl daemon-reload
sudo systemctl enable --now openkore-gateway
sudo systemctl status openkore-gateway
```

---

## 9) Segurança mínima obrigatória (checklist)

1. Trocar todas as senhas e token padrão.
2. Permissão restrita em sessões/auditoria:

```bash
sudo chown openkore:openkore /var/lib/openkore/gateway_sessions.json /var/log/openkore/gateway_audit.jsonl
sudo chmod 600 /var/lib/openkore/gateway_sessions.json /var/log/openkore/gateway_audit.jsonl
```

3. Usar `admin` só para administração.
4. Revisar `gateway_audit.jsonl` com frequência.
5. Rotacionar senha/token periodicamente.

---

## 10) Troubleshooting direto ao ponto

- **401/403 no login**: usuário/senha errados ou JSON mal formatado.
- **401/403 no `/commands`**: faltou Bearer token e/ou `X-Command-Token`.
- **`kore_disconnected`**: `--socket` incorreto ou OpenKore não está com socket ativo.
- **429 (rate limit)**: excesso de comandos no intervalo; ajuste `--command-rate-*` com cuidado.
- **UI abre sem eventos**: WebSocket não conectou ou OpenKore sem tráfego no momento.

---

## 11) Validação final (release flow)

```bash
perl src/test/unittests.pl RemoteGatewaySmokeTest
./tools/check_gateway_release.sh
```

Se os dois passarem, seu ambiente está alinhado com o fluxo de release do gateway.
