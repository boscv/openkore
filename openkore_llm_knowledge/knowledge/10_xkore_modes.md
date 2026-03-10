# XKore Modes

XKore modes define how OpenKore connects to the game client/server pipeline.

## Core modules
- `src/Network/XKore.pm`
- `src/Network/XKore2.pm`
- `src/Network/XKoreProxy.pm`
- `src/Network/DirectConnection.pm` (baseline comparison)

## Mode summary
- **DirectConnection**: bot connects directly to game servers.
- **XKore**: client-assisted mode using forwarding/bridging logic.
- **XKore2**: OpenKore hosts local account/char/map proxy endpoints (`src/Network/XKore2/*`) and relays traffic.
- **XKoreProxy**: proxy-style mediation path for packet bridging.

## Architectural impact
- All modes reuse packet parsing/dispatch and send modules (`src/Network/{Receive,Send}.pm`).
- Mode choice primarily changes transport/session orchestration and how packets are sourced/sinked.
- AI, tasks, actor state, plugins, and macro systems remain mode-agnostic above the network abstraction.
