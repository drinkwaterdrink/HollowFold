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

## I-002 acceptance and future presentation — 2026-10-17

- User reported all ten required real-device checks PASS on version 0.2.0 and approved I-002; I-003 only is now authorized. Agent-run physical checks are not implied.
- Visual direction reaffirmed: eventual quality should approach **Caves (Android)**: polished pixel art, smooth animations, readable environments, attractive effects and cohesive design. This reinforces blueprint §§1.1, 12 and I-022, and guides I-005/I-022 art/UI packets. It does not authorize a graphics overhaul during I-003, nor copying reference-game assets.

## I-003 — 2026-10-17

- F-004/S-004/S-005: six focused RefCounted simulation modules; session owns private copied terrain, logical player, action index, integer time, scheduler, RNG streams, visible/discovered masks. Scenes receive detached masked grid snapshots and structured results. Legacy Grid movement helpers remain only for I-002 fixture compatibility; live gameplay never commits through them.
- Move/Wait cost 100 logical units, action index counts successful time-consuming player actions. Inspect/rejections/navigation cost 0. Scheduler derives readiness period as `ceil(cost * 100 / speed)`, sorted by due time then actor ID; previews max 64 readiness entries before committing. Runtime registers only player; unequal cost/speed actors are fixtures, not AI. No frame-time-based simulation.
- Command IDs are positive and strictly increasing per session; repeated/stale IDs are rejected. Result signals publish after commit; reentrant attempts return BUSY without recursive signal dispatch. Presentation admits one command per input frame and suppresses secondary-touch/emulated-pointer paths. Input-gate state is not simulation time and resets on focus loss/hide/regeneration.
- Canonical replay hash includes content version `i003-v1`, seed, unchanged terrain fingerprint, player cell, action index/time, scheduler, named RNG seed/state pairs and current/discovered visibility. UI transport IDs, event sequence and presentation frames are excluded from world state. Same ordered command list reproduces both canonical world hash and structured event order.
- Worldgen stays unchanged/isolated. Combat/loot/events/NPC streams use deterministic named seeds; no I-003 command needs an artificial random draw. Visual/global randomness cannot affect these streams. This is not save/load serialization or cross-engine-version replay certification.
- Basic integer supercover LOS radius 8, opaque rock/transparent water; corner rays are blocked. Visible target walls can be inspected, remembered-but-unseen/undiscovered/outside tiles return NOT_VISIBLE with empty payload. Fog recollection is sufficient for static I-003 terrain; later terrain-mutation packets must specify last-seen update rules.
- Minimal UI additions: centre Wait, map tap Inspect and #action/tick display; existing atlas gains unknown/dim variants solely for fog. Existing generator, camera, safe-area theme, menu and controls retained. No combat/AI/inventory/targeting/save or art overhaul.
- Version 0.3.0/code 3 and new ignored I003 APK preserve prior builds; same app ID/key/toolchain. I-003 physical checks await the user. I-004 is not authorized.
