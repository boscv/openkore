# OpenKore Remote Access - API Contract (v1)

## Auth model
- Access token (JWT), short TTL.
- Refresh token, revocable and rotated.
- Roles: `viewer`, `operator`, `admin`.

## Common response envelope
```json
{
  "ok": true,
  "data": {},
  "error": null,
  "request_id": "uuid"
}
```

## Endpoints

### `GET /health`
- Auth: none
- Response: service status, OpenKore socket connectivity, version.

### `GET /` (gateway current stage UI)
- Auth: none (network-level protection recommended)
- Returns: responsive HTML UI for live log + command console.

### `POST /auth/login` (gateway current stage)
- Auth: none
- Body: `{ "username": "...", "password": "..." }`
- Success: `{ "access_token": "...", "role": "...", "expires_in": <sec> }`

### `GET /auth/me` (gateway current stage)
- Auth: Bearer access token.
- Returns username/role/expiry for current session.

### `POST /auth/refresh` (gateway current stage)
- Auth: none (requires valid `refresh_token` in body).
- Body: `{ "refresh_token": "..." }`
- Success: rotates and returns new `access_token` + `refresh_token` (persisted when `--session-file` is configured).

### `POST /auth/revoke` (gateway current stage)
- Auth: none (requires `refresh_token` in body).
- Revokes refresh token and linked access token.

### `POST /api/v1/auth/login`
- Auth: none
- Body:
```json
{
  "username": "string",
  "password": "string",
  "otp": "string optional"
}
```
- Success:
```json
{
  "ok": true,
  "data": {
    "access_token": "jwt",
    "refresh_token": "opaque",
    "expires_in": 900,
    "role": "viewer|operator|admin"
  }
}
```

### `POST /api/v1/auth/refresh`
- Auth: refresh token
- Rotates refresh token and returns new pair.

### `POST /api/v1/auth/logout`
- Auth: bearer
- Revokes current refresh token chain.

### `GET /audit` (gateway current stage)
- Auth: admin Bearer token when `--auth-enabled` is active.
- Query: `limit` (1..200, default 50).
- Returns last audit entries from JSONL store.

### `POST /commands` (gateway current stage)
- Auth: `Authorization: Bearer <token>` when `--auth-enabled` is active, otherwise optional `X-Command-Token`
- Body:
```json
{
  "command": "string"
}
```
- Response: `202 Accepted` when forwarded to OpenKore.
- Errors: `missing_token`, `invalid_token`, `token_expired`, `forbidden`, `invalid_json`, `invalid_command`, `rate_limited`, `core_unavailable`, `send_failed`.

### `POST /api/v1/commands`
- Auth: `operator` or `admin`
- Body:
```json
{
  "command": "string",
  "client_ts": "RFC3339 optional"
}
```
- Validation:
  - max length 256
  - no binary payload
  - optional allowlist mode
- Success:
```json
{
  "ok": true,
  "data": {
    "command_id": "uuid",
    "accepted": true
  }
}
```

### `GET /api/v1/audit`
- Auth: `admin`
- Query: `from`, `to`, `actor`, `limit`, `cursor`
- Returns paginated command audit events.

## WebSocket
### `WS /ws/events` (gateway current stage)
- Auth: query token `?token=` or Bearer header when `--auth-enabled` is active.

### `WS /ws/v1/logs`
- Auth: bearer token in header or query (header preferred).
- Roles:
  - `viewer`: read logs
  - `operator/admin`: read logs + receive command lifecycle events

### Server -> client events
- `log_event`
```json
{
  "type": "log_event",
  "payload": {
    "domain": "string",
    "level": "string",
    "message": "string",
    "ts": "RFC3339"
  }
}
```

- `title_event`
```json
{
  "type": "title_event",
  "payload": {
    "title": "string",
    "ts": "RFC3339"
  }
}
```

- `command_result`
```json
{
  "type": "command_result",
  "payload": {
    "command_id": "uuid",
    "status": "accepted|rejected|error",
    "reason": "string optional",
    "ts": "RFC3339"
  }
}
```

### Client -> server actions (optional v1.1)
- `send_command` (same authorization as POST /commands)

## Error codes
- `AUTH_INVALID_CREDENTIALS`
- `AUTH_TOKEN_EXPIRED`
- `AUTH_FORBIDDEN`
- `CMD_INVALID`
- `CMD_RATE_LIMITED`
- `CORE_UNAVAILABLE`

## Rate limits (initial)
- Login: 5 req/min per IP + username bucket.
- Commands: 30 req/min per user.
- WS connections: 3 concurrent per user.
