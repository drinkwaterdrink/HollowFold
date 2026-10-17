# Changelog

## 0.3.0 — I-003 — 2026-10-17

- I-002 accepted following the user's ten reported Android passes on 0.2.0; future Caves-quality presentation direction reaffirmed without a graphics overhaul.
- Typed Move/Wait/Inspect requests and structured results/events; single-writer simulation with detached/masked views, action index, integer time, cost/speed readiness scheduling and named gameplay RNG streams.
- Replay fixture hashes canonical world state including player/time/scheduler/RNG/visibility, not just terrain. Move/Wait cost 100; rejected input, Inspect, navigation and render frames cost zero.
- Basic LOS/fog: rock occludes, water transmits sight, no corner peeking, remembered terrain dimmed, unseen inspection has no terrain payload.
- Centre Wait and map-tap Inspect; one input per frame, duplicate request rejection, bounded reentrant handling and overlapping-touch suppression/recovery.
- Original bootstrap and terrain fixtures retained; scene regressions adapted for detached views, plus deterministic simulation/input/rendered tests. No combat, damage, AI, inventory, spells, save/load or I-004.
- Version code 3 and distinct I003 APK reuse signing identity; physical I-003 acceptance remains UNVERIFIED.

## 0.2.0 — I-002 — 2026-10-17

- I-001 accepted following nine user-reported physical Android passes; optional unperformed checks retained as nonblocking follow-ups.
- One deterministic connected 31×39 region with ground, rock, blocked water, entrance and legal spawn; model separated from TileMapLayer rendering.
- Temporary actor, following/clamped camera, eight-way touch buttons, keyboard steps, wall/boundary/diagonal collision, same-seed regeneration and next-seed debug controls.
- Existing launch panel/Settings retained, with Explore region entry and consistent Back navigation. No save, turn scheduler, enemies, inventory or later-packet systems.
- Added hash fixture, 100-seed generation/collision checks, integrated scene and rendered portrait tests. Initially unverified physical checks were subsequently accepted via the user's ten reported passes on version 0.2.0.

## 0.1.0 — I-001 — 2026-10-17

- Pinned Godot 4.7.2 stable Compatibility project, portrait title interface, New Run placeholder and Settings/Back navigation.
- Safe-area conversion, resize/resume refresh, scrollable layout and keyboard/Android Back paths.
- Headless and rendered smoke checks, CI, isolated Android build instructions and signed debug APK export.
- No world generation, character creation, combat, saves or I-002 gameplay.
- Physical-device acceptance was initially UNVERIFIED; user subsequently reported all nine required manual passes and approved I-001 on 2026-10-17 (see verification ledger).
