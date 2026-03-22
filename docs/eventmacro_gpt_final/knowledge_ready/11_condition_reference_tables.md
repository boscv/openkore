# 10 Condition Reference Tables

- Total conditions: 118 (PROVADO)
- State: 86 (PROVADO)
- Event: 32 (PROVADO)

## Parser mode
- composite_regex_numeric: 63
- csv_list: 7
- numeric_comparison: 29
- regex_literal: 18
- simple_event: 1

## Nota de precisão
- `parser_mode` e `argument_contract` são PROVADO nas famílias resolvidas por herança e por uso explícito de validators; em `custom`, parte da tipagem continua INFERIDO e deve ser checada no módulo da condition.


## Camada de segurança de geração (obrigatória)
- O catálogo JSON (`18_condition_catalog.json`) agora inclui, para cada condition:
  - `generation_safety`: `GENERATION_SAFE` | `EXPLAIN_ONLY` | `UNSAFE`
  - `generation_safety_reason`
  - `generation_policy.can_generate_ready_syntax`
- Regra operacional:
  - `GENERATION_SAFE`: pode gerar sintaxe pronta
  - `EXPLAIN_ONLY`: explicar e pedir confirmação/contexto; não gerar sintaxe final automaticamente
  - `UNSAFE`: não gerar sintaxe; limitar resposta ao comprovado

## Resumo atual de status (catálogo final)
- `GENERATION_SAFE`: 109
- `EXPLAIN_ONLY`: 9
- `UNSAFE`: 0

Condições `EXPLAIN_ONLY` atuais:
- `GuildMsgName`, `NpcMsgName`, `PartyMsgName`, `PrivMsgName`, `PubMsgName`
- `NoMobNear`, `NoNpcNear`, `NoPlayerNear`, `NoPortalNear`


## Uso em criação de macro completa
- Esta tabela/catálogo não serve só para explicar conditions: serve para decidir se uma condition pode entrar na solução final gerada.
- Regra: versão final entregue ao usuário deve conter somente conditions `GENERATION_SAFE`.
- Se qualquer condition da arquitetura for `EXPLAIN_ONLY` ou `UNSAFE`, mudar para modo de proposta controlada (sem template final "pronto").
