# 08 Final Upload Recommendation

## Resultado do patch lexical
- Curadoria foi corrigida por patch (não reautoria total).
- `knowledge_ready` foi preservado com 19 arquivos (<=20).
- Camada lexical agora impede geração por plausibilidade de separador/forma.

## Recomendação operacional
1. Rodar `python3 docs/eventmacro_gpt_final/support/validate_final_package.py`
2. Conferir no catálogo os campos lexicais antes de gerar conditions.
3. Tratar PARTIAL/INSUFFICIENT como bloqueio de geração pronta.
