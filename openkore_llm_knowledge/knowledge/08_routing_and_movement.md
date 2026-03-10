# Routing and Movement

Routing converts destination intent into path segments and movement packets using `src/Task/Route.pm`, `src/Task/Move.pm`, `src/Field.pm`, and `fields/*` data.

```mermaid
flowchart TD
    A[AI/Command target\nmap + coordinates] --> B[Task::Route init]
    B --> C[Load field graph\nsrc/Field.pm + fields/*]
    C --> D[Compute path segments]
    D --> E[Task::Move executes step]
    E --> F[Send move packet\nsrc/Network/Send.pm]
    F --> G[Receive position update\nsrc/Network/Receive.pm]
    G --> H{Reached waypoint?}
    H -- No --> E
    H -- Yes --> I{Reached destination?}
    I -- No --> D
    I -- Yes --> J[Route complete]
```

Routing is iterative and feedback-driven: each movement step is validated by receive updates before continuing.
