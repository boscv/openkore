# 03 Improvement Stages (Execution Tracker)

## Objetivo
Executar melhorias incrementais na curadoria sem quebrar estabilidade.

## Stage 1 (COMPLETED)
- Expandir contratos estruturados de funções/parâmetros.
- Resultado: catálogo aplicado e integrado com gates.

## Stage 2 (COMPLETED)
- Melhorar cobertura COMPLETE de funções macro de uso frequente (`random`, `rand`, `strip`, `keys`, `values`, `push`, `pop`, `shift`, `unshift`, `delete`).
- Resultado: menor bloqueio em geração para funções comuns.

## Stage 3 (COMPLETED)
- Revisão aplicada em 10 conditions de uso recorrente com `_parse_syntax` explícito:
  - `InLockMap`, `JobID`, `JobIDNot`, `InSaveMap`, `InCity`,
  - `InProgressBar`, `InChatRoom`, `IsInCoordinate`, `IsNotInCoordinate`, `IsInMapAndCoordinate`.
- Resultado: cobertura lexical passou de **57 COMPLETE / 61 PARTIAL** para **67 COMPLETE / 51 PARTIAL**.

## Stage 4 (COMPLETED)
- Suíte `golden_macro_cases.json` expandida para **32 casos** (válidos + inválidos).
- Cobertura adicionada para cenários simples/médios/complexos e edge-cases de loop, reentrada e `orphan`.

## Stage 5 (COMPLETED)
- Implementado gerador de relatório de regressão (`generate_regression_report.py`).
- Relatório emitido em `04_regression_report.md` com baseline vs current (COMPLETE/PARTIAL/INSUFFICIENT).

## Plano 1 (em execução) — Lote 1 (COMPLETED)
- Migradas 5 conditions de baixa ambiguidade lexical: `InventoryReady`, `ShopOpened`, `StorageOpened`, `StatusActiveHandle`, `StatusInactiveHandle`.
- Delta do lote: **+5 COMPLETE / -5 PARTIAL**.

## Plano 1 (em execução) — Lote 2 (COMPLETED)
- Migradas 11 conditions por famílias homogêneas de parser:
  - Config keys: `ConfigKeyDefined`, `ConfigKeyNotExist`, `ConfigKeyUndefined`.
  - Quests CSV: `QuestActive`, `QuestComplete`, `QuestInactive`, `QuestIncomplete`, `QuestNotComplete`, `QuestNotIncomplete`, `QuestOnTime`, `QuestTimeOverdue`.
- Delta do lote: **+11 COMPLETE / -11 PARTIAL**.

## Plano 1 (em execução) — Lote 3 (COMPLETED)
- Migradas 18 conditions de famílias baseadas em parsers regex/numeric explícitos:
  - MsgDist: `GuildMsgDist`, `NpcMsgDist`, `PartyMsgDist`, `PrivMsgDist`, `PubMsgDist`.
  - MsgName: `GuildMsgName`, `NpcMsgName`, `PartyMsgName`, `PrivMsgName`, `PubMsgName`.
  - MsgNameDist: `GuildMsgNameDist`, `NpcMsgNameDist`, `PartyMsgNameDist`, `PrivMsgNameDist`, `PubMsgNameDist`.
  - ActorNearDist: `MobNearDist`, `NpcNearDist`, `PlayerNearDist`.
- Delta do lote: **+18 COMPLETE / -18 PARTIAL**.

## Plano 1 (em execução) — Lote 4 (COMPLETED)
- Migradas 12 conditions remanescentes com gramática explícita:
  - Config pairs/duals: `ConfigKey`, `ConfigKeyNot`, `ConfigKeyDualDifferentDefinedValue`, `ConfigKeyDualSameDefinedValue`.
  - Equip/map composites: `IsEquippedID`, `IsNotEquippedID`, `IsNotInMapAndCoordinate`.
  - Hook/value/coord patterns: `EvalHook`, `SimpleHookEvent`, `VarValue`, `isInMapAndCloseToCoordinate`, `isNotInMapOrNotCloseToCoordinate`.
- Delta do lote: **+12 COMPLETE / -12 PARTIAL**.

## Plano 1 — Lote 5 (COMPLETED)
- Fechadas as 5 pendências residuais: `Eval`, `NoMobNear`, `NoNpcNear`, `NoPlayerNear`, `NoPortalNear`.
- Delta do lote: **+5 COMPLETE / -5 PARTIAL**.

## Plano 1 (FINALIZADO)
- Coverage de conditions: **118 COMPLETE / 0 PARTIAL / 0 INSUFFICIENT**.

## Plano 2 (COMPLETED)
- Contratos de **macro functions** migrados para **41 COMPLETE / 0 PARTIAL**.
- Contratos de **automacro parameters** migrados para **13 COMPLETE / 0 PARTIAL** (incluindo `CheckOnAI`).
- Golden cases realinhados para refletir baseline totalmente COMPLETE em conditions/functions/parameters.

## Plano 3 (COMPLETED)
- Adicionado relatório de prontidão de release (`05_release_readiness_report.md`) com snapshot integrado de conditions/functions/parameters.
- Status consolidado de prontidão: **READY**.

## Plano 4 (COMPLETED)
- Empacotamento final de `knowledge_ready` executado via `package_knowledge_ready.py`.
- Revisão final consolidada registrada em `06_final_review_and_packaging.md`.
