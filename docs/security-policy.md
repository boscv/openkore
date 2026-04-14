# OpenKore Remote Access - Security Policy (v1)

## Security posture
- **Default mode:** private access over VPN.
- **Public exposure:** only with HTTPS, hardened reverse proxy, and strong auth.

## Threat model (summary)
- Credential theft.
- Session/token replay.
- Command abuse by authorized users.
- Brute-force login attempts.
- Log data leakage.

## Mandatory controls
1. TLS in transit (or VPN-only private network).
2. Password hashing (Argon2id or bcrypt).
3. Short access-token TTL (<=15 min).
4. Refresh token rotation + revocation support.
5. Role-based permissions:
   - viewer: read-only
   - operator: command execution
   - admin: user/admin + audit access
6. Audit log for every command attempt (accepted/rejected).
7. Rate limiting on login and commands.
8. Security headers and CORS allowlist.
9. Secret management via environment/secrets vault.

## Prohibited patterns
- No direct internet exposure of OpenKore socket.
- No MAC-address-based authorization as primary control.
- No plaintext password storage.
- No long-lived non-rotating admin tokens.

## Session policy
- Access token: 15 minutes.
- Refresh token: 7 days with rotation.
- Inactivity timeout for UI session: 30 minutes.
- Force logout on suspicious activity or manual revoke.

## Audit policy
Capture at minimum:
- `who` (user id, role)
- `what` (command)
- `when` (server timestamp UTC)
- `where` (source IP/device fingerprint best-effort)
- `result` (accepted/rejected/error)

Retention:
- 90 days minimum for command audit.

## Deployment policy
- Gateway should run as non-root user.
- Restrict file permissions for logs and config.
- Enable process restart policy.
- Keep host OS patched.
- Backup audit and config routinely.

## Incident response (minimum)
1. Revoke compromised sessions/tokens.
2. Disable operator accounts if abuse detected.
3. Rotate secrets.
4. Review audit trail window.
5. Publish post-incident summary and corrective actions.

## Compliance checklist (pre-production)
- [ ] RBAC enforced on all endpoints.
- [ ] Command rate limiting enabled.
- [ ] Audit trail query available for admin.
- [ ] Token revoke/rotation tested.
- [ ] TLS/VPN path validated.
- [ ] Backup and restore drill completed.
