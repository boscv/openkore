# Plugin System

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
