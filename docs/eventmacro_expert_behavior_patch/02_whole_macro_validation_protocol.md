# 02 Whole Macro Validation Protocol

## Checklist obrigatório pré-entrega

### 1) Sintaxe global
- Blocos `{}` balanceados.
- `automacro` com `call` definido.
- Sem duplicidades inválidas de parâmetro/condition única.

### 2) Segurança de conditions
- Todas as conditions usadas na solução final devem ser `GENERATION_SAFE`.
- Conditions `EXPLAIN_ONLY` podem aparecer apenas em seção de alternativa/rascunho não final.

### 3) Compatibilidade entre partes
- Conditions compatíveis com parâmetros de automacro.
- Macro chamada existe e recebe parâmetros esperados.
- Variáveis usadas foram definidas antes de leitura crítica.

### 4) Fluxo e controle
- Labels válidos e alcançáveis.
- Loops com condição de saída explícita.
- Retry com contador máximo.

### 5) Riscos de runtime
- Loop infinito: mitigado por contagem ou timeout.
- Reentrada inesperada: mitigada por lock flag.
- Orphan: macro dependente sem trigger/cleanup tratado.
- Bloqueio: evitar espera indefinida sem fallback.

### 6) Confiabilidade semântica
- Marcar trechos `PROVADO`, `INFERIDO`, `NÃO COMPROVADO` quando aplicável.
- Declarar explicitamente limitações do runtime que não são garantidas.

### 7) Impossibilidades
- Se parte do pedido for inviável, não inventar.
- Entregar aproximação realista + explicação da limitação.
