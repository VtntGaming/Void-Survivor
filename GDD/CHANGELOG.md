================================================================================
                         VOID SURVIVOR CHANGELOG
================================================================================
Project: Void Survivor
Engine : Love2D 11.5
Scope  : Consolidated development history after local polish cycles
Status : Playable prototype with controller architecture, boss waves, combo,
         persistence, procedural audio and post-integration polish complete
================================================================================

[2026-04-05] - Combat fairness & UI polish docs sync
--------------------------------------------------------------------------------
Planned / Documented:
- Added a round-start camera zoom-out intro note to the gameplay plan
- Added enemy spawn safety rules: fade-in opacity, short non-damaging grace
  window, and minimum respawn distance from the player after contact
- Added HP bar red damage-loss feedback and mouse-clickable GUI requirements to
  the active roadmap

Verified:
- GDD files synchronized to reflect the next requested polish pass

[2026-04-04] - ExtendedGDD documentation sync
--------------------------------------------------------------------------------
Updated:
- Expanded the official design direction around dark sci-fi environments,
  orange hero-ship styling, and clean circular HUD motifs
- Added clearer notes for accessibility, control support, QA metrics,
  localization-readiness, and presentation priorities in the roadmap docs

[v0.1.0] - Initial Playable Prototype
--------------------------------------------------------------------------------
Added:
- Core top-down survival loop
- Player movement, aiming and shooting
- Enemy waves with chaser / shooter / tank / speeder types
- Score, HP, simple HUD and game state screens
- Basic particle effects and power-ups

Verified:
- First local run completed successfully with no startup errors

[v0.2.0] - Architecture Scale-Up
--------------------------------------------------------------------------------
Added:
- Full controller-based architecture (`GameController`, gameplay/input/audio/
  rendering/data controllers)
- `EventBus` for decoupled communication
- Boss enemy with 2 phases and dedicated boss waves
- Combo multiplier system
- Difficulty selection on title screen
- Procedural 8-bit sound effects
- Weapon power-ups: `spread` and `heavy`
- Parallax background renderer
- Save/load for high score, difficulty and SFX volume

Refactored:
- Thin `main.lua` wrapper
- Centralized tunables in `utils/Constants.lua`
- Split entities into dedicated modules under `entities/`

Verified:
- Full integration test run completed successfully

[v0.2.1] - Cleanup & Stability Pass
--------------------------------------------------------------------------------
Changed:
- Removed legacy flat-file implementation that had been superseded by the new
  architecture
- Updated documentation to match the live code structure

Fixed:
- Input key cleanup issue that could leave stale keypress state behind
- Combo break feedback to display consistently
- Screen shake jitter by clamping offsets
- Several remaining magic numbers moved into constants for easier tuning

Verified:
- Local Love2D run completed with exit code 0

[v0.2.2] - Gameplay Improvement Pass
--------------------------------------------------------------------------------
Added:
- Speeder zigzag/weave movement to better differentiate it from the chaser
- Shooter strafing behavior and 2-shot burst fire
- Hybrid late-game boss waves (boss + regular enemies from wave 10 onward)
- Expanded pause/game over controls: restart and quit-to-menu flow

Improved:
- Late-game encounter variety and combat pressure
- Menu/game-over usability during repeated playtesting

Verified:
- Local Love2D run completed with exit code 0

[v0.2.3] - Polish, Safety & QoL Pass
--------------------------------------------------------------------------------
Added:
- `F11` fullscreen toggle
- Screen flash effects for boss phase transitions and boss death moments
- Kill breakdown stats on the game over screen
- Entity safety caps for bullets, particles and power-ups to reduce long-run
  performance risk

Refined:
- Centralized temporary power-up durations into constants
- Documentation now split into core plan + changelog + prioritized roadmap

Verified:
- Local Love2D run completed with exit code 0

--------------------------------------------------------------------------------
CURRENT SNAPSHOT
--------------------------------------------------------------------------------
The game is now in a strong prototype / vertical-slice state:
- Core loop is fully playable
- Architecture is scalable enough for more content
- Main remaining work is balance, UX polish, progression depth and more content
================================================================================
