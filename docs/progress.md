# Progress ledger

| Packet | Status | Acceptance evidence | Blockers | Commit |
|---|---|---|---|---|
| I-001 | IMPLEMENTED; physical acceptance UNVERIFIED | Godot 4.7.2 import + main scene boot PASS; 28 checks / 0 failures; real rendered pointer navigation PASS; signed debug APK exported and signature/manifest checked; hosted CI PASS | No Android device attached: install/boot, real safe areas, touch comfort and lifecycle UNVERIFIED | `7fd6ac0f148971cde3a35f8501a37df3d102cde7` |

Do not mark on-device acceptance criteria PASS without a real APK installation and observed behavior.

## I-001 evidence — 2026-10-17

- Baseline: `da274ae`, `docs: initialize Hollowfold master blueprint and roadmap`, pushed to `origin/main`. All nine starter files present; complete blueprint preserved unchanged.
- Full item-by-item AC-I001 table, actual commands, failures/resolutions and evidence: [I-001 verification](I-001_Verification.md).
- Build: `./tools/verify.ps1` and `./tools/export_android.ps1` both ran successfully. APK at ignored `builds/android/Hollowfold-debug.apk`, 28,317,023 bytes; v2/v3 signature checks PASS. ARM64, min API 24, target API 36, portrait, no requested permissions.
- `.local/android-sdk/platform-tools/adb.exe devices -l`: empty device list. Physical install/boot, safe-area screenshot, touch and background/resume tests remain **UNVERIFIED**.
- Tools installed locally: Godot 4.7.2, matching Android templates, OpenJDK 17, Android platform/build-tools 36. No release keys or binaries committed. Instructions: [BUILD_ANDROID.md](BUILD_ANDROID.md).
- Hosted CI: [run 39044645463](https://github.com/drinkwaterdrink/HollowFold/actions/runs/39044645463), **success**, verified through GitHub API after push. Tested implementation SHA `7fd6ac0f148971cde3a35f8501a37df3d102cde7`; engine download and import/boot/smoke step all succeeded.
- Implementation: `7fd6ac0f148971cde3a35f8501a37df3d102cde7`, `feat: bootstrap I-001 Godot Android project`, pushed to origin/main; local and remote SHAs matched and working tree was clean. This follow-up documentation commit records that concrete hash and hosted CI evidence without changing runtime code.
- Next packet: **I-002 NOT STARTED and NOT AUTHORIZED**. Review physical AC-I001 evidence first; user approval is required before beginning I-002.
