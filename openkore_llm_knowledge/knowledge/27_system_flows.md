# System Flows

## Plugin hook execution flow
Plugins extend runtime behavior through hook callbacks registered in `src/Plugins.pm` and commonly invoke `src/Commands.pm` or task APIs.

```mermaid
flowchart TD
    A[Plugin load\nplugins/*.pl] --> B[Plugins::register]
    B --> C[Plugins::addHooks]
    C --> D[Runtime event\nloop/packet/config]
    D --> E[Plugin callback]
    E --> F{Action needed?}
    F -- No --> G[Return]
    F -- Yes --> H[Execute command\nsrc/Commands.pm]
    H --> I[Task/Network side effects]
    I --> G
```

Hook callbacks are event-driven and should remain lightweight; heavy operations are usually delegated to commands/tasks.

## Command execution flow

```mermaid
flowchart TD
    A[Input source\nconsole/plugin/macro] --> B[Commands::run]
    B --> C[Command parser\nsrc/Commands.pm]
    C --> D{Built-in or plugin cmd?}
    D -- Built-in --> E[Built-in handler]
    D -- Plugin --> F[Plugin command callback]
    E --> G[Update state / queue task / send packet]
    F --> G
    G --> H[Feedback to interface/log]
```

Commands are a shared control surface across manual operations, plugins, and macro automation.
