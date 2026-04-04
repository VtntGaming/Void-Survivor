VOID SURVIVOR - EXTENDED GDD SUMMARY
====================================

1. PROJECT OVERVIEW
-------------------
Void Survivor is a top-down arena survival shooter built with Love2D (Lua). The player controls a spaceship in a closed 2D battlefield and survives increasingly difficult enemy waves. The main goal is to stay alive as long as possible, defeat enemies, collect power-ups, and achieve a high score.

The game targets short, highly replayable arcade sessions with responsive movement, readable combat, and strong sci-fi presentation.

2. CORE PILLARS
---------------
- Fast and readable combat
- High replayability through escalating waves and random spawns
- Satisfying power-up driven build variety
- Strong dark sci-fi atmosphere with neon feedback
- Easy to learn, hard to master arcade loop

3. CORE GAMEPLAY LOOP
---------------------
1. Start from the main menu
2. Spawn the player in the arena
3. Fight through enemy waves
4. Collect dropped power-ups
5. Survive longer as difficulty rises
6. Reach Game Over, review score/stats, restart or return to menu

State flow:
Menu -> Playing -> Pause -> Playing
Playing -> Game Over -> Menu or Restart

4. CURRENT GAMEPLAY FEATURES
----------------------------
Player:
- 4-direction movement with WASD / Arrow keys
- Mouse aiming and shooting
- Health system with invincibility frames
- Temporary buffs and weapon upgrades

Enemies:
- Chaser: basic pursuer
- Shooter: ranged enemy with distance control
- Tank: slow, durable, high-damage enemy
- Speeder: fast evasive enemy
- Boss: multi-phase enemy appearing on boss waves

Progression:
- Waves scale in count and pressure over time
- Boss waves appear regularly
- Combo scoring rewards aggressive play
- Difficulty options: Easy / Normal / Hard

Power-Ups:
- Health
- Speed Boost
- Rapid Fire
- Shield
- Spread Shot
- Heavy Shot

5. LEVEL / ENCOUNTER DESIGN
---------------------------
The game currently uses one fixed arena for clarity and combat focus. Replayability comes from:
- wave progression
- enemy mix escalation
- random edge spawning
- power-up drops
- score/combo optimization

This is a controlled procedural structure: the arena is fixed, but encounters vary enough to keep runs fresh.

6. UI / UX DIRECTION
--------------------
Main Menu:
- Start game
- Difficulty selection
- High score display
- Quick control hints

Gameplay HUD:
- HP bar
- Score and best score
- Wave display
- Combo feedback
- Active power-up and weapon timers

Pause / Game Over:
- Resume, restart, quit-to-menu flow
- End-of-run stats including kill breakdown

Visual direction for UI:
- clean, futuristic, readable
- subtle circular sci-fi HUD inspiration
- should never obscure active combat

7. CONTROLS
-----------
Current:
- Move: WASD / Arrow keys
- Aim: Mouse
- Shoot: Left Mouse Button
- Pause: ESC
- Fullscreen toggle: F11
- Start / Restart: Enter

Planned:
- Gamepad support
- Remappable controls
- Auto-fire option

8. ART & AUDIO DIRECTION
------------------------
Art Style:
- Dark sci-fi setting
- Neon accents and strong silhouette readability
- Hero ship should feel sleek, fast, and visually distinct
- Reference mood: alien ruins, space battlefield, futuristic orange/blue contrast

Audio Style:
- Retro synth / electronic / space ambient music
- Crisp arcade sound effects for shooting, hits, pickups, and explosions
- Boss moments should feel more dramatic through sound and screen feedback

9. TECHNICAL ARCHITECTURE
-------------------------
The current project uses a controller-based architecture:
- `GameController` for overall flow
- gameplay controllers for spawning, scoring, collisions, entities, and waves
- rendering controllers for background, HUD, and effects
- input, audio, and save controllers
- `EventBus` for decoupled communication

This structure is already suitable for continued prototype-to-demo development.

10. PERFORMANCE & IMPLEMENTATION NOTES
--------------------------------------
Current focus:
- maintain smooth 60 FPS
- keep combat readable under heavy spawn load
- cap bullets / particles / power-ups for stability

Future technical improvements:
- pooling if allocation pressure becomes noticeable
- spatial partitioning if collision checks scale too high
- stronger save-data validation and debug tools

11. ASSET NEEDS
---------------
Visual Assets:
- player ship sprite(s)
- enemy sprites by type
- bullet and power-up icons
- background / arena art layers
- menu / HUD icons and fonts

Audio Assets:
- shoot / hit / explosion / pickup SFX
- menu and gameplay BGM loops

12. ROADMAP SUMMARY
-------------------
Near-term priorities:
- rebalance difficulty and pacing
- improve onboarding and tutorial clarity
- expand settings and accessibility options
- strengthen visual identity and polish

Mid-term priorities:
- add more enemy types and power-ups
- deepen progression and replay systems
- improve presentation, VFX, and boss intros

Long-term possibilities:
- alternate ships
- challenge modes
- leaderboard features
- co-op or larger-scale expansion

13. TESTING & ACCESSIBILITY
---------------------------
Testing goals:
- verify all gameplay systems and menu flows
- keep performance stable at target framerate
- collect playtest data such as average survival time and wave reached

Accessibility goals:
- high UI contrast
- readable fonts and clear status indicators
- audio controls and screen shake options
- future-ready support for remapping and localization

14. OPEN QUESTIONS
------------------
- Final release target: desktop only, or future mobile support?
- Should the game remain score-focused arcade only, or include meta progression?
- How far should the project go with unlocks, achievements, and long-term retention systems?

End of concise English GDD summary.