# Core Subsystems

## AI
- `core/AI.pm` hosts AI stack control and high-level bot behavior gates.
- `core/AI/CoreLogic.pm` contains central decision logic used every loop tick.

## Actor
- `core/Actor.pm` defines the base actor abstraction.
- `core/ActorList.pm` manages indexed actor collections and lookups.

## Network
- `core/Network.pm` defines connection state abstraction.
- `core/Network/PacketParser.pm` performs packet-level extraction/reconstruction logic.
- `core/Network/Receive.pm` maps and dispatches incoming packet handlers.

## Tasks
- `core/Task.pm` is the task base abstraction.
- `core/TaskManager.pm` queues/runs tasks.
- `core/Task/Route.pm` and `core/Task/Move.pm` handle routing and movement execution.
- `core/Task/TalkNPC.pm` encapsulates NPC interaction task flow.

## Commands
- `core/Commands.pm` provides command parsing/dispatch used by console and automation.

## File parsing
- `core/Settings.pm` registers and resolves data/control files.
- `core/FileParsers.pm` parses key config/table formats into runtime structures.
