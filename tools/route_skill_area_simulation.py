#!/usr/bin/env python3
"""Simula evasão de área de skill (casting + persistência) em grid 10x10.

Compara dois modelos:
- old_center_only: skill persistida bloqueia só célula central.
- new_full_area: skill persistida bloqueia toda área (diamante de block distance).

A simulação recalcula rota a cada tick e anda 1 célula por tick em direção ao alvo.
"""

from __future__ import annotations

import heapq
from dataclasses import dataclass

W = H = 10


@dataclass(frozen=True)
class Scenario:
    name: str
    start: tuple[int, int]
    goal: tuple[int, int]
    cast_center: tuple[int, int]
    cast_start: int
    cast_end: int
    persist_start: int
    persist_end: int
    radius: int


def neighbors(x: int, y: int):
    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
        nx, ny = x + dx, y + dy
        if 0 <= nx < W and 0 <= ny < H:
            yield nx, ny


def diamond(cx: int, cy: int, r: int) -> set[tuple[int, int]]:
    out = set()
    for x in range(cx - r, cx + r + 1):
        for y in range(cy - r, cy + r + 1):
            if 0 <= x < W and 0 <= y < H and abs(x - cx) + abs(y - cy) <= r:
                out.add((x, y))
    return out


def astar(start: tuple[int, int], goal: tuple[int, int], blocked: set[tuple[int, int]]):
    pq = [(0, start)]
    g = {start: 0}
    prev: dict[tuple[int, int], tuple[int, int]] = {}

    while pq:
        _, u = heapq.heappop(pq)
        if u == goal:
            break
        for v in neighbors(*u):
            if v in blocked:
                continue
            ng = g[u] + 1
            if ng < g.get(v, 10**9):
                g[v] = ng
                prev[v] = u
                h = abs(v[0] - goal[0]) + abs(v[1] - goal[1])
                heapq.heappush(pq, (ng + h, v))

    if goal not in g:
        return None

    path = [goal]
    while path[-1] != start:
        path.append(prev[path[-1]])
    path.reverse()
    return path


def blocked_cells(s: Scenario, tick: int, model: str):
    if s.cast_start <= tick <= s.cast_end:
        return diamond(*s.cast_center, s.radius)
    if s.persist_start <= tick <= s.persist_end:
        if model == "old_center_only":
            return {s.cast_center}
        return diamond(*s.cast_center, s.radius)
    return set()


def simulate(s: Scenario, model: str):
    pos = s.start
    trace = [pos]
    stepped_on_hazard = False

    for tick in range(0, s.persist_end + 4):
        hazard_real = blocked_cells(s, tick, "new_full_area")
        blocked = blocked_cells(s, tick, model)

        if pos in hazard_real:
            stepped_on_hazard = True

        if pos == s.goal:
            break

        path = astar(pos, s.goal, blocked)
        if not path or len(path) < 2:
            trace.append(pos)
            continue

        pos = path[1]
        trace.append(pos)

    if pos in blocked_cells(s, s.persist_end, "new_full_area"):
        stepped_on_hazard = True

    return trace, stepped_on_hazard


def main():
    scenarios = [
        Scenario("horizontal_lr", (0, 5), (9, 5), (5, 5), 2, 4, 5, 8, 1),
        Scenario("horizontal_rl", (9, 5), (0, 5), (5, 5), 2, 4, 5, 8, 1),
        Scenario("vertical_tb", (5, 0), (5, 9), (5, 5), 2, 4, 5, 8, 1),
        Scenario("vertical_bt", (5, 9), (5, 0), (5, 5), 2, 4, 5, 8, 1),
    ]

    print("Simulação 10x10: bot e monstro em lados opostos; casting + skill persistente")
    print("Legenda: hazard_hit indica passar em célula perigosa real (área completa).\n")

    old_any_hit = False
    new_any_hit = False

    for s in scenarios:
        old_trace, old_hit = simulate(s, "old_center_only")
        new_trace, new_hit = simulate(s, "new_full_area")
        old_any_hit |= old_hit
        new_any_hit |= new_hit

        print(f"[{s.name}] old_center_only: steps={len(old_trace)-1}, hazard_hit={old_hit}")
        print(f"[{s.name}] new_full_area : steps={len(new_trace)-1}, hazard_hit={new_hit}")
        print(f"  old head/tail: {old_trace[:6]} ... {old_trace[-6:]}")
        print(f"  new head/tail: {new_trace[:6]} ... {new_trace[-6:]}")
        print()

    assert old_any_hit, "Esperado: modelo antigo deveria acertar área perigosa em pelo menos 1 cenário"
    assert not new_any_hit, "Esperado: modelo novo não deve acertar área perigosa"

    print("OK: modelo com área completa contorna a skill durante casting e persistência.")


if __name__ == "__main__":
    main()
