# 09 Files Changed and Why

## Arquivos da curadoria alterados
1. `docs/eventmacro_gpt_audit/audit_full/03_grammar_and_parsing.md`
   - Motivo: corrigir claim não comprovado sobre `!include` parse recursivo.

2. `docs/eventmacro_gpt_audit/knowledge_ready/02_grammar_and_parsing.md`
   - Motivo: mesma correção da versão consolidada.

3. `docs/eventmacro_gpt_audit/audit_full/01_file_inventory.md`
   - Motivo: corrigir contagem de módulos em `Condition/Base`.

4. `docs/eventmacro_gpt_audit/knowledge_ready/15_gpt_system_instructions_draft.md`
   - Motivo: corrigir título interno/número do arquivo.

5. `docs/eventmacro_gpt_audit/tools/extract_condition_catalog.py`
   - Motivo: evoluir o catálogo para `parser_mode` + `argument_contract` (reduzir heurística antiga).

6. `docs/eventmacro_gpt_audit/audit_full/09_condition_catalog.json`
   - Motivo: regenerado com schema mais forte (evidências + contrato de argumento).

7. `docs/eventmacro_gpt_audit/knowledge_ready/17_condition_catalog.json`
   - Motivo: sincronização com o catálogo canônico regenerado.

8. `docs/eventmacro_gpt_audit/audit_full/08_condition_catalog.md`
   - Motivo: tabela atualizada para o novo schema (regex/range/csv/var por condition).

9. `docs/eventmacro_gpt_audit/knowledge_ready/07_conditions_state_part_1.md`
10. `docs/eventmacro_gpt_audit/knowledge_ready/08_conditions_state_part_2.md`
11. `docs/eventmacro_gpt_audit/knowledge_ready/09_conditions_event.md`
12. `docs/eventmacro_gpt_audit/knowledge_ready/10_condition_reference_tables.md`
   - Motivo: remover dependência de `arg_hint` e adotar `parser_mode`/`argument_contract`.

## Arquivos de validação criados
- `docs/eventmacro_gpt_validation/00..09` conforme solicitado.
- `docs/eventmacro_gpt_validation/tools/validate_curation.py` para gerar `_validation_data.json` de forma reproduzível.
- `docs/eventmacro_gpt_validation/tools/validate_curation.py` foi ampliado para validar também:
  - tabelas markdown (`07/08/09`) vs catálogo JSON;
  - `16_upload_manifest.md` vs arquivos reais de `knowledge_ready`.
