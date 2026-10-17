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

The project contains the title/menu and seeded region explorer with I-004's deterministic tactical combat. Android application ID: `io.github.drinkwaterdrink.hollowfold`.

Choose **New Run → Explore region**. Use the eight-way pad, arrows/WASD or Q/E/Z/C for diagonals. Rock/water and occupied cells block movement; blocked corners cannot be squeezed through. Centre **Wait** (Space/period) restores up to 4 stamina and briefly guards. Legal Move/Wait cost 100 logical time. Inspect and rejected actions cost nothing; idle frames/navigation never run enemy turns.

Explore to find the red **Hollow mite**. Tap its visible tile to inspect/select it (yellow ring), then press **Attack** or F: range 1, cost100 time/3 stamina, hit/miss plus armor/resistance resolution. HP/stamina, selected enemy HP/behavior and a short combat log are visible. Enemies pursue only when their own senses detect you and retreat when injured. Wait when low on stamina. Hidden enemies cannot be targeted or inspected; no bump auto-attack.

**Regenerate** resets the same seed, actors, HP/stamina, counters, RNG, fog and temporary defeat. **Next seed** selects the next seed. **Back** returns to the launch panel, then title. In-memory exploration persists through menus, but no save/Chronicle/inventory/loot system exists. Death disables actions until regeneration; it does not write a permanent run record. Overlapping input is conservatively suppressed.

## Open, verify and build

Open `project.godot` in **Godot 4.7.2 stable** (Compatibility). From the repository root in PowerShell:

```powershell
./tools/verify.ps1
./tools/export_android.ps1
```

The portable engine, JDK, SDK and export templates are already prepared locally under ignored `.local/`. The I-004 signed debug APK is at `builds/android/Hollowfold-I004-debug.apk`; generated binaries and signing material are not in Git. Previous APKs are preserved separately.

- Setup, exact commands and phone checklist: [Android build guide](docs/BUILD_ANDROID.md)
- Actual checks, results and acceptance limits: [I-001 verification](docs/I-001_Verification.md)
- Region generation, acceptance and manual Android checklist: [I-002 verification](docs/I-002_Verification.md)
- Commands, state/hash, actual evidence and exact Android checklist: [I-003 verification](docs/I-003_Verification.md)
- Combat architecture, every changed file, actual evidence and Android checklist: [I-004 verification](docs/I-004_Verification.md)
- Asset provenance and notices: [Licenses and assets](LICENSES_AND_ASSETS.md)

I-001 through I-003 were accepted following user-reported physical Android passes. I-004 physical-device acceptance is **UNVERIFIED** until the user tests 0.4.0. Stop before I-005. Future I-005/I-022 art/UI work follows the recorded Caves (Android) quality direction; this packet keeps prototype graphics.
