# 01 Inventory of Audited Outputs

## Pasta de curadoria anterior encontrada
- `docs/eventmacro_gpt_audit/audit_full/` (15 arquivos)
- `docs/eventmacro_gpt_audit/knowledge_ready/` (18 arquivos)
- `docs/eventmacro_gpt_audit/tools/` (1 arquivo)

## Arquivos centrais (curadoria)
- spec/gramática/runtime/variáveis/parâmetros/conditions/negativos:
  - `02_eventmacro_canonical_spec.md`
  - `03_grammar_and_parsing.md`
  - `04_commands_and_runtime.md`
  - `05_variables_and_special_variables.md`
  - `07_automacro_parameters.md`
  - `08_condition_catalog.md`
  - `09_condition_catalog.json`
  - `10_invalid_syntax_and_negative_catalog.md`

## Arquivos auxiliares
- exemplos, gaps, draft de system instructions, manifest, e script de extração.
- validação reproduzível: `docs/eventmacro_gpt_validation/tools/validate_curation.py`.

## Inventário do código real (eventMacro)
- parser: `FileParser.pm`
- runtime/core: `Core.pm`, `Runner.pm`, `Automacro.pm`, `Macro.pm`
- dados/variáveis/utilitários: `Data.pm`, `Utilities.pm`, `Lists.pm`
- validação: `Validator/*.pm`
- conditions:
  - `Condition/*.pm` (118)
  - `Condition/Base/*.pm` (13)
  - `Conditiontypes/*.pm` (7)

## Cobertura
- Nenhum módulo de condition real ficou fora do catálogo JSON (118/118).
