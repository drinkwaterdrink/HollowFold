# I-001 verification — 2026-10-17

Scope: title/navigation and Android project bootstrap only. I-002 was not started.

## Environment and baseline

- Existing workspace was an empty Git repository (correct root, no commits, no remote). `git ls-remote` confirmed no remote refs. GitHub API confirmed `drinkwaterdrink/HollowFold`, public, default branch main, size 0.
- Extracted `C:/Users/trent/Downloads/Hollowfold_Repo_Starter.zip` directly into the root; nine required files verified. Corrected setup naming/visibility in README/START_HERE and decision ledger. Full master blueprint preserved from archive, never abbreviated.
- Baseline `da274ae`: `docs: initialize Hollowfold master blueprint and roadmap`; pushed to origin/main.
- Found matching engine ZIP in Downloads. Initial global editor settings pointed to a nonexistent SDK; no Java/ADB on PATH and no installed export templates. Downloaded official matching templates, portable JDK 17 and Android tools into ignored `.local/`; project-local Godot settings isolated with `_sc_`.

## Actual commands and results

Commands below ran from the repository root; full local logs are ignored under `.local/`.

| Command / check | Actual result |
|---|---|
| `.local/tools/Godot_v4.7.2-stable_win64_console.exe --version` | `4.7.2.stable.official.ed1daf0bf` |
| `./tools/verify.ps1` | PASS, exit 0: import, configured main scene boot for 60 frames, behavior tests |
| Direct headless test before boot implementation | RED: `FAIL: boot scene exists`, 1 check, 1 failure, exit 1 |
| `--headless --path . --script tests/headless/bootstrap_smoke.gd` | GREEN: `BOOTSTRAP_SMOKE: 28 checks, 0 failures` |
| `--path . --script tests/headless/visual_smoke.gd` with absolute local log path | PASS, exit 0: `VISUAL_SMOKE: pointer navigation, 3 screenshots, 0 failures`; actual OpenGL 3.3 Compatibility on AMD Radeon 780M |
| `./tools/export_android.ps1` | PASS, exit 0; Android export, alignment, debug signing and APK verification |
| `apksigner.bat verify --verbose builds/android/Hollowfold-debug.apk` | `Verifies`, v2 and v3 signatures true, one signer |
| `aapt.exe dump badging`, `dump permissions`, `dump xmltree ... AndroidManifest.xml` | ID/title correct, min API 24, target/compile API 36, ARM64, portrait value 1, exported launcher alias `com.godot.game.GodotAppLauncher`, no uses-permission entries |
| APK ZIP inventory | Runtime UI resources and Godot license notices present; no docs/tests/tools/.local/keystores included |
| `.local/android-sdk/platform-tools/adb.exe devices -l` | Empty `List of devices attached`; no installation attempted without a target |
| `git diff --check` | PASS |

The headless suite exercises first-install visibility, absence of Continue, New Run/Settings/visible Back, Android Back notifications, Escape, repeated navigation, focus restoration, button widths/heights at 360×640, 360×800 and 320×568, and synthetic notch/side/gesture insets with translated origins and empty safe-area fallback. It does not measure physical dp, GPU behavior on Android or OS-reported insets.

Rendered screenshots: `.local/verification/title.png`, `new-run.png`, `settings.png`. All three inspected: readable text, no clipping at the captured 450×800 desktop window, visible Back, coherent theme. The test injects pointer events into the real viewport; it does not claim physical touch observation.

## Failed attempts and resolutions

- Sandboxed Git networking failed (`getaddrinfo() thread failed to start`); elevated Git access succeeded. Repository identity/root verified before mutation.
- First test harness used the Back constant on MainLoop; pinned API defines it on Node. Corrected harness, then observed intended RED and GREEN.
- Sandboxed Godot could not write its default `user://` profiler/log directories; final checks used actual user execution and absolute log paths. No final import/scene errors.
- Initial Android export exited 1 because ETC2/ASTC import was required. Enabled the explicit exporter-required project setting; subsequent export passed.
- SDK 35 tools worked but warned that target SDK tools did not match. Pinned template inspection showed API 36; installed API 36/build-tools 36.0.0 and reran without that warning. One SDK install invocation had a malformed path argument; corrected quoting and verified installed package files.
- First rendered harness supplied logical coordinates as window pixels, causing three failed navigation assertions. Used viewport-local input (`push_input(event, true)`), then actual GUI navigation passed. No product workaround was needed.

## AC-I001 status

| Acceptance item | Status | Evidence / limitation |
|---|---|---|
| Pinned Godot project opens without parse/scene errors | PASS | Final headless editor import, main scene boot and real renderer |
| Hollowfold title, New Run and Settings; enter/exit placeholder | PASS on desktop | 28 behavior checks and actual rendered pointer navigation; Android behavior UNVERIFIED |
| Compatibility renderer, portrait config and Android export foundation | PASS | Engine renderer output, project settings, successful signed APK and manifest |
| Signed debug APK exported | PASS | Godot export exit 0, signature verification |
| APK installs and boots on physical Android in portrait | UNVERIFIED | No device available |
| Real phone safe areas, touch reach, background/resume and rotation | UNVERIFIED | Synthetic geometry passes; phone screenshot and manual observation required |
| Documented headless scene smoke command | PASS | `./tools/verify.ps1` ran successfully |
| No tracked signing secrets or generated APK/SDK | PASS at local audit | Ignore rules, explicit staging and tracked-path inspection required before commit |
| Clean repository and implementation pushed | Recorded in final report | Confirm with `git status --short --branch` and local/remote SHA equality after commit |
| GitHub CI execution | UNVERIFIED before push | Workflow is included; local script PASS does not claim a hosted run |

**Overall:** Implementation and debug export ready for review; AC-I001 remains **UNVERIFIED** as a whole until physical-device acceptance. I-002 remains gated on the user's review/authorization.

APK from the successful export: 28,317,023 bytes (27.01 MiB), SHA-256 `842FD09960535892142F46B3107F499C4DDF7784A5084900C0DBB75049E2A8EB`. Rebuilding may change ZIP/signature timestamps and hash. [BUILD_ANDROID.md](BUILD_ANDROID.md) contains exact install/launch, capture and manual acceptance steps.

Independent read-only code review found no material findings. Optional test coverage deferred: automated small-window assertions currently cover title controls, not child-panel scrolling/Back reachability at deliberately short heights. Real phone reachability remains explicitly UNVERIFIED.
