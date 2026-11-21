# 05 Console Commands

Comando raiz: `eventMacro` (alias `emacro`).

## Subcomandos
- `auto <automacro>`
- `list`
- `status [macro|automacro]`
- `check [force_stop|force_start|resume]`
- `stop`
- `pause`
- `unpause`
- `var_get [var]`
- `var_set <var> <value>`
- `enable [all|automacro...]`
- `disable [all|automacro...]`
- `include [on|off|list] ...`
- `<nomeMacro> [--repeat|-r N] [--overrideAI] [--exclusive] [--macro_delay F] [--orphan S] [args...]`

Status: **PROVADO**.

## Notas
- Se macro já está rodando, chamada direta avisa e não inicia outra. **PROVADO**.
- `var_set` não permite variável de sistema (`.`). **PROVADO**.
