# I-002 — One explorable deterministic region

Date: 2026-10-17. Authorized scope: master blueprint F-006, S-004, I-002 and AC-I002. I-003 and later systems were not implemented.

## Prior acceptance and environment

I-001 acceptance documentation was committed/pushed separately in `bcaa6e7`: the user reported all nine required physical Android checks PASS and officially approved I-001. Those are **user-reported results, not independently performed agent tests**. Optional extra coverage/screenshot/device metadata remain nonblocking follow-ups. I-001 acceptance does not transfer to this new APK.

Existing toolchain reused: Godot `4.7.2.stable.official.ed1daf0bf`, Compatibility, OpenJDK 17, API 36/build-tools 36.0.0, matching templates, same local debug key and application ID. No locked design decision changed; no dependency installation needed.

## Files and responsibilities

New:

- `scripts/world/region_grid.gd`: terrain bytes, dimensions, passability, spawn/entrance/player cells, adjacent movement/collision, world/cell conversions, stable fingerprint.
- `scripts/world/local_region_generator.gd`: isolated seed-driven bounded generation, independent of scene/render timing.
- `scripts/visual/region_view.gd`: original code-generated prototype atlas, TileMapLayer population and following/clamped Camera2D.
- `scripts/visual/player_marker.gd`: temporary player glyph.
- `scripts/ui/region_screen.gd`, `scenes/region.tscn`: inset-aware portrait region, eight-way pad/keyboard adapter, status, Back and seed debug controls.
- `tests/fixtures/i002_region_v1.json`: committed seed 1337 hash/spawn fixture.
- `tests/headless/region_tests.gd`, `region_scene_smoke.gd`, `region_visual_smoke.gd`: pure data tests, scene integration and actual rendered-viewport input checks. Corresponding generated `.gd.uid` files preserve Godot script identities.
- `docs/plans/I-002_Implementation_Plan.md`, this verification document.

Modified:

- `scenes/boot.tscn`, `scripts/ui/boot.gd`: retain title/New Run/Settings/Back, add Explore region and nested Back handling.
- `project.godot`, `export_presets.cfg`, `tools/export_android.ps1`: version 0.2.0 / code 2, versioned APK filename, same renderer/key/app ID/permissions.
- `tools/verify.ps1`, `.github/workflows/godot-smoke.yml`: add I-002 headless suites to existing checks/CI.
- README, CHANGELOG, LICENSES_AND_ASSETS, build guide, decision/progress ledgers.

## Generation and movement

Revision 1 generates one **31×39** rectangular region. An isolated `RandomNumberGenerator` seeded with the supplied integer carves a maze through odd interior cells using an iterative stack. Eight small clearings create loops. Water pools replace rock; a guaranteed water cell at (2,2), originally rock in the maze, can remove only optional clearing floor and cannot break the original connected path network. The rock boundary is retained. All walkable cells are connected by cardinal steps.

The randomly selected initial odd cell becomes a walkable entrance and player spawn. Ground and entrance are passable; rock, water and out-of-bounds are blocked for this temporary actor. Adjacent eight-way moves require legal destination; diagonals also require both neighboring orthogonal tiles passable. A rejected move leaves logical position unchanged. There is no scheduler, action queue, turn count, enemies, combat, inventory, fog/LOS, macro-world/history, streaming or save implementation.

The renderer reads grid data; it does not own collision. Tiles use provisional 24×24 logical pixels and original simple geometric art. The player glyph is positioned at the model's cell center; TileMapLayer coordinate alignment is tested. A camera follows the glyph and clamps to region bounds inside a clipped SubViewport. Hidden region views stop receiving movement and only render when visible.

**Entry:** New Run → Explore region. Initial seed **1337**. **Regenerate** reconstructs the same seed and resets player/camera to its spawn. **Next seed** increments the integer seed. Back/system Back/Escape returns to New Run, then title. Leaving/re-entering retains temporary in-memory exploration; process restart starts at title and no saved exploration exists.

The SHA-256 fingerprint uses revision, dimensions, seed, spawn, entrance and row-major terrain bytes. It excludes mutable current player position. Golden fixture for seed 1337: spawn **(3,11)**, hash **`bc684a41b41fb3877fe8a325c5a5ffbaa596b436280fdb2f709908269f5131ba`**. Guarantees are scoped to the pinned engine and generation revision. Cross-platform fixture agreement is additionally checked by hosted CI when run.

## Actual tests and build evidence

All commands ran from the repository root. Full logs and captures are ignored under `.local/`.

| Command/check | Actual result |
|---|---|
| New `region_tests.gd` before generator existed | Expected RED, exit 1: `region generator exists`, 1 failed check |
| `./tools/verify.ps1` | PASS: headless editor import, 60-frame main-scene boot, original I-001 suite and both I-002 headless suites |
| Original `bootstrap_smoke.gd` (unchanged) | `BOOTSTRAP_SMOKE: 28 checks, 0 failures` |
| `region_tests.gd` | `REGION_TESTS: 14216 checks, 0 failures`: 100 seeds repeat, raw terrain varies across all 100, legal spawn/entrance, terrain kinds, connected walkable tiles, solid borders, blocked walls/water/bounds/diagonals/invalid deltas, legal cardinal/diagonal moves and coordinate roundtrips |
| `region_scene_smoke.gd` | `REGION_SCENE_SMOKE: 17 checks, 0 failures`: navigation, full tile population, coordinate/actor/camera alignment, actual pad signals, regeneration, seed change, blocked input, key repeat rejection, keyboard adapter and hidden-screen input, visible/Android Back/Escape |
| Original rendered `visual_smoke.gd` (unchanged) | PASS: pointer navigation, three screenshots, zero failures |
| Rendered `region_visual_smoke.gd` | PASS: zero failures; real GUI pointer/key routing, one-step input, player inside clipped camera view, regeneration, next seed, Back and controls contained at 450×800, 360×640 and 450×1000 |
| Desktop screenshot inspection | PASS at captured sizes: visible terrain/entrance/player, clear rock vs water, readable status/seed, reachable pad/debug/Back; no control clipping observed |
| `./tools/export_android.ps1` | Signed debug APK export/alignment/signature verification PASS, including final rebuild after visible-only viewport update |
| APK manifest inspection (`aapt dump badging`, `dump permissions`, `dump xmltree`) | Version 0.2.0/code 2, same `io.github.drinkwaterdrink.hollowfold`, ARM64, API 24 minimum / 36 target, portrait; no requested permissions |
| `adb devices -l` | Empty device list. Agent did not install/test I-002 on a phone |
| `git diff --check` | PASS |
| Hosted GitHub CI | PASS: [run 39047443791](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39047443791), `success` against `7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725`; official Linux engine download and import/boot/headless suite step succeeded, including the seed/hash fixture |

Final APK: **28,334,486 bytes (27.02 MiB)**, SHA-256 **`B13AE3A61BD60BC246660C7D99758F98D9175AC3F8F7B05E4FAF5A160350C092`**. V2/V3 signatures verify. The I-001 and I-002 APK certificate SHA-256 digests match, confirming continuity of the local development signing key. APK ZIP inspection found new region runtime resources and no docs/tests/tools/.local/keystores. Rebuilding can change archive/signature timestamps and hash.

Rendered commands:

```powershell
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/visual-regression.log" --script tests/headless/visual_smoke.gd
& '.local/tools/Godot_v4.7.2-stable_win64_console.exe' --path . --log-file "$PWD/.local/region-visual.log" --script tests/headless/region_visual_smoke.gd
```

Captures include `.local/verification/i002-region.png`, `i002-next-seed.png` and one capture per tested window size. Real renderer was OpenGL 3.3 Compatibility on AMD Radeon 780M. Programmatic viewport input and desktop captures do **not** establish physical touch targets, Android GPU behavior, safe-area reporting or a five-minute phone walkthrough.

## AC-I002

| Acceptance criterion | Status | Evidence |
|---|---|---|
| Same seed reproduces terrain passability and spawn | PASS | Golden fixture plus 100 repeated-seed maps; direct grid/hash comparisons |
| Player cannot spawn inside blocked terrain | PASS | Every seed's spawn and entrance validated passable |
| Moving into solid rock leaves logical position unchanged | PASS | Explicit wall fixture and UI-adapter blocked-movement test; water/bounds/diagonal cases also covered |
| Visible terrain, entrance, actor, camera, collision and temporary touch controls | PASS on desktop; Android UNVERIFIED | Scene tests, actual GUI pointer/key input and captures; phone absent |
| Region fits portrait layout | PASS on desktop; Android UNVERIFIED | Three rendered portrait sizes; actual cutouts/physical comfort need phone test |
| App still launches/navigates; I-001 tests remain passing | PASS on desktop; new APK phone launch UNVERIFIED | Import/main boot, 28 unchanged checks and rendered regression |
| Generated maps can be checked automatically | PASS | Fixed hash/spawn fixture and headless tests included in `verify.ps1`/CI |
| New Android debug APK built and verified | PASS | Signed APK, v2/v3 signature checks, manifest inspection |
| App launches on phone and five-minute walkthrough | UNVERIFIED | No attached device; I-001 reported results apply only to I-001 |

Implementation is ready for I-002 review; physical acceptance remains pending. I-003 is **NOT AUTHORIZED / NOT STARTED**.

Independent read-only code review found no material issues. Reviewer inspected existing logs and ran `git diff --check`, without claiming independent Godot/phone execution. Optional coverage follow-up: compare raw terrain in the scene-level Next seed assertion as well; the pure 100-seed suite already tests raw terrain variation, so this is nonblocking.

Implementation commit: **`7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725`**, pushed to origin/main. Working tree was clean and remote HEAD matched after push. This documentation-only follow-up records that concrete commit and hosted CI result; no runtime change follows the tested implementation.

## Short manual Android checklist

1. Install/update `builds/android/Hollowfold-I002-debug.apk` (same debug key/app ID; version code 2). Launch offline; verify portrait title, Settings and Back still work.
2. New Run → Explore region. Walk at least **five minutes** using the eight-way pad. Check ground, rock, water, gold entrance and player remain readable; camera follows. Walls/water/boundaries and blocked diagonal corners must reject movement without moving the player.
3. Record the seed/map/spawn; move away, press Regenerate and compare all three. Next seed must change terrain. Repeated pad taps should each make at most one adjacent step; holding is deliberately not auto-walk.
4. Test Back and Android system Back → New Run → title; re-enter exploration. Check portrait lock, cutouts/gesture bars, small display settings and control reach. Desktop measurements do not replace this check.
5. Background/resume exploration, then force-stop/relaunch. In-memory exploration should survive backgrounding without process death; fresh process returns to title (no save system). Repeat regeneration/movement in airplane mode. Report device model, Android version, pass/fail observations and screenshot/logs where possible.

See [BUILD_ANDROID.md](BUILD_ANDROID.md) for exact ADB install/launch/capture commands. ADB access and USB trust are the only remaining computer/device setup if using the already prepared local toolchain.
