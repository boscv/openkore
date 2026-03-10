# XKore Modes

## XKore mode 1 (`networking/XKore.pm`)
- Runs a local bridge server and communicates between OpenKore and an RO client.
- Maintains client/server packet channels and forwards transformed packets.
- Useful for hybrid play/automation workflows where a game client remains in the loop.

## XKore mode 2 (`networking/XKore2.pm` + `networking/Network/XKore2/*`)
- Implements proxy-style account/char/map server components.
- Uses dedicated XKore2 server classes:
  - `AccountServer.pm`
  - `CharServer.pm`
  - `MapServer.pm`
- Integrates with hooks to manage packet mangling and in-game synchronization.

## XKore proxy support (`networking/XKoreProxy.pm`)
- Additional proxy integration layer used in XKore-style setups.

## Practical difference summary
- **Mode 1**: direct local bridge style, simpler path for client relay.
- **Mode 2**: fuller proxy stack with separate protocol-stage servers and session handling.
