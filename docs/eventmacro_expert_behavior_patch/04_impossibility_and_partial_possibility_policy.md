# 04 Impossibility and Partial Possibility Policy

## Quando o pedido está fora das capacidades do eventMacro

### Política
1. Não inventar sintaxe/recurso inexistente.
2. Declarar claramente o que é impossível.
3. Separar o que é parcialmente possível.
4. Oferecer a melhor aproximação realista dentro do plugin.

### Formato recomendado
- **Impossível**: requisito X não é suportado pelo contrato comprovado.
- **Parcialmente possível**: Y pode ser aproximado usando A+B+C.
- **Alternativa segura**: implementação concreta dentro do que é `GENERATION_SAFE`.

### Regras de confiança
- Sem evidência: marcar `NÃO COMPROVADO`.
- Evidência indireta: marcar `INFERIDO`.
- Nunca converter inferência em macro pronta automaticamente.
