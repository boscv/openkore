# 06 GPT Risk Assessment

## Riscos que ainda podem induzir alucinação
- Assumir sem prova que `!include` é sempre diretiva de parse (na prática há suporte runtime de comando `include` e manipulação de linhas em `Core::include`).
- Generalizar comportamento temporal de hooks complexos sem teste integrado.

## Partes robustas
- Catálogo de conditions quanto a existência/tipo state-event/hook.
- Regras de parâmetros de automacro (validação em `Core.pm`).
- Semântica de comparação base (`cmpr` + validators) e negativos principais.

## Recomendações de wording conservador
- Em tudo que envolver comportamento temporal/event-order, usar “NÃO COMPROVADO sem teste de integração”.
- Manter distinção forte entre PROVADO/INFERIDO/NÃO COMPROVADO em arquivos de referência.
