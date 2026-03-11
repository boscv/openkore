#!/usr/bin/env python3
"""
Extended runFromTarget/kiting simulation.

Goals:
- Use key AI-flow equivalents:
  - find_kite_position -> meetingPosition
  - getClosestWalls
  - getPositionMobility
  - route/path reachability checks
- Simulate realistic 80x80 maps with walls, corners, dead ends, loose obstacles.
- Run 6 scenarios for 5 minutes worth of ticks each:
  1) ranged kiting vs 1 monster
  2) ranged kiting vs 2 monsters
  3) ranged kiting vs 3 monsters
  4) short-range kiting vs 1 monster
  5) short-range kiting vs 2 monsters
  6) short-range kiting vs 3 monsters

Failure conditions:
- stuck/trapped: no effective movement for prolonged window while under threat.
- encircled: low local exits while multiple monsters adjacent.
- unsafe breakout: bot chooses route steps through monster-occupied cells repeatedly.
"""
from collections import deque
from dataclasses import dataclass
import math

TICKS_5_MIN = 300  # 1 tick ~= 1s

@dataclass
class Actor:
    x: int
    y: int
    walk_speed: float = 0.12

class Field:
    def __init__(self, w, h, blocked):
        self.w, self.h = w, h
        self.blocked = set(blocked)

    def isWalkable(self, x, y):
        return 0 <= x < self.w and 0 <= y < self.h and (x, y) not in self.blocked


def block_distance(a, b):
    return max(abs(a[0]-b[0]), abs(a[1]-b[1]))

def euclidean_distance(a, b):
    dx, dy = a[0]-b[0], a[1]-b[1]
    return (dx*dx + dy*dy) ** 0.5

def can_attack(spot, target, attack_max_distance):
    return block_distance(spot, target) <= attack_max_distance

def neighbors8(pos):
    x, y = pos
    for dx, dy in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(-1,1),(1,-1),(1,1)]:
        yield (x+dx, y+dy)

def neighbors4(pos):
    x, y = pos
    for dx, dy in [(-1,0),(1,0),(0,-1),(0,1)]:
        yield (x+dx, y+dy)

def bfs_tree(field, start, avoid_walls=True):
    if not field.isWalkable(*start):
        return {}, {}
    q = deque([start])
    prev = {start: None}
    dist = {start: 0}
    while q:
        p = q.popleft()
        cands = []
        for np in neighbors8(p):
            if np in prev or not field.isWalkable(*np):
                continue
            if avoid_walls:
                openings = sum(1 for n2 in neighbors4(np) if field.isWalkable(*n2))
                cands.append((-(openings), np))
            else:
                cands.append((0, np))
        cands.sort(key=lambda x: x[0])
        for _, np in cands:
            prev[np] = p
            dist[np] = dist[p] + 1
            q.append(np)
    return prev, dist


def path_from_prev(prev, dest):
    if dest not in prev:
        return []
    path = []
    cur = dest
    while cur is not None:
        path.append(cur)
        cur = prev[cur]
    path.reverse()
    return path


def get_solution(field, start, dest, avoid_walls=True):
    prev, _ = bfs_tree(field, start, avoid_walls=avoid_walls)
    return path_from_prev(prev, dest)

def getClosestWalls(field, from_pos, wall_range):
    closest_d = None
    walls = []
    for dx in range(-wall_range, wall_range+1):
        for dy in range(-wall_range, wall_range+1):
            if dx == 0 and dy == 0:
                continue
            c = (from_pos[0]+dx, from_pos[1]+dy)
            if field.isWalkable(*c):
                continue
            d = euclidean_distance(c, from_pos)
            if closest_d is None or d < closest_d:
                closest_d = d
                walls = [c]
            elif d == closest_d:
                walls.append(c)
    return walls

def getPositionMobility(field, pos):
    walkable_neighbors = sum(1 for n in neighbors8(pos) if field.isWalkable(*n))
    cardinal_openings = sum(1 for n in neighbors4(pos) if field.isWalkable(*n))
    return {"walkable_neighbors": walkable_neighbors, "cardinal_openings": cardinal_openings}

def calc_time_from_solution(solution, speed):
    return len(solution) * speed

def calc_time_from_pathfinding(field, start, dest, speed, avoid_walls=True):
    sol = get_solution(field, start, dest, avoid_walls)
    if not sol:
        return float("inf")
    return calc_time_from_solution(sol, speed)

def meetingPosition(field, actor, target, monsters, attack_max_distance, cfg):
    real_my_pos = (actor.x, actor.y)
    real_target_pos = (target.x, target.y)

    max_path_dist = cfg["runFromTarget_maxPathDistance"] + 1
    min_destination_dist = cfg["runFromTarget_minStep"]

    prev_actor, dist_actor = bfs_tree(field, real_my_pos, avoid_walls=cfg["route_avoidWalls"])
    prev_target, dist_target = bfs_tree(field, real_target_pos, avoid_walls=False)

    # prohibited: occupied by monsters right now
    prohibited = { (m.x, m.y) for m in monsters }

    best = None
    for x in range(real_my_pos[0]-max_path_dist, real_my_pos[0]+max_path_dist+1):
        for y in range(real_my_pos[1]-max_path_dist, real_my_pos[1]+max_path_dist+1):
            spot = (x, y)
            if spot == real_my_pos:
                continue
            if not field.isWalkable(*spot):
                continue
            if spot in prohibited:
                continue

            if spot not in dist_actor:
                continue
            if dist_actor[spot] + 1 > max_path_dist:
                continue
            solution = path_from_prev(prev_actor, spot)
            if not solution:
                continue

            if not can_attack(spot, real_target_pos, attack_max_distance):
                continue

            dist_to_target = block_distance(spot, real_target_pos)
            if dist_to_target < min_destination_dist:
                continue

            min_dist_to_any_monster = min(block_distance(spot, (m.x, m.y)) for m in monsters)
            if min_dist_to_any_monster <= 1:
                continue

            time_actor = calc_time_from_solution(solution, actor.walk_speed)
            time_target = (dist_target[spot] + 1) * target.walk_speed if spot in dist_target else float("inf")
            if time_actor > time_target:
                continue

            mobility = getPositionMobility(field, spot)
            mobility_score = mobility["cardinal_openings"] * 100 + mobility["walkable_neighbors"]

            closest_wall_distance = None
            closest_wall_count = None
            if cfg["runFromTarget_wallRange"] > 0:
                closest_walls = getClosestWalls(field, spot, cfg["runFromTarget_wallRange"])
                closest_wall_count = len(closest_walls)
                closest_wall_distance = (
                    euclidean_distance(spot, closest_walls[0])
                    if closest_wall_count > 0
                    else (cfg["runFromTarget_wallRange"] + 1)
                )

            # extra anti-encirclement term: distance from center of pursuing monsters
            cx = sum(m.x for m in monsters) / max(1, len(monsters))
            cy = sum(m.y for m in monsters) / max(1, len(monsters))
            anti_surround = euclidean_distance(spot, (cx, cy))

            cand = {
                "spot": spot,
                "solution": solution,
                "time": time_actor,
                "mobility_score": mobility_score,
                "cardinal_openings": mobility["cardinal_openings"],
                "closest_wall_distance": closest_wall_distance,
                "closest_wall_count": closest_wall_count,
                "anti_surround": anti_surround,
                "dist_to_target": dist_to_target,
                "min_dist_to_any_monster": min_dist_to_any_monster,
            }

            if best is None:
                best = cand
                continue

            better = False
            if cand["min_dist_to_any_monster"] > best["min_dist_to_any_monster"]:
                better = True
            elif cand["mobility_score"] > best["mobility_score"]:
                better = True
            elif cand["mobility_score"] == best["mobility_score"] and cand["cardinal_openings"] > best["cardinal_openings"]:
                better = True
            elif cand["anti_surround"] > best["anti_surround"] + 0.2:
                better = True
            elif cfg["runFromTarget_wallRange"] > 0 and cand["closest_wall_distance"] is not None:
                if best["closest_wall_distance"] is None or cand["closest_wall_distance"] > best["closest_wall_distance"]:
                    better = True
                elif cand["closest_wall_distance"] == best["closest_wall_distance"] and cand["closest_wall_count"] < best["closest_wall_count"]:
                    better = True
            elif cand["time"] < best["time"]:
                better = True

            if better:
                best = cand

    return best

def find_kite_position(field, bot, monsters, cfg, attack_max_distance):
    # choose the closest monster as current target (attack-like flow)
    target = min(monsters, key=lambda m: block_distance((bot.x, bot.y), (m.x, m.y)))
    return meetingPosition(field, bot, target, monsters, attack_max_distance, cfg), target

def monster_step_towards(field, monster, goal, occupied):
    start = (monster.x, monster.y)
    sol = get_solution(field, start, goal, avoid_walls=False)
    if len(sol) >= 2:
        nxt = sol[1]
        # do not step into bot cell or into another monster cell
        if nxt != goal and nxt not in occupied:
            occupied.discard((monster.x, monster.y))
            monster.x, monster.y = nxt
            occupied.add((monster.x, monster.y))

def make_realistic_map_80():
    blocked = set()
    W = H = 80

    # border
    for i in range(80):
        blocked.add((0, i)); blocked.add((79, i)); blocked.add((i, 0)); blocked.add((i, 79))

    # long walls with choke points
    for x in range(5, 75):
        if x not in (18, 40, 62):
            blocked.add((x, 22))
    for x in range(8, 72):
        if x not in (15, 35, 55):
            blocked.add((x, 47))
    for y in range(10, 70):
        if y not in (20, 44, 66):
            blocked.add((30, y))
    for y in range(7, 76):
        if y not in (14, 33, 58):
            blocked.add((58, y))

    # cul-de-sacs / corners
    for x in range(10, 20):
        blocked.add((x, 65))
        blocked.add((x, 74))
    for y in range(65, 75):
        blocked.add((10, y))
    for x in range(11, 19):
        for y in range(66, 74):
            if y != 70:
                blocked.discard((x, y))

    # scattered objects
    for x in range(12, 70, 7):
        for y in range(9, 72, 9):
            blocked.add((x, y))

    # corner blocks
    for x in range(65, 75):
        for y in range(10, 20):
            if x in (65, 74) or y in (10, 19):
                blocked.add((x, y))

    return Field(W, H, blocked)

def evaluate_encircled(field, bot_pos, monsters):
    adjacent_monsters = sum(1 for m in monsters if block_distance(bot_pos, (m.x, m.y)) <= 1)
    card_openings = sum(1 for n in neighbors4(bot_pos) if field.isWalkable(*n))
    return adjacent_monsters >= 2 and card_openings <= 1

def choose_escape_step(field, bot, monsters, recent_positions):
    cur = (bot.x, bot.y)
    candidates = [cur] + [n for n in neighbors8(cur) if field.isWalkable(*n)]
    occupied = {(m.x, m.y) for m in monsters}
    best = cur
    best_score = -10**9
    for c in candidates:
        if c in occupied:
            continue
        min_d = min(block_distance(c, (m.x, m.y)) for m in monsters)
        mobility = getPositionMobility(field, c)
        revisit_penalty = recent_positions.count(c) * 12
        score = (min_d * 100) + (mobility["cardinal_openings"] * 10) + mobility["walkable_neighbors"] - revisit_penalty
        if score > best_score:
            best_score = score
            best = c
    return best

def run_scenario(name, monster_count, attack_max_distance):
    field = make_realistic_map_80()
    bot = Actor(40, 40)
    starts = [(42, 40), (38, 42), (43, 43)]
    monsters = [Actor(*starts[i]) for i in range(monster_count)]

    cfg = {
        "runFromTarget_minStep": (6 if attack_max_distance >= 5 else (5 if monster_count >= 2 else 3)),
        "runFromTarget_maxPathDistance": 13,
        "runFromTarget_wallRange": 6,
        "route_avoidWalls": 1,
    }

    stuck_counter = 0
    unsafe_breakout_counter = 0
    no_escape_under_threat_counter = 0
    prev_positions = deque(maxlen=20)

    for tick in range(TICKS_5_MIN):
        prev_bot_pos = (bot.x, bot.y)

        nearest_before = min(block_distance((bot.x, bot.y), (m.x, m.y)) for m in monsters)
        moved = False
        if nearest_before <= 1:
            dash_steps = 2 if len(monsters) >= 2 else 1
            for _ in range(dash_steps):
                ex, ey = choose_escape_step(field, bot, monsters, list(prev_positions))
                if (ex, ey) != (bot.x, bot.y):
                    bot.x, bot.y = ex, ey
                    moved = True

        kite, target = find_kite_position(field, bot, monsters, cfg, attack_max_distance)
        if kite and len(kite["solution"]) >= 2:
            # one step per tick on planned route
            nxt = kite["solution"][1]
            if nxt in {(m.x, m.y) for m in monsters}:
                unsafe_breakout_counter += 1
            else:
                bot.x, bot.y = nxt
                moved = True

        if not moved:
            ex, ey = choose_escape_step(field, bot, monsters, list(prev_positions))
            if (ex, ey) != (bot.x, bot.y):
                bot.x, bot.y = ex, ey

        # monsters chase the bot
        occupied = {(m.x, m.y) for m in monsters}
        for m in monsters:
            monster_step_towards(field, m, (bot.x, bot.y), occupied)

        if any((m.x, m.y) == (bot.x, bot.y) for m in monsters):
            no_escape_under_threat_counter += 3

        # threat evaluation
        nearest = min(block_distance((bot.x, bot.y), (m.x, m.y)) for m in monsters)
        under_threat = nearest <= 1

        prev_positions.append((bot.x, bot.y))
        if (bot.x, bot.y) == prev_bot_pos and under_threat:
            stuck_counter += 1
        else:
            stuck_counter = max(0, stuck_counter - 1)

        unique_recent = len(set(prev_positions))
        if len(monsters) >= 2 and under_threat and unique_recent <= 2 and len(prev_positions) == prev_positions.maxlen:
            no_escape_under_threat_counter += 1
        else:
            no_escape_under_threat_counter = max(0, no_escape_under_threat_counter - 1)

        if evaluate_encircled(field, (bot.x, bot.y), monsters):
            no_escape_under_threat_counter += 2

        if no_escape_under_threat_counter > 40 or unsafe_breakout_counter > 10:
            return {
                "name": name,
                "pass": False,
                "tick": tick,
                "stuck_counter": stuck_counter,
                "no_escape_counter": no_escape_under_threat_counter,
                "unsafe_breakout_counter": unsafe_breakout_counter,
                "bot": (bot.x, bot.y),
                "monsters": [(m.x, m.y) for m in monsters],
            }

    return {
        "name": name,
        "pass": True,
        "tick": TICKS_5_MIN,
        "stuck_counter": stuck_counter,
        "no_escape_counter": no_escape_under_threat_counter,
        "unsafe_breakout_counter": unsafe_breakout_counter,
        "bot": (bot.x, bot.y),
        "monsters": [(m.x, m.y) for m in monsters],
    }

if __name__ == "__main__":
    scenarios = [
        ("ranged_1_monster", 1, 14),
        ("ranged_2_monsters", 2, 14),
        ("ranged_3_monsters", 3, 14),
        ("short_range_1_monster", 1, 4),
        ("short_range_2_monsters", 2, 4),
        ("short_range_3_monsters", 3, 4),
    ]

    print("grid=80x80 ticks=300")
    overall_pass = True
    for name, n, dist in scenarios:
        res = run_scenario(name, n, dist)
        state = "PASS" if res["pass"] else "FAIL"
        print(
            f"{name}: {state} | tick={res['tick']} | "
            f"stuck={res['stuck_counter']} no_escape={res['no_escape_counter']} "
            f"unsafe_breakout={res['unsafe_breakout_counter']} "
            f"bot={res['bot']} monsters={res['monsters']}"
        )
        overall_pass = overall_pass and res["pass"]

    if not overall_pass:
        raise SystemExit(1)
