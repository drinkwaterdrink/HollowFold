# Progress ledger

| Packet | Status | Acceptance evidence | Blockers | Commit |
|---|---|---|---|---|
| I-001 | ACCEPTED — user approved 2026-10-17 | Agent import/boot, 28 checks, rendered navigation, APK verification and CI PASS; user reports all nine required Android manual checks PASS | None for required acceptance; optional evidence/coverage follow-ups below | `7fd6ac0f148971cde3a35f8501a37df3d102cde7` |
| I-002 | IMPLEMENTED; physical acceptance UNVERIFIED | Same-seed hash fixture; 14,216 pure checks across 100 seeds; 17 scene checks; original 28 I-001 checks; rendered pointer/key checks at three portrait sizes; signed APK export; hosted CI PASS | No attached phone for new-APK launch, touch/inset/lifecycle checks or five-minute walkthrough | `7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725` |

Do not mark on-device acceptance criteria PASS without a real APK installation and observed behavior.

## I-001 evidence — 2026-10-17

- Baseline: `da274ae`, `docs: initialize Hollowfold master blueprint and roadmap`, pushed to `origin/main`. All nine starter files present; complete blueprint preserved unchanged.
- Full item-by-item AC-I001 table, actual commands, failures/resolutions and evidence: [I-001 verification](I-001_Verification.md).
- Build: `./tools/verify.ps1` and `./tools/export_android.ps1` both ran successfully. APK at ignored `builds/android/Hollowfold-debug.apk`, 28,317,023 bytes; v2/v3 signature checks PASS. ARM64, min API 24, target API 36, portrait, no requested permissions.
- During agent verification ADB listed no device. Subsequently, on 2026-10-17, the user reported installing/testing the I-001 APK and passing all nine required physical checks, and explicitly approved I-001. These are **user-reported physical-device results**, not independently performed agent tests. See the verification document for the nine checks.
- Tools installed locally: Godot 4.7.2, matching Android templates, OpenJDK 17, Android platform/build-tools 36. No release keys or binaries committed. Instructions: [BUILD_ANDROID.md](BUILD_ANDROID.md).
- Hosted CI: [run 39044645463](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39044645463), **success**, verified through GitHub API after push. Tested implementation SHA `7fd6ac0f148971cde3a35f8501a37df3d102cde7`; engine download and import/boot/smoke step all succeeded.
- Implementation: `7fd6ac0f148971cde3a35f8501a37df3d102cde7`, `feat: bootstrap I-001 Godot Android project`, pushed to origin/main; local and remote SHAs matched and working tree was clean. This follow-up documentation commit records that concrete hash and hosted CI evidence without changing runtime code.
- Optional nonblocking follow-ups: device model/Android version and safe-area screenshot were not supplied; additional very-short child-panel scrolling coverage and broader large-font testing remain UNVERIFIED. No new automated pass is inferred from the user's report.
- Next packet: **I-002 AUTHORIZED** by the user on 2026-10-17. I-003 and later remain unauthorized.

## I-002 evidence — 2026-10-17

- I-001 acceptance update committed/pushed first as `bcaa6e7`; all nine manual results are explicitly user-reported. No unperformed automated check was promoted to PASS.
- [Implementation plan](plans/I-002_Implementation_Plan.md), [full verification and AC-I002](I-002_Verification.md), [build/install guide](BUILD_ANDROID.md).
- Pure seeded model (31×39), TileMapLayer renderer, actor/camera and eight-way temporary controls. No I-003 scheduler/commands framework or later systems.
- `./tools/verify.ps1`: import and 60-frame boot PASS; `BOOTSTRAP_SMOKE: 28 checks, 0 failures`; `REGION_TESTS: 14216 checks, 0 failures`; `REGION_SCENE_SMOKE: 17 checks, 0 failures`.
- Both rendered smoke scripts PASS; region controls contained at 450×800, 360×640 and 450×1000; screenshots inspected. Seed 1337 spawn (3,11), SHA-256 `bc684a41b41fb3877fe8a325c5a5ffbaa596b436280fdb2f709908269f5131ba`.
- New ignored APK: `builds/android/Hollowfold-I002-debug.apk`, version 0.2.0/code 2; same key/app ID (matching signing certificate verified). Build/signature checks PASS; previous I-001 APK preserved. Final size 28,334,486 bytes; SHA-256 `B13AE3A61BD60BC246660C7D99758F98D9175AC3F8F7B05E4FAF5A160350C092`.
- ADB lists no device; **I-002 physical Android results UNVERIFIED**, including five-minute walkthrough. The user's I-001 acceptance is not reused as I-002 evidence.
- Implementation `7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725` (`feat: implement I-002 deterministic region exploration`) committed/pushed to origin/main. Local/remote SHA equality and clean tree verified after push.
- Hosted [CI run 39047443791](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39047443791) completed **successfully** against that implementation SHA. GitHub API confirmed engine download and import/boot/all-headless-suite steps passed on Linux, including the committed map fixture. This documentation follow-up records the actual hash/result without changing runtime code.
- Stop after I-002; **I-003 NOT AUTHORIZED / NOT STARTED**. User review of I-002 is required before proceeding.
