#!/usr/bin/env perl
use strict;
use warnings;
no warnings qw(once);

# Full-flow simulation using real function bodies extracted from source files.
# It executes:
# AI::Attack::find_kite_position -> Misc::meetingPosition -> Misc helpers/path checks.

sub extract_sub {
    my ($file, $subname) = @_;
    open my $fh, '<', $file or die "open $file: $!";
    local $/;
    my $src = <$fh>;
    my $start = index($src, "sub $subname {");
    die "sub $subname not found in $file" if $start < 0;
    my $i = index($src, '{', $start);
    my $depth = 0;
    my $end = $i;
    for (; $end < length($src); $end++) {
        my $c = substr($src, $end, 1);
        $depth++ if $c eq '{';
        $depth-- if $c eq '}';
        if ($depth == 0) { $end++; last }
    }
    return substr($src, $start, $end - $start);
}

{ package FieldStub;
  sub new { my ($class,%args)=@_; bless \%args,$class }
  sub isWalkable {
    my ($self,$x,$y)=@_;
    return 0 if $x < 0 || $y < 0 || $x >= $self->{w} || $y >= $self->{h};
    return !$self->{blocked}{"$x,$y"};
  }
  sub baseName { 'sim_map' }
  sub closestWalkableSpot {
    my ($self,$pos,$r)=@_;
    for my $d (0..$r) {
      for my $dx (-$d..$d) {
        for my $dy (-$d..$d) {
          my ($x,$y)=($pos->{x}+$dx,$pos->{y}+$dy);
          return {x=>$x,y=>$y} if $self->isWalkable($x,$y);
        }
      }
    }
    return;
  }
}

{ package ActorStub;
  sub new { my ($class,%args)=@_; bless \%args,$class }
  sub route {
    my ($self,@args)=@_;
    $self->{_last_route_args} = \@args;
    return 1;
  }
  use overload '""' => sub { 'ActorStub' }, fallback => 1;
}

{ package Misc;
  our (%config, %timeout, %players, $field, $char, $playersList, $monstersList, $npcsList, $petsList, $slavesList, $elementalsList);

  sub error { }
  sub debug { }
  sub positionNearPortal { 0 }
  sub canAttack {
    my ($field, $a, $b, $snipe, $maxdist, $sight) = @_;
    return blockDistance($a,$b) <= $maxdist ? 1 : 0;
  }
  sub blockDistance {
    my ($a,$b)=@_;
    my $dx = abs($a->{x} - $b->{x});
    my $dy = abs($a->{y} - $b->{y});
    return $dx > $dy ? $dx : $dy;
  }
  sub distance {
    my ($a,$b)=@_;
    my $dx = $a->{x} - $b->{x};
    my $dy = $a->{y} - $b->{y};
    return sqrt($dx*$dx + $dy*$dy);
  }
  sub calcRectArea2 {
    my ($x,$y,$r)=@_;
    my @res;
    for my $xx ($x-$r..$x+$r) {
      for my $yy ($y-$r..$y+$r) {
        push @res, {x=>$xx,y=>$yy};
      }
    }
    return @res;
  }

  sub get_solution {
    my ($field,$start,$dest)=@_;
    return [] unless $field->isWalkable($start->{x},$start->{y}) && $field->isWalkable($dest->{x},$dest->{y});
    my @dirs = ([-1,0],[1,0],[0,-1],[0,1],[-1,-1],[-1,1],[1,-1],[1,1]);
    my @q = ({x=>$start->{x},y=>$start->{y}});
    my %prev; $prev{"$start->{x},$start->{y}"} = undef;
    my $found;
    while (@q) {
      my $p = shift @q;
      if ($p->{x} == $dest->{x} && $p->{y} == $dest->{y}) { $found = 1; last; }
      for my $d (@dirs) {
        my ($nx,$ny)=($p->{x}+$d->[0],$p->{y}+$d->[1]);
        next unless $field->isWalkable($nx,$ny);
        my $k = "$nx,$ny";
        next if exists $prev{$k};
        $prev{$k} = "$p->{x},$p->{y}";
        push @q, {x=>$nx,y=>$ny};
      }
    }
    return [] unless $found;
    my @path;
    my $cur = "$dest->{x},$dest->{y}";
    while (defined $cur) {
      my ($x,$y)=split /,/, $cur;
      unshift @path, {x=>$x+0,y=>$y+0};
      $cur = $prev{$cur};
    }
    return \@path;
  }

  sub calcTimeFromSolution { my ($sol,$speed)=@_; return (scalar(@$sol) || 1) * ($speed || 0.12); }
  sub calcStepsWalkedFromTimeAndSolution {
    my ($sol,$speed,$time)=@_;
    my $steps = int($time / ($speed||0.12));
    $steps = 0 if $steps < 0;
    my $max = scalar(@$sol)-1;
    $steps = $max if $steps > $max;
    return $steps;
  }
  sub calcTimeFromPathfinding {
    my ($field,$from,$to,$speed)=@_;
    my $sol = get_solution($field,$from,$to);
    return 9999 unless @$sol;
    return calcTimeFromSolution($sol,$speed);
  }
}

{ package AI::Attack;
  our $char;
  sub debug { }
  sub TF { my ($fmt,@a)=@_; return sprintf($fmt,@a); }
  sub meetingPosition { return Misc::meetingPosition(@_); }
}

my $meeting = extract_sub('src/Misc.pm', 'meetingPosition');
my $getwalls = extract_sub('src/Misc.pm', 'getClosestWalls');
my $getmob = extract_sub('src/Misc.pm', 'getPositionMobility');
my $findkite = extract_sub('src/AI/Attack.pm', 'find_kite_position');

my $misc_eval = q{package Misc; our ($field, $char, $playersList, $monstersList, $npcsList, $petsList, $slavesList, $elementalsList); our (%config, %timeout, %players); } . "\n" . $getwalls . "\n" . $getmob . "\n" . $meeting . "\n1;";
eval $misc_eval or die $@;
my $attack_eval = q{package AI::Attack; our ($char); our (%config); } . "\n" . $findkite . "\n1;";
eval $attack_eval or die $@;

# 50x50 scenario with walls, corners, corridors, cul-de-sacs.
my %blocked;
for my $i (0..49) {
  $blocked{"0,$i"}=1; $blocked{"49,$i"}=1; $blocked{"$i,0"}=1; $blocked{"$i,49"}=1;
}
for my $x (5..44) { $blocked{"$x,20"}=1 if $x != 25; }
for my $y (8..42) { $blocked{"30,$y"}=1 if $y != 33; }
for my $x (10..18) { for my $y (30..38) { $blocked{"$x,$y"}=1; } }
for my $x (11..17) { for my $y (31..37) { delete $blocked{"$x,$y"}; } }
for my $x (12..16) { delete $blocked{"$x,31"}; }
for my $x (36..46) { $blocked{"$x,12"}=1; }
for my $y (13..18) { $blocked{"46,$y"}=1; }

$Misc::field = FieldStub->new(w=>50,h=>50,blocked=>\%blocked);
$Misc::playersList = [];
$Misc::monstersList = [];
$Misc::npcsList = [];
$Misc::petsList = [];
$Misc::slavesList = [];
$Misc::elementalsList = [];

%Misc::timeout = (
  meetingPosition_extra_time_actor => { timeout => 0.2 },
  meetingPosition_extra_time_target => { timeout => 0.2 },
);

%Misc::config = (
  runFromTarget => 1,
  runFromTarget_dist => 6,
  runFromTarget_minStep => 7,
  runFromTarget_maxPathDistance => 13,
  runFromTarget_wallRange => 5,
  runFromTarget_noAttackMethodFallback_minStep => 8,
  attackRouteMaxPathDistance => 13,
  attackCanSnipe => 0,
  follow => 0,
  followDistanceMax => 17,
  attackMinPortalDistance => 0,
  clientSight => 14,
  route_avoidWalls => 1,
);

my $char = ActorStub->new(
  pos => {x=>24,y=>24}, pos_to => {x=>24,y=>24}, walk_speed => 0.12,
  time_move => time - 1, solution => [{x=>24,y=>24}], time_move_calc => 0,
);
my $mob = ActorStub->new(
  pos => {x=>25,y=>24}, pos_to => {x=>25,y=>24}, walk_speed => 0.12,
  time_move => time - 1,
);
$Misc::char = $char;
$AI::Attack::char = $char;
%AI::Attack::config = %Misc::config;

my $args = {
  attackMethod => { type => 'weapon', maxDistance => 14 },
};

my $realMyPos = $char->{pos_to};
my $realMobPos = $mob->{pos_to};

my $ok = AI::Attack::find_kite_position($args, 0, $mob, $realMyPos, $realMobPos, 0);

print "simulation_grid=50x50\n";
print "runFromTarget_flow_executed=" . ($ok ? 1 : 0) . "\n";
if ($ok) {
  my ($undef,$x,$y,%opts) = @{$char->{_last_route_args}};
  print "route_destination=$x,$y\n";
  print "route_opts_runFromTarget=$opts{runFromTarget} avoidWalls=$opts{avoidWalls} useManhattan=$opts{useManhattan}\n";
  my $mobility = Misc::getPositionMobility({x=>$x,y=>$y}, $Misc::field);
  my $walls = Misc::getClosestWalls({x=>$x,y=>$y}, $Misc::config{runFromTarget_wallRange}, $Misc::field);
  print "destination_cardinal_openings=$mobility->{cardinal_openings} walkable_neighbors=$mobility->{walkable_neighbors}\n";
  print "destination_closest_wall_count=" . scalar(@$walls) . "\n";
}
