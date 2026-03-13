# NPC Interaction Flow

NPC interactions are executed as task-driven conversations, typically using `src/Task/TalkNPC.pm` and packet handlers under `src/Network/Receive/*.pm`.

```mermaid
sequenceDiagram
    participant U as AI/Command/Plugin
    participant TM as TaskManager
    participant TN as Task::TalkNPC
    participant NS as Network::Send
    participant S as Ragnarok Server
    participant NR as Network::Receive
    participant G as Globals/Actor state

    U->>TM: enqueue NPC interaction
    TM->>TN: start dialogue task
    TN->>NS: send talk/response packet
    NS->>S: outbound packet
    S->>NR: NPC response packet
    NR->>G: update dialogue/state flags
    NR->>TM: task-relevant updates
    TM->>TN: advance next dialogue step
    TN-->>TM: complete/fail
```

`Task::TalkNPC` keeps dialogue progression explicit, while receive handlers synchronize server-side conversation state back into runtime state.
