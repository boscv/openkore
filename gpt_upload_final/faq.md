# OpenKore Technical FAQ
---

## Architecture
1. **Q:** What is OpenKore's main runtime entry point?  
   **A:** `src/functions.pl` initializes modules and runs the main loop.
2. **Q:** Where is global runtime state stored?  
   **A:** Mostly in `src/Globals.pm` and shared structures.
3. **Q:** Which module runs AI logic?  
   **A:** `src/AI.pm` coordinates AI and calls `src/AI/CoreLogic.pm`.
4. **Q:** How are game entities represented?  
   **A:** Through `src/Actor.pm` and `src/ActorList.pm`.
5. **Q:** What handles tasks?  
   **A:** `src/Task.pm` defines tasks and `src/TaskManager.pm` schedules them.
6. **Q:** Where does command parsing happen?  
   **A:** In `src/Commands.pm`.
7. **Q:** How are plugins managed?  
   **A:** Via `src/Plugins.pm` lifecycle and hooks API.
8. **Q:** Why is architecture loop-based?  
   **A:** To repeatedly process receive->state->AI->tasks->send cycles.

## Debugging
9. **Q:** First check when bot freezes?  
   **A:** Confirm AI tick and active task state.
10. **Q:** How to distinguish route vs movement failure?  
    **A:** Check if a route exists, then confirm move packets and position updates.
11. **Q:** Why log packet IDs during failures?  
    **A:** To detect serverType/recvpackets mismatch quickly.
12. **Q:** Best way to debug plugin hooks?  
    **A:** Log both hook registration and callback entry.
13. **Q:** Why test with minimal config?  
    **A:** To remove config side effects masking root causes.
14. **Q:** What indicates desync risk?  
    **A:** Decode errors, unknown packets, or stale actor updates.
15. **Q:** How to verify task deadlock?  
    **A:** Inspect active task and queued tasks in task manager.
16. **Q:** Should I debug with all plugins enabled?  
    **A:** No, isolate with minimal plugin set first.

## Plugins
17. **Q:** Minimum plugin requirements?  
    **A:** `Plugins::register`, optional hooks, and clean unload.
18. **Q:** How to add a custom command?  
    **A:** Use `Commands::register` and unregister on unload.
19. **Q:** Why might plugin load fail silently?  
    **A:** Early syntax/runtime errors or missing dependencies.
20. **Q:** Can plugins alter AI behavior?  
    **A:** Yes, via commands, hooks, and task interactions.
21. **Q:** Where are community plugins stored?  
    **A:** Under `plugins/`.
22. **Q:** How to avoid hook performance issues?  
    **A:** Keep callbacks lightweight and defer heavy work.
23. **Q:** Can multiple plugins share hook names?  
    **A:** Yes, each callback runs if registered correctly.
24. **Q:** Why unregister hooks on unload?  
    **A:** To prevent stale callbacks and inconsistent state.

## Macros / eventMacro
25. **Q:** Difference between macro and eventMacro?  
    **A:** Macro is classic command script flow; eventMacro is event/condition-driven automation.
26. **Q:** Where to set macro file path?  
    **A:** `control/config.txt` via `macro_file`.
27. **Q:** Where to set eventMacro file path?  
    **A:** `control/config.txt` via `eventMacro_file`.
28. **Q:** Why automacro never triggers?  
    **A:** Condition false, plugin not loaded, or parse issue.
29. **Q:** How to test macro trigger quickly?  
    **A:** Manually run equivalent command and compare behavior.
30. **Q:** Why use run-once in eventMacro?  
    **A:** To avoid repeated firing for one-time actions.
31. **Q:** Can macros execute OpenKore commands?  
    **A:** Yes, via `do <command>`.
32. **Q:** How to debug eventMacro parser issues?  
    **A:** Reduce to one trigger + one action and rebuild incrementally.

## Routing / movement
33. **Q:** Which files control routing logic?  
    **A:** `src/Task/Route.pm`, `src/Task/Move.pm`, and `src/Field.pm`.
34. **Q:** What is walkability?  
    **A:** Whether a map cell is traversable based on field data.
35. **Q:** Why does route loop occur?  
    **A:** Stale position updates, blocked transitions, or invalid field assumptions.
36. **Q:** What is lockMap effect?  
    **A:** Restricts behavior to a preferred map scope.
37. **Q:** How to validate map data?  
    **A:** Ensure map exists in `fields/*` and coordinates are valid.
38. **Q:** Why movement works manually but not AI?  
    **A:** AI priorities/config may override movement intents.
39. **Q:** Can aggressive combat stop movement?  
    **A:** Yes, combat states can continuously preempt route tasks.
40. **Q:** Best first movement test?  
    **A:** Short route on same map with minimal automation enabled.

## Networking
41. **Q:** Which module tokenizes incoming packets?  
    **A:** `src/Network/MessageTokenizer.pm`.
42. **Q:** Which module decodes packet structures?  
    **A:** `src/Network/PacketParser.pm` and receive handlers.
43. **Q:** Where is receive dispatch done?  
    **A:** `src/Network/Receive.pm`.
44. **Q:** Where are server-specific packet handlers?  
    **A:** `src/Network/Receive/*` and `src/Network/Send/*`.
45. **Q:** Why packet errors after server patch?  
    **A:** Opcode/table changes requiring updated mappings.
46. **Q:** Can wrong serverType break everything?  
    **A:** Yes, it causes systematic decode/encode mismatch.
47. **Q:** What causes partial desync?  
    **A:** Some packets map correctly while others fail for changed opcodes.
48. **Q:** How to isolate receive vs send bug?  
    **A:** Compare inbound decode logs and outbound packet construction separately.

## NPC interaction
49. **Q:** Which task handles NPC dialogues?  
    **A:** `src/Task/TalkNPC.pm`.
50. **Q:** Why NPC script stalls mid-dialogue?  
    **A:** Response packet mismatch or wrong expected step sequence.
51. **Q:** Must NPC be in actor list first?  
    **A:** Yes, reliable interaction depends on valid actor presence and position.
52. **Q:** Why wrong NPC gets targeted?  
    **A:** Incorrect coordinates or stale target selection.
53. **Q:** What to inspect first in NPC failure?  
    **A:** Talk packet sequence and corresponding receive responses.
54. **Q:** Can plugins interfere with NPC flow?  
    **A:** Yes, if they alter commands/tasks concurrently.

## Config behavior
55. **Q:** Where are core behavior settings?  
    **A:** `control/config.txt`.
56. **Q:** What file controls monster behavior rules?  
    **A:** `control/mon_control.txt`.
57. **Q:** Why config changes seem ignored?  
    **A:** Reload needed, wrong key, or overridden by plugin automation.
58. **Q:** How to keep config deterministic?  
    **A:** Use minimal explicit settings and disable conflicting automation.
59. **Q:** What is saveMap used for?  
    **A:** Preferred return/safety map behavior.
60. **Q:** Why document config with code changes?  
    **A:** Behavior is policy-driven; docs prevent invisible config regressions.

## XKore / client sync
61. **Q:** What is XKore2 role?  
    **A:** Local proxy/relay flow for account/char/map sessions.
62. **Q:** Why client view stale but bot state updates?  
    **A:** Forwarding/session sync issue in XKore bridge path.
63. **Q:** Is debugging Direct and XKore identical?  
    **A:** No, transport/session layers differ significantly.
64. **Q:** First step for XKore sync bugs?  
    **A:** Confirm active mode and trace handshake phase transitions.
