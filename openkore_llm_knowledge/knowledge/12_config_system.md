# Configuration System

## Purpose
Behavior policy is primarily configuration-driven via `control/` and table data under `tables/`.

## Key files
- `control/config.txt`: global runtime/AI/combat/movement/network options.
- `control/items_control.txt`: item pickup/storage/sell policy.
- `control/mon_control.txt`: per-monster behavior policy.

## Runtime integration
- `src/Settings.pm`: config path/file registration.
- `src/FileParsers.pm`: parser logic for control/table formats.
- `src/Globals.pm`: shared runtime state consumed by AI/tasks/plugins.

## Debugging guidance
- Validate key names and value format first.
- Re-test with minimal config to isolate policy conflicts.
- Check plugin/macro automation that may override config expectations.
