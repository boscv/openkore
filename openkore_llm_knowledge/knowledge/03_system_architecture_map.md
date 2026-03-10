# System Architecture Map (Textual)

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
