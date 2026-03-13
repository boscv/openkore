# Learning Path for New OpenKore Developers

## Stage 0: Orientation (Day 1)
- Read `01_llm_context.md`, `02_architecture_overview.md`, `03_system_architecture_map.md`.
- Goal: understand receive->state->AI->task->send loop and key directories.

## Stage 1: Runtime core comprehension (Days 2-3)
- Study `src/functions.pl`, `src/Globals.pm`, `src/Modules.pm`.
- Track one full startup + one main-loop tick.
- Exercise: write a short note describing what runs each tick.

## Stage 2: Network + actor model (Days 4-5)
- Study `src/Network.pm`, `src/Network/Receive.pm`, `src/Network/Send.pm`, `src/ActorList.pm`.
- Exercise: trace one incoming packet to a world-state mutation.
- Exercise: trace one outgoing action from command/task to send packet.

## Stage 3: AI and task flow (Days 6-7)
- Study `src/AI.pm`, `src/AI/CoreLogic.pm`, `src/TaskManager.pm`, `src/Task/Route.pm`, `src/Task/TalkNPC.pm`.
- Exercise: map how AI chooses a task and how task completion feeds back.

## Stage 4: Plugins and automation (Week 2)
- Study `src/Plugins.pm`, `src/Commands.pm`, `plugins/macro/*`, `plugins/eventMacro/*`.
- Build a minimal plugin with one hook and one command.
- Add one macro and one eventMacro automation rule.

## Stage 5: Config-driven behavior (Week 2)
- Study `control/config.txt`, `control/mon_control.txt`, relevant table files.
- Exercise: change one behavior via config only and document impact.

## Stage 6: Debugging proficiency (Week 3)
- Use `15_debugging_playbook.md`, `16_debug_decision_trees.md`, `22_common_pitfalls.md`.
- Reproduce and fix one issue in each category:
  - movement/routing
  - plugin/hook
  - macro/eventMacro
  - packet/XKore sync

## Stage 7: Advanced protocol + XKore (Week 3+)
- Study `09_networking_packets.md`, `10_xkore_modes.md`.
- Compare DirectConnection vs XKore2 flow and identify mode-specific risks.

## Suggested competency checklist
- [ ] Explain OpenKore runtime architecture from memory.
- [ ] Trace packet receive and send paths.
- [ ] Implement and unload a safe plugin.
- [ ] Diagnose macro and eventMacro trigger failures.
- [ ] Diagnose route and movement failures.
- [ ] Diagnose basic packet/serverType desync.
- [ ] Explain XKore sync failure patterns.
