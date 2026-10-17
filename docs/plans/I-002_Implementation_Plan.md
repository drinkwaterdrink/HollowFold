# I-002 — One explorable deterministic region

**Spec:** Master blueprint F-006, S-004 and section 17 I-002 / AC-I002, plus the user's explicit I-002 authorization on 2026-10-17.
**Execution:** Inline in the existing checkout. First push I-001 user-reported acceptance separately (`bcaa6e7`), then implement/test/review/commit I-002 only. User authorizes continued execution without a plan approval pause.

## Design and files

- `scripts/world/region_grid.gd`: pure RefCounted terrain data (ground/rock/water/entrance), bounds, passability, spawn/player cell, collision and stable content fingerprint. No nodes, turns, physics or RNG calls in movement.
- `scripts/world/local_region_generator.gd`: isolated seeded RNG, bounded 31×39 maze carving plus small clearings and water on blocked cells; all traversable cells stay connected. Entrance and legal spawn coincide. Generation revision 1 is covered by a committed seed/hash fixture.
- `scenes/region.tscn`, `scripts/ui/region_screen.gd`: safe-area portrait view, clipped SubViewport, Back, seed/position/status, temporary 8-way pad, Regenerate (same seed/reset spawn) and Next seed. Keyboard arrows/WASD + diagonal Q/E/Z/C; one discrete input per press, no key-repeat movement. Generation is small/bounded and invoked only on explicit entry/debug actions.
- `scripts/visual/region_view.gd`, `scripts/visual/player_marker.gd`: runtime pixel atlas/TileMapLayer, player marker and Camera2D tracking logical position. Explicit cell/world coordinate conversions; renderer reads model and never decides collision.
- Extend `scenes/boot.tscn` / `scripts/ui/boot.gd`: retain existing New Run and Settings panels, add Explore region to New Run and route Back/Escape/Android Back consistently. No creator or persistent run yet.
- Tests: `tests/headless/region_tests.gd`, `tests/headless/region_scene_smoke.gd`, `tests/headless/region_visual_smoke.gd`, `tests/fixtures/i002_region_v1.json`; add headless checks to `tools/verify.ps1` and existing CI. Keep original I-001 tests passing.
- Update project/export version to 0.2.0/code 2; new ignored APK filename preserves I-001 artifact. Record choices, evidence, limitations, asset provenance and manual checklist in README, CHANGELOG, decisions, progress and `docs/I-002_Verification.md`.

## Verification sequence

1. Write/run missing-feature tests (RED), implement minimal grid/generator, run deterministic/hash tests (GREEN). Sweep seeds for repeatability, legal spawn, terrain presence, connected walkable cells; test walls/water/bounds, diagonal obstruction, invalid deltas and cell/world roundtrip.
2. Import/editor/main boot; run unchanged I-001 tests and I-002 headless scene tests (navigation, actual directional button signals, same-seed reset, changed seed, model/marker/camera agreement and hidden-screen input).
3. Real renderer: inject pointer input through viewport, explore/reject a blocked move, regenerate, return through menus, capture/inspect portrait screens at normal and shorter sizes. Check control/map bounds.
4. Export signed APK with existing local key; verify signature, manifest/version/permissions and exclusion of docs/tests/tools/keys. Check ADB availability; physical I-002 testing is UNVERIFIED if no device is listed. I-001 user acceptance does not transfer to the changed APK.
5. Independent review, staged source/artifact audit, commit/push, verify clean tree/remote equality and hosted CI. Record implementation hash in a documentation follow-up if needed.

## Scope and review focus

No material conflict found. The broad S-004/F-006 design is staged; only I-002's local terrain/movement slice is authorized. No scheduler, commands framework, enemies, combat, inventory, fog/LOS, world topology/history/streaming or saves. Tile dimensions/art are prototype choices. Water is blocked for this temporary actor. Diagonal steps require both neighboring orthogonal cells passable to avoid corner cutting. Entrance is a visible starting landmark, not a level transition.

Review boundary/diagonal collision, seed/hash stability across Windows/Linux, controls after hiding region, rapid navigation, camera/map containment, phone inset uncertainty and old/new evidence attribution.

## Execution ledger

- I-001 acceptance: all nine physical checks recorded as user-reported; optional screenshot/device metadata and extra automated coverage remain nonblocking/unverified; docs pushed in `bcaa6e7`.
- Environment: engine reports `4.7.2.stable.official.ed1daf0bf`; existing API 36 tools/templates/debug key available; no engine or renderer migration.
- Pure model: missing-generator RED observed; fixture seed 1337 spawn (3,11) fixed. Final pure suite GREEN: 14,216 checks across 100 seeds. Map variation compares raw terrain bytes (not seed metadata).
- Integration: original 28 I-001 checks remain unchanged/passing; 17 new scene checks and actual rendered pointer/key suite pass. Controls contained at three portrait sizes; captures inspected. Map render mode is visible-only; no hidden-region movement processing.
- Export: version 0.2.0/code 2, original key/app ID, new filename preserves I-001 APK. ADB has no device, so phone acceptance is UNVERIFIED. No material spec conflict or engine change.
- Independent read-only final review: no material findings. Minor optional coverage deferred: scene-level Next seed assertion compares a fingerprint that includes seed metadata; the pure suite already tests variation using raw terrain bytes. This is not a product defect or acceptance blocker.
