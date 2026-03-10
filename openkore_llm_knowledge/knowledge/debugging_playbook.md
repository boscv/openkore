# OpenKore Debugging Playbook

This playbook provides structured troubleshooting for common OpenKore runtime issues.

---

## 1) Bot Not Moving

### Possible causes
- Movement/task pipeline blocked (AI state, mutex, sit/stand state, map lock logic).
- Invalid route target or unreachable coordinates.
- Network-side movement packets not being sent/accepted.
- Configuration constraints preventing movement.

### Files to inspect
- Core runtime/task modules:
  - `core/AI/CoreLogic.pm`
  - `core/TaskManager.pm`
  - `core/Task/Route.pm`
  - `core/Task/Move.pm`
- Movement/network path:
  - `networking/Send.pm`
  - `networking/Network/Send/ServerType0.pm` (or active server-specific send module)
- Config:
  - `config/config.txt`
  - `config/timeouts.txt`

### Configuration checks
- Verify movement/route-related settings in `config.txt` (lock map, teleport fallback, attack-route behavior).
- Confirm no conflicting delay/timeouts in `timeouts.txt`.
- Confirm map/server profile alignment (server selection and table set).

### Debugging steps
1. Confirm AI is active and not paused/stuck in an unexpected state.
2. Inspect active tasks (route/move) and whether they are advancing or looping.
3. Check if movement packets are being emitted by send logic.
4. Validate map data/path constraints from route calculations.
5. Re-test with a simple direct move target; compare behavior.

---

## 2) NPC Interaction Issues

### Possible causes
- NPC not found in actor list or wrong target coordinates.
- Dialogue state machine mismatch (unexpected prompt/response sequence).
- Packet handler mismatch for NPC-related responses.
- Route-to-NPC task never reaches interaction range.

### Files to inspect
- Task and command flow:
  - `core/Task/TalkNPC.pm`
  - `core/Commands.pm`
  - `core/AI/CoreLogic.pm`
- Receive handlers:
  - `networking/Receive.pm`
  - server-specific receive module (`networking/Network/Receive/*.pm`)
- Tables/config:
  - `tables/portals.txt` (if interaction depends on map pathing)
  - `config/config.txt`

### Configuration checks
- Ensure NPC scripts/macros (if used) match actual in-game dialogue sequence.
- Confirm route/lock-map settings still allow navigation to NPC.
- Validate server packet profile (`recvpackets`) is current.

### Debugging steps
1. Verify NPC is visible/tracked in actor context.
2. Step through `TalkNPC` task progression (init, talk, select, complete).
3. Check receive handlers for expected NPC dialogue packets.
4. Validate command/script parameters (NPC name/id, sequence values).
5. Retry with a minimal NPC interaction command path.

---

## 3) Plugin Not Loading

### Possible causes
- Plugin disabled by load policy.
- Plugin name not listed when selective loading is enabled.
- Missing dependencies/imports in plugin code.
- Startup callback failure throws during register/load.

### Files to inspect
- Plugin architecture docs/code:
  - `knowledge/plugin_system.md`
  - `plugins/<plugin>/<plugin>.pl`
- Config controls:
  - `config/sys.txt`
- (Core plugin loader reference in source repo: `src/Plugins.pm`, `src/functions.pl`)

### Configuration checks
- In `sys.txt`, verify:
  - `loadPlugins` mode
  - `loadPlugins_list` / `skipPlugins_list`
- Confirm plugin filename matches expected plugin name.

### Debugging steps
1. Check startup logs for plugin load exception details.
2. Validate plugin register/unload function signatures.
3. Verify required modules are available and import paths are correct.
4. If selective loading, explicitly include plugin in list and restart.
5. Test plugin command availability after successful load.

---

## 4) Macro Not Triggering

### Possible causes
- Macro/eventMacro plugin not loaded.
- Macro file path key incorrect (`macro_file` / `eventMacro_file`).
- Condition never becomes true (state/event mismatch).
- Automacro disabled, timed out, or blocked by check mode.

### Files to inspect
- Macro system docs/code:
  - `knowledge/macro_system.md`
  - `plugins/macro/macro.pl`
  - `plugins/eventMacro/eventMacro.pl`
  - `plugins/eventMacro/eventMacro/*`
- Config:
  - `config/config.txt`
  - `config/sys.txt`

### Configuration checks
- Confirm macro plugin is in plugin load list.
- Validate macro file names/paths (`macros.txt` / `eventMacros.txt` equivalents).
- Check macro/eventMacro options (orphans/check-on-AI/enable states).

### Debugging steps
1. Confirm plugin loaded and command is available (`macro`, `eventMacro`, `emacro`).
2. Reparse/reload macro file and verify no parse errors.
3. Use status/list commands to inspect macro/automacro states.
4. Verify trigger condition using simple known event first.
5. Incrementally add conditions until failing condition is isolated.

---

## 5) Routing Problems

### Possible causes
- Pathfinding cannot compute a valid route.
- Map data mismatch or stale map/portal table information.
- Dynamic obstacles or combat interruptions constantly reset route.
- Route task repeatedly interrupted by higher-priority tasks.

### Files to inspect
- Routing logic:
  - `core/Task/Route.pm`
  - `core/Task/Move.pm`
  - `core/TaskManager.pm`
- Table references:
  - `tables/portals.txt`
  - profile map tables (`tables/kRO/maps.txt`, `tables/iRO/maps.txt`)
- Config:
  - `config/config.txt`

### Configuration checks
- Confirm map/portal table set matches target server profile.
- Check route-related config constraints in `config.txt`.
- Verify no over-restrictive lockMap/avoid settings.

### Debugging steps
1. Test short route on same map first.
2. Inspect route task generated path length/waypoints.
3. Check for repeated interruptions/timeouts.
4. Validate map transition assumptions (portal routes).
5. Re-test after narrowing to minimal route scenario.

---

## 6) Packet Desync

### Possible causes
- Wrong `recvpackets` profile for active server/client build.
- Server-type receive/send module mismatch.
- Packet format changed on server side.
- Corrupted/incomplete packet framing in tokenizer path.

### Files to inspect
- Packet docs/code:
  - `knowledge/networking_packets.md`
  - `networking/PacketParser.pm`
  - `networking/MessageTokenizer.pm`
  - `networking/Receive.pm`
  - `networking/Send.pm`
- Tables:
  - `tables/servers.txt`
  - `tables/*/recvpackets.txt`
  - `tables/packetlist.txt`
  - `tables/packetdescriptions.txt`

### Configuration checks
- Verify selected server profile points to correct packet map.
- Ensure regional family tables (kRO/iRO/etc.) are aligned with server.

### Debugging steps
1. Identify first unknown/broken packet switch in logs.
2. Match switch against packet list/description tables.
3. Confirm recvpackets version/profile used at runtime.
4. Compare affected switch handling in server-specific receive/send modules.
5. Re-validate behavior after profile/module adjustment.

---

## 7) XKore Issues

### Possible causes
- Port/listener conflicts.
- Wrong XKore mode assumptions (mode 1 bridge vs mode 2 proxy stack).
- Session/state transition mismatch between account/char/map stages.
- Client forwarding path blocked or malformed.

### Files to inspect
- XKore docs/code:
  - `knowledge/xkore_modes.md`
  - `networking/XKore.pm`
  - `networking/XKore2.pm`
  - `networking/XKoreProxy.pm`
  - `networking/Network/XKore2/{AccountServer,CharServer,MapServer}.pm`
- Config:
  - `config/config.txt`
  - `config/poseidon.txt` (if related environment integration is used)

### Configuration checks
- Confirm XKore mode and listen/public IP/port values.
- Validate no duplicate process is already binding required ports.
- Ensure server-type settings are propagated correctly in XKore2 mode.

### Debugging steps
1. Start with a single XKore mode and minimal config.
2. Verify listener startup and handshake progression.
3. Check state transitions (account -> char -> map).
4. Confirm packet forwarding in both directions.
5. If mode 2 fails, isolate failing stage server (Account/Char/Map).

---

## General Triage Order (Recommended)
1. Confirm plugin/config/table profile alignment.
2. Isolate whether issue is logic-layer (AI/Task) or protocol-layer (packet/network).
3. Reproduce with minimal commands/actions.
4. Inspect module-specific path for first divergence.
5. Apply smallest fix/reconfiguration and re-test.
