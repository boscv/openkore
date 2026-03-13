# Code Index for Knowledge Curation

## Runtime entry & orchestration
- `openkore.pl` — process startup, module bootstrap, interface init.
- `src/functions.pl` — main loop state machine, plugin/data/network init sequencing.
- `src/Modules.pm` — module registration/reload utilities.

## Configuration and data
- `src/Settings.pm` — control/table folder resolution, CLI args, file registration/loading.
- `src/FileParsers.pm` — parsers for config/control/table files.
- `src/Globals.pm` — shared runtime state and loaded data structures.
- `control/*.txt` — live bot behavior config.
- `tables/**` — static/server-specific knowledge (items, maps, skills, recvpackets, etc.).

## AI, behavior, and tasks
- `src/AI.pm`, `src/AI/CoreLogic.pm`, `src/AI/Attack.pm`.
- `src/TaskManager.pm`, `src/Task.pm`, `src/Task/*.pm`.

## Actors and game entities
- `src/Actor.pm`, `src/Actor/*.pm`, `src/ActorList.pm`.
- `src/InventoryList.pm`, `src/InventoryList/*.pm`.
- `src/Skill.pm`, `src/Field.pm`.

## Networking, packets, and proxies
- `src/Network.pm`, `src/Network/DirectConnection.pm`.
- `src/Network/PacketParser.pm`, `src/Network/Receive.pm`, `src/Network/Send.pm`.
- `src/Network/Receive/*`, `src/Network/Send/*` — serverType/region/version specialization.
- `src/Network/XKore.pm`, `src/Network/XKore2.pm`, `src/Network/XKoreProxy.pm`, `src/Network/XKore2/*`.

## Plugin framework and notable plugins
- `src/Plugins.pm` — plugin lifecycle + hooks.
- `plugins/*/*.pl` — plugin entrypoints.
- High-value deep plugin trees:
  - `plugins/macro/**`
  - `plugins/eventMacro/**`
  - `plugins/profiles/**`
  - `plugins/reconnect/**`
  - `plugins/map/**`

## Debugging and diagnostics
- `src/Log.pm`, `src/ErrorHandler.pm`, `src/Interface/Console.pm`.
- `src/test/*` — unit/regression tests useful for behavior confirmation.
- Optional advanced debug plugins under `plugins/needs-review/*`.
