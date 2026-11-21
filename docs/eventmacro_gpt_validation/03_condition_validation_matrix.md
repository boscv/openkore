# 03 Condition Validation Matrix

## Resultado global
- Conditions no source: **118**
- Conditions no catálogo JSON: **118**
- Módulos ausentes/extras no catálogo: **0**
- Divergência state/event (resolução por herança): **0**
- Divergência de hooks declarados: **0**
- Knowledge_ready: **18 arquivos**, orçamento <=20: **OK**.
- Tabelas markdown de conditions (state/event) vs JSON: **OK**.
- Upload manifest vs arquivos reais em `knowledge_ready`: **OK**.

## Escopo verificado automaticamente
- Existência de módulo por condition.
- `condition_type` efetivo (state/event) por cadeia de herança.
- `_hooks` declarados no módulo de condition.
- Presença das chaves mínimas de schema no catálogo (`parser_mode`, `argument_contract`, `confidence`, `evidence`, etc.).
- Limite de upload do conjunto `knowledge_ready`.
- Consistência entre tabelas markdown de conditions e catálogo JSON.
- Consistência entre `16_upload_manifest.md` e lista real de arquivos de `knowledge_ready`.

## Limitações
- `parser_mode`/`argument_contract` cobrem formalmente famílias por herança e por uso explícito de validators.
- Nesta iteração, nenhuma condition ficou em `custom` no catálogo regenerado.

## Classificação
- Existência/tipo/hook: **PROVADO**
- `parser_mode`/`argument_contract`:
  - catálogo atual: **PROVADO**
