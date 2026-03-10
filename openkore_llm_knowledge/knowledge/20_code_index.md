# Code Index (Architecture-Oriented)

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
