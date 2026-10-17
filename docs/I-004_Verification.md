# I-004 — Tactical combat slice verification

Date: 2026-10-17. Scope: F-005/F-016, S-004/S-005, blueprint §4.2/§14/I-004/AC-I004. Engine `4.7.2.stable.official.ed1daf0bf`, Compatibility; same Android SDK36/JDK17/debug key. **Stop before I-005.**

## Acceptance boundary

I-003 was officially approved after the user installed 0.3.0 and reported all nine physical acceptance groups PASS, with no problems observed. These are **user-reported physical-device results**, not agent-executed tests. Recorded separately in acceptance commit `86355f0`; exact groups remain in I-003_Verification.md. I-004's changed APK requires separate phone acceptance and is **UNVERIFIED on a physical Android device**. Optional prior screenshots/device metadata remain nonblocking.

## Implemented architecture

- Existing command/session/result/scheduler/RNG/visibility architecture is retained. No alternate simulation framework. Six I-003 modules remain; four small `scripts/combat/` data/pure helper modules extend them. The session is the sole runtime writer of position, HP, stamina, statuses, AI state and death. Scene nodes receive copied visible actor records and terrain; animations only react to committed events.
- Shared ActorState for player and mite: stable ID, name, logical tile, HP/maxHP, stamina/max, offense, accuracy/evasion, armor, penetration, shield, typed resistances, attack range/time/resource costs, speed, alive, AI profile/perception radius/behavior and status records. Mutable actors never leave session; diagnostic actor_record/canonical_state return copies, while actor_view/view/Inspect enforce perception. These diagnostic APIs are for replay/testing, not UI sensed information.
- Typed Attack command carries request ID, attacking actor ID and target actor ID. UI may command player only; internal AI uses the same resolver. At submission and immediately before resolution, validate current actor/target identity, living state, range, LOS and resources. Hidden/dead/missing targets use TARGET_UNAVAILABLE (no hidden-existence probe). Other failures include OUT_OF_RANGE, OBSTRUCTED, INSUFFICIENT_STAMINA, OCCUPIED and PLAYER_DEFEATED. Invalid requests spend no time/stamina/RNG or statuses.
- Provisional default tuning: player HP30/stamina12/offense7/accuracy85/evasion10/armor1, attack range1/time100/stamina3; mite HP18/stamina8/offense4/accuracy75/evasion10/armor1, range1/readiness120/stamina2. Move/Wait cost100, Move stamina0. Wait restores4 capped, and applies a brief shared guarded status. These values are content tuning, not new locked design decisions.
- Combat stream draws one roll0..99 per legal attack (including misses). Hit chance clamps accuracy - evasion - status bonus to5..95. On hit, subtract nonnegative effective armor after penetration, then flat shield; scale by damage-type resistance clamped -100..100 percent and floor. Damage never heals; reported actual damage caps at remaining HP. Resistance100 prevents damage, -100 doubles post-defense damage. No critical hits, equipment or environmental effect chains.
- Resolve player action atomically, commit bounded scheduler plan, then execute living eligible enemy turns by due time/ID. Enemy action eligibility derives from existing action-cost/speed periods. One player action can produce zero or more bounded readiness entries. Immediate lethal attacks remove enemy slots before precomputed readiness executes. Every lethal transition emits exactly one actor_died; dead actors lose active occupancy/scheduler membership. Player defeat rejects subsequent gameplay and disables controls; regeneration can start fresh. No permanent save/tombstone/Chronicle is written.
- Stable result/event ordering: accepted → owner status expiry → player movement/attack/wait (+visibility or status application) → chronological readiness/enemy actions → turn_completed. Damage/miss/death carry actor/target/time, typed damage and exact post-hit HP. Existing I-003 event order stays unchanged in old content mode. Combat events have monotonically increasing sequence/request IDs; duplicate/reentrant commands cannot reapply outcomes.
- Visibility privacy: only currently visible actors appear in perceived views/Inspect. Hidden NPC readiness remains internal. Movement wholly in sight emits enemy_moved; leaving/entering sight emits enemy_left_sight/enemy_entered_sight containing only observed endpoints. Invisible movement never discloses hidden coordinates. Target selection clears when target dies or leaves sight; stable IDs are revalidated rather than attacking a replacement tile occupant.

## Encounter, AI and statuses

One original placeholder **Hollow mite** (`mite-001`), distinguished from the pale player diamond by a red insect glyph. Deterministic BFS finds a reachable legal spawn at path distance8, fallback>=6, without modifying terrain or overlapping the player. Fifty seeded independent legal-path checks verify safe separation/reachability and identical initial actor/RNG state. No turns happen at region creation or while idle. The actual default seed1337 encounter is also won by a test using production Move/Wait/Attack, including injured retreat.

AI senses the player only through its own current radius6 + LOS. No hidden-position memory is invented. Healthy sensed mite pursues via BFS bounded by region tile count; injured mite (<=one-third maxHP) attempts a legal step increasing distance, or fights when cornered. No sensory contact means idle/Wait recovery. Legal movement respects terrain, water, occupied cells and occupied/blocked diagonal corners. No advanced AI, factions or ecosystem.

Minimal shared status foundation: stable guarded identifier/tags/priority, duration in owner actions, refresh/replace/ignore stacking, max8 records and max100 duration. Unknown statuses/durations are rejected. Guard grants10 evasion; Wait applies duration1 after the owner expiry tick, protecting during subsequent enemy phase and expiring at the next valid owner action. Status applied/removed events are structured; rejected actions and Inspect do not tick durations. No poison/fire/disease/mutation catalogue or reaction system.

## Android interaction

Existing region scene, safe area, camera, map renderer and eight-way input remain. Map Inspect selects a visible mite and shows armor/resistance/range without time. Yellow ring marks selected identity; explicit Attack button/F submits one attack. Player HP/stamina, target HP/behavior, two-line bounded log, damage/miss/death messages, spotted warning and short presentation-only hit tween provide feedback. Wait recovers stamina. There is no bump auto-attack. Detailed HUD/loot/polished art remain I-005/I-022.

Existing one-frame admission, primary touch ownership, secondary suppression, key-echo rejection and focus-reset protect Attack as well as movement. Rejected commands release normal admission next frame. Death disables movement/Wait/Attack; Back and Regenerate remain available. Regenerate/Next Seed rebuild all actors, statuses, RNG, scheduling, fog, target and defeat state. Menus preserve temporary in-memory state, process restart does not save it.

## Reproducible fixtures and compatibility

Original `tests/fixtures/i003_replay_v1.json` is **unchanged**, still default content `i003-v1` and hash:
`c012bae20d987d6690063267db09e1d4f890bec37a7478f611b93356b42de328`.

The runtime explicitly opts into `i004-v1`. Its canonical array retains terrain/player/action/time/scheduler/named RNG/visible+discovered state and appends sorted complete actor snapshots (including combat stats, status and AI fields). Old content rejects Attack and does not append combat state. No old golden was updated merely to accommodate combat. Generator, terrain fixture and prior test source files remain unchanged.

New `tests/fixtures/i004_combat_v1.json`: seed1337, explicit11×9 arena and actor definitions,24 commands: Move, engagement, Attack, Wait, misses/damage, scheduled enemy approach/attacks, lethal player outcome and post-death rejections. Stronger fixture enemy (HP100) is explicit content, not runtime default. Golden full-world SHA256:
`a15623f036fcc22c88b460227f972a3eb5a05b5e8d2860c61057e029ea4798e7`.
Golden complete event-history SHA256:
`3e6df1da26affeb7c6cf101fafa77b32fd3fdd6a6b23b6596b680b551d92c428`.
Every command prefix compares fresh sessions' result records/events/state. Same fixture pins actual damage and exactly one death despite later requests. Separate fixtures verify enemy defeat/removal, player defeat, armor/resistance, attack costs150, bounded scheduler rejection, sensory privacy and legal retreat.

## Actual verification results

Commands executed from repository root; logs/captures stay ignored under `.local/verification/`.

| Check | Actual result |
|---|---|
| `./tools/verify.ps1` | PASS: exact engine, editor import, configured main scene60-frame boot, all seven suites |
| `bootstrap_smoke.gd` | **28 checks,0 failures**, unchanged |
| `region_tests.gd` | **14,216 checks,0 failures**, unchanged terrain golden |
| `region_scene_smoke.gd` | **17 checks,0 failures**, unchanged source |
| `simulation_tests.gd` | **82 checks,0 failures**, unchanged I-003 canonical golden/source |
| `simulation_scene_smoke.gd` | **18 checks,0 failures**, unchanged source; 120 idle frames, navigation/input/seed regressions |
| `combat_tests.gd` | **259 checks,0 failures**; replay/event hash, typed resolution/costs/defense, stamina, death/removal, status, sensing/AI, occupancy/corners, hidden-event privacy, snapshots,50 seeded placement checks, actual default encounter win/retreat |
| `combat_scene_smoke.gd` | **18 checks,0 failures**; target selection, rapid/overlap Attack, costs/feedback/vitals, invalid recovery,60 idle frames/menu isolation, defeat disable/recovery, complete regen/next-seed reset |
| Existing rendered title/region/simulation scripts | All three PASS,0 failures; prior navigation, camera, controls, input stress, fog, free Inspect and three portrait sizes retained |
| `combat_visual_smoke.gd` | PASS,0 failures; actual viewport pointer target/Attack, generated encounter, duplicate clicks, routed synthetic touch overlap, portrait layout and controlled defeat/regeneration |
| Screenshot inspection | PASS at450×800,360×640,450×1000: vitals/target/log/pad/Attack/debug controls readable and inside viewport; red mite/pale player/yellow target distinguishable; defeat clear. OpenGL3.3 Compatibility/Radeon780M |
| `./tools/export_android.ps1` | Final post-review PASS: export/alignment/signing/V2+V3 verification; privacy fixes packaged |
| Certificate comparison | PASS: SHA256 `fee5859fe0c55b2e3c0d191007d91ae2cbf354fa19ea2189b36f8ad474f4b7d8`, identical to I-003 |
| `aapt dump badging/permissions/xmltree` | PASS:0.4.0/code4, same app ID, ARM64,minAPI24,target36,portrait,no requested permissions |
| APK ZIP inventory | PASS: four combat modules compiled/packaged, no tests/docs/tools/.local/keystore entries |
| `adb devices -l` | Empty; no install or phone combat test performed by agent |
| `git diff --check` | PASS |
| Hosted GitHub CI | Pending push; concrete run/hash recorded in subsequent evidence update |

Rendered commands (all ran successfully after review fixes):

```powershell
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/verification/i004-title-regression.log" --script tests/headless/visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/verification/i004-region-regression.log" --script tests/headless/region_visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/verification/i004-simulation-regression.log" --script tests/headless/simulation_visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/verification/combat-visual.log" --script tests/headless/combat_visual_smoke.gd
```

Captures: `i004-initial.png`, `i004-target.png`, `i004-combat.png`, `i004-360x640.png`, `i004-450x800.png`, `i004-450x1000.png`, `i004-defeat.png`. Synthetic viewport touch is **not physical Android OS-input verification**. The rendered defeat uses an explicit1HP fixture through the production scene; default stats are separately exercised by the generated encounter test.

## Failures encountered and fixes

- Initial missing-actor test RED (1check/1failure). New session-encounter test then exposed the absent constructor/API; no runtime script error was counted as a passing suite. Implemented shared actors/session extension.
- Initial draft replay failed to reach death because the correctly retreating low-HP enemy escaped while the draft only attacked/waited. Replaced the explicitly new fixture's actor content with a stronger enemy to exercise player death; measured new fixture hashes then locked them. Existing I-003 golden was never changed.
- Scene test RED because Attack node did not yet exist. During implementation, a Python read used Windows default encoding and failed on existing Unicode arrows; corrected to explicit UTF-8 before scene update. Final import/scenes/tests clean.
- Initial sandbox attempts blocked user:// and ADB daemon paths. Retried established checks with normal local-runtime access; engine/JDK/SDK/key were not replaced. ADB subsequently reported no devices.
- Independent review: scheduler registration had a side effect inside assert (which release exports omit). Registration is now unconditional with a separate assertion; ordinary scheduler/actor tests pass. No release APK test is claimed.
- Hidden readiness privacy regression: **251checks/5failures RED →251/0 GREEN** after filtering hidden NPC readiness while retaining internal turns.
- Review's LOS-boundary regression: **259checks/4failures RED →259/0 GREEN**. Hidden movement endpoints replaced with departure/arrival events carrying only observed coordinates. New and old golden hashes unchanged by this correction.
- Final full suite, all four rendered checks and signed export ran after all runtime/review fixes. No unresolved material review finding remains. Additional tuning/art/device metadata are future feedback, not unperformed PASS results.

## AC-I004

| Blueprint criterion | Status | Supporting evidence |
|---|---|---|
| Enemy outside LOS does not react as if seeing player | **PASS** automated | Own range+LOS gate; blocked/range fixtures, five scheduled hidden turns unchanged position/idle; boundary privacy tests |
| Lethal HP emits death exactly once | **PASS** automated | Enemy/player lethal fixtures; replay one death plus post-death rejections; removed scheduler/occupancy, precomputed dead slots skipped |
| Same action fixture gives same damage | **PASS** automated | Fixed full-event golden plus full canonical golden and every-prefix fresh-session equality; combat RNG isolation |
| Ranged target behind wall is rejected | **PASS** automated | Shared ranged-intent resolver returns OBSTRUCTED; session hidden target rejected without costs/leak. Player's temporary attack remains melee |
| Fight monster, take/give damage, warnings, lethal defeat | **PASS** local logic/rendered; **UNVERIFIED** phone | Default generated encounter win/retreat; scene/rendered HP/log/target/defeat checks; no phone attached |
| Android attack input and feedback review | **UNVERIFIED** physical | Desktop viewport pointer/touch checks PASS; awaiting user install0.4.0 |

Required implementation is complete; physical I-004 acceptance remains pending. I-001–I-003 automated regressions and user-reported historical acceptance are preserved. I-005 is not authorized.

## APK and setup

Latest local APK: `builds/android/Hollowfold-I004-debug.apk`, **0.4.0/code4**, **28,377,437bytes (27.06MiB)**.
SHA256: `EDE7D5BA83BF1F6189DF9F16761DB7A1F84956470F9E4ED315D016E38080E9E6`.
Same app ID/signing identity; earlier APKs retained. APK/key/SDK remain ignored/untracked. Existing machine needs no new tool installation. Connect an ARM64 Android7+ device and install/update with the existing key; follow BUILD_ANDROID.md. Rebuilding can change archive timestamps/hash.

## Exact physical Android combat checklist (UNVERIFIED)

1. Install/update0.4.0 using `adb -s SERIAL install -r builds/android/Hollowfold-I004-debug.apk` or transfer/install APK. Confirm title/version, New Run/Settings/Back, portrait/camera/system insets. Open Explore region.
2. Seed1337 begins(3,11),#0/t0,HP30/30,stamina12/12. Idle10seconds: no movement/time/HP change. Attack without selecting: clear rejection, no cost. Blocked wall/water/corner moves remain free; legal moves100time.
3. Explore until red Hollow mite appears. It must be separate from player, never on rock/water, with no automatic off-screen starting attack. Tap visible mite: yellow target ring, name/HP/behavior and armor/resistance/range information; time/stamina unchanged. Unknown/dim unseen tiles cannot disclose live creature details.
4. Select from beyond melee range and press Attack: visible out-of-range rejection; time/index/stamina unchanged. Regain legal range; Attack once: one action/+100time/-3stamina whether hit or miss. Observe readable log, hit/miss feedback and enemy HP change on damage. No bump auto-attack.
5. Enemy approaches only on legal player turns when it can sense you, obeying terrain/water/corners/occupied cells. Wait and observe enemy scheduled attack/miss and player HP loss. Inspect/menu/idle must never grant an enemy action. Walk around obstacles/out of sight; hidden markers/target/positions must disappear without revealing unseen movement.
6. Spend stamina by attacking. At<3, Attack reports shortage with no costs; Wait adds100time, restores up to4 (never above12), briefly guards, and allows enemy turn. Attack works again afterward. HP/stamina remain within bounds.
7. Injure mite to6HP or lower; observe retreat when an escape exists. Chase legally and defeat it. Defeat message appears once; marker/target disappears, tile no longer occupied, no more actions/damage from that enemy. Attack on an unavailable target is free.
8. Regenerate, engage again, deliberately Wait under attack until player HP0. Clear temporary Defeated message; movement/Wait/Attack disabled. Idle/extra taps do not advance time or produce repeated death. Back remains usable. Regenerate restores fullHP/stamina,#0/t0,fog/actors and controls; no save/tombstone/Chronicle expected.
9. Rapid-tap and hold Attack; overlap Attack/movement/Wait with two fingers. One discrete gesture must not duplicate actions/resources; overlapping input may be ignored. Release/focus again: controls recover. Repeat after invalid attack and stamina shortage.
10. Regenerate same seed: same terrain/starting actor state and fresh RNG/defeat/status/target. Next Seed: new deterministic region/encounter and reset counters. Repeat a short identical command sequence after same-seed reset; outcomes should match.
11. Back/menu/re-entry preserves temporary combat state without turns; Android system Back works. Background/resume during a press: no autonomous action, control recovers. Check rotation lock/insets, airplane mode and at least5minutes combat/exploration/regeneration. Force-stop/relaunch returns to title without a saved run.
12. Report PASS/FAIL per group, phone model/Android version and any logs/screenshots before approving I-004. Stop before I-005.

## Every created or modified file in this user task

Includes separate I-003 acceptance documentation and I-004 implementation/evidence. `.gd.uid` files are intentional Godot resource identifiers.

```text
CHANGELOG.md
README.md
docs/BUILD_ANDROID.md
docs/I-003_Verification.md
docs/I-004_Verification.md
docs/decisions.md
docs/plans/I-004_Implementation_Plan.md
docs/progress.md
export_presets.cfg
project.godot
scenes/boot.tscn
scenes/region.tscn
scripts/combat/actor_state.gd
scripts/combat/actor_state.gd.uid
scripts/combat/attack_resolver.gd
scripts/combat/attack_resolver.gd.uid
scripts/combat/enemy_ai.gd
scripts/combat/enemy_ai.gd.uid
scripts/combat/status_effects.gd
scripts/combat/status_effects.gd.uid
scripts/game_session/action_command.gd
scripts/game_session/simulation_session.gd
scripts/game_session/turn_scheduler.gd
scripts/ui/region_screen.gd
scripts/visual/enemy_marker.gd
scripts/visual/enemy_marker.gd.uid
scripts/visual/region_view.gd
scripts/world/region_grid.gd
tests/fixtures/i004_combat_v1.json
tests/headless/combat_scene_smoke.gd
tests/headless/combat_scene_smoke.gd.uid
tests/headless/combat_tests.gd
tests/headless/combat_tests.gd.uid
tests/headless/combat_visual_smoke.gd
tests/headless/combat_visual_smoke.gd.uid
tools/export_android.ps1
tools/verify.ps1
```
