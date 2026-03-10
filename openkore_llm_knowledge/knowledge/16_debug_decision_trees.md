# Debug Decision Trees

These trees provide fast triage paths for recurring OpenKore failures.

## A) Bot not moving / Routing failure

```mermaid
flowchart TD
    A[Bot not moving] --> B{AI ticking?}
    B -- No --> B1[Inspect src/AI.pm and main loop in src/functions.pl]
    B -- Yes --> C{Task::Route or Task::Move queued?}
    C -- No --> C1[Inspect AI decisions in src/AI/CoreLogic.pm and config gates]
    C -- Yes --> D{Move packets sent?}
    D -- No --> D1[Inspect src/Network/Send.pm and command/task path]
    D -- Yes --> E{Position updates received?}
    E -- No --> E1[Inspect src/Network/Receive.pm and packet mapping]
    E -- Yes --> F{Path valid in fields data?}
    F -- No --> F1[Inspect src/Field.pm + fields/*]
    F -- Yes --> G[Check blockers/lock settings in control/config.txt]
```

Use this when movement appears frozen or route tasks fail repeatedly.

## B) NPC interaction failure

```mermaid
flowchart TD
    A[NPC interaction fails] --> B{NPC present in ActorList?}
    B -- No --> B1[Inspect src/ActorList.pm updates from receive handlers]
    B -- Yes --> C{TalkNPC task created?}
    C -- No --> C1[Inspect trigger path in AI/commands/plugins]
    C -- Yes --> D{Talk packets emitted?}
    D -- No --> D1[Inspect src/Task/TalkNPC.pm + src/Network/Send.pm]
    D -- Yes --> E{Expected response packet decoded?}
    E -- No --> E1[Inspect src/Network/Receive/* serverType handlers]
    E -- Yes --> F[Validate dialogue sequence assumptions in task script]
```

Use this when NPC talks stop, loop, or complete with wrong branch.

## C) Plugin not loading / Hook not firing

```mermaid
flowchart TD
    A[Plugin issue] --> B{Plugin loads successfully?}
    B -- No --> B1[Check syntax/dependencies + src/Plugins.pm loader logs]
    B -- Yes --> C{Hook registered via Plugins::addHooks?}
    C -- No --> C1[Fix registration block in plugin file]
    C -- Yes --> D{Event emitted at runtime?}
    D -- No --> D1[Inspect event source in src/functions.pl / network paths]
    D -- Yes --> E{Callback guard conditions pass?}
    E -- No --> E1[Log callback inputs and config-dependent guards]
    E -- Yes --> F[Inspect side effects via Commands/TaskManager]
```

Use this for both plugin boot failures and silent hooks.

## D) Macro/eventMacro not triggering

```mermaid
flowchart TD
    A[Macro/eventMacro not triggering] --> B{Plugin loaded?}
    B -- No --> B1[Inspect plugins/macro or plugins/eventMacro load path]
    B -- Yes --> C{Script file parsed?}
    C -- No --> C1[Validate macro_file/eventMacro_file in control/config.txt]
    C -- Yes --> D{Trigger condition true in live state?}
    D -- No --> D1[Log variables/events used by automacro]
    D -- Yes --> E{Action executes manually?}
    E -- No --> E1[Inspect command path in src/Commands.pm]
    E -- Yes --> F[Investigate scheduler/wait constraints in runner]
```

Use this to isolate parser issues from trigger logic and action execution.

## E) Packet desync / XKore sync / visual client desync

```mermaid
flowchart TD
    A[Desync observed] --> B{Wrong serverType/packet table?}
    B -- Yes --> B1[Fix control/config.txt + tables/* packet mappings]
    B -- No --> C{Receive decode errors?}
    C -- Yes --> C1[Inspect MessageTokenizer/PacketParser/Receive handlers]
    C -- No --> D{Only in XKore mode?}
    D -- No --> D1[Inspect send/receive parity and opcode updates]
    D -- Yes --> E{Client and bot state diverge?}
    E -- Yes --> E1[Inspect src/Network/XKore*.pm forwarding/session state]
    E -- No --> F[Inspect map-transition/session phase sync]
```

Use this for protocol mismatches and client-bridge synchronization drift.
