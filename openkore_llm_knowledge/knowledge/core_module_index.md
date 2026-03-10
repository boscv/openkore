# Core Module Index

- `core/functions.pl` — startup states, initialization sequence, and main loop transitions.
- `core/Modules.pm` — module registration and reload mechanics.
- `core/Globals.pm` — shared globals and runtime containers.
- `core/Settings.pm` — path/file registration and load policies.
- `core/FileParsers.pm` — parsers for core config/table content.
- `core/Commands.pm` — runtime command entrypoints.
- `core/AI.pm` — AI framework control.
- `core/AI/CoreLogic.pm` — primary decision-cycle logic.
- `core/Actor.pm` — actor base model.
- `core/ActorList.pm` — actor indexing/lookup list.
- `core/Task.pm` — task primitive.
- `core/TaskManager.pm` — task scheduler/runner.
- `core/Task/Route.pm` — route planning task.
- `core/Task/Move.pm` — movement task execution.
- `core/Task/TalkNPC.pm` — NPC conversation task.
- `core/Network.pm` — network state machine abstraction.
- `core/Network/PacketParser.pm` — packet decode/shape logic.
- `core/Network/Receive.pm` — incoming packet dispatch and handlers.
