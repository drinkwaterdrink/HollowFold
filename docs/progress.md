# Progress ledger

| Packet | Status | Acceptance evidence | Blockers | Commit |
|---|---|---|---|---|
| I-001 | ACCEPTED — user approved 2026-10-17 | Agent import/boot, 28 checks, rendered navigation, APK verification and CI PASS; user reports all nine required Android manual checks PASS | None for required acceptance; optional evidence/coverage follow-ups below | `7fd6ac0f148971cde3a35f8501a37df3d102cde7` |
| I-002 | ACCEPTED — user approved 2026-10-17 | Prior agent tests/build/CI PASS; user reports all ten Android acceptance checks PASS on version 0.2.0, including five-minute exploration | No required acceptance blocker; optional metadata/captures/test coverage remain nonblocking | `7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725` |
| I-003 | IMPLEMENTED; physical acceptance UNVERIFIED | Replay canonical hash; 82 simulation + 18 input/frame checks; bootstrap 28, terrain 14,216 and region 17 checks; rendered Wait/Inspect/fog/input/portrait checks; signed APK; hosted CI PASS | User must test new 0.3.0 APK, especially real touch stress/OS emulation; no device attached | `ec34a61d77e1807ae0e97071dccab694b0adc72c` |

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
- I-002 was authorized and subsequently accepted; current authorization is I-003 only (see latest acceptance below).

## I-002 evidence — 2026-10-17

- I-001 acceptance update committed/pushed first as `bcaa6e7`; all nine manual results are explicitly user-reported. No unperformed automated check was promoted to PASS.
- [Implementation plan](plans/I-002_Implementation_Plan.md), [full verification and AC-I002](I-002_Verification.md), [build/install guide](BUILD_ANDROID.md).
- Pure seeded model (31×39), TileMapLayer renderer, actor/camera and eight-way temporary controls. No I-003 scheduler/commands framework or later systems.
- `./tools/verify.ps1`: import and 60-frame boot PASS; `BOOTSTRAP_SMOKE: 28 checks, 0 failures`; `REGION_TESTS: 14216 checks, 0 failures`; `REGION_SCENE_SMOKE: 17 checks, 0 failures`.
- Both rendered smoke scripts PASS; region controls contained at 450×800, 360×640 and 450×1000; screenshots inspected. Seed 1337 spawn (3,11), SHA-256 `bc684a41b41fb3877fe8a325c5a5ffbaa596b436280fdb2f709908269f5131ba`.
- New ignored APK: `builds/android/Hollowfold-I002-debug.apk`, version 0.2.0/code 2; same key/app ID (matching signing certificate verified). Build/signature checks PASS; previous I-001 APK preserved. Final size 28,334,486 bytes; SHA-256 `B13AE3A61BD60BC246660C7D99758F98D9175AC3F8F7B05E4FAF5A160350C092`.
- Agent-run ADB checks listed no device. Subsequently the user reported ten physical PASS results for version 0.2.0 and officially approved I-002. These are **user-reported real-device results**, not tests independently performed by the agent; exact checklist is in the I-002 verification document.
- Implementation `7e5f917e798c0bf9cdf3fbd96ff2b38a14e83725` (`feat: implement I-002 deterministic region exploration`) committed/pushed to origin/main. Local/remote SHA equality and clean tree verified after push.
- Hosted [CI run 39047443791](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39047443791) completed **successfully** against that implementation SHA. GitHub API confirmed engine download and import/boot/all-headless-suite steps passed on Linux, including the committed map fixture. This documentation follow-up records the actual hash/result without changing runtime code.
- I-003 is now explicitly authorized by the user. **I-004 and later NOT AUTHORIZED / NOT STARTED**. Missing optional screenshots/device metadata or extra automated coverage do not block the user's I-002 approval.

## I-003 evidence — 2026-10-17

- User-reported I-002 acceptance/visual preference committed and pushed separately as `7f362ea`. No independent agent physical test is implied. Caves-quality art direction remains for I-005/I-022.
- [Plan](plans/I-003_Implementation_Plan.md), [architecture/every changed file/actual evidence/AC-I003/exact Android checklist](I-003_Verification.md).
- Single-writer commands/results, integer time/action index, bounded cost/speed scheduler, named RNG streams, detached views, LOS/fog/hidden Inspect. No I-004/combat/AI/inventory/save/art overhaul.
- Full headless `verify.ps1` PASS: bootstrap 28, terrain 14,216, retained region-scene 17, simulation 82 and simulation-scene 18 checks, all zero failures. Rendered menu, region and I-003 suites PASS at three portrait sizes. No gameplay progression from idle frames/navigation.
- Seed1337 replay fixture final cell (4,11), action3/time300, canonical SHA-256 `c012bae20d987d6690063267db09e1d4f890bec37a7478f611b93356b42de328`; includes player/time/scheduler/RNG/visibility, not just map.
- Independent review identified stale-view test assertions/evidence wording; corrected and verified. Intentional echo mutant rejected; original restored. Overlap regression RED→GREEN, including routed synthetic-touch/emulated-pointer coverage. These do not certify Android OS behavior.
- Final local APK `builds/android/Hollowfold-I003-debug.apk`, 0.3.0/code3, 28,356,092 bytes, SHA-256 `EAD7876C02078283248AFF2C7FEE934DC1EF44A43F6F228663B52617C9EF64B2`; export/signature/certificate/manifest/resources PASS. Same key/app ID; earlier APKs preserved.
- ADB empty: physical I-003 acceptance remains **UNVERIFIED**. User's prior version results do not transfer to new code.
- Implementation `ec34a61d77e1807ae0e97071dccab694b0adc72c` (`feat: implement I-003 deterministic command and turn engine`) committed/pushed to origin/main. Local/remote SHA equality and clean tree verified after push.
- Hosted [CI run 39050865033](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39050865033) completed **successfully** against that SHA. GitHub API confirmed official Linux engine download and import/boot/all-headless-suite steps succeeded, including both terrain and canonical replay fixtures. This documentation-only follow-up records the real hash/result without changing runtime code.
- **STOP after I-003. I-004 NOT AUTHORIZED / NOT STARTED.**
