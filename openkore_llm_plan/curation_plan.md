# Curation Plan (Staged, Small-Batch Extraction)

## Stage 0 — Seed context (small, high-signal)
**Goal:** Let GPT answer “what is OpenKore?” and explain startup/config basics.
- `README.md`, `openkore.pl`
- `src/functions.pl`, `src/Settings.pm`, `src/Globals.pm`, `src/FileParsers.pm`
- `control/config.txt`, `control/sys.txt`
- `tables/servers.txt`, top-level `tables/recvpackets.txt` (if present for base profile)

## Stage 1 — Core runtime and AI
**Goal:** Explain bot behavior orchestration and object model.
- `src/AI.pm`, `src/AI/CoreLogic.pm`, `src/AI/Attack.pm`
- `src/Task.pm`, `src/TaskManager.pm`, key `src/Task/*.pm`
- `src/Actor.pm`, `src/Actor/*.pm`, `src/ActorList.pm`, `src/InventoryList*.pm`, `src/Skill.pm`, `src/Field.pm`

## Stage 2 — Plugin framework + mainstream plugins
**Goal:** Cover extension model and commonly used plugin workflows.
- `src/Plugins.pm`
- Mainline plugin entrypoints (top-level plugin `.pl` files)
- Deep include: `plugins/macro/**`, `plugins/eventMacro/**`, `plugins/profiles/**`, `plugins/reconnect/**`, `plugins/map/**`

## Stage 3 — Config/control corpus
**Goal:** Make GPT strong at control-file troubleshooting.
- Entire `control/*.txt` defaults
- Any config-relevant docs in repo root and `src/doc/` (only user-facing references)
- Map each file to parser + runtime module (from `Settings.pm` / `functions.pl`)

## Stage 4 — Tables corpus (split by profile)
**Goal:** Avoid oversize ingestion while preserving lookup value.
- Batch A: core generic top-level tables (`tables/*.txt`)
- Batch B: one reference server profile (e.g., `tables/kRO`)
- Batch C+: regional packs (`iRO`, `bRO`, `idRO`, etc.) as separate increments
- Keep `Old/` as optional legacy annex

## Stage 5 — Networking and packets
**Goal:** Enable packet/version/serverType reasoning.
- Core: `src/Network.pm`, `src/Network/PacketParser.pm`, `src/Network/Receive.pm`, `src/Network/Send.pm`
- XKore: `src/Network/XKore*.pm`, `src/Network/XKore2/*`
- Packet families in chunks: generic server types first, then regional/date variants
- Align each code chunk with corresponding `tables/**/recvpackets.txt`

## Stage 6 — Debugging and validation corpus
**Goal:** Improve diagnostic answers and developer guidance.
- `src/Log.pm`, `src/ErrorHandler.pm`, `src/Interface/Console.pm`
- `src/test/*` (selected high-signal unit tests)
- Debug-oriented plugins (e.g., `plugins/needs-review/packet-recorder`, `packetMiner`) as optional annex

## Stage 7 — Public GPT polish
- Add concise metadata per file group: purpose, audience, volatility, risk of stale packet info.
- Tag known “advanced/internal” areas (Poseidon, bus, XKore2 internals) to avoid novice confusion.
- Maintain a changelog-driven refresh cycle (network files and tables refresh most frequently).
