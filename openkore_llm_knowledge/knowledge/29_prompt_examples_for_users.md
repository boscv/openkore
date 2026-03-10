# Prompt Examples for Users

Realistic prompts users can ask an OpenKore-focused GPT assistant.

## Architecture and code navigation
1. "Explain how `src/functions.pl` orchestrates the OpenKore main loop."
2. "Map the dependency chain between AI, TaskManager, and Network::Send."
3. "Which modules should I read first to understand actor updates from packets?"
4. "Summarize how plugin hooks interact with command execution."

## Debugging
5. "My bot stopped moving. Give me a step-by-step diagnosis plan with files to inspect."
6. "How do I distinguish packet desync from route calculation failure?"
7. "Generate a troubleshooting checklist for NPC dialogue failures."
8. "Why are my plugin hooks not firing even though plugin loads fine?"
9. "Help me debug eventMacro that parses but never triggers."
10. "Create a minimal reproduction plan for XKore client sync issues."

## Plugins
11. "Create a minimal plugin skeleton with register, hooks, and unload cleanup."
12. "Add a custom command `farmstatus` that prints current map and task."
13. "Show best practices for lightweight hook callbacks in OpenKore plugins."
14. "How do I instrument a plugin with debug logs without spamming output?"

## Macro / eventMacro
15. "Write an automacro that pauses looting above 85% weight."
16. "Create eventMacro rules to send a chat message only once when entering Prontera."
17. "Compare macro and eventMacro for reactive combat behavior."
18. "How can I test whether a macro trigger condition is actually true at runtime?"

## Routing and movement
19. "Explain why route tasks can oscillate and how to debug it."
20. "Show a script strategy to test short movement segments before full routes."
21. "What configs can block movement even if route exists?"

## Networking and packets
22. "How do I verify that serverType and recvpackets are correctly configured?"
23. "Trace one incoming movement packet from socket bytes to Actor update."
24. "What logs should I capture when packet decode errors start after a patch?"
25. "Explain where to add temporary logging for packet send construction."

## Configuration
26. "Review my config goals and suggest a minimal stable `config.txt` baseline."
27. "Which `mon_control.txt` settings commonly interfere with movement tasks?"
28. "How do lockMap and saveMap influence AI behavior?"

## Learning and onboarding
29. "Build me a 2-week learning plan to become productive in OpenKore development."
30. "Give me a study order for networking, AI, tasks, plugins, and macros with exercises."
