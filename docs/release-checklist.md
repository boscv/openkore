# Remote Gateway Release Checklist (Final Stage)

Use this checklist before tagging a release candidate.

## 1) Functional checks
- [ ] Gateway starts with intended flags (`--auth-enabled`, `--users-file`, `--session-file`).
- [ ] `users-file` is based on `tools/gateway-users.example.json` and all default passwords replaced.
- [ ] `GET /health` shows expected config and connected state.
- [ ] `GET /` UI loads and can connect WS.
- [ ] `POST /auth/login` returns access/refresh tokens.
- [ ] `GET /auth/me` returns role and expiry for valid token.
- [ ] `POST /auth/refresh` rotates tokens.
- [ ] `POST /auth/revoke` revokes access linked to refresh token.
- [ ] `POST /commands` enforces role (`operator+`) and rate limit.
- [ ] `GET /audit` enforces role (`admin`) and returns bounded entries.

## 2) Security checks
- [ ] Gateway bound to `127.0.0.1` or private interface only.
- [ ] Access path is VPN/private network (no direct public exposure).
- [ ] `users-file` and `session-file` permissions restricted.
- [ ] Audit file path writable and monitored.
- [ ] Security headers present in HTTP responses.

## 3) Regression checks
- [ ] Run `tools/check_gateway_release.sh` successfully.
- [ ] Confirm `RemoteGatewaySmokeTest` passing in CI/local.

## 4) Operational docs
- [ ] `docs/deploy-hardening.md` reflects current flags and examples.
- [ ] `docs/api-contract.md` matches implemented endpoints.
- [ ] `docs/remote-access-project-plan.md` updated with release status.

## Release command
```bash
./tools/check_gateway_release.sh
```

- [ ] `docs/release-notes-remote-gateway.md` reviewed and finalized.
