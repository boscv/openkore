# OpenKore LLM Context
---

## Objective
This layer gives an LLM enough structural context to reason about OpenKore runtime behavior, module boundaries, and extension points.

## Runtime model (high level)
1. `src/functions.pl` boots runtime services, loads config/tables, initializes network mode, and drives the main loop.
2. Network receive handlers (`src/Network/Receive*.pm`) transform packets into world-state updates.
3. Actor state (`src/Actor.pm`, `src/ActorList.pm`) becomes the shared world model for decision logic.
4. AI (`src/AI.pm`, `src/AI/CoreLogic.pm`) evaluates state and schedules actions through tasks.
5. Task execution (`src/TaskManager.pm`, `src/Task/*.pm`) performs multi-step actions and emits packets through send modules (`src/Network/Send*.pm`).
6. Plugins (`src/Plugins.pm`, `plugins/*`) and macro layers (`plugins/macro`, `plugins/eventMacro`) inject automation and custom behavior.

## Key architecture anchors
- **Entry/control loop**: `src/functions.pl`
- **Global state/config loading**: `src/Globals.pm`, `src/Settings.pm`, `src/FileParsers.pm`, `control/`
- **AI + behavior**: `src/AI.pm`, `src/AI/CoreLogic.pm`
- **Actor model**: `src/Actor.pm`, `src/ActorList.pm`, `src/Actor/*`
- **Task orchestration**: `src/Task.pm`, `src/TaskManager.pm`, `src/Task/*`
- **Networking and packets**: `src/Network.pm`, `src/Network/*`
- **Plugin/macro automation**: `src/Plugins.pm`, `plugins/macro/*`, `plugins/eventMacro/*`

# OpenKore Architecture Overview
---

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

# System Architecture Map (Textual)
---

## Primary flow
`functions.pl main loop` -> `Network receive` -> `Actor/Globals update` -> `AI decision` -> `Task execution` -> `Network send`

## Subsystem map

### 1) Networking
- Connection/mode handling: `src/Network.pm`, `src/Network/DirectConnection.pm`, `src/Network/XKore*.pm`
- Packet ingestion and dispatch: `src/Network/MessageTokenizer.pm`, `src/Network/PacketParser.pm`, `src/Network/Receive.pm`, `src/Network/Receive/*`
- Packet construction: `src/Network/Send.pm`, `src/Network/Send/*`

### 2) Actor system
- Base entity model: `src/Actor.pm`, `src/Actor/*`
- Actor collections and lookup: `src/ActorList.pm`
- World/map coupling: `src/Field.pm`, map and position state in globals

### 3) AI subsystem
- AI stack state and sequencing: `src/AI.pm`
- Core behavior logic: `src/AI/CoreLogic.pm`
- Uses actor/world/config state; issues actions via task manager and commands

### 4) Task subsystem
- Task abstraction: `src/Task.pm`
- Scheduler and lifecycle: `src/TaskManager.pm`
- High-impact tasks: `src/Task/Route.pm`, `src/Task/Move.pm`, `src/Task/TalkNPC.pm`, `src/Task/UseSkill.pm`

### 5) Configuration subsystem
- Config discovery/loading: `src/Settings.pm`, `src/FileParsers.pm`
- Runtime shared state: `src/Globals.pm`
- Policy sources: `control/*`, `tables/*`

### 6) Plugin + macro subsystem
- Hook and plugin lifecycle: `src/Plugins.pm`
- Command bridge: `src/Commands.pm`
- Macro engines: `plugins/macro/*`, `plugins/eventMacro/*`

## Key entry points
- Startup/main loop: `src/functions.pl`
- Command dispatch: `src/Commands.pm`
- Hook registration: `src/Plugins.pm`
- AI tick path: `src/AI.pm` -> `src/AI/CoreLogic.pm`
- Packet receive path: `src/Network/Receive.pm` + server-specific receivers

# Core Subsystems
---

## AI
- Main modules: `src/AI.pm`, `src/AI/CoreLogic.pm`
- Role: maintain AI queues/state machines, evaluate combat/loot/movement priorities, enqueue tasks.
- Inputs: actor state, config policies, packet-driven updates.
- Outputs: task requests, command invocations, action intents.

## Actor system
- Main modules: `src/Actor.pm`, `src/ActorList.pm`, `src/Actor/*`
- Role: represent player/NPC/monster/portal entities, with indexed lookup for targeting and proximity logic.
- Inputs: receive handlers and map updates.
- Outputs: query surface for AI, tasks, commands, and plugins.

## Networking
- Main modules: `src/Network.pm`, `src/Network/{Receive,Send,PacketParser,MessageTokenizer}.pm`, `src/Network/XKore*.pm`
- Role: manage transport mode, parse inbound packets, encode outbound actions, support server-specific packet families.
- Inputs: socket data + outgoing action intents.
- Outputs: state mutations via receive handlers and serialized packets to servers/clients.

## Task system
- Main modules: `src/Task.pm`, `src/TaskManager.pm`, `src/Task/*`
- Role: run asynchronous multi-step actions (route, move, NPC dialogs, skill/item use).
- Inputs: AI/command/plugin action requests.
- Outputs: packet sends, follow-up tasks, completion/failure states consumed by AI.

## Plugin system
- Main modules: `src/Plugins.pm`, `plugins/*`
- Role: dynamic extension lifecycle (`register`, hooks, unload), runtime behavior injection.
- Inputs: startup/load events, packet-related hooks, periodic loop hooks.
- Outputs: custom commands, state transitions, automation triggers.

## Configuration system
- Main modules: `src/Settings.pm`, `src/FileParsers.pm`, `control/*`, `tables/*`
- Role: load policy and data files that parameterize AI, networking, and gameplay handling.
- Inputs: text configs and table files.
- Outputs: normalized runtime config/state in globals and subsystem-specific structures.

## Macro system
- Main modules: `plugins/macro/macro.pl`, `plugins/macro/Macro/*`, `plugins/eventMacro/eventMacro.pl`, `plugins/eventMacro/eventMacro/*`
- Role: declarative automation over hooks and game events, with conditional triggers and scripted actions.
- Inputs: macro definitions and live runtime events.
- Outputs: command execution and indirect task/network activity.

## Routing
- Main modules: `src/Task/Route.pm`, `src/Task/Move.pm`, `src/Field.pm`, `fields/*`
- Role: compute and execute navigation paths across map cells/portals.
- Inputs: destination intents, field data, actor position/state.
- Outputs: stepwise movement actions and route completion/fallback states.

# Module Dependency Map
---

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

# Code Index (Architecture-Oriented)
---

## Runtime entry and orchestration
- `src/functions.pl` — startup sequence and main loop
- `src/Modules.pm` — module loading registry
- `src/Globals.pm` — shared runtime state container

## AI
- `src/AI.pm` — AI framework and queue/state management
- `src/AI/CoreLogic.pm` — core decision routines

## Actor and world model
- `src/Actor.pm` — actor base model
- `src/ActorList.pm` — actor collections/indexing
- `src/Actor/*` — actor specializations
- `src/Field.pm` — map/field representation

## Task execution
- `src/Task.pm` — task abstraction
- `src/TaskManager.pm` — scheduler/executor
- `src/Task/Route.pm` — route planning/execution wrapper
- `src/Task/Move.pm` — movement task
- `src/Task/TalkNPC.pm` — NPC dialogue workflow
- `src/Task/UseSkill.pm` — skill-use workflows

## Networking and packets
- `src/Network.pm` — network facade and state
- `src/Network/DirectConnection.pm` — direct server mode
- `src/Network/XKore.pm`, `src/Network/XKore2.pm`, `src/Network/XKoreProxy.pm` — proxy/bridge modes
- `src/Network/MessageTokenizer.pm` — packet frame/token extraction
- `src/Network/PacketParser.pm` — packet definition parsing
- `src/Network/Receive.pm` + `src/Network/Receive/*` — inbound packet dispatch/handlers
- `src/Network/Send.pm` + `src/Network/Send/*` — outbound packet builders

## Commands, plugins, and automation
- `src/Commands.pm` — command parser/dispatcher
- `src/Plugins.pm` — plugin lifecycle and hook API
- `plugins/macro/macro.pl` + `plugins/macro/Macro/*` — legacy macro automation
- `plugins/eventMacro/eventMacro.pl` + `plugins/eventMacro/eventMacro/*` — event-driven macro automation

## Configuration and data sources
- `src/Settings.pm` — config path and file registration
- `src/FileParsers.pm` — config/table parsing
- `control/*` — user behavior policies and runtime options
- `tables/*` — server/data tables
- `fields/*` — map grids for routing/navigation

# Core Module Index
---

- `src/functions.pl` — bootstrap and main loop.
- `src/Modules.pm` — module registration/loading.
- `src/Globals.pm` — shared runtime state.
- `src/Settings.pm` — config path and file registration.
- `src/FileParsers.pm` — control/table parsing.
- `src/Commands.pm` — command parser and handlers.
- `src/AI.pm` and `src/AI/CoreLogic.pm` — AI orchestration and decisions.
- `src/Actor.pm` and `src/ActorList.pm` — entity model and indexing.
- `src/Task.pm` and `src/TaskManager.pm` — task abstraction and scheduling.
- `src/Task/Route.pm`, `src/Task/Move.pm`, `src/Task/TalkNPC.pm` — routing, movement, NPC flows.
- `src/Network.pm`, `src/Network/PacketParser.pm`, `src/Network/Receive.pm`, `src/Network/Send.pm` — network core.
