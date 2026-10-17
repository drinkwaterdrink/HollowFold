# I-004 Tactical Combat Slice Implementation Plan

**Goal:** One deterministic, fair player-versus-monster encounter on Android, preserving I-003.
**Architecture:** Extend the existing session as single writer. Shared actor records, pure attack/status/AI helpers, existing bounded scheduler and named combat RNG; detached snapshots/events drive minimal combat presentation.
**Tech stack:** Godot 4.7.2 stable Compatibility, typed GDScript, established portable Android SDK/JDK17/debug key.
**Spec:** Master blueprint §4.2, §14, F-005/F-016, S-004/S-005, I-004/AC-I004 and user's explicit I-004 requirements.

## Constraints and decisions

- Native execution in the existing clean checkout; user explicitly requests plan then implementation and push, so no additional routine approval gate.
- Preserve `i003-v1` default session behavior and golden hash unchanged. Runtime explicitly selects `i004-v1`; combat canonical state includes sorted full actor/status/AI records. Old revision rejects Attack.
- Player Move/Wait/Attack time100. Attack stamina3; Move free stamina; Wait restores4 capped at maximum. Monster readiness period120, attack stamina2. Costs and stats are provisional I-004 content tuning, not new locked design decisions.
- Shared player HP30/stamina12, offense7, accuracy85/evasion10, armor1; one hollow mite HP18/stamina8/offense4/accuracy75/evasion10/armor1. Physical damage; validated attack profile supports ranged LOS fixtures, no player ranged arsenal.
- Hit chance clamped5..95 = accuracy - evasion; damage = max(0, offense - max(0, armor-penetration) - shield) scaled by clamped -100..100 percent resistance with integer rounding down. No critical hits, equipment or elemental interactions.
- One stable `mite-001`, deterministic bounded BFS placement at path distance8..12 (fallback >=6), legal reachable nonoverlap. No enemy turn occurs until a legal player action. Detection requires range6 and own LOS; no pursuit memory. Retreat at <=one-third HP when player sensed. Deterministic bounded BFS pursuit; legal occupancy-aware retreat.
- Minimal shared status store: stable IDs, duration and refresh/replace/ignore rules, max8 entries/duration100, one representative `guarded` evasion modifier fixture. No status attack catalogue or environmental chains.
- No I-005: no inventory/loot/magic/save/Chronicle/polished art or full HUD redesign. Death is temporary; Regenerate starts fresh.

## Tasks and checks

- [x] Record I-003 user-reported acceptance separately (docs/progress.md, docs/I-003_Verification.md).
- [x] Add failing combat tests, then shared `scripts/combat/{actor_state,attack_resolver,status_effects,enemy_ai}.gd`. Validate stats, typed intent/rejections, armor/resistance, bounded statuses and AI sensory/collision behavior.
- [x] Extend `action_command.gd`, `simulation_session.gd`, `turn_scheduler.gd`, `region_grid.gd`: attacks, actors, occupancy, scheduler removal, death-once, versioned canonical replay, detached views/inspection. Keep old fixtures/tests intact. Tests must cover missing/dead targets, blocked/ranged LOS, resource shortages, same-event replay, death scheduling, mutation isolation and no hidden enemy inspection.
- [x] Extend existing region screen/view/scene: visible target selection via map Inspect, explicit Attack button, player HP/stamina, target HP, short event log, placeholder mite marker, temporary defeat. Reuse existing touch gate; test rapid/overlap attacks, invalid recovery, no autonomous turns, menus and regeneration.
- [x] Add fixed combat replay fixture plus scene/rendered suites; register headless tests in tools/verify.ps1 (therefore hosted CI). Run full suites, all rendered scripts and inspect portrait captures.
- [x] Version0.4.0/code4, new ignored I004 APK path, established key/export/signature/manifest checks. Update README/CHANGELOG/build guide/decisions/progress and I004 verification with actual results and exact physical checklist.
- [x] Fresh independent source review, resolve material findings with tests. Full checks, explicit staging, commit/push; verify hosted CI, remote hash and clean tree. Stop before I005.

Execution evidence and final commit/CI status: ../I-004_Verification.md.

## Review focus

Enemy sensory privacy (including rejected attacks), stale identity targets, occupied diagonal corners, lethal actor removal during a precomputed schedule, insufficient stamina recovering via Wait, duplicate attack input and focus recovery. Every item is covered by combat or scene tests; physical OS touch behavior remains UNVERIFIED.
