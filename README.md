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

The project contains the title menu, New Run launch panel, Settings/Back navigation and I-002's temporary seeded region explorer. Android application ID: `io.github.drinkwaterdrink.hollowfold`.

Choose **New Run → Explore region**. Use the eight-way pad, arrows/WASD or Q/E/Z/C for diagonals. Rock and water block this temporary actor. **Regenerate** recreates the same seed and resets its spawn; **Next seed** selects the next integer seed. **Back** returns to the New Run panel, then title. Exploration has no saves, turns, enemies or combat yet.

## Open, verify and build

Open `project.godot` in **Godot 4.7.2 stable** (Compatibility). From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1
```

The portable engine, JDK, SDK and export templates are already prepared locally under ignored `.local/`. The I-002 signed debug APK is at `builds/android/Hollowfold-I002-debug.apk`; generated binaries and signing material are not in Git. The previous I-001 APK is preserved separately.

- Setup, exact commands and phone checklist: [Android build guide](docs/BUILD_ANDROID.md)
- Actual checks, results and acceptance limits: [I-001 verification](docs/I-001_Verification.md)
- Region generation, acceptance and manual Android checklist: [I-002 verification](docs/I-002_Verification.md)
- Asset provenance and notices: [Licenses and assets](LICENSES_AND_ASSETS.md)

I-001 was accepted on 2026-10-17 after the user reported all nine required physical Android checks passing. I-002 has separate acceptance: its new APK still requires a physical phone walkthrough; agent-run phone testing is **UNVERIFIED**. I-003 is not authorized or implemented.
