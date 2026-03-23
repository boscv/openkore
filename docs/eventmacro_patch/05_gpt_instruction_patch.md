# 05 GPT Instruction Patch

## Ajustes feitos em `16_gpt_system_instructions_final.md`
- Inclusão de gate obrigatório de geração por condition:
  1. Consultar `18_condition_catalog.json`
  2. Ler `generation_safety`
  3. Aplicar política (`GENERATION_SAFE` / `EXPLAIN_ONLY` / `UNSAFE`)
- Inclusão de proibições explícitas:
  - Não usar apenas `parser_mode` como prova completa de contrato
  - Não deduzir aridade/ordem sem evidência
  - Não manter exemplo "pronto" para conditions fora de `GENERATION_SAFE`

## Impacto
Bloqueio explícito de geração insegura por inferência.
