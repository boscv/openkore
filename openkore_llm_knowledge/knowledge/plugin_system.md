# Plugin System

## Architecture (as seen in representative plugins)
OpenKore plugins are Perl packages under `plugins/` with an entrypoint `.pl` file. A plugin typically:
1. imports core APIs (`Plugins`, `Commands`, `Settings`, `Globals`),
2. registers itself,
3. subscribes to runtime hooks,
4. optionally registers console commands,
5. cleans up on unload.

Representative curated files:
- `plugins/macro/macro.pl`
- `plugins/eventMacro/eventMacro.pl`
- `plugins/reconnect/reconnect.pl`
- `plugins/profiles/profiles.pl`
- `plugins/map/map.pl`

## Hook system
Representative plugins use hook APIs such as:
- `Plugins::addHooks(...)` for multiple hook subscriptions.
- Event points like `start3`, `mainLoop_pre`, and `configModify`.
- Hook callbacks to react to runtime state or packets.

In the macro/eventMacro plugins, hooks are used to load macro configs at startup, react to config changes, and run checks/actions each loop cycle.

## Plugin lifecycle
Common lifecycle pattern:
- `Plugins::register(name, description, unload_cb[, reload_cb])`
- startup callback(s) load plugin state and files
- runtime callbacks handle logic
- unload callback removes hooks/commands and clears state

The macro plugin includes both unload and reload behavior; eventMacro includes explicit unload cleanup and file reparse logic.

## Command registration
Plugins can expose user commands via `Commands::register`.
Examples in this bundle:
- macro plugin: `macro ...`
- eventMacro plugin: `eventMacro ...` and `emacro ...`

These command handlers provide runtime control (status, list, enable/disable, variable ops, etc.) without modifying core code.
