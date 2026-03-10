# Code Index (Core Bundle)

## Boot and lifecycle
- `core/src/functions.pl` — startup state machine and main loop phases.
- `core/src/Modules.pm` — module registration/reload support.
- `core/src/Globals.pm` — shared runtime/global state.

## Configuration and parsing
- `core/src/Settings.pm` — control/table resolution and file registration.
- `core/src/FileParsers.pm` — parsing routines for config/table data.

## AI and tasks
- `core/src/AI.pm`
- `core/src/AI/CoreLogic.pm`
- `core/src/AI/Attack.pm`
- `core/src/Task.pm`
- `core/src/TaskManager.pm`
- `core/src/Task/Route.pm`
- `core/src/Task/Move.pm`
- `core/src/Task/TalkNPC.pm`

## Game entities
- `core/src/Actor.pm`
- `core/src/ActorList.pm`

## Networking core
- `core/src/Network.pm`
- `core/src/Network/PacketParser.pm`
- `core/src/Network/Receive.pm`
- `core/src/Network/Send.pm`

## Runtime support and diagnostics
- `core/src/Commands.pm`
- `core/src/Misc.pm`
- `core/src/Log.pm`
- `core/src/ErrorHandler.pm`
- `core/src/Interface.pm`
- `core/src/Plugins.pm`

## Reference docs from `src/`
- `core/src/doc/modules.txt`
