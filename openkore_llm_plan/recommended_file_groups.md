# Recommended File Groups for Public OpenKore GPT

## 01_openkore_core
- `README.md`, `openkore.pl`, `start.pl`
- `src/functions.pl`, `src/Modules.pm`, `src/Globals.pm`, `src/Settings.pm`, `src/FileParsers.pm`
- `src/AI.pm`, `src/AI/CoreLogic.pm`, `src/AI/Attack.pm`, `src/AI/Slave*.pm`
- `src/TaskManager.pm`, `src/Task.pm`, `src/Task/*.pm`
- `src/Actor.pm`, `src/Actor/*.pm`, `src/ActorList.pm`
- `src/InventoryList*.pm`, `src/Skill.pm`, `src/Field.pm`, `src/Misc.pm`, `src/Commands.pm`

## 02_openkore_plugins
- `src/Plugins.pm`
- Plugin entrypoints: `plugins/*/*.pl`
- Full include priority:
  - `plugins/macro/**`
  - `plugins/eventMacro/**`
  - `plugins/profiles/**`
  - `plugins/reconnect/**`
  - `plugins/map/**`
- Optional annex (advanced/legacy): `plugins/needs-review/**`

## 03_openkore_config
- Entire `control/*.txt`
- Include especially:
  - `control/config.txt`
  - `control/sys.txt`
  - `control/mon_control.txt`
  - `control/items_control.txt`
  - `control/timeouts.txt`
  - `control/poseidon.txt`
- If macro/eventMacro examples exist in deployments, include `control/macros.txt` and `control/eventMacros.txt` patterns as documentation snippets.

## 04_openkore_tables
- Top-level canonical tables in `tables/*.txt`
- One primary server profile first (recommended: `tables/kRO/**` due breadth)
- Then regional packs in separate batches (`tables/iRO/**`, `tables/bRO/**`, `tables/idRO/**`, etc.)
- Optional legacy: `tables/Old/**`

## 05_openkore_networking
- Core networking:
  - `src/Network.pm`
  - `src/Network/DirectConnection.pm`
  - `src/Network/PacketParser.pm`
  - `src/Network/Receive.pm`
  - `src/Network/Send.pm`
- Server specializations:
  - `src/Network/Receive/**`
  - `src/Network/Send/**`
- XKore:
  - `src/Network/XKore.pm`
  - `src/Network/XKore2.pm`
  - `src/Network/XKoreProxy.pm`
  - `src/Network/XKore2/**`
- Packet mapping tables:
  - `tables/**/recvpackets.txt`
  - `tables/**/sync.txt`

## 06_openkore_docs
- `README.md`, `LegacyChangelog.md`
- `src/doc/**`
- `plugins/eventMacro/README.md`
- Any plugin-local README files and test docs that explain behavior boundaries
- Keep historical/obsolete docs lower priority than runtime + config + packet sources
