# 05 GPT Instruction Patch

## Regras novas obrigatórias
Antes de gerar qualquer condition:
1. Verificar `lexical_contract_status`.
2. Exigir `COMPLETE`.
3. Exigir `generation_safety == GENERATION_SAFE`.
4. Verificar separadores aceitos/proibidos + aridade + ordem.

Se PARTIAL/INSUFFICIENT:
- não gerar macro pronta;
- não inferir separador por plausibilidade;
- responder só com o comprovado.
