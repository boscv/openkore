# 12 Examples Invalid

## Dois event-type na mesma automacro
```txt
automacro bad {
  OnCharLogIn any
  AttackStart poring
  call foo
}
```
Resultado: automacro ignorada. **PROVADO**.

## Parâmetro inválido
```txt
automacro bad2 {
  InMap prontera
  call foo
  run-once maybe
}
```
Resultado: automacro ignorada. **PROVADO**.

## Índice de array inválido dinâmico
```txt
$idx = "abc"
$x = $arr[$idx]
```
Resultado: erro (índice array deve numérico após parse). **PROVADO**.

## `defined` em tipo não suportado
```txt
if (&defined(@arr)) { log x }
```
Resultado: erro (defined só escalar/acesso array/acesso hash). **PROVADO**.


## Separador inválido (vírgula no lugar de whitespace posicional)
```txt
automacro bad_sep {
  CurrentHP,<,40%
  call foo
}
```
Resultado: forma lexical não comprovada/esperada para comparação numérica; tratar como inválida para geração. **PROVADO como regra de curadoria lexical**.
