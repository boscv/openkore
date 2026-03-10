# Execution Flows

## AI decision loop
1. `core/functions.pl` runs the main loop and enters initialized state.
2. AI stack calls into `core/AI.pm` and `core/AI/CoreLogic.pm`.
3. Decisions enqueue/update tasks via `core/TaskManager.pm`.

## NPC interaction flow
1. AI/commands request NPC interaction.
2. `core/Task/TalkNPC.pm` drives conversation steps.
3. Packet responses are consumed via `core/Network/Receive.pm` handlers and reflected back into task state.

## Packet receive flow
1. Raw network data is managed through `core/Network.pm` runtime state.
2. `core/Network/PacketParser.pm` resolves packet framing and decode shape.
3. `core/Network/Receive.pm` dispatches switch-specific logic updating globals/actors/tasks.

## Routing and movement flow
1. AI or commands schedule movement-related tasks.
2. `core/Task/Route.pm` computes route-level progression.
3. `core/Task/Move.pm` executes movement steps and reacts to packet/position updates.

## Actor state updates
1. Incoming packets are decoded and mapped in `core/Network/Receive.pm`.
2. Actor entities from `core/Actor.pm` are created/updated.
3. Collections in `core/ActorList.pm` are synchronized and used by AI/task decisions.
