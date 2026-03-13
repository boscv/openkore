# Module Dependency Map

## Dependency chains (high impact)
1. `src/functions.pl` -> `src/Settings.pm` / `src/FileParsers.pm` / `src/Modules.pm` (bootstrap)
2. `src/functions.pl` -> `src/Network.pm` + `src/Network/*` (connection and packet loop)
3. `src/Network/Receive*.pm` -> `src/Globals.pm` + `src/Actor*.pm` (state mutation)
4. `src/AI.pm` -> `src/AI/CoreLogic.pm` -> `src/TaskManager.pm` + `src/Task/*` (decision to execution)
5. `src/Task/*` -> `src/Network/Send*.pm` (action serialization)
6. `src/Plugins.pm` + `plugins/*` -> `src/Commands.pm` / AI / TaskManager (extension control paths)

## Subsystem dependency view
- **AI depends on**: Actor state, config policies, task scheduler, command surface.
- **Actor system depends on**: Network receive updates and global runtime registries.
- **Task system depends on**: AI/commands/plugins for intents; network send + actor/map updates for progression.
- **Plugin/macro depends on**: hook lifecycle (`src/Plugins.pm`), command execution (`src/Commands.pm`), global state.
- **Routing depends on**: task framework, field data (`fields/*`), movement packet sends.

## Coupling hotspots
- `src/Globals.pm`: shared mutable state touched by receive, AI, and plugins.
- `src/Commands.pm`: cross-cutting control surface used by user input and automation.
- `src/TaskManager.pm`: convergence point for AI and scripted automation.
- `src/Network/Receive.pm`: ingress bridge from protocol events to internal state transitions.

## Practical navigation order for analysis
1. Start at `src/functions.pl`.
2. Follow receive path (`src/Network/Receive.pm`, subtype receivers).
3. Inspect AI loop (`src/AI.pm`, `src/AI/CoreLogic.pm`).
4. Inspect task execution (`src/TaskManager.pm`, route/move/NPC tasks).
5. Inspect extension points (`src/Plugins.pm`, macro/eventMacro plugins).
