# Debugging Guide (Networking and Tables)

## 1) Confirm server/profile alignment
- Validate `serverType` and packet profile selection in `control/config.txt`.
- Verify matching packet tables in `tables/*` for the selected server family.

## 2) Trace receive path
- `src/Network/MessageTokenizer.pm` -> `src/Network/PacketParser.pm` -> `src/Network/Receive.pm` -> `src/Network/Receive/*`
- Look for first packet decode mismatch point.

## 3) Trace send path
- Inspect command/task origin, then `src/Network/Send.pm` + `src/Network/Send/*` packet construction.
- Confirm opcode/structure expected by current server profile.

## 4) XKore-specific checks
- Inspect `src/Network/XKore.pm`, `src/Network/XKore2.pm`, `src/Network/XKoreProxy.pm`.
- Validate session phase transitions and packet forwarding symmetry.

## 5) Iterative workflow
1. Reproduce with minimal actions.
2. Isolate receive vs send failure.
3. Validate serverType/packet table pairing.
4. Re-test after one controlled change.
