================================================================================
               VOID SURVIVOR - PRIORITY GAME PLAN / ROADMAP
================================================================================
Date   : 2026-04-04
Status : Playable vertical-slice prototype
Goal   : Move from polished prototype -> content-rich, replayable arcade game
================================================================================

[CURRENT DEVELOPMENT STATE]
================================================================================
Already strong:
- Stable core survival loop
- Controller-based architecture ready for extension
- 5 enemy archetypes including boss
- Combo, difficulty, procedural SFX, save data, pause/game-over UX
- Weapon power-ups and boss-phase spectacle

Main gaps now:
- Balance and pacing still need repeated playtest iteration
- Mid/late-game content depth and build variety are still limited
- Art identity needs a stronger unified pass around the dark sci-fi / neon look from the concept references
- Accessibility / settings / onboarding / localization are still light
- Meta progression and retention systems are not present yet

================================================================================
[PRIORITY ORDER]
================================================================================
P0 = Critical for next milestone (should be done first)
P1 = High-value features for replayability and feel
P2 = Medium-term expansion after the game feels solid
P3 = Long-term backlog / nice-to-have scale-up work

================================================================================
[DONE]
================================================================================
Core Gameplay
- [DONE] Player movement, aiming, shooting and HP system
- [DONE] Arena survival loop with escalating waves
- [DONE] Enemy types: Chaser, Shooter, Tank, Speeder, Boss
- [DONE] Boss phase transition and boss-wave pacing
- [DONE] Score + combo multiplier + wave bonus
- [DONE] Power-ups: health, speed, rapid fire, shield, spread, heavy

Systems / Tech
- [DONE] Controller architecture and EventBus communication
- [DONE] Save/load for high score, difficulty and SFX volume
- [DONE] Procedural audio generation
- [DONE] Parallax background and particle system
- [DONE] Screen shake and flash feedback
- [DONE] Entity safety limits for long sessions

UX / Menus
- [DONE] Title screen with difficulty selection
- [DONE] Pause screen with resume / restart / quit-to-menu
- [DONE] Game over screen with score, best score and kill breakdown
- [DONE] Fullscreen toggle (`F11`)

================================================================================
[TODO - P0 / NEXT SPRINT]
================================================================================
1. BALANCE & FEEL PASS
   Priority: P0
   Why:
   - The game is playable now, so the highest-value work is tuning what already
     exists instead of adding too much new complexity.
   Tasks:
   - [TODO] Rebalance enemy HP / speed / damage for each difficulty
   - [TODO] Tune boss HP and attack cadence so boss fights feel threatening but fair
   - [TODO] Add a brief round-start zoom-out intro when entering a run
   - [TODO] Fix the enemy respawn/reposition bug so enemies never reappear right beside the player after contact
   - [TODO] Add spawn fade-in opacity and a short grace window before newly spawned regular enemies can deal contact damage
   - [TODO] Adjust drop rates for support vs weapon power-ups
   - [TODO] Tune combo timer and score values for satisfying risk/reward
   - [TODO] Review wave break duration and spawn cadence after wave 10+

2. ONBOARDING / CLARITY
   Priority: P0
   Why:
   - New players need clearer guidance to understand systems quickly.
   Tasks:
   - [TODO] Add a short gameplay tip panel on the title screen
   - [TODO] Add first-run tutorial prompts for movement / aim / shoot / pickups
   - [TODO] Add clearer telegraphing for boss phase 2 and heavy damage threats
   - [TODO] Improve readability of active weapon and power-up timers in HUD
   - [TODO] Add a red damage-loss effect to the HP UI so health drops are easier to read
   - [TODO] Ensure title / pause / settings GUI can be clicked with the mouse and has hover feedback

3. SETTINGS / ACCESSIBILITY
   Priority: P0
   Why:
   - Strong usability improvements with relatively low engineering cost.
   Tasks:
   - [TODO] Add adjustable SFX volume UI in menu
   - [TODO] Add music mute / volume controls alongside SFX settings
   - [TODO] Add toggle for screenshake intensity or disable option
   - [TODO] Add color/accessibility-friendly UI contrast pass
   - [TODO] Consider auto-fire toggle in menu options
   - [TODO] Add input remap plan for keyboard and future gamepad support
   - [TODO] Prepare UI text to be localization-friendly (VN/EN ready structure)

================================================================================
[TODO - P1 / HIGH VALUE]
================================================================================
4. CONTENT DEPTH - MORE ENEMY VARIETY
   Priority: P1
   Tasks:
   - [TODO] Add 1-2 new elite enemies with unique attack patterns
   - [TODO] Add mini-boss encounters before major boss waves
   - [TODO] Add enemy-specific telegraphs or special effects
   - [TODO] Add late-wave behavior modifiers (rage, split, shielded, etc.)

5. MORE POWER-UPS / BUILD VARIETY
   Priority: P1
   Tasks:
   - [TODO] Add magnet pickup, crit-shot, piercing, freeze and drone companions
   - [TODO] Add stackable or synergistic power-up interactions
   - [TODO] Add temporary ultimate pickups with strong short burst effects
   - [TODO] Add weighted drop tables based on current player state

6. PROGRESSION / REPLAY LOOP
   Priority: P1
   Tasks:
   - [TODO] Add run summary screen with deeper stats and performance grading
   - [TODO] Add achievements / milestones
   - [TODO] Add unlockable cosmetics, ships or weapon variants
   - [TODO] Add persistent meta-currency for repeat runs

================================================================================
[BACKLOG - P2 / MEDIUM TERM]
================================================================================
7. WORLD & PRESENTATION EXPANSION
   Priority: P2
   - [BACKLOG] More background themes / arena biomes
   - [BACKLOG] Push the visual identity toward a dark sci-fi battlefield with alien ruins / wreck silhouettes
   - [BACKLOG] Evolve the HUD with subtle circular high-tech motifs inspired by the concept reference while keeping clarity
   - [BACKLOG] Finalize a consistent ship / enemy silhouette language and neon color palette
   - [BACKLOG] Animated title screen and stronger visual identity
   - [BACKLOG] Impact lines, hit-stop and richer VFX pass
   - [BACKLOG] Better boss intro / warning presentation

8. INPUT & PLATFORM EXPANSION
   Priority: P2
   - [BACKLOG] Gamepad support
   - [BACKLOG] Rebindable controls
   - [BACKLOG] Borderless fullscreen/window mode options
   - [BACKLOG] Better save management and reset options

9. TECH / QUALITY IMPROVEMENTS
   Priority: P2
   - [BACKLOG] Spatial partitioning for collision performance at very high entity counts
   - [BACKLOG] Bullet / object pooling if profiling shows allocation pressure
   - [BACKLOG] More robust save-data validation / corruption handling
   - [BACKLOG] Automated smoke test checklist for release candidates
   - [BACKLOG] More debug overlays for balancing and spawn analysis
   - [BACKLOG] Track playtest metrics such as average survival time, average wave reached, and major FPS drops

================================================================================
[BACKLOG - P3 / LONG TERM]
================================================================================
10. ADVANCED GAME MODES
    Priority: P3
    - [BACKLOG] Endless challenge modifiers
    - [BACKLOG] Daily seed / challenge runs
    - [BACKLOG] Hardcore mode with one life
    - [BACKLOG] Timed score-attack mode

11. LARGE-SCALE FEATURES
    Priority: P3
    - [BACKLOG] Multiple playable ships with unique passives
    - [BACKLOG] Local co-op prototype
    - [BACKLOG] Expanded campaign / mission structure
    - [BACKLOG] Online leaderboard integration

================================================================================
[RECOMMENDED NEXT MILESTONE]
================================================================================
Milestone Name: "Prototype to Demo"
Target focus for the next development block:
- Finish P0 balance + onboarding + settings work first
- Then add one P1 enemy and one P1 power-up branch
- Re-test difficulty curves and boss pacing after every balance change
- Avoid major architectural changes unless profiling shows a real issue
================================================================================
