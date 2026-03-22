# 00 Validation Scope and Method

## Escopo validado
- Código-fonte real: `plugins/eventMacro/eventMacro*` e `plugins/eventMacro/eventMacro/Condition/**`.
- Curadoria anterior:
  - `docs/eventmacro_gpt_audit/audit_full/**`
  - `docs/eventmacro_gpt_audit/knowledge_ready/**`
  - `docs/eventmacro_gpt_audit/tools/**`

## Método
- **A) Factual**: checagem contra source (parser/runtime/validators/conditions).
- **B) Estrutural**: checagem de consistência entre os próprios artefatos da curadoria.
- Automação usada:
  - `tools/validate_curation.py` para comparar catálogo JSON vs módulos reais de conditions (existência, tipo state/event por herança, hooks declarados), validar schema mínimo e validar orçamento de upload (`knowledge_ready <= 20`).
- Classificação de evidência:
  - **PROVADO**: suportado diretamente por código.
  - **INFERIDO**: derivado por herança/estrutura.
  - **NÃO COMPROVADO**: não demonstrável de forma segura pelo source observado.

## Critério de severidade
- **CRÍTICO**: conhecimento falso perigoso para GPT público.
- **ALTO**: divergência factual relevante e localizada.
- **MÉDIO**: imprecisão/ambiguidade/overclaim.
- **BAIXO**: organização/wording/numeração.
