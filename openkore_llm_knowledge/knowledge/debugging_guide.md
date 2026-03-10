# Debugging Guide (Networking & Tables)

## 1) Confirm server/table alignment
- Verify the active server profile in `tables/servers.txt`.
- Confirm matching `recvpackets.txt` set (e.g., kRO vs iRO).
- Packet mismatch symptoms: unknown switch warnings, broken map/actor parsing, failed actions.

## 2) Trace receive path
- Start from `networking/Receive.pm` dispatch behavior.
- Compare overridden handlers in server-specific receive modules (`ServerType0`, `kRO`, `iRO`).
- Use packet references (`tables/packetlist.txt`, `tables/packetdescriptions.txt`) to identify suspect opcodes.

## 3) Trace send path
- Inspect `networking/Send.pm` and server-specific send modules.
- Validate whether a command/action is encoded in the expected packet version/format.

## 4) XKore-specific troubleshooting
- For bridge issues, inspect `networking/XKore.pm` lifecycle and channel forwarding.
- For proxy/session issues, inspect `networking/XKore2.pm` and `Network/XKore2/{AccountServer,CharServer,MapServer}.pm`.
- Ensure client/server stage transitions match expected state.

## 5) Practical iterative workflow
1. Reproduce issue with minimal actions.
2. Isolate receive vs send failure.
3. Validate server profile + recvpackets table pairing.
4. Check server-specific module overrides.
5. Re-test and document exact packet/table combination that works.
