# OpenKore Core Architecture (Curated Bundle)

This knowledge bundle focuses on **core runtime architecture** from `src/` only.

## Runtime flow
1. `openkore.pl` bootstraps module paths and loads core modules.
2. `src/functions.pl` drives the startup state machine:
   - load plugins
   - load control/table data
   - initialize networking
   - finalize initialization
   - enter steady `mainLoop`
3. Core behavior then cycles through AI, task scheduling, command handling, and packet IO.

## Included core layers
- **Boot + orchestration**: `src/functions.pl`, `src/Modules.pm`, `src/Globals.pm`
- **Configuration/parsing**: `src/Settings.pm`, `src/FileParsers.pm`
- **AI/task execution**: `src/AI.pm`, `src/AI/CoreLogic.pm`, `src/AI/Attack.pm`, `src/Task*.pm`
- **Actor model**: `src/Actor.pm`, `src/ActorList.pm`
- **Networking core**: `src/Network.pm`, `src/Network/{PacketParser,Receive,Send}.pm`
- **Command/log/debug glue**: `src/Commands.pm`, `src/Misc.pm`, `src/Log.pm`, `src/ErrorHandler.pm`, `src/Interface.pm`
- **Plugin framework dependency** (core extensibility context): `src/Plugins.pm`

## Curation constraints applied
- Source scope restricted to `src/` content for copied code files.
- No binaries, archives, build artifacts, logs, or temp assets were included.
- Bundle is intentionally small and architecture-first for public GPT ingestion.
