# I-001 implementation plan

**Goal:** Bootstrap the approved Godot 4.7.2 Compatibility project and Android export foundation, stopping before I-002.
**Spec:** Complete master blueprint, section 17 AC-I001; `docs/agents/I-001_Godot_Agent_Kickoff.md`.
**Execution:** Inline in the existing initially empty checkout on main, as requested. Separate baseline and implementation commits. No additional approval gate: user explicitly authorized all I-001 work.

## Constraints and design

- Godot 4.7.2 stable, typed GDScript, Compatibility; portrait, offline, no gameplay permissions.
- Project/game title Hollowfold; repository HollowFold; Android ID `io.github.drinkwaterdrink.hollowfold`.
- One boot scene contains three mutually exclusive menu panels: title, New Run placeholder, Settings placeholder. New Run creates no world/state. Settings truthfully explains the bootstrap scope, with working Back; no fake preferences.
- Runic Field Journal direction: charcoal/slate, parchment text, teal actions, amber detail, plain text surfaces. Use Godot's built-in font and an original SVG mark; no new asset dependency.
- A focused safe-area container converts screen-pixel insets to viewport coordinates, refreshes on resize/resume, and provides a separate pure calculation for synthetic tests. Scrollable content and visible Back paths support small windows, touch, keyboard and Android Back.

## Files and tasks

1. `project.godot`, `.godot-version`, `export_presets.cfg`, `assets/icon.svg`, `assets/ui/hollowfold_theme.tres`: pinned settings, portrait canvas, theme and APK preset with no tracked signing paths/secrets. Retain exporter's minimum SDK default until inspected.
2. `tests/headless/bootstrap_smoke.gd`: first write and run against absent boot scene to establish RED; then exercise actual button signals, Escape/Android Back, repeated navigation, focus, layout and synthetic cutout geometry. Exit nonzero on failures.
3. `scenes/boot.tscn`, `scripts/ui/boot.gd`, `scripts/ui/safe_area.gd`: minimal presentation and navigation only. Validate GREEN with editor import, headless main scene launch and behavior suite.
4. `.github/workflows/godot-smoke.yml`: pinned official engine download, import, scene boot and smoke suite. CI run evidence must be distinguished from local checks.
5. `tools/verify.ps1`, `tools/export_android.ps1`, `docs/BUILD_ANDROID.md`, `docs/I-001_Verification.md`, `LICENSES_AND_ASSETS.md`, `CHANGELOG.md`, README and decision/progress ledgers: reproducible checks/build, actual results and manual device checklist.
6. Review all changes against packet boundaries, secret/artifact exclusions and AC-I001; commit and push implementation separately.

## Verification and review focus

- Run real Godot import, main scene boot and smoke tests; no error-output-only success when Godot exits zero.
- Check title/New Run/Settings/Back, repeated taps, Escape, Android Back notification and focus restoration.
- Test 360×640 and taller layouts and synthetic top/side/bottom insets, translated screen origin, empty safe area. Synthetic tests do not prove a phone's reported insets.
- Render/capture the real Godot viewport for visual inspection if supported; distinguish this from native input/device observation.
- Inspect pinned engine exporter defaults; attempt signed debug APK export with official tools. Install/launch only if ADB lists an authorized device; physical acceptance otherwise UNVERIFIED.
- Check git diff, tracked secrets/artifacts, preserved full blueprint, and remote commit equality after push.

## Execution ledger

- Baseline: nine starter files verified, full blueprint read, setup corrections recorded; commit `da274ae` pushed to origin/main.
- Environment: matching 4.7.2 engine ZIP found; SDK configured in old editor settings does not exist, no export templates or Java/ADB on PATH. Official portable build tools will be isolated and ignored under `.local/`.
- Tool-path finding: sandbox and elevated processes expose different TEMP directories; use the shared workspace `.local/` for reproducible paths across calls.
- Implementation: configured one scene, two focused UI scripts, shared theme/icon and Android preset. No simulation/world/save scaffolding.
- Verification: intentional missing-scene RED; final `verify.ps1` GREEN (import, 60-frame boot, 28 checks). Rendered pointer suite GREEN after correcting test input coordinates. All three captures visually inspected.
- Export: initial missing compression import requirement fixed; actual template target API 36 verified and matching tools installed. Final helper exported and signature-verified APK successfully. ADB reported no devices; physical acceptance remains UNVERIFIED.
- Ruling: retain min API 24/target API 36 from inspected pinned template instead of forcing the stable web guide's API 35 package list; the pinned engine/export contract is the relevant authority. Cost if wrong: device compatibility must be validated before I-002/release.
- Final review: independent read-only code review found no material correctness or scope issues. Minor deferred: the small-window automated checks cover title buttons; an extra deliberately short child-panel scrolling/Back reachability test would strengthen coverage. Actual phone scrolling/Back remains in the required manual checklist and UNVERIFIED.
