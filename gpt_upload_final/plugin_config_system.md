# Plugin System
---

## Purpose
OpenKore plugins extend runtime behavior without editing core modules.

## Core interfaces
- `src/Plugins.pm`: plugin lifecycle and hook dispatch.
- `src/Commands.pm`: command registration/execution surface used by plugins.
- `plugins/*`: plugin implementations (`*.pl` entrypoints + helper modules).

## Lifecycle pattern
1. Register plugin with `Plugins::register(...)`.
2. Register hooks with `Plugins::addHooks(...)`.
3. Optionally register commands via `Commands::register(...)`.
4. On unload, remove hooks/commands and clear plugin state.

## Common hook usage
- Startup hooks (e.g., startup/init phases)
- Loop hooks (periodic behavior)
- Packet hooks (`packet/*`, `packet_pre/*`)
- Config-change hooks (`configModify`)

## Representative plugins
- `plugins/macro/macro.pl`
- `plugins/eventMacro/eventMacro.pl`
- `plugins/reconnect/reconnect.pl`
- `plugins/profiles/profiles.pl`
- `plugins/map/map.pl`

# Configuration System
---

## Purpose
Behavior policy is primarily configuration-driven via `control/` and table data under `tables/`.

## Key files
- `control/config.txt`: global runtime/AI/combat/movement/network options.
- `control/items_control.txt`: item pickup/storage/sell policy.
- `control/mon_control.txt`: per-monster behavior policy.

## Runtime integration
- `src/Settings.pm`: config path/file registration.
- `src/FileParsers.pm`: parser logic for control/table formats.
- `src/Globals.pm`: shared runtime state consumed by AI/tasks/plugins.

## Debugging guidance
- Validate key names and value format first.
- Re-test with minimal config to isolate policy conflicts.
- Check plugin/macro automation that may override config expectations.

# Macro System
---

## Components
- Macro plugin: `plugins/macro/macro.pl`, `plugins/macro/Macro/*`
- eventMacro plugin: `plugins/eventMacro/eventMacro.pl`, `plugins/eventMacro/eventMacro/*`

## Configuration keys
- `macro_file` -> macro script path (commonly `macros.txt`).
- `eventMacro_file` -> eventMacro script path (commonly `eventMacros.txt`).

## Execution model
1. Plugin loads and parses macro file.
2. Hooks/events trigger condition evaluation.
3. Matching automacro rules enqueue/execute actions.
4. Actions flow through command/task/network paths.

## Operational notes
- Macro and eventMacro are complementary automation layers.
- Troubleshooting should separate: load -> parse -> trigger -> action execution.

# Table Reference
---

## Purpose
`tables/` contains protocol and gameplay data used by network parsing, IDs, maps, and runtime lookups.

## Core packet/profile tables
- `tables/servers.txt`
- `tables/packetlist.txt`
- `tables/packetdescriptions.txt`
- server-family `recvpackets.txt` files (e.g., `tables/kRO/recvpackets.txt`, `tables/iRO/recvpackets.txt`)

## Gameplay identity tables
- `tables/SKILL_id_handle.txt`
- `tables/STATUS_id_handle.txt`
- `tables/statusnametable.txt`
- `tables/itemtypes.txt`
- `tables/elements.txt`

## World/content tables
- `tables/portals.txt`
- `tables/skillsarea.txt`
- regional `maps.txt`, `items.txt`, `skillnametable.txt`

## Notes
Packet-related incidents should always be validated against serverType + recvpackets alignment.
