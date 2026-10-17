# I-003 — Deterministic action and turn engine

Spec: master blueprint F-004, S-004/S-005, §14 and I-003/AC-I003; explicit user authorization, 2026-10-17. Execute inline without routine approval pauses. Preserve engine, terrain generation revision/hash, rendering/camera/menu architecture. No material contradiction found.

## Implementation

1. Record/push user-reported ten-check I-002 acceptance and future Caves-quality direction separately (`7f362ea`). Do not reinterpret prior evidence as independent agent testing.
2. Add `scripts/game_session/action_command.gd`, `action_result.gd`, `turn_scheduler.gd`, `rng_streams.gd`, `visibility.gd`, `simulation_session.gd`. Commands carry request ID, actor, kind and direction/target. Session owns a private copied terrain, player cell, committed action index/time, scheduler, named RNGs and visibility/discovery. Only session commits canonical state. Expose detached/masked views, never authoritative state to scene nodes. Existing Grid fixture helpers may remain for compatibility, but runtime UI cannot commit through them.
3. Move/Wait cost 100 logical units; Inspect/rejections/UI navigation cost zero. Scheduler uses actor cost/speed to derive integer ready times, tie-breaks by actor ID, previews a bounded batch (max 64 readiness events) before atomic commit. Runtime has only the player; fixture actors exercise future unequal costs/speeds without AI. No frame-driven simulation.
4. Seed fixed named combat/loot/events/NPC streams separately from existing worldgen/visual randomness. Canonical hash includes content revision, seed, terrain fingerprint, player, action index/time, scheduler state and RNG states, visible/discovered bits. Exclude presentation/input transport bookkeeping. Commit a replay fixture; test reproducibility and state-field sensitivity.
5. Structured synchronous result publication after commit: accepted/rejected, moved/waited/inspected, actor readiness and turn completion in stable order. Strict monotonically increasing request IDs suppress duplicates/stale requests. Reentrant submission returns BUSY without recursively publishing another signal. UI admits at most one command per rendered input frame and ignores overlapping secondary touch gestures/key echo; controls recover after rejection/resume/hide. Input gating never advances simulation.
6. Minimal integer LOS radius 8, rock opaque/water transparent; blocked diagonal corner rays rejected. Currently visible and ever-discovered masks are authoritative simulation data; unknown terrain masked in UI views, explored-but-unseen dimmed. Inspect only currently visible targets; hidden/out-of-range rejection contains no terrain payload. Tapping map inspects; centre pad Wait; keyboard Space/period Wait, I Inspect self. No targeting/combat systems.
7. Integrate `region_screen.gd` with commands/results, update `region_view.gd` only for visibility, retain all I-001/I-002 behaviors. Version 0.3.0/code 3; distinct ignored I003 APK with existing key. No art overhaul.

## Verification

- RED before session implementation; then deterministic replay golden hash, move/wait costs, wall/water/diagonal/invalid inputs, Inspect time/RNG/hidden-information behavior, duplicate/reentrant processing, event ordering, scheduler budget/speed/cost, LOS/corner fixtures, snapshot isolation and RNG stream isolation.
- Preserve original 28 bootstrap and 100-seed I-002 terrain checks. Adapt I-002 scene tests to detached views/command ownership without removing their navigation/collision/camera/seed coverage. Add I-003 input/frame/no-time-advance tests.
- Actual rendered pointer/key/touch-event tests and three portrait captures; verify old rendered regressions, Wait/Inspect/fog and menu/regeneration behavior. Programmatic input is not physical Android evidence.
- Full `verify.ps1`, signed APK export/signature/certificate/manifest/resource-exclusion checks, ADB availability. Physical I-003 checks remain UNVERIFIED until the user tests this APK.
- Independent code review, explicit-path stage audit, implementation commit/push, hosted Linux CI, documentation follow-up with real commit/hash/evidence; clean local/remote HEAD. Stop before I-004.

## Ledger

- Existing I-002 generator/grid separation, atlas/TileMapLayer, camera, safe-area layout, menu and testing pipeline inspected; Godot 4.7.2 and Android tools/key available.
- I-002 acceptance and presentation preference committed/pushed before code in `7f362ea`.
- Tests: missing-session RED observed. Golden replay measured and fixed at action 3/time 300, hash `c012bae20d987d6690063267db09e1d4f890bec37a7478f611b93356b42de328`. Final pure simulation suite: 82 checks PASS; original bootstrap 28 and terrain 14,216 PASS; adapted region-scene 17 PASS.
- Import caught a controller-source indentation generation error; corrected before final runs. A self-capturing reentrant test signal caused fixture-only resource leaks; disconnected explicitly after its test. Final runs have no such errors/leaks.
- Review found stale detached-view assertions in old scene tests; fixed by reacquiring current views. An intentional echo-handling mutant failed the corrected assertion, original code restored, suite GREEN. Reviewer did not report a runtime simulation defect.
- Focused overlap test exposed an emulated-button path while a secondary touch existed (RED); admission now rejects overlapping/suppressed touch frames (GREEN). Final input scene suite 18 checks; rendered viewport-routed touches plus emulated-pointer convergence, Wait/Inspect, idle frames and portrait layout PASS. OS Android touch emulation remains UNVERIFIED.
- Deferred-later scope from reviewer: combat/AI execution, persistence, advanced targeting and art are intentionally absent; no implementation ruling needed. Physical I-003 acceptance remains with the user.
