# 11 Examples Valid

## Automacro state + call
```txt
automacro hp_pot {
  CurrentHP < 40%
  call use_pot
  priority 0
  CheckOnAI auto
}
```
Status: **PROVADO** (lexical COMPLETE: forma positional com whitespace e operador numérico).

## Automacro event + regex
```txt
automacro got_priv {
  PrivMsg /^hi$/i
  call answer_hi
}
```
Status: **REBAIXADO para EXPLAIN_ONLY** (condition `PrivMsg` depende de contrato de parser composto herdado; evitar gerar pronto sem confirmação do contexto).

## Call com parâmetros
```txt
automacro call_args {
  OnCharLogIn any
  call buff_me 123 "abc"
}
```
Status: **PROVADO** (`call` guarda args; execução define `.param`).

## Macro com fluxo
```txt
macro test_flow {
  if ($x == 1) log ok
  while ($x < 3) {
    $x++
  }
}
```
Status: **PROVADO** (`if` pós-fixado e `while` em runner).


## Regra de uso destes exemplos para geração
- Exemplo com condition marcada `EXPLAIN_ONLY` não deve ser emitido como template final automático.
- Use apenas como explicação e peça confirmação de formato/escopo antes de gerar macro pronta.
- Exemplo com condition `GENERATION_SAFE` pode ser usado como base de geração controlada.


## Nota de arquitetura
- Estes exemplos são blocos-base; uma solução completa exige passagem pelo protocolo de síntese e pelo checklist whole-macro antes da entrega final.


## Checagem lexical aplicada aos exemplos
- `CurrentHP < 40%`: separador por whitespace posicional + operador explícito (`<`).
- `PrivMsg /^hi$/i`: regex delimitada; exemplo permanece apenas para EXPLAIN_ONLY, sem geração final automática.
- Nenhum exemplo aqui autoriza trocar whitespace por vírgula sem prova da condition específica.
