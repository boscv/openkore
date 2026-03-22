# 05 Complex Pattern Cookbook

## Padrão 1 — Trigger + execução separada
- `automacro` com conditions seguras.
- `call` para macro executora.
- Guard de reentrada por variável.

## Padrão 2 — Chain de macros com checkpoints
- Macro A prepara estado.
- Macro B executa ação principal.
- Macro C valida resultado / fallback.

## Padrão 3 — Retry controlado
- Variável contador `retry_count`.
- Loop com limite máximo.
- Delay entre tentativas.

## Padrão 4 — Fallback defensivo
- Se condição principal falhar N vezes, chamar macro fallback.
- Registrar estado de falha para evitar thrashing.

## Padrão 5 — Exclusividade/Interrupção
- Lock flag (`$state_lock`) antes de fluxo crítico.
- Liberação explícita ao final/erro.

## Padrão 6 — Reentrada controlada
- Automacro checa lock/cooldown antes de `call`.
- Define lock no início da macro chamada.

## Padrão 7 — Delay e timeout robustos
- `delay`/`timeout` em pontos de espera.
- Nunca depender de espera infinita sem escape.

## Padrão 8 — Validação defensiva de parâmetros
- Checar argumento esperado antes de ação sensível.
- Em dúvida, abortar com log e fallback.
