# 08 Examples of Full Macro Design

## Exemplo A — Arquitetura trigger + execução + fallback

### Arquitetura
- `automacro`: detecta gatilho seguro.
- `macro principal`: executa ação.
- `macro fallback`: recupera em falha.

### Implementação (esqueleto)
```txt
automacro am_main {
  CurrentHP < 40%
  call do_main
  timeout 1
}

macro do_main {
  if ($.state_lock == 1) stop
  $.state_lock = 1
  # ação principal
  if ($.retry_count > 2) call do_fallback
  $.state_lock = 0
}

macro do_fallback {
  # ação de recuperação
  $.retry_count = 0
  $.state_lock = 0
}
```

### Validação resumida
- Condition usada: precisa ser `GENERATION_SAFE`.
- Loop/reentrada: lock + contador + fallback.
- Limitação: ajustar comandos concretos ao cenário do usuário.

## Exemplo B — Revisão de macro com risco de loop
- Problema: `while` sem condição de saída forte.
- Correção: inserir contador máximo e timeout.
- Resultado: fluxo determinístico com fail-safe.
