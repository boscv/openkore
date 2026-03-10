# Table Reference

## Purpose
`tables/` contains protocol and gameplay data used by network parsing, IDs, maps, and runtime lookups.

## Core packet/profile tables
- `tables/servers.txt`
- `tables/packetlist.txt`
- `tables/packetdescriptions.txt`
- server-family `recvpackets.txt` files (e.g., `tables/kRO/recvpackets.txt`, `tables/iRO/recvpackets.txt`)

## Gameplay identity tables
- `tables/SKILL_id_handle.txt`
- `tables/STATUS_id_handle.txt`
- `tables/statusnametable.txt`
- `tables/itemtypes.txt`
- `tables/elements.txt`

## World/content tables
- `tables/portals.txt`
- `tables/skillsarea.txt`
- regional `maps.txt`, `items.txt`, `skillnametable.txt`

## Notes
Packet-related incidents should always be validated against serverType + recvpackets alignment.
