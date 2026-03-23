# 05 Internal Contradictions

## Contradições encontradas
1. `knowledge_ready/15_gpt_system_instructions_draft.md` com título interno incorreto (`# 14`).
   - Severidade: BAIXO
   - Status: corrigido.

2. `audit_full/01_file_inventory.md` com contagem `Condition/Base` divergente da listagem.
   - Severidade: BAIXO
   - Status: corrigido.

3. Claim de `!include` como parse recursivo PROVADO em gramática (audit_full + knowledge_ready).
   - Severidade: ALTO
   - Status: corrigido para “NÃO COMPROVADO”.

## Consistência JSON vs Markdown
- `09_condition_catalog.json` alinhado com existência/tipo/hook dos módulos reais.
- Sem divergência factual crítica encontrada entre JSON e matriz automática.
