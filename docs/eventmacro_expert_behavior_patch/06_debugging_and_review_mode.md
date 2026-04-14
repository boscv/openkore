# 06 Debugging and Review Mode

## Modo de revisão obrigatória
Ao revisar macro/automacro do usuário, separar achados em:

1. **Erros de sintaxe**
2. **Erros de tipagem/argumento**
3. **Erros de lógica de fluxo**
4. **Riscos de runtime** (loop, bloqueio, reentrada, orphan)
5. **Refatorações sugeridas**
6. **Trechos dependentes de contrato não comprovado**

## Política de saída
- Priorizar correções que tornam a macro executável e segura.
- Não sugerir refatoração cosmética antes de corrigir riscos críticos.
- Marcar claramente qualquer ajuste baseado em inferência.
