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
- `arg listlength listitem cartamount cart Cart itemCard itemCardAmount itemOption itemOptAmount config defined eval exists delete invamount inventory Inventory InventoryType keys monster nick npc player push pop unshift shift random rand shopamount split store storamount storage Storage strip questStatus questInactiveCount questIncompleteCount questCompleteCount values vender venderitem venderItem venderprice venderamount`.

Notas de consistência (PROVADO):
- `listlength` e `listitem` são aceitos como aliases compatíveis no runtime.
- `venderitem` e `venderItem` são aceitos como aliases compatíveis no runtime.
- O catálogo contratual (`19_macro_and_parameter_contracts.json`) cobre 100% das keywords canônicas de `Data.pm` e dos ramos de `Runner::parse_command`.

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
- Cobertura atual do catálogo estruturado: universo completo de keywords canônicas/compatíveis do runtime (47 funções).
