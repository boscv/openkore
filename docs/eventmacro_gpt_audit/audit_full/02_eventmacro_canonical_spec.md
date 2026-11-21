# 02 EventMacro Canonical Spec

## Conceitos
- **macro**: bloco executável com linhas de comando (`macro <name> { ... }`). **PROVADO**.
- **automacro**: bloco declarativo com parâmetros + conditions que dispara `call`. **PROVADO**.
- **sub**: bloco perl registrado dinamicamente (`sub <name> { ... }`). **PROVADO**.

## Tipos de condition
- **state condition**: mantém estado (`is_fulfilled`) e participa da fila de automacros. **PROVADO**.
- **event condition**: valida apenas no evento; não mantém estado persistente igual state para fila contínua. **PROVADO**.
- Restrição: no máximo **1 event-type condition por automacro**. **PROVADO**.

## Parâmetros de automacro suportados
`timeout, delay, run-once, disabled, call, overrideAI, orphan, macro_delay, priority, exclusive, self_interruptible, repeat, CheckOnAI`. **PROVADO**.

## Restrições de automacro
- Nome sem espaços. **PROVADO**.
- Requer conditions e parameters, e parâmetro `call` válido. **PROVADO**.
- Parâmetro duplicado rejeita automacro. **PROVADO**.
- Condition única (quando módulo define `is_unique_condition`) não pode repetir no mesmo automacro. **PROVADO**.

## Operadores e comparações
- Numérico/texto/lista/regex em `Utilities::cmpr`. **PROVADO**.
- Range `a..b` suportado para igualdade/inequidade (`==`, `=`, `!=`, `=~`, `~` no `cmpr`). **PROVADO**.
- Regex literal `/.../i?` suportado. **PROVADO**.
- Lista CSV com `~` (membro em lista, case-insensitive no `cmpr`). **PROVADO**.

## Variáveis
- Tipos: scalar `$`, array `@`, hash `%`, acessos `$a[i]`, `$h{k}`. **PROVADO**.
- Variáveis de sistema iniciando com `.` existem (somente leitura para set manual/assign). **PROVADO**.
- Uso de variáveis de sistema em automacro conditions geralmente bloqueado pelos validadores. **PROVADO**.

## NÃO SUPORTADO (núcleo)
- Mais de uma event condition por automacro. **PROVADO**.
- `eventMacro` dentro de `do ...` em macro script. **PROVADO**.
- `do ai clear` em macro script. **PROVADO**.
- Misturar `&&` e `||` sem agrupamento apropriado em statement. **PROVADO** (erro em `resolve_multi...`).
