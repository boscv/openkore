# 03 Generation Safety Reclassification

## Regra aplicada
- `lexical_contract_status == COMPLETE` => pode permanecer `GENERATION_SAFE`.
- `lexical_contract_status == PARTIAL/INSUFFICIENT` => rebaixar para `EXPLAIN_ONLY`/`UNSAFE`.

## Contagem final
- GENERATION_SAFE: 57
- EXPLAIN_ONLY: 61
- UNSAFE: 0

## Reclassificações
- Total reclassificadas: 52
- Direção predominante: `GENERATION_SAFE -> EXPLAIN_ONLY` por lacuna lexical de separador/forma em parser composto.

## Caso-modelo revisado: QuestHuntCompleted
- CSV externo + whitespace interno por membro (`quest_id mob_id`).
- Rejeita membro sem dois slots e separação inadequada.
- Mantida como `GENERATION_SAFE` por contrato lexical explícito no `_parse_syntax`.
