package MapRouteKStepTest;
use strict;
use Test::More;
use FindBin qw($RealBin);
use lib "$RealBin/..";
use lib "$RealBin/../deps";
use lib "$RealBin/../auto/XSTools";
use lib "$RealBin/../..";

use Globals;
use Settings;
use FileParsers;
use Misc qw(compilePortals);
use Task::CalcMapRoute;
use Task::MapRoute;
use Utils qw(parse_portal_conversation_args);

{
	package MapRouteKStepTest::MockInventory;
	sub new { bless {}, shift }
	sub getByNameID { return undef }

	package MapRouteKStepTest::MockChar;
	sub new { bless { zeny => 9_999_999 }, shift }
	sub inventory { MapRouteKStepTest::MockInventory->new() }

	package MapRouteKStepTest::MockActorList;
	sub new { bless { actor => $_[1] }, shift }
	sub getByID {
		my ($self, $id) = @_;
		return unless $self->{actor};
		return $self->{actor} if ($self->{actor}{ID} eq $id);
		return;
	}
}

sub start {
	print "### Starting MapRouteKStepTest\n";

	$Settings::tables_folder = "$RealBin/../../tables/iRO";
	$Settings::fields_folder = "$RealBin/../../fields";

	parseROLUT("$Settings::tables_folder/resnametable.txt", \%mapAlias_lut, 1, ".gat");
	parseROLUT("$Settings::tables_folder/maps.txt", \%maps_lut);
	parsePortals("$Settings::tables_folder/portals.txt", \%portals_lut);
	{ local *Misc::writePortalsLOS = sub {} and compilePortals(); }

	$char = MapRouteKStepTest::MockChar->new();
	$timeout{ai_route_calcRoute}{timeout} = 5;

	my $calc = Task::CalcMapRoute->new(
		sourceMap => 'rachel',
		sourceX   => 275,
		sourceY   => 125,
		map       => 'airplane_01',
		x         => 245,
		y         => 60,
	);
	$calc->activate;
	my $max_iter = 15_000;
	$calc->iterate while ($calc->getStatus != Task::DONE && --$max_iter > 0);
	ok($max_iter > 0, 'CalcMapRoute finished within iteration limit');
	ok(!$calc->getError, 'CalcMapRoute returned without error');

	my $route = $calc->getRoute;
	ok(ref($route) eq 'ARRAY' && @$route >= 2, 'CalcMapRoute produced inter-map route nodes');

	my ($field_to_airship) = grep { $_->{map} eq 'ra_fild12' && $_->{pos}{x} == 295 && $_->{pos}{y} == 208 } @$route;
	ok($field_to_airship, 'Route contains ra_fild12 airship transition node');
	is($field_to_airship->{steps}, 'k c r0', 'Airship transition steps are k c r0');

	my @parsed_steps = parse_portal_conversation_args($field_to_airship->{steps});
	is_deeply(\@parsed_steps, [qw(k c r0)], 'TalkNPC parser reads k-step sequence correctly');

	my ($go_direct_to_npc, $route_dist_from_goal, $talk_trigger_dist) =
		Task::MapRoute::_npcRouteDistancesFromSteps($field_to_airship->{steps}, 8, 10);
	is($go_direct_to_npc, 1, 'MapRoute helper marks k-step as direct-to-NPC');
	is($route_dist_from_goal, 0, 'MapRoute helper sets distFromGoal=0 for k-step');
	is($talk_trigger_dist, 0, 'MapRoute helper sets talk trigger distance=0 for k-step');

	my @distances = (10, 5, 1, 0);
	my @talk_allowed = grep { $_ <= $talk_trigger_dist } @distances;
	is_deeply(\@talk_allowed, [0], 'With k-step, talk starts only at exact portal tile');

	my $portal_id = pack('V', 24);
	my $portal_actor = bless {
		ID  => $portal_id,
		pos => { x => 295, y => 208 },
	}, 'Actor::Portal';
	$portalsList = MapRouteKStepTest::MockActorList->new($portal_actor);
	$npcsList = MapRouteKStepTest::MockActorList->new();
	$monstersList = MapRouteKStepTest::MockActorList->new();
	my $fake_maproute = bless {
		mapSolution => [{
			pos   => { x => 295, y => 208 },
			steps => 'k c r0',
		}],
	}, 'Task::MapRoute';
	{
		no warnings 'redefine';
		local *AI::findAction = sub { return 0 if $_[0] eq 'mapRoute'; return undef; };
		local *AI::args = sub { return $fake_maproute; };
		is(Misc::resolveAutoNpcTalkSequence($portal_id), 'c r0', 'autoNpcTalk resolves sequence from mapRoute and drops leading k for active dialog');
	}
}

1;
