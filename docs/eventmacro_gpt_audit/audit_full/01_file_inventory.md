# 01 File Inventory

Status: **PROVADO** (levantado diretamente do repositório).

## Escopo auditado
- Core/runtime: Core.pm, Automacro.pm, Runner.pm, Macro.pm, Lists.pm, Data.pm, Utilities.pm.
- Parser/gramática: FileParser.pm e parser de comandos/condições em Runner.pm.
- Validação: Validator/*.pm e lógica de validação nos módulos Condition*.
- Conditions: Condition.pm, Conditiontypes/*.pm, Condition/Base/*.pm, Condition/*.pm.
- Entrada plugin/comandos console: eventMacro.pl.

## Árvore (arquivos principais)
```
plugins/eventMacro/eventMacro/Automacro.pm
plugins/eventMacro/eventMacro/Condition.pm
plugins/eventMacro/eventMacro/Core.pm
plugins/eventMacro/eventMacro/Data.pm
plugins/eventMacro/eventMacro/FileParser.pm
plugins/eventMacro/eventMacro/Lists.pm
plugins/eventMacro/eventMacro/Macro.pm
plugins/eventMacro/eventMacro/Runner.pm
plugins/eventMacro/eventMacro/Utilities.pm
plugins/eventMacro/eventMacro/Validator.pm
plugins/eventMacro/eventMacro/Condition/ (118 módulos)
  AttackEnd.pm
  AttackStart.pm
  AttackStartRegex.pm
  BaseLevel.pm
  BusMsg.pm
  CartCurrentSize.pm
  CartCurrentWeight.pm
  CartMaxSize.pm
  CartMaxWeight.pm
  CharCurrentWeight.pm
  CharMaxWeight.pm
  ChatRoomNear.pm
  ConfigKey.pm
  ConfigKeyDefined.pm
  ConfigKeyDualDifferentDefinedValue.pm
  ConfigKeyDualSameDefinedValue.pm
  ConfigKeyNot.pm
  ConfigKeyNotExist.pm
  ConfigKeyUndefined.pm
  Console.pm
  CurrentHP.pm
  CurrentSP.pm
  Eval.pm
  EvalHook.pm
  FreeSkillPoints.pm
  FreeStatPoints.pm
  GuildMsg.pm
  GuildMsgDist.pm
  GuildMsgName.pm
  GuildMsgNameDist.pm
  InCart.pm
  InCartID.pm
  InChatRoom.pm
  InCity.pm
  InInventory.pm
  InInventoryID.pm
  InLockMap.pm
  InMap.pm
  InMapRegex.pm
  InProgressBar.pm
  InPvP.pm
  InSaveMap.pm
  InStorage.pm
  InStorageID.pm
  InventoryCurrentSize.pm
  InventoryReady.pm
  IsEquippedID.pm
  IsInCoordinate.pm
  IsInMapAndCoordinate.pm
  IsNotEquippedID.pm
  IsNotInCoordinate.pm
  IsNotInMapAndCoordinate.pm
  JobID.pm
  JobIDNot.pm
  JobLevel.pm
  LocalMsg.pm
  MapLoaded.pm
  MaxHP.pm
  MaxSP.pm
  MobNear.pm
  MobNearCount.pm
  MobNearDist.pm
  MobNotNear.pm
  NoMobNear.pm
  NoNpcNear.pm
  NoPlayerNear.pm
  NoPortalNear.pm
  NotInMap.pm
  NpcMsg.pm
  NpcMsgDist.pm
  NpcMsgName.pm
  NpcMsgNameDist.pm
  NpcNear.pm
  NpcNearCount.pm
  NpcNearDist.pm
  NpcNotNear.pm
  OnCharLogIn.pm
  PartyMsg.pm
  PartyMsgDist.pm
  PartyMsgName.pm
  PartyMsgNameDist.pm
  PlayerNear.pm
  PlayerNearCount.pm
  PlayerNearDist.pm
  PlayerNotNear.pm
  PortalNearCount.pm
  PrivMsg.pm
  PrivMsgDist.pm
  PrivMsgName.pm
  PrivMsgNameDist.pm
  PubMsg.pm
  PubMsgDist.pm
  PubMsgName.pm
  PubMsgNameDist.pm
  QuestActive.pm
  QuestComplete.pm
  QuestHuntCompleted.pm
  QuestHuntOngoing.pm
  QuestInactive.pm
  QuestIncomplete.pm
  QuestNotComplete.pm
  QuestNotIncomplete.pm
  QuestOnTime.pm
  QuestTimeOverdue.pm
  ShopOpened.pm
  SimpleHookEvent.pm
  SkillLevel.pm
  Spirits.pm
  StatAdded.pm
  StatusActiveHandle.pm
  StatusInactiveHandle.pm
  StorageOpened.pm
  SystemMsg.pm
  VarValue.pm
  Zeny.pm
  ZenyChanged.pm
  isInMapAndCloseToCoordinate.pm
  isNotInMapOrNotCloseToCoordinate.pm
plugins/eventMacro/eventMacro/Condition/Base/ (13 módulos)
  ActorNear.pm
  ActorNearCount.pm
  ActorNearDist.pm
  ActorNotNear.pm
  InCart.pm
  InInventory.pm
  InStorage.pm
  Inventory.pm
  Msg.pm
  MsgDist.pm
  MsgName.pm
  MsgNameDist.pm
  NoActorNear.pm
plugins/eventMacro/eventMacro/Conditiontypes/ (7 módulos)
  ListConditionEvent.pm
  ListConditionState.pm
  NumericConditionEvent.pm
  NumericConditionState.pm
  RegexConditionEvent.pm
  RegexConditionState.pm
  SimpleEvent.pm
plugins/eventMacro/eventMacro/Validator/ (3 módulos)
  ListMemberCheck.pm
  NumericComparison.pm
  RegexCheck.pm
```

## Mapa de responsabilidade
- **Gramática de arquivo**: `FileParser::parseMacroFile`, `isNewCommandBlock`, `isNewWrongCommandBlock`.
- **Execução de linguagem macro**: `Runner::define_next_valid_command`, `Runner::next`, `Runner::parse_command`.
- **Comparação/range/regex/lista**: `Utilities::cmpr`, `Utilities::match`, `Validator::NumericComparison`, `Validator::RegexCheck`, `Validator::ListMemberCheck`.
- **Variáveis/sistema de tipos**: `Data.pm` (regex de variável), `Utilities::find_variable`, `Core` (set/get callbacks e especiais).
- **Semântica de automacro/fila/prioridade**: `Core.pm`, `Automacro.pm`.
- **Comandos console (`eventMacro`/`emacro`)**: `eventMacro.pl::commandHandler`.
