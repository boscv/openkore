# 04 Examples Validation

## examples_valid (audit_full + knowledge_ready)
1. `hp_pot` (CurrentHP < 40%, call, priority, CheckOnAI)
   - Classificação: **VALIDADO COMO VÁLIDO** (numeric + parâmetro válido)
2. `got_priv` (PrivMsg regex + call)
   - Classificação: **VALIDADO COMO VÁLIDO**
3. `call_args` (OnCharLogIn any + call com args)
   - Classificação: **VALIDADO COMO VÁLIDO**
   - Nota: em `OnCharLogIn`, o argumento é aceito por não haver parser sintático específico na condition (valor é essencialmente ignorado).
4. `test_flow` (if pós-fixado + while)
   - Classificação: **VALIDADO COMO VÁLIDO**

## examples_invalid (audit_full + knowledge_ready)
1. 2 event-type conditions no mesmo automacro
   - Classificação: **VALIDADO COMO INVÁLIDO**
2. `run-once maybe`
   - Classificação: **VALIDADO COMO INVÁLIDO**
3. índice array dinâmico não numérico
   - Classificação: **VALIDADO COMO INVÁLIDO**
4. `defined(@arr)`
   - Classificação: **VALIDADO COMO INVÁLIDO**

## Correções necessárias
- Nenhuma correção adicional de exemplo foi necessária nesta rodada.
