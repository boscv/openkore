# 07 Required Corrections Summary

## Correções aplicadas nesta validação
1. Rebaixamento de claim sobre `!include` de PROVADO para NÃO COMPROVADO (2 arquivos).
2. Correção de contagem `Condition/Base` no inventário.
3. Correção de numeração de título no arquivo `knowledge_ready/15`.
4. Evolução do catálogo JSON: `arg_hint` heurístico substituído por `parser_mode` + `argument_contract` + `evidence`.
5. Tabelas de conditions (`audit_full`/`knowledge_ready`) regeneradas para o novo schema.

## Correções já previamente aplicadas e revalidadas
1. `FileParser::isNewWrongCommandBlock` (`$line`, regex `else`).
2. `Validator::RegexCheck` (`$var_name` para checagem de system var).

## Pendências não-bloqueantes
- Criar testes de integração temporal (hooks/event-order) para elevar de “forense estático” para “forense dinâmico”.
