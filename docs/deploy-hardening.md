# Remote Gateway Deploy + Hardening (Task 6)

## Scope delivered in this stage
- Incremental hardening in gateway runtime:
  - security headers in HTTP responses,
  - per-source command rate limiting,
  - configurable rate-limit window/threshold.

## New runtime flags
- `--command-rate-limit <int>` (default: `30`)
- `--command-rate-window <seconds>` (default: `60`)
- `--kore-host <host>` + `--kore-port <port>` (optional TCP mode to reach OpenKore endpoint)

## Recommended launch (VPN-first)
```bash
perl tools/remote_gateway.pl \
  --socket /path/to/console.socket \
  --listen-host 127.0.0.1 \
  --listen-port 18085 \
  --command-token "CHANGE_ME" \
  --audit-file /var/log/openkore/gateway_audit.jsonl \
  --command-rate-limit 30 \
  --command-rate-window 60 \
  --auth-enabled \
  --users-file /etc/openkore/gateway-users.json \
  --token-ttl 900 \
  --session-file /var/lib/openkore/gateway_sessions.json

# users file example:
# cp tools/gateway-users.example.json /etc/openkore/gateway-users.json
```

If your OpenKore endpoint is TCP (instead of Unix socket), replace `--socket ...` with:

```bash
--kore-host 127.0.0.1 --kore-port 2350
```

## Operational notes
- Keep bind host as `127.0.0.1` and publish via VPN tunnel.
- Avoid exposing gateway directly to public internet at this stage.
- Rotate users/passwords or token policy periodically.
- Protect `--session-file` permissions (contains active tokens).
- Monitor audit JSONL and command rejection reasons.

## systemd example
```ini
[Unit]
Description=OpenKore Remote Gateway
After=network.target

[Service]
Type=simple
WorkingDirectory=/workspace/openkore
ExecStart=/usr/bin/perl /workspace/openkore/tools/remote_gateway.pl --socket /path/to/console.socket --listen-host 127.0.0.1 --listen-port 18085 --command-token CHANGE_ME --audit-file /var/log/openkore/gateway_audit.jsonl
Restart=always
RestartSec=2
User=openkore
Group=openkore

[Install]
WantedBy=multi-user.target
```

## Automated smoke test
```bash
perl src/test/unittests.pl RemoteGatewaySmokeTest
```

This validates basic gateway boot, UI endpoint, token enforcement, and command rate-limit behavior.


## Audit query check (admin token)
```bash
curl -s "http://127.0.0.1:18085/audit?limit=20" -H "Authorization: Bearer <ADMIN_TOKEN>"
```


## Session token rotation check
```bash
curl -s -X POST "http://127.0.0.1:18085/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<REFRESH_TOKEN>"}'
```


## Session introspection check
```bash
curl -s "http://127.0.0.1:18085/auth/me" -H "Authorization: Bearer <ACCESS_TOKEN>"
```


## Final pre-release command
```bash
./tools/check_gateway_release.sh
```

See full checklist in `docs/release-checklist.md`.


See `docs/release-notes-remote-gateway.md` for MVP release summary.
