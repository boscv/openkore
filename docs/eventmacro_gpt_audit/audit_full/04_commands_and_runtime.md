# 04 Commands and Runtime

## Comandos console
`eventMacro|emacro`:
- `auto`, `list`, `status`, `check`, `stop`, `pause`, `unpause`, `var_get`, `var_set`, `enable`, `disable`, `include`, ou nome de macro. **PROVADO**.

## Comandos da linguagem macro
- Atribuição (`$x = ...`, `$x++`, `$x--`, `@a=(...)`, `%h=(k=>v,...)`). **PROVADO**.
- `do ...`, `log|warning|error ...`, `pause [n]`, `stop`, `release`, `lock`, `call`, `set`, `include`. **PROVADO**.
- Suporte a `push/unshift/pop/shift`, `delete/exists`, `defined` via macro keywords. **PROVADO**.

## Fila/prioridade/disparo
- Automacros state fulfilled entram em fila ordenada por `priority` (menor valor = maior prioridade efetiva na frente). **PROVADO**.
- Event conditions não entram na fila contínua; disparam no callback e escolhem melhor prioridade entre candidatos no evento. **PROVADO**.
- `timeout` controla re-disparo de automacro; `delay` atraso inicial do macro chamado; `macro_delay` atraso entre comandos. **PROVADO**.
- `run-once` desabilita automacro após chamada. **PROVADO**.

## interruptibilidade/AI/orphan
- `exclusive=1` => macro não interruptível (`interruptible=0`) e pausa checking de automacros (salvo force user). **PROVADO**.
- `self_interruptible` bloqueia interrupção por seu próprio automacro chamador quando 0. **PROVADO**.
- `overrideAI=1` retira `eventMacro` da AI queue. **PROVADO**.
- `orphan`: `terminate|terminate_last_call|reregister|reregister_safe`. **PROVADO**.

## clear_queue/handoff
- `clear_queue` encerra runner, remove hook de iteração e restaura checking quando necessário. **PROVADO**.
- Ao limpar fila sem `skip`, `handoff_to_pending_automacros` pode chamar automacro pendente imediatamente. **PROVADO**.
