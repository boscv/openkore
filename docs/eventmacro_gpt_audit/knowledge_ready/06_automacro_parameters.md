# 07 Automacro Parameters

Status de validação: **PROVADO** (Core::create_automacro_list + Automacro::set_parameters).

| Parâmetro | Regra de validação | Default |
|---|---|---|
| timeout | número (uso runtime) | 0 |
| delay | número (`^[\d\.]*\d+$`) | 0 |
| run-once | `0|1` | 0 |
| disabled | `0|1` | 0 |
| call | macro existente; pode conter args | obrigatório |
| overrideAI | `0|1` | 0 |
| orphan | `terminate|terminate_last_call|reregister|reregister_safe` | `config{eventMacro_orphans}` |
| macro_delay | número decimal permitido | `timeout{eventMacro_delay}` |
| priority | inteiro não-negativo | 0 |
| exclusive | `0|1` | 0 |
| self_interruptible | `0|1` | 0 |
| repeat | inteiro não-negativo | 1 |
| CheckOnAI | CSV de `auto|off|manual` | `config{eventMacro_CheckOnAI}` |

## Regras adicionais
- Parâmetro duplicado invalida automacro. **PROVADO**.
- Ausência de `call` invalida automacro. **PROVADO**.
- `call` com args separa nome e grava `.param` quando executar. **PROVADO**.
