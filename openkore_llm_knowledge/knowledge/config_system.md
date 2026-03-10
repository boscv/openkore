# Configuration System (Curated from `control/`)

Configuration files in `control/` define runtime behavior and policies. This bundle copies the full `control/*.txt` set into `openkore_llm_knowledge/config/`.

## `config.txt`
Primary behavior configuration file. It contains the main bot options (AI behavior, combat options, looting, movement, network/runtime preferences, plugin-related keys, etc.).

Use `config.txt` to set high-level behavior and feature toggles.

## `items_control.txt`
Item-level policy file controlling item handling rules.
Typical usage includes deciding whether items should be picked up, stored, sold, or ignored based on names/IDs and rule flags.

Use `items_control.txt` for inventory and looting policy tuning.

## `mon_control.txt`
Monster-level AI policy file.
It defines per-monster behavior such as attack mode, teleport/disconnect response, and conditional thresholds.

Use `mon_control.txt` to tune combat risk handling and target strategy.

## Practical model
- `config.txt` = global behavior defaults
- `items_control.txt` = item policy overrides
- `mon_control.txt` = monster policy overrides

Together, these provide most day-to-day operational control without changing source modules.
