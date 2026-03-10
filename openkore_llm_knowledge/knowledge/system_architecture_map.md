# OpenKore System Architecture Map

This map describes how the curated OpenKore knowledge bundle components fit together at runtime.

## 1) AI Subsystem

### Purpose
Coordinate autonomous behavior: combat decisions, state transitions, and action triggering.

### Main modules
- `core/AI.pm`
- `core/AI/CoreLogic.pm`
- (supporting interaction surfaces: `core/Commands.pm`, `core/TaskManager.pm`)

### Interactions
- Consumes actor/world state from the Actor subsystem.
- Schedules and updates executable work through the Task subsystem.
- Reacts to network-derived state updates (packet handlers).
- Can be influenced by Plugins/Macros through hook and command surfaces.

### Important entry points
- AI cycle invoked from the main loop (`core/functions.pl`).
- Decision logic concentrated in `core/AI/CoreLogic.pm`.

---

## 2) Actor System

### Purpose
Represent dynamic world entities (player, monsters, NPCs, other actors) and maintain indexed state.

### Main modules
- `core/Actor.pm`
- `core/ActorList.pm`

### Interactions
- Updated primarily by packet receive handlers.
- Queried by AI and Tasks for targeting, proximity, and world context.
- Exposed indirectly to plugins/macros through runtime globals and events.

### Important entry points
- Actor creation/update from packet decode paths.
- Actor lookup/list operations through `core/ActorList.pm`.

---

## 3) Task System

### Purpose
Provide executable units for actions and multi-step workflows.

### Main modules
- `core/Task.pm`
- `core/TaskManager.pm`
- `core/Task/Route.pm`
- `core/Task/Move.pm`
- `core/Task/TalkNPC.pm`

### Interactions
- Receives intent from AI, commands, and automation systems.
- Uses Network subsystem for action-side packet emission.
- Depends on Actor/Map state updates from receive flow to advance steps.

### Important entry points
- Task queueing/scheduling in `core/TaskManager.pm`.
- Specialized flow handlers in route/move/talk task modules.

---

## 4) Network Subsystem

### Purpose
Manage connection state, transport lifecycle, and bridging/proxy modes.

### Main modules
- `networking/Network.pm`
- `networking/DirectConnection.pm`
- `networking/XKore.pm`
- `networking/XKore2.pm`
- `networking/XKoreProxy.pm`
- `networking/Network/XKore2/{AccountServer,CharServer,MapServer}.pm`

### Interactions
- Feeds decoded data into Packet Handling.
- Receives outgoing payload requests from Tasks, Commands, and Plugins.
- Selects mode-dependent behavior (direct, bridge, proxy/XKore2).

### Important entry points
- Runtime connection state transitions.
- XKore mode startup/iteration paths.

---

## 5) Packet Handling Subsystem

### Purpose
Decode, map, dispatch, and construct protocol packets across server variants.

### Main modules
- `networking/PacketParser.pm`
- `networking/MessageTokenizer.pm`
- `networking/Receive.pm`
- `networking/Send.pm`
- Server-specific variants under:
  - `networking/Network/Receive/*`
  - `networking/Network/Send/*`

### Interactions
- Input side updates actor/runtime state and triggers higher-level events.
- Output side encodes requested actions for transport.
- Coupled to table definitions (servers + recvpackets mapping).

### Important entry points
- Receive dispatch in `networking/Receive.pm`.
- Send construction in `networking/Send.pm`.
- Server-type overrides in `ServerType0`, `kRO`, `iRO`, etc.

---

## 6) Routing and Movement Subsystem

### Purpose
Convert navigation intent into route computation and movement execution.

### Main modules
- `core/Task/Route.pm`
- `core/Task/Move.pm`
- (coordination via `core/TaskManager.pm` and AI core)

### Interactions
- Triggered by AI decisions or direct command/plugin logic.
- Uses actor/map state from packet updates.
- Emits move-related packets through send pipeline.

### Important entry points
- Route planning task instantiation.
- Movement step processing and re-evaluation.

---

## 7) Plugin System

### Purpose
Extend runtime behavior without changing core source.

### Main modules
- Representative plugin entries in curated bundle:
  - `plugins/macro/macro.pl`
  - `plugins/eventMacro/eventMacro.pl`
  - `plugins/reconnect/reconnect.pl`
  - `plugins/profiles/profiles.pl`
  - `plugins/map/map.pl`

### Interactions
- Registers hooks into startup/main loop/config/packet related events.
- Registers commands to expose operational controls.
- Can influence AI/task execution by issuing commands or scheduling logic.

### Important entry points
- `Plugins::register(...)`
- `Plugins::addHooks(...)`
- `Commands::register(...)`
- Plugin unload/reload callbacks.

---

## 8) Config System

### Purpose
Provide operator-controlled behavior policies without code edits.

### Main modules / files
- `config/config.txt` (global behavior)
- `config/items_control.txt` (item policy)
- `config/mon_control.txt` (monster behavior policy)
- Additional control files in `config/` for specialized behavior domains.

### Interactions
- Loaded/parsed by settings + file parser paths.
- Consumed by AI, task logic, plugins, and packet behavior decisions.
- Changes can trigger plugin/config hooks in runtime.

### Important entry points
- Initial load during startup sequence.
- Config modification events watched by plugins (e.g., macro/eventMacro).

---

## 9) Macro System

### Purpose
Offer text-configured automation layers for reactive behavior.

### Main modules
- Macro stack:
  - `plugins/macro/macro.pl`
  - `plugins/macro/Macro/*`
- EventMacro stack:
  - `plugins/eventMacro/eventMacro.pl`
  - `plugins/eventMacro/eventMacro/*`

### Interactions
- Subscribes to hooks/events and loop phases.
- Evaluates automacro conditions against runtime state and events.
- Triggers commands/actions that flow into AI/tasks/network send paths.

### Important entry points
- Macro file load keys (`macro_file`, `eventMacro_file`).
- Commands: `macro`, `eventMacro`, `emacro`.

---

## System Interaction Overview

At runtime, the main loop initializes modules, loads config/table data, and enters iterative execution. Incoming network data is tokenized and parsed, then dispatched by receive handlers that refresh actor/world state. AI logic evaluates this state and schedules tasks. Tasks execute concrete workflows (move, route, NPC interactions), producing outgoing actions encoded by send logic and delivered through the active network mode.

Plugins hook into this lifecycle at well-defined points (startup, loop, config updates, packet-related events), extending behavior and command surfaces. Macro/eventMacro layers run on top of plugin hooks, evaluating declarative automacro rules and injecting actions back into command/task pipelines.

### Example runtime flows

#### A) AI loop
1. Main loop tick runs.
2. AI evaluates current actor/state context.
3. AI enqueues/updates tasks.
4. Tasks emit action requests -> send packets.

#### B) NPC interaction
1. AI/command/plugin requests NPC action.
2. `Task/TalkNPC` drives dialogue steps.
3. Receive handlers process NPC responses.
4. Task advances/completes based on packet-updated state.

#### C) Packet receive flow
1. Raw bytes arrive via network backend.
2. Tokenizer/parser resolves packet boundaries/opcodes.
3. Receive dispatch maps to handler.
4. Handler mutates globals/actors/tasks and may trigger hooks.

#### D) Plugin hook execution
1. Plugin registers hooks and commands at startup.
2. Runtime events invoke plugin callbacks.
3. Plugin callback performs logic (state check, action trigger, config reload).
4. Optional commands expose runtime control to operator.

#### E) Routing decision flow
1. AI decides to navigate to target/map/coordinate.
2. Route task computes route segments.
3. Move task executes stepwise movement.
4. Receive updates position/context; route logic re-evaluates until arrival/failure.
