# Core Subsystems

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
