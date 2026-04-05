================================================================================
                         VOID SURVIVOR CHANGELOG
================================================================================
Project: Void Survivor
Engine : Love2D 11.5
Scope  : Consolidated development history after the local polish sprint
Status : Playable prototype with controller architecture, boss waves, combo,
         persistence, and all P0 features complete - ready for P1 content expansion
================================================================================

[2026-04-05] - P0 Feature Pass Complete
--------------------------------------------------------------------------------
Added:
- First-run tutorial prompts: timed overlay showing movement, aim/shoot, and
  pickup instructions during the first game session
- Music volume control slider in Settings alongside existing SFX volume
- Auto-fire toggle option in Settings (ON/OFF)
- Localization module (utils/Localization.lua) with full VN/EN ready string table
- Improved power-up timer HUD: centered bars with fill ratio, low-time flash
  warning, and clearer label/timer text
- Input remap info shown in title-screen tips panel (ESC/F11 bindings)

Improved:
- Boss balance: HP reduced 400→350, fire rate slowed 1.0→1.3s, fan bullets 5→7
  with wider 80° spread for more spectacle but fairer dodging, phase-2 less
  aggressive (speed mult 1.5→1.3, fire mult 0.5→0.6)
- Settings screen reorganized: SFX + Music + Screen Shake + Auto-Fire all on one
  page with reusable volume slider component
- UI contrast pass on power-up indicators for better readability in combat

[2026-04-05] - Local polish sprint complete
--------------------------------------------------------------------------------
Added:
- Enemy spawn fairness pass: fade-in opacity, short non-damaging grace window,
  and safe-radius / edge-biased spawning to reduce unfair contact hits
- HP bar red damage-loss (chip) feedback for clearer combat readability
- Mouse-clickable title / pause / game-over / settings buttons with hover states
- Settings screen with SFX volume slider and screen shake intensity toggle
  (`off` / `low` / `full`)
- Title-screen gameplay tips panel and a brief round-start zoom-out intro

Improved:
- Rebalanced enemy HP / speed / damage across difficulties for a fairer early and
  mid-game curve
- Reweighted power-up drops toward survival-support outcomes while preserving
  weapon variety
- Added boss phase-2 warning / telegraph presentation for stronger readability
- Tuned wave-break pacing and combo scoring windows for a faster, smoother flow

Verified:
- Repeated local Love2D test runs completed successfully with exit code 0 after
  each polish cycle

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
- Core loop is fully playable and noticeably fairer / more readable after the P0 polish sprint
- Architecture is scalable enough for more content and more settings
- Main remaining work is tutorial prompts, deeper progression, broader accessibility, and more content variety
================================================================================
