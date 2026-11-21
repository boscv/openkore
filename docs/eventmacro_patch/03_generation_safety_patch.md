# 03 Generation Safety Patch

## Implementação
A camada de segurança foi adicionada diretamente em `docs/eventmacro_gpt_final/knowledge_ready/18_condition_catalog.json` com os campos:
- `generation_safety`
- `generation_safety_reason`
- `generation_policy`

## Status final
- `GENERATION_SAFE`: 109
- `EXPLAIN_ONLY`: 9
- `UNSAFE`: 0

## Conditions rebaixadas para EXPLAIN_ONLY
- `GuildMsgName` (composite_regex_numeric)
- `NoMobNear` (composite_regex_numeric)
- `NoNpcNear` (composite_regex_numeric)
- `NoPlayerNear` (composite_regex_numeric)
- `NoPortalNear` (composite_regex_numeric)
- `NpcMsgName` (composite_regex_numeric)
- `PartyMsgName` (composite_regex_numeric)
- `PrivMsgName` (composite_regex_numeric)
- `PubMsgName` (composite_regex_numeric)

## Critério usado
- Onde o contrato permaneceu parcialmente implícito para geração pronta (ex.: parser composto herdado sem fechamento sintático local), aplicar `EXPLAIN_ONLY`.
