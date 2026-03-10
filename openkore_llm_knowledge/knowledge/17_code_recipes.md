# Code Recipes

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
