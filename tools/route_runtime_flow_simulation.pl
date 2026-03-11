# Runtime simulation to be executed inside OpenKore via:
#   perl openkore.pl --no-connect --command "eval do q{tools/route_runtime_flow_simulation.pl}"

use strict;
use warnings;

use Globals qw(%config %monsters @spellsID %spells $field $quit);
use Field;
use Settings;
use Task;
use Task::Route;

{
	package RouteRuntimeSim::MockSkill;
	sub new { bless { id => $_[1] }, $_[0] }
	sub getIDN { $_[0]->{id} }
}

sub _hazard_cells {
	my ($cx, $cy, $r) = @_;
	my %out;
	for my $x ($cx - $r .. $cx + $r) {
		for my $y ($cy - $r .. $cy + $r) {
			next if abs($x - $cx) + abs($y - $cy) > $r;
			$out{"$x,$y"} = 1;
		}
	}
	return \%out;
}

sub _intersects_hazard {
	my ($path, $haz) = @_;
	for my $step (@{$path}) {
		return 1 if $haz->{$step->{x} . ',' . $step->{y}};
	}
	return 0;
}

sub _find_line_scenario {
	my ($map, $distance, $radius) = @_;
	my $w = $map->{width};
	my $h = $map->{height};

	for my $y ($radius + 2 .. $h - $radius - 3) {
		for my $x (2 .. $w - $distance - 3) {
			my $start = {x => $x, y => $y};
			my $goal = {x => $x + $distance, y => $y};
			my $center = {x => $x + int($distance / 2), y => $y};

			next unless $map->isWalkable($start->{x}, $start->{y}) && $map->isWalkable($goal->{x}, $goal->{y});

			my $ok = 1;
			for my $px ($start->{x} .. $goal->{x}) {
				$ok = 0, last unless $map->isWalkable($px, $y);
			}
			next unless $ok;

			my $haz = _hazard_cells($center->{x}, $center->{y}, $radius);
			for my $coord (keys %{$haz}) {
				my ($hx, $hy) = split /,/, $coord;
				$ok = 0, last unless $map->isWalkable($hx, $hy);
			}
			next unless $ok;

			my $detourY = $y - ($radius + 1);
			next if $detourY < 0;
			for my $px ($start->{x} .. $goal->{x}) {
				$ok = 0, last unless $map->isWalkable($px, $detourY);
			}
			next unless $ok;

			return ($start, $goal, $center);
		}
	}

	die "Could not find a suitable walkable line scenario on map " . $map->name . "\n";
}

sub _plan {
	my ($start, $goal) = @_;
	my @solution;
	my $ok = Task::Route->getRoute(\@solution, $field, $start, $goal, 1, 0, 0, 1);
	die "getRoute failed\n" unless $ok && @solution;
	return \@solution;
}

sub _simulate_attack_flow {
	my ($start, $monster_pos, $cast_center, $radius) = @_;

	my %timeline = (
		cast_start => 2,
		cast_end => 3,
		persist_start => 4,
		persist_end => 7,
	);

	my $bot = {x => $start->{x}, y => $start->{y}};
	my @trace = ({%{$bot}});

	for my $tick (0 .. 11) {
		@spellsID = ();
		%spells = ();
		%monsters = ();

		if ($tick >= $timeline{cast_start} && $tick <= $timeline{cast_end}) {
			%monsters = (
				M1 => {
					aggressive => 1,
					pos_to => {x => $monster_pos->{x}, y => $monster_pos->{y}},
					casting => {
						x => $cast_center->{x},
						y => $cast_center->{y},
						skill => RouteRuntimeSim::MockSkill->new(0xDEAD),
					},
				}
			);
		} elsif ($tick >= $timeline{persist_start} && $tick <= $timeline{persist_end}) {
			%monsters = (
				M1 => {
					aggressive => 1,
					pos_to => {x => $monster_pos->{x}, y => $monster_pos->{y}},
				}
			);
			@spellsID = ('SPELL1');
			%spells = (
				SPELL1 => {
					sourceID => 'M1',
					pos => { x => $cast_center->{x}, y => $cast_center->{y} },
					range => $radius,
					type => 0xDEAD,
				}
			);
		}

		my $path = _plan($bot, $monster_pos);
		last if @{$path} < 2;

		$bot = {x => $path->[1]{x}, y => $path->[1]{y}};
		push @trace, {%{$bot}};

		last if $bot->{x} == $monster_pos->{x} && $bot->{y} == $monster_pos->{y};
	}

	return \@trace;
}

sub run {
	local $quit;

	# Allow standalone execution without full OpenKore bootstrap.
	$Settings::fields_folder = 'fields' if -d 'fields';

	$field = Field->new(name => 'prontera') unless $field && $field->name eq 'prontera';
	$config{route_avoidSkillArea} = 1;

	my ($start, $goal, $center) = _find_line_scenario($field, 10, 1);
	my $hazard_real = _hazard_cells($center->{x}, $center->{y}, 1);

	no warnings 'redefine';
	local *Task::Route::judgeSkillArea = sub {
		my ($skill_id) = @_;
		return 1 if $skill_id == 0xDEAD;
		return 0;
	};

	@spellsID = ();
	%spells = ();
	%monsters = ();
	my $baseline = _plan($start, $goal);
	my $baseline_hit = _intersects_hazard($baseline, $hazard_real); # expected: can be true because no hazard is active yet

	my $attack_trace = _simulate_attack_flow($start, $goal, $center, 1);
	my $attack_hit = _intersects_hazard($attack_trace, $hazard_real);

	print "[route-runtime-sim] map=" . $field->name . " bot_start=($start->{x},$start->{y}) monster=($goal->{x},$goal->{y}) skill_center=($center->{x},$center->{y})\n";
	print "[route-runtime-sim] phase=baseline_to_target steps=" . scalar(@{$baseline}) . " intersects_future_hazard=$baseline_hit\n";
	print "[route-runtime-sim] phase=attack_flow ticks=" . (scalar(@{$attack_trace}) - 1) . " intersects_hazard=$attack_hit\n";

	die "Simulation failed: attack-flow trace intersects hazard\n" if $attack_hit;

	print "[route-runtime-sim] OK: attack flow avoided skill area while monster casted + persisted ground skill.\n";

	$quit = 1;
}

run();
1;
