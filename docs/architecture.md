# OpenKore Remote Access - Architecture (v1)

## Objective
Provide secure remote visibility and command execution for OpenKore using a browser/mobile UI, while keeping OpenKore unchanged.

## Non-goals (v1)
- Native mobile apps.
- Multi-tenant isolation.
- Public unauthenticated access.

## High-level components
1. **OpenKore process**
   - Existing runtime.
   - Emits console output and accepts input through socket interface.
2. **Gateway service (new)**
   - Local process on the same host.
   - Connects to OpenKore socket.
   - Exposes HTTPS API + WebSocket to clients.
   - Applies authn/authz, rate limits, and auditing.
3. **Web UI (new)**
   - Responsive browser UI.
   - Live log viewer and command console.
4. **Security transport**
   - Preferred: VPN-only exposure.
   - Alternative: public HTTPS with hardening.

## Data flow
1. OpenKore writes output events.
2. Gateway consumes socket events.
3. Gateway broadcasts normalized log events via WebSocket.
4. User command from UI hits API/WS action.
5. Gateway validates authorization and forwards as OpenKore input.
6. Gateway records audit entry.

## Runtime topology (VPN-first)
- Single host: OpenKore + Gateway + static UI files.
- Remote clients: browser over VPN.
- No direct internet exposure of OpenKore socket.

## Interfaces
### Internal (Gateway <-> OpenKore)
- Unix socket path: `<logs_folder>/console.socket`
- Event semantics based on existing OpenKore socket protocol.

### External (Client <-> Gateway)
- `GET /health`
- `POST /api/v1/auth/login`
- `POST /api/v1/auth/refresh`
- `POST /api/v1/commands`
- `GET /api/v1/audit` (admin)
- `WS /ws/v1/logs`

## Reliability
- Auto-reconnect loop to OpenKore socket.
- Bounded in-memory log ring for replay (N lines).
- Backpressure strategy for slow WS clients (drop oldest, signal overflow).

## Observability
- Structured JSON logs.
- Correlation ID per command request.
- Metrics: active sessions, WS clients, command latency, dropped events.

## Security baseline
- Short-lived access tokens.
- Refresh token rotation.
- Role-based access control.
- Command allowlist option (server-side).
- Audit trail for every command request.

## Release strategy
- Milestone A: read-only live log.
- Milestone B: authenticated command execution.
- Milestone C: audit + hardening + runbook.
