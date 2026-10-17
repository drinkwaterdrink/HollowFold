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

Read `AGENTS.md`. Implement one authorized I-packet at a time; do not begin the next packet without the user's approval.

The project contains the title/menu and seeded region explorer with I-003's deterministic Move/Wait/Inspect engine, logical time and basic line-of-sight/fog. Android application ID: `io.github.drinkwaterdrink.hollowfold`.

Choose **New Run → Explore region**. Use the eight-way pad, arrows/WASD or Q/E/Z/C for diagonals. Rock and water block movement; rock also blocks sight. Centre **Wait** (Space/period) advances one action. Tap a map tile to **Inspect**, or press I to inspect the player's tile. Inspect is free and cannot reveal hidden terrain. Every accepted Move/Wait advances the action counter by 1 and time by 100; rejected input, idle frames and navigation advance neither. Unknown tiles are concealed; remembered tiles outside current sight are dim.

**Regenerate** resets the same seed, spawn, turns/time, RNG and fog; **Next seed** selects the next seed. **Back** returns to the launch panel, then title. Exploration remains temporary, with no saves, enemies, combat or inventory. Normal separate taps are discrete actions; overlapping touches/input within one frame are conservatively ignored to prevent duplicate commands.

## Open, verify and build

Open `project.godot` in **Godot 4.7.2 stable** (Compatibility). From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1
```

The portable engine, JDK, SDK and export templates are already prepared locally under ignored `.local/`. The I-003 signed debug APK is at `builds/android/Hollowfold-I003-debug.apk`; generated binaries and signing material are not in Git. Previous APKs are preserved separately.

- Setup, exact commands and phone checklist: [Android build guide](docs/BUILD_ANDROID.md)
- Actual checks, results and acceptance limits: [I-001 verification](docs/I-001_Verification.md)
- Region generation, acceptance and manual Android checklist: [I-002 verification](docs/I-002_Verification.md)
- Commands, state/hash, actual evidence and exact Android checklist: [I-003 verification](docs/I-003_Verification.md)
- Asset provenance and notices: [Licenses and assets](LICENSES_AND_ASSETS.md)

I-001 and I-002 were accepted after the user reported their required physical Android checks passing. I-003 requires separate physical testing of its new APK; agent-run phone testing is **UNVERIFIED**. I-004 is not authorized or implemented. Future I-005/I-022 art/UI work should pursue the recorded Caves (Android) quality direction; I-003 retains prototype graphics.
