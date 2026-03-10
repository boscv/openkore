# OpenKore Developer FAQ

This FAQ is based on the curated OpenKore knowledge bundle and references core, plugin, networking, config, and table modules.

## 1) How do I write a plugin?
Start with a Perl file that calls `Plugins::register`, adds hooks via `Plugins::addHooks`, and optionally registers commands via `Commands::register`.
Reference: `knowledge/code_recipes.md`, `plugins/macro/macro.pl`, `plugins/eventMacro/eventMacro.pl`.

## 2) What is the smallest plugin skeleton?
A minimal plugin includes `package`, `use Plugins`, `Plugins::register(...)`, optional hook/command setup, and unload cleanup.
Reference: `knowledge/code_recipes.md`.

## 3) How do I register hooks in a plugin?
Use `Plugins::addHooks` with event/callback pairs such as `start3`, `mainLoop_pre`, and `configModify`.
Reference: `knowledge/plugin_system.md`, `plugins/macro/macro.pl`.

## 4) How do I add a custom console command?
Use `Commands::register` and provide a callback receiving command parameters.
Reference: `knowledge/code_recipes.md`, `plugins/eventMacro/eventMacro.pl`.

## 5) How do plugins clean up on unload?
Implement unload callback to remove hooks (`Plugins::delHooks`) and unregister commands.
Reference: `plugins/macro/macro.pl`, `plugins/eventMacro/eventMacro.pl`.

## 6) How does the AI system work at a high level?
The main loop invokes AI logic, which inspects world state and schedules tasks.
Reference: `core/functions.pl`, `core/AI.pm`, `core/AI/CoreLogic.pm`, `knowledge/system_architecture_map.md`.

## 7) Where is combat/behavior decision logic concentrated?
In `core/AI/CoreLogic.pm`.
Reference: `knowledge/core_subsystems.md`, `knowledge/module_dependency_map.md`.

## 8) How are actors represented?
Actor entities use a base model plus indexed actor collections.
Reference: `core/Actor.pm`, `core/ActorList.pm`, `knowledge/core_subsystems.md`.

## 9) Where is NPC interaction implemented?
Primary flow is in `core/Task/TalkNPC.pm` with related command/receive participation.
Reference: `knowledge/execution_flows.md`, `knowledge/debugging_playbook.md`.

## 10) How does task scheduling work?
Tasks derive from `Task` and are queued/executed by `TaskManager`.
Reference: `core/Task.pm`, `core/TaskManager.pm`, `knowledge/module_dependency_map.md`.

## 11) Where is routing implemented?
Routing is in `core/Task/Route.pm`, and movement execution in `core/Task/Move.pm`.
Reference: `knowledge/execution_flows.md`, `knowledge/core_subsystems.md`.

## 12) How does packet receive flow work?
Data is tokenized/parsing handled, then dispatched by receive handlers to update runtime state.
Reference: `networking/MessageTokenizer.pm`, `networking/PacketParser.pm`, `networking/Receive.pm`, `knowledge/networking_packets.md`.

## 13) Where are outgoing packets built?
Primarily in `networking/Send.pm` and server-specific send modules.
Reference: `knowledge/networking_packets.md`, `networking/Network/Send/ServerType0.pm`.

## 14) How do server-specific packet differences get handled?
Through receive/send server-type modules and matching `recvpackets.txt` table data.
Reference: `networking/Network/Receive/*`, `networking/Network/Send/*`, `tables/*/recvpackets.txt`.

## 15) What causes packet desync most often?
Profile mismatch between server configuration and selected `recvpackets` mapping.
Reference: `knowledge/debugging_playbook.md`, `knowledge/table_reference.md`.

## 16) What are XKore modes?
Mode 1 is bridge-style; mode 2 is a fuller proxy stack with account/char/map components.
Reference: `knowledge/xkore_modes.md`, `networking/XKore.pm`, `networking/XKore2.pm`.

## 17) Where are XKore2 stage servers implemented?
In `networking/Network/XKore2/AccountServer.pm`, `CharServer.pm`, and `MapServer.pm`.
Reference: `knowledge/xkore_modes.md`.

## 18) Where is global runtime state stored?
In `core/Globals.pm`, consumed broadly by AI/network/task/command modules.
Reference: `knowledge/module_dependency_map.md`.

## 19) Where is configuration path/file loading controlled?
In `core/Settings.pm` and parser routines in `core/FileParsers.pm`.
Reference: `knowledge/core_subsystems.md`, `knowledge/module_dependency_map.md`.

## 20) Which config files matter most for behavior tuning?
`config.txt`, `items_control.txt`, and `mon_control.txt`.
Reference: `knowledge/config_system.md`.

## 21) How does `lockMap` work conceptually?
It constrains activity/navigation to a target map (optionally coordinate-focused with lock map coords).
Reference: `knowledge/code_recipes.md` route locking example, `knowledge/config_system.md`.

## 22) Where should I tune item pickup behavior?
In `config/items_control.txt`.
Reference: `knowledge/config_system.md`, `knowledge/code_recipes.md`.

## 23) Where should I tune monster engagement/avoidance?
In `config/mon_control.txt`.
Reference: `knowledge/config_system.md`, `knowledge/code_recipes.md`.

## 24) Where do plugin load policies live?
In `config/sys.txt` (`loadPlugins`, include/skip lists).
Reference: `knowledge/debugging_playbook.md`, `knowledge/plugin_system.md`.

## 25) How do I tell macro and eventMacro apart?
Both are automation systems, but eventMacro emphasizes event/condition-driven structures with distinct parser/runner modules.
Reference: `knowledge/macro_system.md`, `plugins/macro/*`, `plugins/eventMacro/*`.

## 26) Where are macro commands implemented?
In `plugins/macro/macro.pl` (`macro` command) and `plugins/eventMacro/eventMacro.pl` (`eventMacro`, `emacro`).
Reference: `knowledge/plugin_system.md`.

## 27) Why would macros not trigger?
Common causes: plugin not loaded, wrong macro file path, false conditions, or disabled automacro.
Reference: `knowledge/debugging_playbook.md`.

## 28) How do I set emergency teleport automation?
Use macro/eventMacro conditions on HP threshold and teleport action commands.
Reference: `knowledge/code_recipes.md`.

## 29) How can I create a farming loop quickly?
Define a recursive macro with movement and `ai auto` pauses, gated by an automacro trigger.
Reference: `knowledge/code_recipes.md`.

## 30) How do I debug “bot not moving”?
Inspect AI/task state and movement packet emission paths, then validate route/map constraints.
Reference: `knowledge/debugging_playbook.md`.

## 31) How do I debug NPC interaction failures?
Trace `Task/TalkNPC` progression and corresponding receive handler updates.
Reference: `knowledge/debugging_playbook.md`, `knowledge/execution_flows.md`.

## 32) How do I debug plugin load failures?
Check `sys.txt` plugin load mode/lists and plugin startup exceptions.
Reference: `knowledge/debugging_playbook.md`.

## 33) How do I debug routing failures?
Validate route generation, movement progression, and map/portal tables.
Reference: `knowledge/debugging_playbook.md`, `tables/portals.txt`.

## 34) What are the key packet reference tables?
`tables/packetlist.txt`, `tables/packetdescriptions.txt`, and server profile `recvpackets.txt` files.
Reference: `knowledge/table_reference.md`.

## 35) What does `tables/servers.txt` do?
Defines server profiles and serverType anchors used by network/packet handling.
Reference: `knowledge/table_reference.md`, `knowledge/networking_packets.md`.

## 36) Why include both kRO and iRO tables in curation?
They provide representative regional profiles for packet/content differences.
Reference: `knowledge/table_reference.md`.

## 37) What is the role of `core/functions.pl`?
It drives startup stages and main loop transitions.
Reference: `knowledge/core_module_index.md`, `knowledge/module_dependency_map.md`.

## 38) Why is `Commands.pm` so central?
It is a common control surface for operators, plugins, and automation.
Reference: `knowledge/module_dependency_map.md`.

## 39) Why is `Network::Receive` so important?
Incoming packets drive most runtime state changes (actors, events, dialogs, combat updates).
Reference: `knowledge/networking_packets.md`, `knowledge/module_dependency_map.md`.

## 40) How do plugins interact with runtime without core edits?
By hooking lifecycle/events and registering commands.
Reference: `knowledge/plugin_system.md`.

## 41) Where should I start when extending behavior safely?
Start with a small plugin command + one lightweight hook; expand incrementally.
Reference: `knowledge/code_recipes.md`.

## 42) How do I avoid plugin performance issues?
Keep `mainLoop_pre` callbacks lightweight and avoid heavy repeated processing.
Reference: `knowledge/code_recipes.md` notes.

## 43) How do I map a runtime problem to the right subsystem quickly?
Use the system map: AI/Task for decisions/actions, Network/Packet for protocol/state updates, Config/Plugin for policy/extension.
Reference: `knowledge/system_architecture_map.md`.

## 44) Where is the best overview of subsystem interactions?
`knowledge/system_architecture_map.md` and `knowledge/execution_flows.md`.

## 45) What is the recommended debugging sequence?
Confirm profile alignment, isolate logic vs protocol layer, reproduce minimally, trace first divergence, re-test.
Reference: `knowledge/debugging_playbook.md`.

## 46) How do I inspect module dependencies quickly?
Use `knowledge/module_dependency_map.md` for purpose + dependency + reverse-dependency summaries.

## 47) Which modules are “top priority” for understanding architecture?
Start with `functions.pl`, AI, Actor, Task, Commands, Network, Receive/PacketParser, Settings/FileParsers, and Globals.
Reference: `knowledge/module_dependency_map.md` Top 20 section.

## 48) How do I create map-entry automation?
Use eventMacro conditions like `InMap` + `mapLoaded` and issue config/AI commands.
Reference: `knowledge/code_recipes.md`.

## 49) How do I create monster-proximity reactions?
Use eventMacro presence/distance conditions and trigger defensive actions (e.g., teleport).
Reference: `knowledge/code_recipes.md`.

## 50) Where can I find practical examples across plugin/macro/config work?
`knowledge/code_recipes.md` contains concise snippets for all three domains.

## 51) What if a change seems correct but behavior is still wrong?
Re-check server profile + packet table alignment first, then verify module override family (ServerType/kRO/iRO).
Reference: `knowledge/debugging_playbook.md`, `knowledge/networking_packets.md`.

## 52) How should I keep this knowledge bundle maintainable?
Update high-volatility areas first: networking modules, packet tables, and macro/plugin docs tied to runtime hooks.
Reference: prioritize updates to `knowledge/networking_packets.md`, `knowledge/table_reference.md`, and `knowledge/plugin_system.md` when runtime behavior changes.
