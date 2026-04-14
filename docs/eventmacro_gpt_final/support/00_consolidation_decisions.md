# 00 Consolidation Decisions

## Decisões principais
1. Base consolidada partiu do conjunto `docs/eventmacro_gpt_audit/knowledge_ready` por já estar validado e dentro do budget.
2. Foi criado um pacote final dedicado em `docs/eventmacro_gpt_final/knowledge_ready` para separar material de upload de material de auditoria/validação.
3. Mantivemos `state` e `event` separados para consulta rápida e menor confusão semântica.
4. Mantivemos `examples_valid` e `examples_invalid` separados para treinamento de revisão de código.
5. Mantivemos `condition_catalog.json` para lookup estruturado por GPT, com referência markdown curta (`11_condition_reference_tables.md`).
6. Criamos arquivo dedicado de operadores/comparações/regex/ranges (`04_...`) para reduzir dispersão de regras.
7. Criamos instruções finais do GPT (`16_...`) com regras anti-alucinação explícitas e classificação de confiança.

## Resultado
- Pacote final com 19 arquivos (<=20), autoexplicativo e pronto para upload.
