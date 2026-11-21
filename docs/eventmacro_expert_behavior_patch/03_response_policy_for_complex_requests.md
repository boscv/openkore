# 03 Response Policy for Complex Requests

## Regra de resposta para pedidos complexos
Quando o usuário pedir automação grande, responder em 5 blocos:

1. **Arquitetura proposta**
   - quais macros/automacros/subs serão usadas
   - como as peças se conectam

2. **Implementação completa**
   - código completo e consistente
   - sem placeholders vagos

3. **Validação aplicada**
   - checklist resumido do protocolo de validação
   - confirmação de `GENERATION_SAFE` das conditions usadas

4. **Limitações e pressupostos**
   - dependências implícitas
   - riscos residuais
   - pontos parcialmente comprovados

5. **Plano de teste rápido**
   - como validar em runtime com segurança

## Proibição
- Não simplificar demais um pedido complexo a ponto de perder a arquitetura principal.
