# 10 Invalid Syntax and Negative Catalog

- Automacro sem conditions/parameters/call: rejeitado. **PROVADO**.
- Duplicidade de automacro/macro: rejeitado. **PROVADO**.
- Mais de 1 event condition no mesmo automacro: rejeitado. **PROVADO**.
- Condition única duplicada: rejeitado. **PROVADO**.
- Nome com espaço (macro/automacro): rejeitado. **PROVADO**.
- `set` com parâmetro desconhecido: erro em runtime macro. **PROVADO**.
- `do eventMacro ...` e `do ai clear`: proibidos. **PROVADO**.
- `defined()` em array/hash sem acesso (`@a`/`%h`) é inválido (aceita escalar, `$a[i]`, `$h{k}`). **PROVADO**.
- Índice de array não numérico e chave de hash inválida após parse dinâmico: erro. **PROVADO**.
- Uso de variáveis sistema (`.x`) em diversas conditions/validators: bloqueado. **PROVADO**.
- Regex malformada em validação (`RegexCheck`) ou statement (`parse_and_check_condition_text`): erro. **PROVADO**.
- Misturar `&&` e `||` sem estrutura válida de grupos: erro. **PROVADO**.

## Itens potencialmente alucináveis
- `~` não é regex; em `cmpr` é membership CSV case-insensitive. **PROVADO**.
- Range é `a..b` dentro de comparação; não é operador genérico separado. **PROVADO**.
- Event conditions não substituem state queueing; semântica é diferente. **PROVADO**.

## Mitigações práticas para GPT especialista
- Sempre mapear operador para backend real: `Utilities::cmpr` + `Validator::*` antes de sugerir sintaxe. **PROVADO**.
- Bloquear resposta que proponha >1 event condition por automacro. **PROVADO**.
- Separar resposta em “state condition” vs “event condition” com semântica de fila/disparo distinta. **PROVADO**.
- Se comparar com macro plugin antigo sem evidência local, marcar **NÃO COMPROVADO**. **PROVADO**.
