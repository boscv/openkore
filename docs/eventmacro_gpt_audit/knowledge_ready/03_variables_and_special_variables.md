# 05 Variables and Special Variables

## Sintaxe de variáveis
- Escalar: `$name`
- Array: `@name`
- Hash: `%name`
- Acesso array: `$name[index]` (index numérico ou variável resolvível)
- Acesso hash: `$name{key}` (key alfanumérico/underscore ou variável resolvível)

Status: **PROVADO**.

## Regex-base de nomes
- Nomes válidos: `\.?[a-zA-Z][a-zA-Z\d_]*`. **PROVADO**.
- Complementos em parse amplo: índices/chaves dinâmicos aceitos em regex mais ampla. **PROVADO**.

## Variáveis especiais `.xxx`
Exemplos implementados em `Core::get_scalar_var`:
- tempo: `.time .datetime .hour ...`
- mapa: `.map .incity .inlockmap`
- personagem: `.job .pos .name .hp .sp .lvl .joblvl .spirits .zeny .weight ...`
- status: `.status .statushandle`
- inventário/carrinho/storage: `.inventoryitems .cart* .shopopen .storage*`

Status: **PROVADO**.

## Restrições
- Definição manual de variáveis de sistema (prefixo `.`) é bloqueada em `var_set` e em atribuição de macro runner. **PROVADO**.
- Validadores de conditions geralmente rejeitam variáveis de sistema como argumento de automacro. **PROVADO**.

## Callbacks de mudança
- `Core` dispara callbacks por tipo (`scalar`, `array`, `hash`, `accessed_array`, `accessed_hash`) e gerencia complementos dinâmicos para acessos aninhados via variáveis. **PROVADO**.

## Arrays e hashes completos
- `set_full_array`, `set_full_hash`, `clear_array`, `clear_hash`, `push/pop/shift/unshift`, `delete_key`, `exists_hash`, `keys`, `values`. **PROVADO**.
