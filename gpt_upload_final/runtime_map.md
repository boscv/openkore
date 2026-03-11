# OpenKore Runtime Execution Map

This document summarizes how OpenKore operates during runtime.

It provides a simplified overview of the main execution loop.

---

## Main Runtime Flow

Main Loop  
↓  
AI Tick  
↓  
Check Task Queue  
↓  
Execute Task  
↓  
Action Performed  
(movement, combat, interaction)  
↓  
Packet Sent To Server  
↓  
Server Response Received  
↓  
Packet Handler Processes Data  
↓  
Actor State Updated  
↓  
AI Loop Continues

---

## Important Runtime Components

### AI System

Responsible for decision-making and task scheduling.

### Actor System

Represents entities in the game world:

- player
- monsters
- NPCs
- other players

### Networking System

Handles packet communication between OpenKore and the game server.

### Task System

Manages AI tasks such as:

- routing
- combat
- interaction

---

## Runtime Behavior Sources

OpenKore behavior can originate from several sources:

- core AI logic
- configuration files
- macros and eventMacros
- plugins
- server packet responses

Understanding which subsystem is responsible is critical when debugging issues.