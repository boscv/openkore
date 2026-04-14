# 00 Patch Scope and Method

## Objetivo
Aplicar correções cirúrgicas na curadoria existente do `eventMacro` para endurecer segurança de geração sem reautoria total.

## Escopo aplicado
- Reuso da estrutura já existente em `docs/eventmacro_gpt_final/knowledge_ready/`.
- Revisão de lacunas críticas de contrato de conditions com base no catálogo já extraído do código.
- Inclusão de camada explícita de `generation_safety` por condition no catálogo JSON final.
- Ajustes pontuais em arquivos de referência, exemplos e instruções do GPT.

## Método
1. Inventário dos artefatos existentes (`audit_full`, `knowledge_ready`, `final`, `validation`).
2. Leitura dos campos de contrato no `18_condition_catalog.json` (parser_mode, argument_contract, syntax_regex_fragments, evidence).
3. Classificação conservadora por condition em:
   - `GENERATION_SAFE`
   - `EXPLAIN_ONLY`
   - `UNSAFE`
4. Patch minimalista: só arquivos necessários para bloquear geração insegura.

## Regra de evidência
Quando o contrato não está explicitamente fechado para geração (especialmente parser herdado sem fragmento sintático local), rebaixar para `EXPLAIN_ONLY`.
