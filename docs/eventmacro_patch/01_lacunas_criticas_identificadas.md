# 01 Lacunas Críticas Identificadas

## Lacunas encontradas
1. Ausência de camada explícita de segurança de geração por condition no catálogo final.
2. Risco de interpretar `parser_mode` como prova suficiente de aridade/ordem/separadores.
3. Exemplo válido com `PrivMsg` marcado como pronto, apesar de contrato parcial para geração automática.
4. Instruções do GPT sem gate obrigatório de consulta de `generation_safety` antes de gerar.

## Impacto
- O GPT podia explicar bem, mas ainda gerar sintaxe pronta em casos que deveriam ficar em modo conservador (`EXPLAIN_ONLY`).

## Correção aplicada
- Inclusão de campos de segurança por condition no JSON final.
- Rebaixamento explícito de conditions com contrato parcial para `EXPLAIN_ONLY`.
- Ajuste de exemplo e instruções para impedir geração pronta sem evidência suficiente.
