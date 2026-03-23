# 07 Files Changed and Why

## Arquivos existentes alterados
1. `docs/eventmacro_gpt_final/knowledge_ready/18_condition_catalog.json`
   - Inclusão de campos de contrato lexical e reclassificação de generation safety.
2. `docs/eventmacro_gpt_final/knowledge_ready/11_condition_reference_tables.md`
   - Regra explícita: gerar apenas com lexical COMPLETE + GENERATION_SAFE.
3. `docs/eventmacro_gpt_final/knowledge_ready/13_examples_valid.md`
   - Reforço de validação lexical em exemplos válidos.
4. `docs/eventmacro_gpt_final/knowledge_ready/14_examples_invalid.md`
   - Adição de exemplo inválido por separador incorreto.
5. `docs/eventmacro_gpt_final/knowledge_ready/16_gpt_system_instructions_final.md`
   - Gate lexical obrigatório antes de gerar conditions.
6. `docs/eventmacro_gpt_final/knowledge_ready/17_upload_manifest.md`
   - Gate lexical adicional no checklist pré-upload.
7. `docs/eventmacro_gpt_final/support/validate_lexical_contracts.py`
   - Validação automática de completude lexical para evitar erro de separador/forma.

## Novos arquivos de patch
- `docs/eventmacro_lexical_contract_patch/00_patch_scope_and_method.md`
- `docs/eventmacro_lexical_contract_patch/01_lexical_contract_failures_found.md`
- `docs/eventmacro_lexical_contract_patch/02_condition_lexical_contract_patch.json`
- `docs/eventmacro_lexical_contract_patch/03_generation_safety_reclassification.md`
- `docs/eventmacro_lexical_contract_patch/04_examples_revalidated_for_delimiters.md`
- `docs/eventmacro_lexical_contract_patch/05_gpt_instruction_patch.md`
- `docs/eventmacro_lexical_contract_patch/06_conditions_requiring_delimiter_attention.md`
- `docs/eventmacro_lexical_contract_patch/07_files_changed_and_why.md`
- `docs/eventmacro_lexical_contract_patch/08_final_upload_recommendation.md`
