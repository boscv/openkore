# OpenKore Architecture Overview

## Top-level structure
- `src/`: core runtime modules (AI, actor model, networking, tasks, plugins API, command layer).
- `control/`: operator configuration and behavior policies (`config.txt`, control lists, route/macro inputs).
- `tables/`: protocol/game data mappings (packet maps, item/skill/map metadata, server-specific variants).
- `plugins/`: optional extensions, including macro/eventMacro automation stacks.
- `fields/`: map field data used by routing/navigation.

## Core runtime layers
1. **Bootstrap + loop**: `src/functions.pl` and `src/Modules.pm`
2. **State + config**: `src/Globals.pm`, `src/Settings.pm`, `src/FileParsers.pm`
3. **Network transport + packet translation**: `src/Network.pm`, `src/Network/{Receive,Send,PacketParser}.pm`
4. **World model**: `src/Actor.pm`, `src/ActorList.pm`, `src/Field.pm`
5. **Decision engine**: `src/AI.pm`, `src/AI/CoreLogic.pm`
6. **Execution engine**: `src/TaskManager.pm`, `src/Task/*.pm`
7. **Extension surface**: `src/Plugins.pm`, `src/Commands.pm`, `plugins/*`

## Architectural characteristics
- **Event-driven and loop-based**: runtime state is advanced each tick by receive updates + AI/task progression.
- **Protocol-adapter design**: packet send/receive classes are split by server type under `src/Network/Receive/*` and `src/Network/Send/*`.
- **Policy outside code**: behavior is heavily configured via `control/` and `tables/` files.
- **Extension-first automation**: macro/eventMacro run as plugins and reuse command/hook/task pathways.
