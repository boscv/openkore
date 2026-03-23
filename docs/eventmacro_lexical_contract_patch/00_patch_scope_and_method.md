# 00 Patch Scope and Method

## Objetivo
Patch cirúrgico da curadoria existente com foco em contratos lexicais de entrada e formas aceitas/rejeitadas.

## Método aplicado
1. Reuso de `18_condition_catalog.json` como base.
2. Normalização de campos lexicais para TODAS as 118 conditions.
3. Reclassificação de generation safety orientada por `lexical_contract_status`.
4. Atualização pontual de examples e instruções do GPT.

## Status consolidado
- Conditions totais: 118
- Lexical COMPLETE: 57
- Lexical PARTIAL: 61
- Lexical INSUFFICIENT: 0
