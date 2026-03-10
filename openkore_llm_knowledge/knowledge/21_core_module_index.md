# Core Module Index

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
