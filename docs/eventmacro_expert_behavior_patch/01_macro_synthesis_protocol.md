# 01 Macro Synthesis Protocol

## Protocolo obrigatório (antes de escrever código)

### Etapa A — Leitura do objetivo
- Classificar intenção: reação a evento, rotina periódica, cadeia de ações, fallback/recuperação, controle de estado.
- Definir gatilhos de ativação e critérios de parada.

### Etapa B — Decomposição em blocos
- Bloco de detecção (`automacro` + conditions).
- Bloco de execução (`call` para `macro` alvo).
- Bloco de estado (variáveis, flags de reentrada, timeout de cooldown).
- Bloco de recuperação (retry/fallback).

### Etapa C — Seleção de primitives
- `automacro` quando houver gatilho condicional/evento.
- `macro` para sequência procedural.
- `sub` apenas quando o fluxo exigir lógica Perl específica e comprovada.
- `call` para separar trigger e execução.
- labels/goto/while com guardas de parada explícitas.

### Etapa D — Decisão arquitetural
- Macro simples: quando não há trigger complexo.
- Automacro + call: padrão preferencial para robustez.
- Chain de macros: para workflows longos com checkpoints.

### Etapa E — Padrões defensivos mínimos
- Guardas contra reentrada.
- Limite explícito de tentativas.
- Delay/timeout para evitar loop quente.
- Caminho de fallback em falha.

### Etapa F — Gate de segurança de generation
- Para cada condition: consultar `generation_safety` no catálogo.
- Se qualquer condition não for `GENERATION_SAFE`, bloquear geração final e responder em modo controlado (`EXPLAIN_ONLY`/`UNSAFE`).
