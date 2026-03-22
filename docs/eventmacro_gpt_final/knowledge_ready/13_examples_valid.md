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
Status: **PROVADO** (numeric validator aceita `%`, operador `<`, call obrigatório).

## Automacro event + regex
```txt
automacro got_priv {
  PrivMsg /^hi$/i
  call answer_hi
}
```
Status: **PROVADO** (RegexConditionEvent).

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
