# 17 Upload Manifest (Final)

## Lista exata de arquivos recomendados para upload (ordem sugerida)
1. `00_scope_rules_and_usage.md` — escopo, regras de confiança e uso do pacote.
2. `01_architecture_and_runtime.md` — visão de arquitetura e execução.
3. `02_grammar_and_parsing.md` — gramática e parsing de macros/automacros.
4. `03_variables_and_special_variables.md` — variáveis e especiais.
5. `04_operators_regex_ranges_and_comparisons.md` — operadores/comparações/regex/ranges.
6. `05_console_commands.md` — comandos `eventMacro`/`emacro`.
7. `06_macro_keywords_and_functions.md` — keywords e funções de macro.
8. `07_automacro_parameters.md` — parâmetros de automacro.
9. `08_conditions_state_part_1.md` — conditions de estado (parte 1).
10. `09_conditions_state_part_2.md` — conditions de estado (parte 2).
11. `10_conditions_event.md` — conditions de evento.
12. `11_condition_reference_tables.md` — tabelas de referência rápida.
13. `12_invalid_syntax_and_negative_catalog.md` — catálogo de inválidos/negativos.
14. `13_examples_valid.md` — exemplos válidos selecionados.
15. `14_examples_invalid.md` — exemplos inválidos selecionados.
16. `15_ambiguities_and_nonprovable_claims.md` — ambiguidades e não comprovados.
17. `16_gpt_system_instructions_final.md` — instruções operacionais do GPT.
18. `17_upload_manifest.md` — este manifesto.
19. `18_condition_catalog.json` — catálogo completo de conditions para lookup estruturado.

## Contagem
- Total: **19 arquivos**.
- Confirmação: **não ultrapassa 20 arquivos**.

## Mais importantes (núcleo mínimo)
- `02_grammar_and_parsing.md`
- `03_variables_and_special_variables.md`
- `04_operators_regex_ranges_and_comparisons.md`
- `07_automacro_parameters.md`
- `08_conditions_state_part_1.md`
- `09_conditions_state_part_2.md`
- `10_conditions_event.md`
- `12_invalid_syntax_and_negative_catalog.md`
- `16_gpt_system_instructions_final.md`
- `18_condition_catalog.json`

## Opcionais para versão ainda mais compacta
- `13_examples_valid.md`
- `14_examples_invalid.md`
- `11_condition_reference_tables.md` (se `18_condition_catalog.json` for mantido)
- `17_upload_manifest.md` (apenas após upload concluído)


## Gate pré-upload (obrigatório)
- Executar: `python3 docs/eventmacro_gpt_final/support/validate_final_package.py`.
- Só subir o pacote se o script retornar `OK: final package validated`.
- Em caso de falha, corrigir antes de qualquer upload para evitar perda de cobertura crítica.

- Executar também: `python3 docs/eventmacro_gpt_final/support/validate_lexical_contracts.py`.
- Só subir o pacote se ambos os gates (pacote + lexical) retornarem OK.
