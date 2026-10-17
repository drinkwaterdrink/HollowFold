# Hollowfold

An offline-first, portrait Android tactical roguelike built incrementally in Godot 4.7.2 and GDScript.

Repository: [drinkwaterdrink/HollowFold](https://github.com/drinkwaterdrink/HollowFold) (public). Game title: **Hollowfold**.

## Design contract

- Master blueprint: `docs/plans/Hollowfold_Master_Blueprint_v1.md`
- Roadmap: `docs/roadmap/Hollowfold_Roadmap_Quick_Reference.md`
- Codex first task: `docs/agents/I-001_Godot_Agent_Kickoff.md`
- Progress: `docs/progress.md`
- Change log: `docs/decisions.md`

## Workflow

Read `AGENTS.md`. Implement one I-packet at a time. Start with I-001 and do not begin I-002 without the human's review.

I-001 now contains the Godot project, title menu, New Run placeholder and Settings/Back navigation. It contains no gameplay yet. Android application ID: `io.github.drinkwaterdrink.hollowfold`.

## Open, verify and build

Open `project.godot` in **Godot 4.7.2 stable** (Compatibility). From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1
```

The portable engine, JDK, SDK and export templates are already prepared locally under ignored `.local/`. The signed debug APK is at `builds/android/Hollowfold-debug.apk`; generated binaries and signing material are not in Git.

- Setup, exact commands and phone checklist: [Android build guide](docs/BUILD_ANDROID.md)
- Actual checks, results and acceptance limits: [I-001 verification](docs/I-001_Verification.md)
- Asset provenance and notices: [Licenses and assets](LICENSES_AND_ASSETS.md)

Physical-device installation, portrait/safe-area behavior and touch comfort are **UNVERIFIED** because no Android device was connected. I-002 is not authorized or implemented. Review I-001 on a real phone before requesting the next packet.
