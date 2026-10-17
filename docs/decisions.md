# Decision and change log

## Pre-I-001

- Locked: New repository, portrait Android, offline-first single-player, Godot 4.7.2 stable, typed GDScript, Compatibility renderer.
- Locked: Game-design requirements and F/S/I identifiers in master blueprint.
- LOCKED: Final game title **Hollowfold** (D-031); formerly a placeholder. The user's explicit repository name is **HollowFold** at `drinkwaterdrink/HollowFold`.
- DELEGATED: During I-001, derive and record a lowercase Android application ID from the actual repository owner, using `io.github.<owner>.hollowfold` where valid; confirm uniqueness before any public store release.

For later changes, record old/new decision, rationale, and affected D/F/S/I identifiers before editing implementation.

## Repository initialization — 2026-10-17

- User request overrides the starter's private-repository setup assumption and repository casing in D-031: use the existing public `drinkwaterdrink/HollowFold` repository and `main`. GitHub API confirmed `private=false`, default branch `main`, size 0 before initialization. No visibility change was made. The master blueprint is preserved in full, unchanged from the ZIP; the game title remains Hollowfold.
