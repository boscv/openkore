# 09 Conditions Event

| Condition | Parser mode | Hooks | regex | range | csv | var |
|---|---|---|---|---|---|---|
| AttackEnd | csv_list | attack_end | false | false | true | false |
| AttackStart | csv_list | attack_start | false | false | true | false |
| AttackStartRegex | regex_literal | attack_start | true | false | false | false |
| BusMsg | regex_literal | - | true | false | false | false |
| Console | regex_literal | log | true | false | false | false |
| GuildMsg | regex_literal | - | true | false | false | false |
| GuildMsgDist | composite_regex_numeric | - | true | true | false | false |
| GuildMsgName | composite_regex_numeric | - | true | true | false | false |
| GuildMsgNameDist | composite_regex_numeric | - | true | true | false | false |
| LocalMsg | regex_literal | - | true | false | false | false |
| MapLoaded | csv_list | packet_mapChange | false | false | true | false |
| NpcMsg | regex_literal | - | true | false | false | false |
| NpcMsgDist | composite_regex_numeric | - | true | true | false | false |
| NpcMsgName | composite_regex_numeric | - | true | true | false | false |
| NpcMsgNameDist | composite_regex_numeric | - | true | true | false | false |
| OnCharLogIn | simple_event | in_game | false | false | false | false |
| PartyMsg | regex_literal | - | true | false | false | false |
| PartyMsgDist | composite_regex_numeric | - | true | true | false | false |
| PartyMsgName | composite_regex_numeric | - | true | true | false | false |
| PartyMsgNameDist | composite_regex_numeric | - | true | true | false | false |
| PrivMsg | regex_literal | - | true | false | false | false |
| PrivMsgDist | composite_regex_numeric | - | true | true | false | false |
| PrivMsgName | composite_regex_numeric | - | true | true | false | false |
| PrivMsgNameDist | composite_regex_numeric | - | true | true | false | false |
| PubMsg | regex_literal | - | true | false | false | false |
| PubMsgDist | composite_regex_numeric | - | true | true | false | false |
| PubMsgName | composite_regex_numeric | - | true | true | false | false |
| PubMsgNameDist | composite_regex_numeric | - | true | true | false | false |
| SimpleHookEvent | composite_regex_numeric | - | true | true | false | true |
| StatAdded | csv_list | packet_charStats | false | false | true | false |
| SystemMsg | regex_literal | - | true | false | false | false |
| ZenyChanged | numeric_comparison | zeny_change | false | true | false | false |
