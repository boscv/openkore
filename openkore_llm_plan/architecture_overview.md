# OpenKore Architecture Overview (for LLM Curation)

## 1) Runtime entry and initialization flow
- Entry script: `openkore.pl`.
- Bootstrap loads `src/` and `src/deps/`, initializes interface + settings, then requires `src/functions.pl`.
- Main loop state machine (in `functions.pl`) progresses through:
  1. plugin loading
  2. control/table loading
  3. networking init
  4. portal DB init
  5. first-time prompt
  6. final init
  7. steady-state loop.

## 2) Core functional layers
- **Execution & AI**: `src/AI*.pm`, `src/Task*.pm`, `src/TaskManager.pm`.
- **Domain model**: `src/Actor*.pm`, `src/ActorList.pm`, `src/InventoryList*.pm`, `src/Skill.pm`, `src/Field.pm`.
- **Network stack**: `src/Network*.pm`, `src/Network/Receive/*`, `src/Network/Send/*`, plus XKore modes.
- **Configuration/data loading**: `src/Settings.pm`, `src/FileParsers.pm`, `src/Globals.pm`, `control/*.txt`, `tables/**`.
- **Extensibility**: `src/Plugins.pm` + `plugins/*`.
- **Interfaces/logging/debug**: `src/Interface*.pm`, `src/Log.pm`, `src/ErrorHandler.pm`, `src/test/*`.

## 3) Plugin and automation architecture
- Plugin framework discovers `.pl` plugin files and supports selective load via `control/sys.txt`.
- Two automation ecosystems to prioritize for GPT knowledge:
  - **macro** plugin (`plugins/macro/*`) using `macro_file` (default `macros.txt`).
  - **eventMacro** plugin (`plugins/eventMacro/*`) using `eventMacro_file` (default `eventMacros.txt`).

## 4) Networking specialization points
- Packet parsing/sending core in `src/Network/PacketParser.pm`, `src/Network/Receive.pm`, `src/Network/Send.pm`.
- Server/client packet mappings are server-type specific (`src/Network/Receive/*`, `src/Network/Send/*`) and table-backed by `tables/**/recvpackets.txt`.
- XKore paths:
  - `src/Network/XKore.pm` (mode 1)
  - `src/Network/XKore2.pm` + `src/Network/XKore2/*` (proxy mode)
  - `src/Network/XKoreProxy.pm`.

## 5) Curation implication
For a public knowledge base, keep conceptual coverage broad but file payload bounded: include framework files + representative server-type packet files first, then expand by region/date-specific packet modules in later batches.
