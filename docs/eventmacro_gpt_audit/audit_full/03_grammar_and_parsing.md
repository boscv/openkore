# 03 Grammar and Parsing

## Arquivo eventMacros
- `macro <name> { ... }` abre macro. **PROVADO**.
- `automacro <name> { ... }` abre automacro. **PROVADO**.
- `sub <name> { ... }` abre sub perl. **PROVADO**.
- Comentário de fim de linha (`#...`) removido no parser de arquivo. **PROVADO**.
- Espaços são normalizados (`trim` e colapso de múltiplos espaços). **PROVADO**.

## include/call/sub
- `!include <arquivo>` **NÃO foi comprovado** em `FileParser.pm` como diretiva de parse recursivo nesta revisão.
- Em automacro: `call nomeMacro [args...]` grava em parâmetro `call`. **PROVADO**.
- Em automacro: `call { ... }` gera macro interna `automacro_<name>_call_block`. **PROVADO**.
- `sub` vira código perl compilado em runtime via `eval`, e registrado em `main::`. **PROVADO**.

## Parser de fluxo de macro (Runner)
- Blocos reconhecidos: `if/elsif/else`, `switch/case/else`, `while`, labels `:x`, `goto`. **PROVADO**.
- `[` e `]` ativam/desativam `macro_block` (execução sem esperar timeout entre linhas do bloco). **PROVADO**.
- `if` pós-fixado (`cmd if (...)`) suportado. **PROVADO**.
- `switch` aceita apenas `case` e `else` dentro do bloco. **PROVADO**.

## Erros de parsing/validação que invalidam automacro
- Nome com espaço, sem conditions, sem parameters, sem `call`, parâmetro inválido, módulo de condition inexistente, sintaxe inválida de condition. **PROVADO**.
- Duplicidade de parâmetro, duplicidade de condition única, múltiplas event-type conditions. **PROVADO**.

## Ambiguidades
- Há regex permissivas em `isNewCommandBlock/isNewWrongCommandBlock` (ex.: `else*`), podendo aceitar padrões inesperados. **INFERIDO**.
