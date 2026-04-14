# Release Notes - Remote Gateway MVP

## Highlights
- Local gateway service for OpenKore with HTTP + WebSocket surface.
- Embedded web UI for quick mobile/desktop operation.
- RBAC roles (`viewer`, `operator`, `admin`) with session endpoints (`/auth/login`, `/auth/me`, `/auth/refresh`, `/auth/revoke`).
- Command path protection with rate limiting and audit logging.
- Admin-only audit retrieval endpoint.
- Smoke test automation and release-check script.

## Main endpoints
- `GET /health`
- `GET /`
- `GET /events`
- `GET /ws/events`
- `POST /commands`
- `POST /auth/login`
- `GET /auth/me`
- `POST /auth/refresh`
- `POST /auth/revoke`
- `GET /audit`

## Runtime artifacts
- Audit JSONL file (default: `gateway_audit.jsonl`)
- Session file (configurable with `--session-file`)

## Validation
Run:
```bash
./tools/check_gateway_release.sh
```

## Notes
- Recommended deployment remains VPN-first.
- Do not expose gateway directly to the public internet without additional hardening.
