# 00 Audit Scope and Method

## Escopo
- **PROVADO**: A auditoria usa exclusivamente código-fonte local do repositório (`plugins/eventMacro/...`).
- **PROVADO**: Sem wiki/documentação externa como fonte de verdade.
- **PROVADO**: Foco em parser, gramática, validação, runtime, variáveis, comandos e todas as conditions.

## Método (9 passagens)
1. Inventário de arquivos (parser/core/runner/conditions/validators/comandos).
2. Extração canônica de gramática, parâmetros, operadores, funções e variáveis.
3. Normalização por condition (catálogo JSON + tabela consolidada).
4. Auditoria profunda de parser (`FileParser.pm`, `Runner.pm`).
5. Auditoria de comparação/range/regex (`Utilities.pm`, `Validator/*`).
6. Auditoria de variáveis/tipagem/callbacks (`Data.pm`, `Utilities.pm`, `Core.pm`).
7. Auditoria de runtime/fila/prioridade/pause/orphan (`Core.pm`, `Automacro.pm`, `Runner.pm`).
8. Catálogo de negativos e não-suportado.
9. Produção em dois níveis: `audit_full/` e `knowledge_ready/`.

## Regras de classificação de conclusões
- **PROVADO**: comportamento explícito no código.
- **INFERIDO**: dedução estrutural (ex.: por herança/base class).
- **NÃO COMPROVADO**: não há evidência suficiente no código auditado.
