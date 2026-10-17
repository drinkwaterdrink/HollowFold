# Hollowfold — Roadmap Quick Reference

**Blueprint:** `Hollowfold_Master_Blueprint_v1.md` (authoritative)  
**Title:** **Hollowfold** (LOCKED)  
**Target:** Offline, portrait, single-player Android roguelike  
**Stack:** Godot 4.7.2 stable, typed GDScript, Compatibility renderer  
**Implementation method:** One small testable AI-coding-agent packet per step.

## Full game vision, preserved

24 playable species; multiple lineages with branching/hidden evolutions; all 36 handcrafted backgrounds plus point-buy custom starting builds; any species/background combination; tactical grid and hybrid skill/talent/specialization progression; rich spells/element interactions; rolling loot and crafting; mining; gods, reputation, NPCs, procedural quests; layered world history, realms, procedural settlements, dungeons; companions; traditional permadeath with reliable resume; polished portrait UI and pixel art.

## The 24-packet roadmap

| Phase | Packets | What becomes playable |
|---|---|---|
| A — First playable APK | I-001–I-007 | Godot boots on Android; one seeded region; movement, combat, inventory, save, death, boss and short victory. **First key checkpoint.** |
| B — Systemic alpha | I-008–I-015 | More regions, dungeons, map, creator, representative species/backgrounds, skill training, spell/talent synergy, loot, mining/crafting, survival. |
| C — Living world | I-016–I-019 | Villages, NPC routines, shops, factions, gods, branching quests, multiple victory approaches, companions, monster variants. |
| D — Full content and polish | I-020–I-024 | Expand toward 24 species/36 backgrounds, lineages/hidden forms; hardened saves/chronicle; visuals/controls/accessibility; seed/performance audit; signed release. |

## Immediate action

1. Create a **new, empty Git repository** for the game. Do **not** reuse Project Conflux.
2. Put the full blueprint in `docs/plans/Hollowfold_Master_Blueprint_v1.md`.
3. Send the standalone file `I-001_Godot_Agent_Kickoff.md` to the coding agent, along with the blueprint.
4. Tell it to implement **only I-001**, report actual tests, and stop. Review the evidence before sending I-002.
5. For every later packet: inspect existing code → plan only current packet → build → run checks → test on Android where applicable → document acceptance results → commit.

## Rules for avoiding scope explosion

- The full roster is a long-term design commitment, **not** the target for first APK.
- New mechanics must be data-driven wherever reasonable, deterministic, and covered by a failure/replay test.
- Gameplay state belongs to the simulation, not animations or touch widgets.
- No mobile Android success claim without exported APK and device evidence; missing access means **UNVERIFIED**.
- No remote API, monetization, accounts, online AI dialogue, full building sandbox or multiplayer.
- Preserve ironman permadeath without sacrificing Android save/resume reliability.
- Keep stable F/S/I/AC IDs from the blueprint; changes go into its decision ledger first.

## First real checkpoint (I-001–I-007)

The first genuine milestone is **not** a mockup. It is an Android APK in which you can choose a basic character, enter a real seed, walk around a region, fight monsters, pick up/equip an item, enter a short dungeon, win or permanently die, close the app and later resume only if alive. A small working game is the foundation for all later complexity.
