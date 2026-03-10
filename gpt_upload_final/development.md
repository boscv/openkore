# Code Recipes
---

Practical snippets for common OpenKore development tasks.

## 1) Minimal plugin skeleton
```perl
package myPlugin;

use strict;
use Plugins;
use Log qw(message warning error);

my $hooks = [];

Plugins::register('myPlugin', 'Minimal plugin skeleton', \&on_unload);
$hooks = Plugins::addHooks(
    ['start3', \&on_start],
    ['AI_pre', \&on_ai_pre],
);

sub on_start {
    message "[myPlugin] started\n", 'info';
}

sub on_ai_pre {
    my ($hookName, $args) = @_;
    # lightweight periodic logic
}

sub on_unload {
    Plugins::delHooks($hooks);
    message "[myPlugin] unloaded\n", 'info';
}

1;
```

## 2) Hook registration pattern
```perl
my $hooks = Plugins::addHooks(
    ['packet_pre/actor_moved', \&on_actor_moved],
    ['packet/map_changed', \&on_map_changed],
    ['configModify', \&on_config_modify],
);

sub on_actor_moved {
    my ($hook, $args) = @_;
    # inspect $args->{ID}, $args->{coords}
}
```

## 3) Command registration
```perl
Commands::register(
    ['mycmd', 'run custom action', \&cmd_mycmd]
);

sub cmd_mycmd {
    my (undef, $args) = @_;
    message "[myPlugin] mycmd args: $args\n", 'info';
}

# on unload:
Commands::unregister('mycmd');
```

## 4) Packet hook example
```perl
my $hooks = Plugins::addHooks(
    ['packet_pre/login_error', \&on_login_error],
    ['packet/map_changed', \&on_map_changed],
);

sub on_login_error {
    my ($hook, $args) = @_;
    warning "Login error packet received: $args->{type}\n";
}
```

## 5) Macro example (`macros.txt`)
```txt
automacro autoHeal {
    hp < 40%
    timeout 1
    call {
        do ss 28
    }
}

macro goTown {
    do move prontera
}
```

## 6) eventMacro example
```txt
automacro checkWeight {
    InLockMap 1
    weight > 85%
    call {
        do conf itemsTakeAuto 0
        do ai clear
    }
}

automacro greetOnMap {
    map prontera
    run-once 1
    call {
        do c Hello from OpenKore
    }
}
```

## 7) Configuration examples (`control/config.txt`)
```txt
lockMap prontera
saveMap prontera
route_randomWalk 1
teleportAuto_hp 25
itemsTakeAuto 2
attackAuto 2
macro_file macros.txt
eventMacro_file eventMacros.txt
```

## 8) Debugging snippets
### 8.1 Print current map and coordinates
```perl
use Globals qw($field %char);
message sprintf("Map=%s x=%d y=%d\n", $field->baseName, $char{pos_to}{x}, $char{pos_to}{y}), 'debug';
```

### 8.2 Trace command callback entry
```perl
sub cmd_mycmd {
    my (undef, $args) = @_;
    message "[TRACE] cmd_mycmd called with '$args'\n", 'debug';
}
```

### 8.3 Check task queue state quickly
```perl
use TaskManager;
my $task = TaskManager::getTaskManager()->activeTask;
message "Active task: " . ($task ? ref($task) : 'none') . "\n", 'debug';
```

# Learning Path for New OpenKore Developers
---

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

# Prompt Examples for Users
---

Realistic prompts users can ask an OpenKore-focused GPT assistant.

## Architecture and code navigation
1. "Explain how `src/functions.pl` orchestrates the OpenKore main loop."
2. "Map the dependency chain between AI, TaskManager, and Network::Send."
3. "Which modules should I read first to understand actor updates from packets?"
4. "Summarize how plugin hooks interact with command execution."

## Debugging
5. "My bot stopped moving. Give me a step-by-step diagnosis plan with files to inspect."
6. "How do I distinguish packet desync from route calculation failure?"
7. "Generate a troubleshooting checklist for NPC dialogue failures."
8. "Why are my plugin hooks not firing even though plugin loads fine?"
9. "Help me debug eventMacro that parses but never triggers."
10. "Create a minimal reproduction plan for XKore client sync issues."

## Plugins
11. "Create a minimal plugin skeleton with register, hooks, and unload cleanup."
12. "Add a custom command `farmstatus` that prints current map and task."
13. "Show best practices for lightweight hook callbacks in OpenKore plugins."
14. "How do I instrument a plugin with debug logs without spamming output?"

## Macro / eventMacro
15. "Write an automacro that pauses looting above 85% weight."
16. "Create eventMacro rules to send a chat message only once when entering Prontera."
17. "Compare macro and eventMacro for reactive combat behavior."
18. "How can I test whether a macro trigger condition is actually true at runtime?"

## Routing and movement
19. "Explain why route tasks can oscillate and how to debug it."
20. "Show a script strategy to test short movement segments before full routes."
21. "What configs can block movement even if route exists?"

## Networking and packets
22. "How do I verify that serverType and recvpackets are correctly configured?"
23. "Trace one incoming movement packet from socket bytes to Actor update."
24. "What logs should I capture when packet decode errors start after a patch?"
25. "Explain where to add temporary logging for packet send construction."

## Configuration
26. "Review my config goals and suggest a minimal stable `config.txt` baseline."
27. "Which `mon_control.txt` settings commonly interfere with movement tasks?"
28. "How do lockMap and saveMap influence AI behavior?"

## Learning and onboarding
29. "Build me a 2-week learning plan to become productive in OpenKore development."
30. "Give me a study order for networking, AI, tasks, plugins, and macros with exercises."
