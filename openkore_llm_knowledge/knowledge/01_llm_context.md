# OpenKore LLM Context

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
