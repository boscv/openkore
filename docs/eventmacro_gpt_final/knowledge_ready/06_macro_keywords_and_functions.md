# 06 Macro Keywords and Functions

## Macro keywords (`&keyword(...)`)
Base em `Data.pm` + execução em `Runner::parse_command`.

Principais suportados (PROVADO):
- lookup/ids: `npc player monster vender inventory Inventory InventoryType cart Cart storage Storage`
- quantidades/preços: `invamount cartamount shopamount storamount venderamount venderprice`
- utilitários: `arg random rand split strip config`
- hash/array: `keys values push pop shift unshift exists delete defined`
- quest: `questStatus questInactiveCount questIncompleteCount questCompleteCount`
- equipamento: `itemCard itemCardAmount itemOption itemOptAmount`
- `eval` (bloqueado por lockdown global)

Inventário canônico em `Data.pm` (lista completa da regex de reconhecimento):
- `arg listlength cartamount cart Cart itemCard itemCardAmount itemOption itemOptAmount config defined eval exists delete invamount inventory Inventory InventoryType keys monster nick npc player push pop unshift shift random rand shopamount split store storamount storage Storage strip questStatus questInactiveCount questIncompleteCount questCompleteCount values vender venderitem venderprice venderamount`.

Notas de consistência (PROVADO):
- Existe divergência entre `Data.pm` e `Runner::parse_command` para `listlength`/`listitem`.
  - `Data.pm` lista `listlength`.
  - `Runner::parse_command` tem ramo `listitem`.
- Existe ramo `venderItem` (camelCase) no `Runner`, enquanto o canônico em `Data.pm` é `venderitem` (lowercase).
- Para geração segura, tratar como canônicas as formas reconhecidas por `Data.pm` e considerar os desvios acima como inconsistências de runtime.

## Subrotinas perl
- Subs registradas por bloco `sub` podem ser chamadas como `nomeSub(...)` no parser de comando. **PROVADO**.
- Se sub inexistente: erro.
- Pode retornar scalar/ref array/ref hash, com tratamento específico no parser. **PROVADO**.

## Funções internas de comparação
- `cmpr` suporta operadores: `= == != > < >= <= ~ =~`. **PROVADO**.
- Regex literal somente formato `/.../` com opcional `i`. **PROVADO**.
- Range com `..` suportado para igualdade/inequidade. **PROVADO**.


## Contratos lexicais estruturados
- Fonte estruturada complementar: `19_macro_and_parameter_contracts.json` (`macro_functions`).
- Regra de geração: só usar forma pronta quando `lexical_contract_status == COMPLETE`.
- Se `PARTIAL`, explicar e pedir confirmação antes de gerar chamada final.
- Cobertura atual do catálogo estruturado: subconjunto contratado para geração guiada (41 funções), não o universo completo de keywords de `Data.pm`.
