# I-003 — Deterministic action and turn engine

Date: 2026-10-17. Scope: F-004, S-004/S-005, blueprint §14 and I-003/AC-I003. Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility, established Android toolchain/key. I-003 is now accepted; I-004 only is authorized.

## Prior acceptance and preserved architecture

The user's ten reported Android passes on **0.2.0** complete I-002 acceptance; they are **user-reported real-device results**, not tests independently performed by the agent. Recorded separately in `7f362ea`. The renewed Caves (Android) presentation preference is recorded for I-005/I-022. No major art/UI overhaul was performed here.

The master blueprint, I-002 generator, terrain hash fixture, original 28-check bootstrap and 14,216-check terrain suite remain unchanged. The TileMapLayer/camera/safe-area/menu architecture remains. Old scene/rendered tests now fetch fresh detached views after input, preserving their prior behavioral checks without granting UI write access to simulation.

## Command, state and turn architecture

- `action_command.gd`: typed fields for request ID, actor ID, Move/Wait/Inspect kind, direction/target; factory and replay-record constructors.
- `simulation_session.gd`: **single authoritative writer**. Private copied terrain, player position, action index, logical time/scheduler, RNGs and visibility/fog. Construction/regeneration creates a fresh session. UI gets deep-copied, masked views; mutating a view or supplied fixture cannot mutate canonical state. Legacy Grid movement helpers are retained only for isolated I-002 fixtures/read-view compatibility, never used by live gameplay.
- Move/Wait cost **100 logical units**. A successful time-consuming action increments action index once. Blocked/out-of-bounds/corner/invalid/duplicate/Inspect/UI navigation/render frames consume **zero** time and do not advance that index. Space/period and centre Wait submit Wait; map tap or I on keyboard submits Inspect.
- `turn_scheduler.gd`: readiness period `ceil(action_cost * 100 / speed)` in integer units; preview resolves due entries by time then actor ID, with a **64-entry bound** and atomic commit only after validation. Only player is registered at runtime. Fixture profiles exercise unequal costs/speeds. Readiness events prepare future integration; no actor AI/combat execution is implemented.
- `rng_streams.gd`: fixed combat/loot/events/NPC streams derived deterministically from seed/name, separate from unchanged worldgen and any global/visual RNG. Move/Wait/Inspect do not draw unnecessary random numbers. Exact RNG seed/state pairs are included in canonical state.
- `action_result.gd`: success, stable code, request ID, from/to cell, cost, action index/time, optional visible inspection and ordered events. Codes: OK, BLOCKED, CORNER_BLOCKED, OUT_OF_BOUNDS, INVALID_COMMAND, INVALID_ACTOR, NOT_VISIBLE, DUPLICATE, BUSY, BUDGET_EXCEEDED.
- Results publish **after atomic commit**. Event phases are accepted → moved/waited/inspected → visibility update (Move) → due actor readiness → turn completed. Each event has a monotonically increasing sequence. Rejections publish command_rejected. Reentrant submission returns structured BUSY without recursively emitting another signal. Positive increasing request IDs suppress duplicate/stale commands; these transport IDs/event counters are outside canonical gameplay state.
- Presentation admits at most one command per input frame, ignores key echo, tracks one primary touch, and suppresses overlapping/secondary touch and potential emulated-pointer paths. Rejection does not permanently lock controls; focus loss/hide/regeneration clear gesture state. This input admission uses frame identity only; **no gameplay timer or turn is advanced by frames**.

## Visibility and inspection

`visibility.gd` uses bounded integer supercover LOS in radius 8. Rock is opaque and a visible wall can itself be inspected; water transmits sight. Corner rays cannot peek through blocked adjacent orthogonal cells. Current visibility is recomputed on successful movement; discovered cells persist in memory. Unknown cells are masked out of the presentation snapshot and rendered dark; remembered cells outside current LOS are dimmed. Inspect only succeeds for a currently visible tile, costs no time, and leaves RNG/world unchanged. Hidden, remembered-but-unseen or out-of-bounds Inspect returns NOT_VISIBLE and **no terrain payload**.

This is static-terrain fog memory, not advanced targeting, enemy perception, save/load or mutable-world recollection. Later terrain-mutation packets must define last-seen terrain behavior.

## Canonical replay fixture

`tests/fixtures/i003_replay_v1.json` fixes seed 1337/content `i003-v1` and nine ordered requests, including rejection, Inspect, Wait, Move and a duplicate request. Final position **(4,11)**, action index **3**, time **300**; canonical SHA-256:

`c012bae20d987d6690063267db09e1d4f890bec37a7478f611b93356b42de328`

The hash covers content version, seed, unchanged terrain fingerprint, player cell, action index/time, sorted scheduler records, named RNG seed/state pairs, current visibility and discovered bits. It excludes presentation frames, event history and transport request bookkeeping. It is **not merely a terrain hash**. Identical command prefixes and final states/events are compared between fresh sessions; content-version sensitivity and visibility/RNG membership are also checked. Guarantees apply to the pinned engine/content/generation revisions, not arbitrary future engine changes.

## Actual verification

Run from repository root; logs/captures remain ignored under `.local/`.

| Command/check | Actual result |
|---|---|
| New missing-session test before implementation | Expected RED, exit 1 |
| `./tools/verify.ps1` | PASS: editor import, configured main scene boot for 60 frames, all five headless suites |
| Original `bootstrap_smoke.gd` | 28 checks, 0 failures |
| Original `region_tests.gd` | 14,216 checks, 0 failures; original terrain seed/hash/spawn unchanged |
| Adapted `region_scene_smoke.gd` | 17 checks, 0 failures; navigation/seed/collision/actor/camera/echo/hidden input retained with current snapshots |
| `simulation_tests.gd` | 82 checks, 0 failures: replay/world hash, Move/Wait costs, rejected costs, Inspect/RNG/privacy, duplicate/reentrant behavior, stable result/event order, scheduler speed/cost/budget, RNG isolation, snapshot isolation, LOS/visibility/fog memory |
| `simulation_scene_smoke.gd` | 18 checks, 0 failures: rapid button input admitted once, command routing, rejection recovery, Inspect privacy, detached UI data, touch ownership/overlap suppression/recovery, focus reset, menu isolation, regeneration, next seed, 120 idle frames without world advancement |
| Original rendered `visual_smoke.gd` | PASS, 0 failures; title/New Run/Settings/Back |
| Adapted rendered `region_visual_smoke.gd` | PASS, 0 failures; actual pointer/key movement, actor/camera, seed reset/change, Back and three portrait sizes |
| `simulation_visual_smoke.gd` | PASS, 0 failures; actual viewport Wait/map-tap visible/hidden Inspect, rapid click convergence, routed synthetic touch/secondary-touch plus emulated-pointer path, recovery, idle frames, three portrait sizes |
| Desktop visual inspection | Captures at 450×800, 360×640, 450×1000: readable counters/status, controls contained, actor/visible terrain/unknown fog correct. Existing original textures retained; fog variants only |
| `./tools/export_android.ps1` | PASS: APK export, alignment, signing and verification; final build includes overlap fix |
| `apksigner verify` and certificate comparison | V2/V3 signatures PASS; certificate digest matches I-002 |
| `aapt dump badging/permissions/xmltree` | 0.3.0/code 3; same app ID, portrait, ARM64, minimum API 24/target 36; no requested permissions |
| APK inventory | All six simulation modules packaged; no tests/fixtures/docs/tools/.local/keystores |
| `adb devices -l` | Empty list; **no I-003 phone install/test performed by agent** |
| `git diff --check` | PASS |
| Hosted Linux CI | PASS: [run 39050865033](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39050865033), success against implementation `ec34a61d77e1807ae0e97071dccab694b0adc72c`; official engine download and import/boot/all five headless suites passed, including canonical and terrain fixtures |

Rendered commands:

```powershell
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/i003-title-regression.log" --script tests/headless/visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/i003-region-regression.log" --script tests/headless/region_visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/i003-visual.log" --script tests/headless/simulation_visual_smoke.gd
```

Real renderer: OpenGL 3.3 Compatibility on AMD Radeon 780M. Captures: `.local/verification/i003-initial-fog.png`, `i003-visible-inspect.png`, `i003-360x640.png`, `i003-450x800.png`, `i003-450x1000.png`. Routed synthetic events do **not** certify Android's OS touch-to-mouse adapter or physical multi-touch behavior.

### Failures and review fixes

- Initial fixture hash/action values were intentionally not assumed; measured actual replay results, then locked expected hash/index/time and reran successfully.
- Controller file generation lost indentation; import caught the parse error and it was corrected. A reentrant fixture's self-capturing signal was disconnected after use to remove fixture-only resource leaks. Final runs show neither error.
- Independent source review found two old assertions checking stale detached views. They now reacquire current views. A deliberate temporary echo-handler mutant was rejected by the corrected test (17 checks, one expected failure), original source restored, final suite PASS.
- Review correctly distinguished direct `_input` touch-bookkeeping checks from viewport routing. Added actual viewport-routed synthetic touch coverage and explicitly retained the OS/physical uncertainty.
- A new overlap test was RED when an emulated button could submit while secondary touch was held; added suppression/recovery guard, test GREEN (18 checks) and rendered routed-touch suite GREEN. No scheduler/world-state workaround or later-packet system was introduced.
- Combat/AI execution, persistence, advanced targeting and art remain intentionally deferred, not missing I-003 work. No unresolved review finding is represented as fixed by an unrun test.

## AC-I003 and acceptance boundary

| Criterion | Status | Evidence |
|---|---|---|
| Same seed + content + ordered commands gives same final canonical world hash | PASS | Golden replay plus per-prefix/final-state/event equality; full canonical fields listed above |
| Legal Move/Wait advances defined action cost, invalid blocked/diagonal moves do not | PASS | Pure and scene tests; player/time/index unchanged on rejection |
| Inspect does not advance turn/RNG and hidden info is not disclosed | PASS | Visible/hidden/remembered cases, snapshots and rendered map inspection |
| No duplicate action on fast repeated/overlapping input | PASS — automated and user-reported physical | Duplicate-ID/reentrant checks, same-frame GUI suppression and routed synthetic-touch coverage; Android OS/input stress awaits user |
| No simulation progression from frames or navigation | PASS | 120 headless idle frames, rendered idle frames and menu/hidden input checks |
| I-001/I-002 behaviors retained | PASS — automated and user-reported physical | Original bootstrap/terrain suites and retained scene/rendered behavior coverage; generation fixture unchanged |
| Android debug build and established signing/pipeline | PASS | Signed APK, matching certificate, manifest/resource checks |
| Real Android I-003 functionality and input stress | PASS — user-reported | User installed 0.3.0 and passed all nine acceptance groups; no independent agent phone test |

Required I-003 acceptance is complete following the user report below. I-004 only is now authorized. Historical agent-run evidence and unavailable-device results above remain unchanged.

Implementation commit **`ec34a61d77e1807ae0e97071dccab694b0adc72c`** is pushed to origin/main. Working tree was clean and remote HEAD matched after push. The documentation-only follow-up records this actual commit and hosted CI result; no runtime change follows the verified implementation. I-002 acceptance/future visual direction was committed separately as **`7f362ea2c3c58ecacd97fb31a6f85668356c176a`**.

## APK

`builds/android/Hollowfold-I003-debug.apk`: **28,356,092 bytes (27.04 MiB)**, version **0.3.0/code 3**. SHA-256 **`EAD7876C02078283248AFF2C7FEE934DC1EF44A43F6F228663B52617C9EF64B2`**. Same `io.github.drinkwaterdrink.hollowfold` and local debug signing identity. Previous APKs preserved; no APK/key committed. Rebuilding may alter archive/signature timestamps/hash.

## Exact Android checklist for I-003

Use the new **0.3.0** APK. Report PASS/FAIL per item, phone model and Android version; optional captures/logs are useful. These remain **UNVERIFIED until the user tests**.

1. Update/install with the same package/key (`adb install -r` command in BUILD_ANDROID.md). Verify 0.3.0 title, New Run, Settings, Back and portrait/insets. New Run → Explore region.
2. Fresh process starts seed **1337**, cell **3,11**, counter **#0 t0**. Wait idle for at least 10 seconds: position, counter and time must not change.
3. At the initial spawn, press Up/Left into rock and a blocked diagonal: position remains 3,11, **#0 t0**, and failure reports no time used. After each rejected press, a legal action must still work.
4. From the initial spawn press Right once: cell **4,11**, **#1 t100**. Each later accepted adjacent Move adds exactly one action and 100 time. Rock/water/bounds and blocked corners never advance either.
5. Press centre **Wait** once: same cell, **#2 t200** after the sequence above. Wait changes time/index, never position. Keyboard equivalents if available: Space/period Wait; arrows/WASD + Q/E/Z/C move.
6. Tap the player's visible tile and a visible adjacent wall/ground: status gives that visible tile's terrain/coordinates; position, action index and time do not change. I on a keyboard inspects the player's tile.
7. Tap a black/unknown map area: status says not currently visible, no terrain details, and no change to position/index/time. Walk around a corner: new tiles reveal; previously seen tiles outside LOS dim. Tapping a dim unseen tile must not reveal live details or use time.
8. Single ordinary taps must produce at most one adjacent step each; holding is not auto-walk. Rapidly tap movement/Wait, then press overlapping pad buttons with two fingers. Overlapping input may be ignored, never multiply a gesture into extra turns. Release all fingers; subsequent single actions must work. Repeat after a rejected blocked move.
9. Open Back → launch panel → title/Settings, wait, then re-enter exploration: navigation consumed no time and in-memory position/counters remain. Android system Back follows the same hierarchy. No save/load is promised after process death.
10. **Regenerate**: same seed/map/spawn, counters **#0 t0**, initial fog restored. **Next seed**: seed increments, different terrain/spawn, fresh counters/fog. Repeat movement/Wait/Inspect after both; no stale lock or event should carry over.
11. Background/resume during exploration and during a finger press: no autonomous action/time progression; after releasing/re-focusing controls recover. Rotate phone, check camera follow/cutouts/gesture areas, then repeat in airplane mode.
12. Explore for at least five minutes with frequent Wait/Inspect/navigation/regeneration and rapid input. Report any freeze, duplicate movement, time jump, hidden-info leak or stuck input. Force-stop/relaunch should return to title with a fresh unsaved explorer, not falsely claim restored run state.

## Every changed file in this task

This inventory includes the separate I-002 acceptance/documentation commit and I-003 implementation/evidence. `.gd.uid` companions are intentional Godot identifiers, not generated build artifacts.

```text
CHANGELOG.md
README.md
docs/BUILD_ANDROID.md
docs/decisions.md
docs/I-002_Verification.md
docs/I-003_Verification.md
docs/plans/I-003_Implementation_Plan.md
docs/progress.md
export_presets.cfg
project.godot
scenes/boot.tscn
scenes/region.tscn
scripts/game_session/action_command.gd
scripts/game_session/action_command.gd.uid
scripts/game_session/action_result.gd
scripts/game_session/action_result.gd.uid
scripts/game_session/rng_streams.gd
scripts/game_session/rng_streams.gd.uid
scripts/game_session/simulation_session.gd
scripts/game_session/simulation_session.gd.uid
scripts/game_session/turn_scheduler.gd
scripts/game_session/turn_scheduler.gd.uid
scripts/game_session/visibility.gd
scripts/game_session/visibility.gd.uid
scripts/ui/region_screen.gd
scripts/visual/region_view.gd
scripts/world/region_grid.gd
tests/fixtures/i003_replay_v1.json
tests/headless/region_scene_smoke.gd
tests/headless/region_visual_smoke.gd
tests/headless/simulation_scene_smoke.gd
tests/headless/simulation_scene_smoke.gd.uid
tests/headless/simulation_tests.gd
tests/headless/simulation_tests.gd.uid
tests/headless/simulation_visual_smoke.gd
tests/headless/simulation_visual_smoke.gd.uid
tools/export_android.ps1
tools/verify.ps1
```

## User-reported physical acceptance

On 2026-10-17 the user officially approved I-003 after installing/testing **0.3.0** on an Android phone. **All nine groups PASSED; no problems observed.** These are user-reported physical-device results, not tests independently executed by the coding agent.

1. Launch, menus, portrait orientation and screen insets.
2. Seed 1337 starts (3,11), #0/t0; idle does not progress turns.
3. Blocked/diagonal moves cost nothing; Right gives (4,11), #1/t100.
4. Wait gives #2/t200 without movement.
5. Inspect costs no time and protects hidden information.
6. Fog reveals new areas and dims remembered terrain.
7. Rapid taps/holds/overlapping touches cause no duplicate actions or stuck controls.
8. Regenerate/Next Seed reset/change terrain, counters and fog correctly.
9. Navigation, background/resume, offline use and extended exploration work without crashes or autonomous turns.

Required AC-I003 is complete. Optional screenshots/device metadata and additional unperformed tests remain nonblocking follow-ups; no new automated result is inferred. The prior checklist and agent no-device findings above are retained as historical evidence.
