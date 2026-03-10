# OpenKore Core Architecture Overview

This bundle captures only the **core architecture** from `src/` for public AI-assistant knowledge use.

## Structural layers
- **Runtime orchestration**: `core/functions.pl` controls initialization stages and the recurring main loop.
- **State and configuration**: `core/Globals.pm`, `core/Settings.pm`, `core/FileParsers.pm`.
- **Behavior engine**: `core/AI.pm`, `core/AI/CoreLogic.pm`.
- **World model**: `core/Actor.pm`, `core/ActorList.pm`.
- **Task execution**: `core/Task.pm`, `core/TaskManager.pm`, `core/Task/{Route,Move,TalkNPC}.pm`.
- **Packet/network core**: `core/Network.pm`, `core/Network/{PacketParser,Receive}.pm`.
- **Command surface**: `core/Commands.pm`.

## Why this is “core”
The selected modules define startup, state, decision logic, movement/NPC flows, and packet ingestion—the minimum architecture needed to explain how OpenKore runs end-to-end without pulling in plugin- or UI-heavy areas.
