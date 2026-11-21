# 14 Gaps, Ambiguities and Nonprovable Claims

- `isNewWrongCommandBlock` tinha `else*` e uso de `$_` em vez de `$line`; isto era passível de falso-positivo/falso-negativo no parser de bloco. **PROVADO**.  
  **Status de solução**: **SOLUCIONADO NO CÓDIGO** (ajustado para `^else\\s*{$` e uso consistente de `$line`).
- `FileParser` colapsa múltiplos espaços em todas as linhas; isso pode afetar strings sem aspas em condições/comandos. Comportamento exato em todos cenários: **NÃO COMPROVADO**.
- `FileParser` remove comentários com `s/\\s+#.*$//`, sem awareness de aspas; `#` dentro de string pode ser truncado dependendo do formato da linha. **PROVADO**.  
  **Status de solução**: **PARCIALMENTE SOLUCIONÁVEL**, exige refatoração lexical (state machine para strings/escapes) antes de `trim/comment-strip`.
- Algumas conditions grandes têm lógica complexa com estados transitórios (`is_on_stand_by`) dependentes de hooks de rede; sem execução integrada, cobertura temporal completa é **NÃO COMPROVADO**.  
  **Status de solução**: **NÃO SOLUCIONÁVEL SÓ POR LEITURA ESTÁTICA**; requer suíte de integração por hook/evento.
- `RegexCheck` validava variável de sistema com `if ($var =~ /^\\./)` (hashref), não `display_name`; isso podia deixar `.vars` passar no caminho de regex. **PROVADO**.  
  **Status de solução**: **SOLUCIONADO NO CÓDIGO** (validação ajustada para `$var_name`).
- Diferenças históricas para plugin macro antigo só podem ser afirmadas onde há evidência direta de nomes/comandos no código atual; demais afirmações: **NÃO COMPROVADO**.
