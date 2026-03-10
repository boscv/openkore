# OpenKore Code Recipes

Practical snippets for common OpenKore customization tasks.

---

## 1) Plugin Development

### A) Minimal plugin skeleton
```perl
package MyPlugin;

use strict;
use Plugins;
use Log qw(message);

my $hooks;
my $cmds;

Plugins::register('MyPlugin', 'Minimal example plugin', \&on_unload);

sub on_unload {
    Plugins::delHooks($hooks) if $hooks;
    Commands::unregister($cmds) if $cmds;
    message "[MyPlugin] unloaded\n", 'success';
}

1;
```

### B) Registering hooks
```perl
use Plugins;
use Log qw(message);

$hooks = Plugins::addHooks(
    ['start3', sub { message "[MyPlugin] start3 fired\n", 'info'; }],
    ['mainLoop_pre', sub { 
        # periodic logic
        # keep this lightweight
    }],
    ['configModify', sub {
        my (undef, $args) = @_;
        message "[MyPlugin] config changed: $args->{key}\n", 'info';
    }],
);
```

### C) Handling packets (hook-based)
```perl
# Example: observe a packet-level hook exposed by core/plugins
$hooks = Plugins::addHooks(
    ['packet_pre/map_changed', sub {
        my (undef, $args) = @_;
        # inspect packet arguments; avoid mutating unless needed
        message "[MyPlugin] map changed detected\n", 'info';
    }],
);
```

### D) Adding console commands
```perl
use Commands;
use Log qw(message);

$cmds = Commands::register([
    'mycmd',
    'My custom command',
    sub {
        my (undef, $params) = @_;
        $params //= '';
        message "[MyPlugin] mycmd called with: $params\n", 'list';
    }
]);
```

---

## 2) Macros (`macros.txt` style)

### A) Teleport on HP threshold
```txt
automacro emergency_tp {
    hp < 35%
    timeout 1
    run-once 0
    call {
        do conf teleportAuto_useSkill 1
        do conf teleportAuto_useChatCommand 0
        do sp 26 1   # Teleport level 1 (example)
    }
}
```

### B) Simple farming loop
```txt
macro farm_loop {
    do move prontera 150 180
    pause 1
    do ai auto
    pause 10
    do move prontera 120 160
    pause 1
    do ai auto
    pause 10
    do macro farm_loop
}

automacro start_farming {
    map prontera
    timeout 3
    run-once 1
    call farm_loop
}
```

### C) NPC interaction macro
```txt
macro use_healer {
    do talknpc 156 186 c r0 c c
}

automacro low_hp_heal {
    hp < 60%
    map prontera
    timeout 15
    run-once 0
    call use_healer
}
```

---

## 3) EventMacros (`eventMacros.txt` style)

### A) Reacting to monster presence
```txt
automacro danger_near {
    MonsterNear 1
    MonsterNearDist < 6
    call {
        do conf attackAuto 0
        do sp 26 1
    }
}
```

### B) Map entry trigger
```txt
automacro entered_payon {
    InMap payon
    mapLoaded
    call {
        do conf attackAuto 2
        do conf route_randomWalk 1
        do ai auto
    }
}
```

---

## 4) Configuration Recipes

### A) Item pickup logic (`items_control.txt`)
```txt
# item name                keep  storage  sell
"Red Potion"              30    0        1
"Blue Potion"             20    0        1
"Jellopy"                 0     0        1
"Empty Bottle"            0     0        0
```

### B) Monster avoidance (`mon_control.txt`)
```txt
# monster          attack teleport search
"Baphomet"        -1     1        0
"Hydra"            1     0        0
"Pupa"             0     0        0
```

### C) Route locking (`config.txt`)
```txt
lockMap prontera
lockMap_x 156
lockMap_y 186
attackAuto_inLockOnly 1
route_randomWalk 0
```

---

## Notes
- Packet IDs, skill IDs, and command behaviors may vary by server profile.
- Keep plugin `mainLoop_pre` handlers lightweight to avoid lag.
- Test macros/eventMacros in a safe map before production farming routes.
