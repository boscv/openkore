# 07 Conditions State Part 1

Classificação: nome/tipo/hook **PROVADO**; `argument_contract` em `custom` pode ser **INFERIDO**.

| Condition | Parser mode | Hooks | regex | range | csv | var |
|---|---|---|---|---|---|---|
| BaseLevel | numeric_comparison | base_level_changed, Network::Receive::map_changed, in_game, packet/stat_info | false | true | false | false |
| CartCurrentSize | numeric_comparison | cart_ready, cart_info_updated, packet_mapChange, packet/cart_off | false | true | false | false |
| CartCurrentWeight | numeric_comparison | cart_ready, cart_info_updated, packet_mapChange, packet/cart_off | false | true | false | false |
| CartMaxSize | numeric_comparison | cart_ready, cart_info_updated, packet_mapChange, packet/cart_off | false | true | false | false |
| CartMaxWeight | numeric_comparison | cart_ready, cart_info_updated, packet_mapChange, packet/cart_off | false | true | false | false |
| CharCurrentWeight | numeric_comparison | inventory_clear, inventory_ready, packet/stat_info | false | true | false | false |
| CharMaxWeight | numeric_comparison | inventory_clear, inventory_ready, packet/stat_info | false | true | false | false |
| ChatRoomNear | regex_literal | packet_mapChange, chat_created, packet_chatinfo, chat_removed, chat_modified | true | false | false | false |
| ConfigKey | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | true |
| ConfigKeyDefined | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | true |
| ConfigKeyDualDifferentDefinedValue | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | false |
| ConfigKeyDualSameDefinedValue | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | false |
| ConfigKeyNot | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | true |
| ConfigKeyNotExist | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | true |
| ConfigKeyUndefined | composite_regex_numeric | post_configModify, pos_load_config.txt, in_game | true | true | false | true |
| CurrentHP | numeric_comparison | Network::Receive::map_changed, in_game, packet/stat_info, packet/hp_sp_changed | false | true | false | false |
| CurrentSP | numeric_comparison | Network::Receive::map_changed, in_game, packet/stat_info, packet/hp_sp_changed | false | true | false | false |
| Eval | composite_regex_numeric | AI_pre | true | true | false | false |
| EvalHook | composite_regex_numeric | - | true | true | false | true |
| FreeSkillPoints | numeric_comparison | packet/stat_info, packet_charSkills, packet_homunSkills | false | true | false | false |
| FreeStatPoints | numeric_comparison | packet/stat_info, packet/stats_info | false | true | false | false |
| InCart | numeric_comparison | - | false | true | false | false |
| InCartID | numeric_comparison | - | false | true | false | false |
| InChatRoom | composite_regex_numeric | packet_mapChange, chat_created, chat_leave, chat_joined | true | true | false | false |
| InCity | composite_regex_numeric | Network::Receive::map_changed, in_game, packet_mapChange | true | true | false | false |
| InInventory | numeric_comparison | - | false | true | false | false |
| InInventoryID | numeric_comparison | - | false | true | false | false |
| InLockMap | composite_regex_numeric | packet_mapChange, configModify, pos_load_config.txt, in_game | true | true | false | false |
| InMap | csv_list | Network::Receive::map_changed, in_game, packet_mapChange | false | false | true | false |
| InMapRegex | regex_literal | Network::Receive::map_changed, in_game, packet_mapChange | true | false | false | false |
| InProgressBar | composite_regex_numeric | packet/progress_bar, packet/progress_bar_stop, packet_mapChange, packet/map_property3 | true | true | false | false |
| InPvP | csv_list | packet_mapChange, pvp_mode | false | false | true | false |
| InSaveMap | composite_regex_numeric | Network::Receive::map_changed, in_game, packet_mapChange, configModify, pos_load_config.txt | true | true | false | false |
| InStorage | numeric_comparison | - | false | true | false | false |
| InStorageID | numeric_comparison | - | false | true | false | false |
| InventoryCurrentSize | numeric_comparison | inventory_clear, inventory_ready, item_gathered, inventory_item_removed | false | true | false | false |
| InventoryReady | composite_regex_numeric | inventory_clear, inventory_ready | true | true | false | false |
| IsEquippedID | composite_regex_numeric | inventory_clear, equipped_item, unequipped_item, inventory_ready | true | true | false | true |
| IsInCoordinate | composite_regex_numeric | - | true | true | false | true |
| IsInMapAndCoordinate | composite_regex_numeric | packet/actor_movement_interrupted, packet/high_jump, packet/character_moves, packet_mapChange, packet/map_property3 | true | true | false | true |
| IsNotEquippedID | composite_regex_numeric | inventory_clear, equipped_item, unequipped_item, inventory_ready | true | true | false | true |
| IsNotInCoordinate | composite_regex_numeric | - | true | true | false | true |
| IsNotInMapAndCoordinate | composite_regex_numeric | - | true | true | false | true |
