# Decision and change log

## Pre-I-001

- Locked: New repository, portrait Android, offline-first single-player, Godot 4.7.2 stable, typed GDScript, Compatibility renderer.
- Locked: Game-design requirements and F/S/I identifiers in master blueprint.
- LOCKED: Final game title **Hollowfold** (D-031); formerly a placeholder. The user's explicit repository name is **HollowFold** at `drinkwaterdrink/HollowFold`.
- DELEGATED: During I-001, derive and record a lowercase Android application ID from the actual repository owner, using `io.github.<owner>.hollowfold` where valid; confirm uniqueness before any public store release.

For later changes, record old/new decision, rationale, and affected D/F/S/I identifiers before editing implementation.

## Repository initialization — 2026-10-17

- User request overrides the starter's private-repository setup assumption and repository casing in D-031: use the existing public `drinkwaterdrink/HollowFold` repository and `main`. GitHub API confirmed `private=false`, default branch `main`, size 0 before initialization. No visibility change was made. The master blueprint is preserved in full, unchanged from the ZIP; the game title remains Hollowfold.

## I-001 — 2026-10-17

- D-025 retained: executable reports `4.7.2.stable.official.ed1daf0bf`; Compatibility renderer. No engine migration.
- Delegated Android ID: `io.github.drinkwaterdrink.hollowfold`, derived from verified repository owner. Stable across updates; store uniqueness must be checked before any public store release.
- Android foundation: standard signed debug APK, ARM64 only, exporter-provided minimum API 24 and target API 36 (verified from the pinned template and exported manifest). Build tools 36.0.0/API 36 match the actual template. Stable web documentation listed API 35 tools; the inspected pinned binary is authoritative for this build. No NDK/CMake/Gradle installation is needed for the standard prebuilt-template export; revisit for native plugins/custom Gradle builds.
- Export validation required `rendering/textures/vram_compression/import_etc2_astc=true`; enabled without changing Compatibility rendering.
- S-001/I-001 only: New Run and Settings are honest placeholder panels with Back. No settings persistence or future gameplay scaffolding. Built-in font, original SVG mark, 360×640 base canvas with expanding aspect and scroll fallback; final art pipeline and physical target sizes remain subject to phone validation.
- Toolchain is portable under ignored `.local/`, with `_sc_` isolating Godot settings/templates from the user's global editor. Debug keystore remains local. No release signing credential, SDK or APK is committed.
