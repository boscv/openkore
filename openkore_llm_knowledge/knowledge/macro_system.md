# Macro System

## `macros.txt`
The macro plugin (`plugins/macro/macro.pl`) loads a macro file from config key `macro_file`, defaulting to `macros.txt`.

What it provides:
- macro definitions (named scripts/blocks)
- automacro triggers
- runtime command control via `macro` command

The plugin reparses the configured macro file when `macro_file` changes and hooks runtime events according to defined automacro conditions.

## `eventMacros.txt`
The eventMacro plugin (`plugins/eventMacro/eventMacro.pl`) loads from config key `eventMacro_file`, defaulting to `eventMacros.txt`.

What it provides:
- event-driven macro model
- condition-based automacro activation
- runtime control via `eventMacro` / `emacro` commands

If no event macro file is present, the plugin disables itself in startup logic.

## Automacro behavior (conceptual)
Across both macro systems, automacros generally follow this pattern:
1. Parse macro file and build macro/automacro structures.
2. Subscribe to relevant hooks/events.
3. Evaluate conditions (state/event/regex/numeric checks).
4. Queue or execute macro actions when conditions are satisfied.
5. Respect timeout/run-once/enable-disable states and user commands.

This makes macro automation configurable from text files rather than source edits.
