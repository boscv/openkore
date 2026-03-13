# OpenKore Symptom Index

This document maps common user problems to relevant documentation.

It helps the assistant quickly identify which subsystem may be responsible.

---

## Bot Not Moving

Possible causes:

- routing failure
- pathfinding issues
- configuration preventing movement
- plugin overriding behavior

See:

- debugging.md
- system_flows.md

---

## NPC Interaction Not Working

Possible causes:

- packet desynchronization
- incorrect map coordinates
- interaction sequence failure

See:

- system_flows.md
- debugging.md

---

## Plugin Not Loading

Possible causes:

- plugin registration failure
- syntax errors
- missing hooks

See:

- plugin_config_system.md
- debugging.md

---

## Macro Not Triggering

Possible causes:

- incorrect macro syntax
- event condition not met
- configuration conflict

See:

- plugin_config_system.md
- development.md

---

## Packet Desynchronization

Possible causes:

- networking issues
- incorrect packet interpretation
- server-specific behavior

See:

- system_flows.md
- debugging.md

---

## Movement Visible In Bot But Not In Client

Possible causes:

- client synchronization issue
- packet handling problem

See:

- networking_packets.md
- debugging.md