# Module Dependency Map (Core-Curated View)

This dependency map is derived from `openkore_llm_knowledge/core/` and focuses on AI, Actor, Network, Commands, Task, Routing, and File Parsing relationships.

## Major Module Relationships

### 1) `functions.pl`
- **Purpose:** Runtime bootstrap loop and subsystem orchestration.
- **Key dependencies:** `AI`, `Commands`, `Network::Receive`, `TaskManager`, `Settings`.
- **Depended on by:** Runtime entry flow (top-level bootstrap path).

### 2) `AI`
- **Purpose:** AI mode/state management and behavior control surface.
- **Key dependencies:** `Globals`, `Utils`, `Log`, `Field`.
- **Depended on by:** `AI::CoreLogic`, `Commands`, `Network::Receive`, task modules.

### 3) `AI::CoreLogic`
- **Purpose:** Main decision engine for combat/behavior execution.
- **Key dependencies:** `AI`, `Globals`, `Misc`, `Network::Send`, `Commands`, `FileParsers`, `Task::TalkNPC`.
- **Depended on by:** `functions.pl` runtime loop and AI-driven task flow.

### 4) `Actor`
- **Purpose:** Base actor model (player, mob, NPC entity behavior/state object).
- **Key dependencies:** `Globals`, `Utils`, `Task`, `Misc`, `Translation`.
- **Depended on by:** `ActorList`, `Network::Receive`, `AI`, routing/task logic.

### 5) `ActorList`
- **Purpose:** Indexed actor container and type-aware lookup.
- **Key dependencies:** `Actor` + actor subclasses.
- **Depended on by:** `functions.pl`, `Task::TalkNPC` and other actor-consumers.

### 6) `Commands`
- **Purpose:** Operator and automation command dispatch.
- **Key dependencies:** `Globals`, `Network`, `Network::Send`, `Settings`, `AI`, `Task`.
- **Depended on by:** `AI::CoreLogic`, `Task::TalkNPC`, packet/automation callbacks.

### 7) `FileParsers`
- **Purpose:** Parse control/table data into runtime structures.
- **Key dependencies:** `Settings`, `Plugins`, `Utils`, `Log`.
- **Depended on by:** `Settings`, `AI::CoreLogic`, `Network::Receive`, `Commands`.

### 8) `Settings`
- **Purpose:** Configuration path resolution, file registration, and argument parsing.
- **Key dependencies:** `Globals`, `Utils::ObjectList`, `Translation`, `Modules`.
- **Depended on by:** `functions.pl`, `Commands`, `FileParsers`, AI/network modules.

### 9) `Globals`
- **Purpose:** Shared runtime state and exported global structures.
- **Key dependencies:** `Modules`.
- **Depended on by:** Nearly all core subsystems (`AI`, `Commands`, `Network::*`, `Task::*`).

### 10) `Network`
- **Purpose:** Connection state abstraction and shared network constants.
- **Key dependencies:** `Modules`.
- **Depended on by:** `Commands`, `Network::PacketParser`, `Network::Receive`, `Task::*`.

### 11) `Network::PacketParser`
- **Purpose:** Packet data parsing/reconstruction and packet utility constants.
- **Key dependencies:** `Globals`, `Network`, `Network::MessageTokenizer`, `Plugins`, `Utils`.
- **Depended on by:** `Network::Receive`, `Commands`.

### 12) `Network::Receive`
- **Purpose:** Incoming packet dispatch and handler execution.
- **Key dependencies:** `Network::PacketParser`, `AI`, `Globals`, `FileParsers`, `Plugins`, `Skill`, `Actor::Slave::*`.
- **Depended on by:** Core runtime/loop flows and state update paths.

### 13) `Task`
- **Purpose:** Base task abstraction (lifecycle/priority/state).
- **Key dependencies:** `Modules`, `Utils::CallbackList`, `Utils::Set`.
- **Depended on by:** `TaskManager`, task subclasses, actor/AI command flows.

### 14) `TaskManager`
- **Purpose:** Task scheduling/execution container.
- **Key dependencies:** `Task`, `Utils::Set`, `Utils::CallbackList`.
- **Depended on by:** `functions.pl` orchestration loop and AI/task producers.

### 15) `Task::Route`
- **Purpose:** Route planning and navigation workflow control.
- **Key dependencies:** `Task::Move`, `AI`, `Network`, `Field`, `Utils::PathFinding`.
- **Depended on by:** `AI::CoreLogic` and movement decision flow.

### 16) `Task::Move`
- **Purpose:** Movement execution subtask and movement-state progression.
- **Key dependencies:** `Task::WithSubtask`, `Task::SitStand`, `Network`, `Plugins`, `Globals`.
- **Depended on by:** `Task::Route` and route execution chains.

### 17) `Task::TalkNPC`
- **Purpose:** NPC conversation/state-machine interactions.
- **Key dependencies:** `Task`, `AI`, `Commands`, `Network`, `Misc`, `Plugins`.
- **Depended on by:** `AI::CoreLogic` and command-triggered NPC workflows.

### 18) `Modules`
- **Purpose:** Core module registration/reload helper used across subsystems.
- **Key dependencies:** Perl runtime utilities (`Config`, `FindBin`, `File::Spec`).
- **Depended on by:** `Globals`, `Settings`, `Network`, `Task`, `Commands` and others.

---

## Top 20 Most Important Modules (Architecture Perspective)

1. `functions.pl`
2. `AI`
3. `AI::CoreLogic`
4. `Actor`
5. `ActorList`
6. `Task`
7. `TaskManager`
8. `Task::Route`
9. `Task::Move`
10. `Task::TalkNPC`
11. `Commands`
12. `Network`
13. `Network::PacketParser`
14. `Network::Receive`
15. `Settings`
16. `FileParsers`
17. `Globals`
18. `Modules`
19. `Network::Send` (critical dependency referenced by core decision/command paths)
20. `Misc` (high-touch utility dependency in AI/task/command/network logic)

> Note: Items 1–18 are present in the curated `core/` set; 19–20 are explicitly identified from core dependency references to preserve architectural completeness.
