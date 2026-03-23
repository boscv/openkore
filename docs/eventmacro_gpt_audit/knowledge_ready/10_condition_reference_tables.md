# 10 Condition Reference Tables

- Total conditions: 118 (PROVADO)
- State: 86 (PROVADO)
- Event: 32 (PROVADO)

## Parser mode
- composite_regex_numeric: 63
- csv_list: 7
- numeric_comparison: 29
- regex_literal: 18
- simple_event: 1

## Nota de precisão
- `parser_mode` e `argument_contract` são PROVADO nas famílias resolvidas por herança e por uso explícito de validators; em `custom`, parte da tipagem continua INFERIDO e deve ser checada no módulo da condition.
