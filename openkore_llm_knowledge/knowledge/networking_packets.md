# Networking & Packets

## Packet handling architecture
OpenKore networking is structured around base transport/state modules plus packet parser/dispatcher modules:
- `networking/Network.pm` and `networking/DirectConnection.pm` for connection state and transport.
- `networking/PacketParser.pm` and `networking/MessageTokenizer.pm` for framing/tokenization and packet reconstruction support.
- `networking/Receive.pm` for incoming packet dispatch.
- `networking/Send.pm` for outgoing packet construction.

## Receive flow (high level)
1. Bytes arrive from the active network backend.
2. Tokenizer/parser identifies packet boundaries and switch IDs.
3. `Receive.pm` maps switches to handlers.
4. Server-type subclasses (for example `Network/Receive/ServerType0.pm`, `Network/Receive/kRO.pm`, `Network/Receive/iRO.pm`) override or extend behavior.
5. Handlers update runtime state (actors, inventory, map/chat/combat events).

## Send flow (high level)
1. Runtime logic requests an action (move, skill, talk, item ops).
2. `Send.pm` builds base packet payloads.
3. Server-type send classes (for example `Network/Send/ServerType0.pm`, `kRO.pm`, `iRO.pm`) apply server-specific packet formats.
4. Transport layer sends encoded bytes to the game server/proxy endpoint.

## Table coupling
Packet behavior is tightly coupled to table data:
- `tables/servers.txt` selects server profile/type.
- `tables/*/recvpackets.txt` maps opcode formats by server build/family.
- `tables/packetlist.txt` and `tables/packetdescriptions.txt` assist packet reference/debug workflows.
