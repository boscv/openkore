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

## Subrotinas perl
- Subs registradas por bloco `sub` podem ser chamadas como `nomeSub(...)` no parser de comando. **PROVADO**.
- Se sub inexistente: erro.
- Pode retornar scalar/ref array/ref hash, com tratamento específico no parser. **PROVADO**.

## Funções internas de comparação
- `cmpr` suporta operadores: `= == != > < >= <= ~ =~`. **PROVADO**.
- Regex literal somente formato `/.../` com opcional `i`. **PROVADO**.
- Range com `..` suportado para igualdade/inequidade. **PROVADO**.
