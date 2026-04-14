# OpenKore Remote Access Project Plan (Web/Mobile)

## 1) Objetivo do projeto
Criar um sistema remoto para:
- visualizar logs em tempo real (live log),
- enviar comandos ao OpenKore como no console,
- usar via navegador (desktop e mobile),
- operar com segurança e rastreabilidade.

---

## 2) Escopo funcional (MVP)
### Incluído
- Live log em tempo real via WebSocket.
- Envio de comandos remotos (`input`) com feedback.
- Interface web responsiva para celular.
- Login e controle de permissões (viewer/operator/admin).
- Auditoria de comandos (quem, quando, comando, resultado).
- Deploy e operação com segurança (preferência por VPN).

### Não incluído no MVP
- App nativo mobile (Android/iOS).
- Recursos avançados de analytics.
- Multi-tenant/múltiplos bots com isolamento completo.

---

## 3) Base técnica existente no OpenKore
- Há interface de socket para conectar clientes e trocar mensagens.
- Há suporte para receber entrada remota (`input`) e envio de saída.
- Há script de attach à sessão (`attach-to-console.pl`).

> Decisão: Reaproveitar essa base e construir um gateway seguro para web/mobile.

---

## 4) Arquitetura proposta
1. **OpenKore host (casa)**
   - OpenKore rodando normalmente.
   - Interface socket habilitada.
2. **Gateway local (novo serviço)**
   - Conecta no `console.socket` local.
   - Traduz eventos para WebSocket/API.
   - Aplica autenticação/autorização/auditoria.
3. **UI Web (desktop/mobile)**
   - Carregada no navegador.
   - Mostra live log e permite enviar comandos.
4. **Camada de segurança**
   - Preferência: acesso via VPN (Tailscale/WireGuard).
   - Alternativa: HTTPS público com hardening extra.

Fluxo simplificado:

`Navegador celular -> Gateway Web -> console.socket -> OpenKore`

---

## 5) Plano executivo em 7 tasks (macro)

## Task 1 — Arquitetura e contratos
**Objetivo:** fechar API/eventos/auth sem ambiguidades.
- Definir contratos de API e WebSocket (`v1`).
- Definir papéis e permissões.
- Definir política de acesso remoto.

**Entregáveis:**
- `docs/architecture.md`
- `docs/api-contract.md`
- `docs/security-policy.md`

**DoD:** contratos aprovados e versionados.

## Task 2 — Gateway core
**Objetivo:** conectar gateway ao socket do OpenKore com estabilidade.
- Cliente de socket + parser de eventos.
- Reconexão automática.
- Healthcheck.

**Entregáveis:** serviço gateway local funcionando.

**DoD:** stream estável e reconexão validada.

## Task 3 — Live log em tempo real
**Objetivo:** live log no navegador.
- Endpoint WebSocket.
- Broadcast + replay curto.
- Filtros básicos de log.

**Entregáveis:** cliente web recebe logs ao vivo.

**DoD:** reconexão e replay funcionando.

## Task 4 — Comandos remotos + auditoria
**Objetivo:** controlar bot remotamente com rastreabilidade.
- Endpoint de comando.
- Validação e limites.
- Gravação de auditoria.

**Entregáveis:** comando remoto operacional.

**DoD:** permissões aplicadas e auditoria persistente.

## Task 5 — UI Web responsiva
**Objetivo:** UX prática em desktop e celular.
- Login/sessão.
- Live log com filtros.
- Console de comandos + histórico.

**Entregáveis:** painel web funcional mobile/desktop.

**DoD:** operação completa no celular.

## Task 6 — Segurança e deploy
**Objetivo:** produção segura e sustentável.
- Deploy (systemd/docker).
- Secrets/env e logs.
- VPN/TLS, rate limit e hardening.

**Entregáveis:** guia de deploy + ambiente operacional.

**DoD:** serviço estável com segurança mínima validada.

## Task 7 — QA E2E e runbook
**Objetivo:** previsibilidade operacional.
- Testes E2E de fluxo crítico.
- Testes de falha e recuperação.
- Runbook de incidentes e manutenção.

**Entregáveis:** `docs/test-plan.md` e `docs/runbook.md`.

**DoD:** checklist de release aprovado.

---

## 6) Sequenciamento sugerido (sprints)
- **Sprint 1:** Tasks 1 e 2
- **Sprint 2:** Tasks 3 e 4
- **Sprint 3:** Tasks 5 e 6
- **Sprint 4:** Task 7 + release MVP

Estimativa:
- MVP funcional: 7 a 12 dias úteis (1 dev).
- Com polimento e segurança ampliada: 2 a 3 semanas.

---

## 7) Registro de progresso (catálogo vivo)

## Estado atual
- Etapa atual: **Task final concluída (pronto para release candidate)**
- Status geral: **Execução iniciada**
- Código implementado até agora: **gateway pronto para release candidate (MVP)**

## Changelog de projeto (preencher continuamente)
- 2026-04-14: Documento inicial de planejamento criado.
- 2026-04-14: Task 1 executada com criação de `architecture.md`, `api-contract.md` e `security-policy.md`.
- 2026-04-14: Task 2 executada com criação de `tools/remote_gateway.pl` e `docs/gateway-core.md`.
- 2026-04-14: Task 3 executada com endpoint `GET /ws/events`, replay inicial e broadcast live.
- 2026-04-14: Task 4 executada com `POST /commands`, validação de comando e auditoria em arquivo JSONL.
- 2026-04-14: Task 5 (MVP) executada com UI embutida em `GET /` para live log e envio de comandos.
- 2026-04-14: Task 6 (parcial) executada com rate limiting por origem, headers de segurança e guia de deploy/hardening.
- 2026-04-14: Task 6.2 concluída com teste automatizado `RemoteGatewaySmokeTest` integrado ao `unittests.pl`.
- 2026-04-14: Task 7 (parcial) executada com `POST /auth/login` e autorização Bearer para `/commands` e `/ws/events`.
- 2026-04-14: Task 7.2 (parcial) executada com `GET /audit` autenticado para papel admin.
- 2026-04-14: Task 8 (parcial) executada com `POST /auth/refresh` e `POST /auth/revoke`.
- 2026-04-14: Task 8.2 (parcial) executada com semântica de papéis (`viewer/operator/admin`) validada por smoke test.
- 2026-04-14: Task 9 (parcial) executada com persistência de sessão em `--session-file`.
- 2026-04-14: Task 9.2 (parcial) executada com endpoint `GET /auth/me` e validação em smoke test.
- 2026-04-14: Task final (parcial) executada com `tools/check_gateway_release.sh` e `docs/release-checklist.md`.
- 2026-04-14: Task final concluída com `gateway-users.example.json` e `release-notes-remote-gateway.md`.

## Template de atualização por task
Use o bloco abaixo ao concluir cada subetapa:

```md
### [DATA] Task X - <nome>
- Status: todo | doing | blocked | done
- Responsável:
- Mudanças realizadas:
  - arquivo/serviço:
  - resumo técnico:
- Segurança impactada?
- Testes executados:
- Riscos pendentes:
- Próximo passo:
```

---

## 8) Controle de contexto (anti-perda)
- Sempre registrar decisões de arquitetura e motivo.
- Nunca iniciar task sem DoD definido.
- Toda mudança deve atualizar este documento (seção 7).
- Toda feature nova deve ter teste mínimo e rollback descrito.
- Se houver bloqueio, registrar em até 24h com mitigação proposta.

---

## 9) Decisões técnicas atuais
- Caminho recomendado para acesso remoto: **VPN first**.
- Evitar expor socket cru do OpenKore à internet pública.
- Priorizar entrega web responsiva antes de app nativo.

---

## 10) Próxima ação imediata
Próximo passo imediato:
1. validar ambiente alvo com checklist
2. marcar release candidate
3. coletar feedback operacional inicial

