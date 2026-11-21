# 02 Source vs Curation Mismatches

## Mismatch 01
- **Severidade**: ALTO
- **Arquivo da curadoria**: `docs/eventmacro_gpt_audit/audit_full/03_grammar_and_parsing.md` (e equivalente knowledge)
- **Trecho problemático**: claim de que `!include` é parseado recursivamente por `parseMacroFile` como PROVADO.
- **Fonte real**:
  - `plugins/eventMacro/eventMacro/FileParser.pm` (sem parser explícito de diretiva `!include`)
  - `plugins/eventMacro/eventMacro/Runner.pm` (`include` como comando de macro runtime)
  - `plugins/eventMacro/eventMacro/Core.pm` (`include` para toggle/list de linhas `!include` no arquivo)
- **Classificação**: PROVADO (que o claim anterior era overclaim)
- **Correção aplicada**: rebaixado para “NÃO COMPROVADO” em ambos os arquivos de gramática.

## Mismatch 02
- **Severidade**: BAIXO
- **Arquivo da curadoria**: `docs/eventmacro_gpt_audit/audit_full/01_file_inventory.md`
- **Trecho problemático**: contagem `Condition/Base` estava 11, lista contém 13.
- **Fonte real**: `plugins/eventMacro/eventMacro/Condition/Base/*.pm`
- **Classificação**: PROVADO
- **Correção aplicada**: contagem corrigida para 13.

## Mismatch 03
- **Severidade**: BAIXO
- **Arquivo da curadoria**: `docs/eventmacro_gpt_audit/knowledge_ready/15_gpt_system_instructions_draft.md`
- **Trecho problemático**: título interno estava `# 14 ...`.
- **Classificação**: PROVADO
- **Correção aplicada**: título alinhado para `# 15 ...`.

## Observações de edge cases já corrigidos no source
- `FileParser::isNewWrongCommandBlock`: uso de `$line` + ajuste regex `else`.
- `Validator::RegexCheck`: validação de variável de sistema por `$var_name`.
