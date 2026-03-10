# Common Pitfalls

Concise checklist of high-frequency debugging traps in OpenKore architecture and operations.

## 1) Assuming movement issues are only routing bugs
- AI state locks, command overrides, or task queue starvation can mimic routing failures.
- Check AI/task state before editing route logic.

## 2) Ignoring serverType/packet table drift
- Packet desync often starts after server updates when recvpackets/opcodes change.
- Keep `control/config.txt` server settings aligned with `tables/*` packet definitions.

## 3) Debugging plugin hooks without proving event emission
- A hook can be correct but never run if the event is not emitted in the current flow.
- Verify both registration and actual event source path.

## 4) Treating macro trigger failures as parser failures
- Many cases are valid parse + false trigger conditions.
- Separate: plugin load -> file parse -> trigger true -> action execution.

## 5) Overlooking config-side constraints
- `control/config.txt`, `mon_control.txt`, and related files can disable or redirect behavior.
- Always test with minimal, known-good config for reproduction.

## 6) Mixing XKore and DirectConnection assumptions
- Transport/session behavior differs; debugging steps are mode-specific.
- Confirm active mode first before tracing packet/session paths.

## 7) Trusting visual client state over bot internal state
- In XKore scenarios, client view may lag/diverge from bot state.
- Compare bot-side actor/position updates with forwarded client packets.

## 8) Investigating deep modules before reproducing minimally
- Large automation stacks (AI + plugin + macro + eventMacro) hide root causes.
- Reproduce with minimal script/task/command to localize fault domain.

## Fast isolation matrix
| Symptom | First subsystem to verify | Primary files |
|---|---|---|
| Bot not moving | AI/Task | `src/AI.pm`, `src/TaskManager.pm` |
| Route fails | Routing/Field | `src/Task/Route.pm`, `src/Field.pm` |
| NPC fails | Task + Receive | `src/Task/TalkNPC.pm`, `src/Network/Receive.pm` |
| Plugin not loading | Plugin loader | `src/Plugins.pm`, plugin file |
| Hook silent | Event dispatch | `src/Plugins.pm`, event source module |
| Macro not triggering | Macro pipeline | `plugins/macro/*`, `src/Commands.pm` |
| eventMacro issues | eventMacro runner | `plugins/eventMacro/eventMacro/*` |
| Packet desync | Packet mapping | `src/Network/PacketParser.pm`, `tables/*` |
| XKore sync issues | XKore bridge | `src/Network/XKore*.pm` |
| Client view stale | XKore forwarding | `src/Network/XKore*.pm`, `src/ActorList.pm` |
