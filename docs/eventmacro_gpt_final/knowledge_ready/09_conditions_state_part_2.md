# 08 Conditions State Part 2

Classificação: nome/tipo/hook **PROVADO**; `argument_contract` em `custom` pode ser **INFERIDO**.

| Condition | Parser mode | Hooks | regex | range | csv | var |
|---|---|---|---|---|---|---|
| JobID | composite_regex_numeric | Network::Receive::map_changed, in_game, sprite_job_change | true | true | false | true |
| JobIDNot | composite_regex_numeric | Network::Receive::map_changed, in_game, sprite_job_change | true | true | false | true |
| JobLevel | numeric_comparison | job_level_changed, Network::Receive::map_changed, in_game, packet/stat_info | false | true | false | false |
| MaxHP | numeric_comparison | Network::Receive::map_changed, in_game, packet/stat_info, packet/hp_sp_changed | false | true | false | false |
| MaxSP | numeric_comparison | Network::Receive::map_changed, in_game, packet/stat_info, packet/hp_sp_changed | false | true | false | false |
| MobNear | regex_literal | - | true | false | false | false |
| MobNearCount | numeric_comparison | - | false | true | false | false |
| MobNearDist | composite_regex_numeric | - | true | true | false | false |
| MobNotNear | regex_literal | - | true | false | false | false |
| NoMobNear | composite_regex_numeric | - | true | true | false | false |
| NoNpcNear | composite_regex_numeric | - | true | true | false | false |
| NoPlayerNear | composite_regex_numeric | - | true | true | false | false |
| NoPortalNear | composite_regex_numeric | - | true | true | false | false |
| NotInMap | csv_list | - | false | false | true | false |
| NpcNear | regex_literal | - | true | false | false | false |
| NpcNearCount | numeric_comparison | - | false | true | false | false |
| NpcNearDist | composite_regex_numeric | - | true | true | false | false |
| NpcNotNear | regex_literal | - | true | false | false | false |
| PlayerNear | regex_literal | - | true | false | false | false |
| PlayerNearCount | numeric_comparison | - | false | true | false | false |
| PlayerNearDist | composite_regex_numeric | - | true | true | false | false |
| PlayerNotNear | regex_literal | - | true | false | false | false |
| PortalNearCount | numeric_comparison | - | false | true | false | false |
| QuestActive | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestComplete | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestHuntCompleted | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestHuntOngoing | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestInactive | composite_regex_numeric | achievement_list, quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestIncomplete | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestNotComplete | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestNotIncomplete | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestOnTime | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| QuestTimeOverdue | composite_regex_numeric | quest_all_list_end, quest_all_mission_end, quest_added, quest_update_mission_hunt_end, quest_delete, quest_active | true | true | false | true |
| ShopOpened | composite_regex_numeric | in_game, open_shop, packet_send/shop_open, packet_send/shop_close, shop_closed, packet_mapChange | true | true | false | false |
| SkillLevel | numeric_comparison | packet/skill_update, packet/skills_list, packet/skill_add, packet/skill_delete | false | true | false | false |
| Spirits | numeric_comparison | packet/revolving_entity | false | true | false | false |
| StatusActiveHandle | composite_regex_numeric | Actor::setStatus::change | true | true | false | true |
| StatusInactiveHandle | composite_regex_numeric | in_game, Actor::setStatus::change | true | true | false | true |
| StorageOpened | composite_regex_numeric | in_game, packet_storage_open, packet_storage_close | true | true | false | false |
| VarValue | composite_regex_numeric | - | true | true | false | true |
| Zeny | numeric_comparison | zeny_change, packet/stat_info, packet/stats_info, complete_deal | false | true | false | false |
| isInMapAndCloseToCoordinate | composite_regex_numeric | packet/actor_movement_interrupted, packet/high_jump, packet/character_moves, packet_mapChange, packet/map_property3 | true | true | false | false |
| isNotInMapOrNotCloseToCoordinate | composite_regex_numeric | packet/actor_movement_interrupted, packet/high_jump, packet/character_moves, packet_mapChange, packet/map_property3 | true | true | false | false |
