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

## I-002 — 2026-10-17

- Authorization: user approved I-001 after nine **user-reported** physical passes and explicitly authorized I-002 only. Required I-001 AC complete; optional missing screenshots/metadata or extra tests do not block that approval.
- F-006/S-004/I-002: one 31×39 local region, generation revision 1. Isolated seeded Godot RNG, iterative maze carving, eight small clearings and blocked water pools; original traversable network stays connected. No continent/topology/history/fog/streaming work.
- Logical terrain, spawn/player cell, passability and temporary movement live in RefCounted data, independent of rendering. Movement accepts one adjacent eight-way delta; bounds, rock and water block movement; diagonal steps require both orthogonal neighbors passable. This is a temporary I-002 adapter, not the I-003 turn/command/scheduler engine.
- Same-seed/debug controls: initial seed 1337, Regenerate resets the same seed/spawn, Next seed increments it. Fingerprint includes revision, dimensions, seed, spawn/entrance and row-major terrain bytes; it excludes current mutable player position. Fixture stability is promised for the pinned engine/generation revision, not arbitrary future generator/engine changes.
- Presentation: existing safe-area/theme retained, clipped SubViewport with one TileMapLayer, original 24×24 prototype atlas, simple actor glyph and clamped Camera2D. The viewport only updates when visible. Tile size is provisional, not a locked art-pipeline choice. Entrance is a starting landmark; no level transition yet.
- Existing New Run placeholder remains a launch panel with Explore region; Back returns to that panel and then title. Leaving/re-entering region keeps temporary in-memory exploration; process restart returns to title with no saved exploration. No persistence is implied.
- Version 0.2.0 / Android code 2 and ignored `Hollowfold-I002-debug.apk` preserve the previous I-001 APK and use the existing debug key/app ID. I-001 phone results do not establish I-002 phone acceptance. I-003 requires separate authorization.
