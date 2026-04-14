# Gateway Core (Task 2/3) - Execution Notes

## What was implemented
- `tools/remote_gateway.pl`
  - Connects to OpenKore unix socket.
  - Sends `set active` on connect.
  - Parses OpenKore bus messages via `Bus::MessageParser`.
  - Normalizes core events (`output`, `title changed`, `inputted`) into an internal ring buffer.
  - Reconnects automatically after disconnect.
  - Exposes health endpoint: `GET /health`.
  - Exposes built-in web UI: `GET /` (mobile/desktop, live log + command console).
  - Exposes debug endpoint: `GET /events` (recent normalized events).
  - Exposes WebSocket endpoint: `GET /ws/events` with:
    - replay of buffered events on connect,
    - live event broadcast to connected clients,
    - basic ping/pong and close handling.

## Run
```bash
perl tools/remote_gateway.pl --socket /path/to/console.socket --listen-host 127.0.0.1 --listen-port 18085
```

## Health check
```bash
curl -s http://127.0.0.1:18085/health
```

## UI quick check
```bash
http://127.0.0.1:18085/
```

## WebSocket quick check
```bash
# example endpoint
ws://127.0.0.1:18085/ws/events
```

## Notes
- This stage delivers gateway core + live streaming + initial command write path.
- `POST /commands` accepts JSON `{ "command": "..." }` with validation, optional `X-Command-Token`, and per-source rate limiting.
- Command attempts are persisted in JSONL audit file (`--audit-file`).
- Rate limiting flags: `--command-rate-limit` and `--command-rate-window`.
- Optional RBAC session mode: `--auth-enabled --users-file <json> --token-ttl <sec>`.
- Initial auth session endpoints: `POST /auth/login`, `GET /auth/me`, `POST /auth/refresh`, `POST /auth/revoke` (Bearer token for `/commands` and `/ws/events`).
- Session store can persist to disk via `--session-file`.
- Admin-only audit retrieval available at `GET /audit?limit=`.
- Keep endpoint private (VPN/local), do not expose publicly in this stage.


## Role semantics (current stage)
- `viewer`: WebSocket read access only
- `operator`: viewer + `POST /commands`
- `admin`: operator + `GET /audit`
