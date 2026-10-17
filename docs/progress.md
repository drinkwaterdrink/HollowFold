# Progress ledger

| Packet | Status | Acceptance evidence | Blockers | Commit |
|---|---|---|---|---|
| I-001 | IMPLEMENTED; physical acceptance UNVERIFIED | Godot 4.7.2 import + main scene boot PASS; 28 checks / 0 failures; real rendered pointer navigation PASS; signed debug APK exported and signature/manifest checked | No Android device attached: install/boot, real safe areas, touch comfort and lifecycle UNVERIFIED | Implementation commit containing this row; resolve with command below |

Do not mark on-device acceptance criteria PASS without a real APK installation and observed behavior.

## I-001 evidence — 2026-10-17

- Baseline: `da274ae`, `docs: initialize Hollowfold master blueprint and roadmap`, pushed to `origin/main`. All nine starter files present; complete blueprint preserved unchanged.
- Full item-by-item AC-I001 table, actual commands, failures/resolutions and evidence: [I-001 verification](I-001_Verification.md).
- Build: `./tools/verify.ps1` and `./tools/export_android.ps1` both ran successfully. APK at ignored `builds/android/Hollowfold-debug.apk`, 28,317,023 bytes; v2/v3 signature checks PASS. ARM64, min API 24, target API 36, portrait, no requested permissions.
- `.local/android-sdk/platform-tools/adb.exe devices -l`: empty device list. Physical install/boot, safe-area screenshot, touch and background/resume tests remain **UNVERIFIED**.
- Tools installed locally: Godot 4.7.2, matching Android templates, OpenJDK 17, Android platform/build-tools 36. No release keys or binaries committed. Instructions: [BUILD_ANDROID.md](BUILD_ANDROID.md).
- CI workflow included; a successful local run does not establish hosted CI status. Consult the GitHub Actions run after push.
- Commit identity: `git log -1 --format=%H -- docs/progress.md` resolves the implementation commit that contains this ledger. Its own literal hash cannot be embedded in that same commit; final handoff reports the actual hash.
- Next packet: **I-002 NOT STARTED and NOT AUTHORIZED**. Review physical AC-I001 evidence first; user approval is required before beginning I-002.
