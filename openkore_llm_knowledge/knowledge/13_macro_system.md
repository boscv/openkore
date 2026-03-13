# Macro System

## Components
- Macro plugin: `plugins/macro/macro.pl`, `plugins/macro/Macro/*`
- eventMacro plugin: `plugins/eventMacro/eventMacro.pl`, `plugins/eventMacro/eventMacro/*`

## Configuration keys
- `macro_file` -> macro script path (commonly `macros.txt`).
- `eventMacro_file` -> eventMacro script path (commonly `eventMacros.txt`).

## Execution model
1. Plugin loads and parses macro file.
2. Hooks/events trigger condition evaluation.
3. Matching automacro rules enqueue/execute actions.
4. Actions flow through command/task/network paths.

## Operational notes
- Macro and eventMacro are complementary automation layers.
- Troubleshooting should separate: load -> parse -> trigger -> action execution.
