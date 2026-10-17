# HOLLOWFOLD — MASTER GAME BLUEPRINT

**Title:** **Hollowfold** (LOCKED — user)  
**Version:** 1.0 — 2026-10-17  
**Status:** Design-complete first implementation baseline; content numbers and balancing remain tuning targets.  
**Product:** Offline-first, single-player, portrait-first, turn-based pixel-art roguelike for Android.  
**Development:** New repository, entirely AI-agent-assisted / “vibe coded,” with human review and real-device verification.  
**Recommended foundation:** Godot **4.7.2 stable**, typed GDScript, Compatibility renderer, Git, headless smoke/unit tests, Android APK smoke tests.  
**Authority:** User's explicit decisions > this blueprint's locked decisions > delegated design defaults > coding agent guesses. Record any change before implementation.

> **One-sentence promise.** Every death ends a unique fantasy world, but every new life offers an extraordinary combination of species, lineage, background, talents, magic, discoveries, and possibilities within an intricate, living, procedurally generated realm.

## 0. How to use this document

- This file is the authoritative **design and implementation contract**, not a single giant build prompt.
- Stable IDs: decisions `D-xxx`, features `F-xxx`, screens `S-xxx`, implementation packets `I-xxx`, acceptance checks `AC-xxx`, tests `T-xxx`.
- Build **one I-packet at a time**. Each packet must leave the game launchable and previously passing behavior intact.
- Mark proposed balancing values as *tuning*, not immovable specifications; do not silently change feature contracts.
- The **first playable slice** deliberately has fewer species, backgrounds, creatures, and regions than the complete vision.
- No game source code, prototype, or existing repository was supplied for this new game. This is a plan, **not a claim of implemented or tested software**.

---

# 1. Product definition and creative direction

## 1.1 The core fantasy

The player creates a character from many biologically distinct species, chooses an evolving lineage, selects a starting background or assembles a custom one, spends trait points, and enters a freshly seeded world. Its geography, conflicts, settlements, hidden histories, caves, ancient structures, factions, boss lairs, and connections to other realms are generated coherently. The player explores in a tile-based top-down view, fights on a deterministic tactical grid, learns skills, selects talents, crafts equipment, recruits allies, pursues legends, and can ultimately win through a central quest with more than one route. One death ends both character and the live world. Completed runs remain in a read-only chronicle.

**Inspirations are design references, not asset or code sources:** Dungeon Crawl Stone Soup (tactical/build depth); Caves of Qud (mutations, factions, procedural history, systemic interactions); Caves on Android (readable pixel art and touch responsiveness); Terraria (biome identity, exploration rewards, materials, rare bosses, valuable drops). This is **not a side-scroller**, a direct clone, a multiplayer game, or a mandatory building sandbox.

## 1.2 North-star player experience

1. Choose a Myconid with a Rotborn lineage, take the Spellblade background, accept Light Sensitivity in exchange for Symbiotic Blood, and see every consequence clearly before starting.
2. Enter a new world's marsh border at a settlement whose faction has a historical feud with a nearby dwarven mining guild.
3. Explore a cave, discover a collapsed tunnel, mine a bypass, create flammable spore clouds, and defeat a fire-wielding creature by manipulating water and sightlines instead of trading blows.
4. Claim a cursed relic, unlock an unusual fungal-necromancy talent, and decide whether to pursue a branching lineage or a hazardous secret metamorphosis.
5. On death, see a clear cause, a run chronicle, and an immediate route to create a new character and world.

## 1.3 Goals, boundaries, quality bars

**Must excel:** tactical decisions; meaningful character differences; world discovery; polished touch-first play; reliable save/resume; replayability; content extensibility through coherent data and tests.

**Non-goals at launch:** online multiplayer, accounts, cloud services, gacha, ads, procedural AI-generated text via paid APIs, real-time combat, full Terraria-style unrestricted construction, autonomous empire simulation, universal limb/organ injury simulation, paid asset dependencies, mandatory Internet. Native desktop editing/test execution is a developer tool, not a separate consumer platform commitment.

**Success is observable:** a working Android APK; a full coherent short victory path; at least one non-combat solution; meaningfully different starting builds; no broken objective seeds in validation; a save that restores the same state after process termination; actionable UI feedback; deterministic reruns for bugs; independent feature-packet verification.

## 1.4 The game's signature design pillars

1. **Buildcraft without class prisons:** background = starting training, not permanent ability ownership.
2. **A world with causes:** biomes, civilization histories, resources, factions, quests, and sites reinforce one another.
3. **Systems that collide:** fire ignites gas; digging exposes rooms; enchantments interact with species physiology; NPCs respond to acts.
4. **Tactical consequence, visual speed:** turns are deliberate; presentations are quick and skip-friendly.
5. **Meaningful death, reliable continuation:** genuine permadeath; closing an app never counts as dying.
6. **One-hand-legible Android UX:** portrait, readable map, low tap count, no hidden gesture-only critical actions.

---

# 2. Decision ledger and scope protection

| ID | Status | Decision / consequence |
|---|---|---|
| D-001 | LOCKED — user | Android, portrait, single-player; plan for mobile touch first. |
| D-002 | LOCKED — user | Brand-new project; do not reuse Project Conflux code or conventions. |
| D-003 | LOCKED — user | 100% vibe-coded; packetized implementation, tests, explicit agent acceptance checks. |
| D-004 | LOCKED — user | Hybrid art: AI-assisted original sprites, licensed asset packs, code-driven effects. |
| D-005 | LOCKED — user | Multirealm predominantly dark/high fantasy; Qud-like oddities are accents, not wholesale sci-fi. |
| D-006 | LOCKED — user | Traditional character AND active-world permadeath, new world every run. |
| D-007 | LOCKED — user | Connected local regions plus strategic world map. |
| D-008 | LOCKED — user | Layered seeded geography, civilizations, and history; living but not full empire simulation. |
| D-009 | LOCKED — user | Deep settlements, NPC routines, dynamic factions, reputation, branching/procedural quests. |
| D-010 | LOCKED — user | Diverse dungeons; mining, gathering, crafting, limited destructible terrain. |
| D-011 | LOCKED — user | 24 base playable species; meaningful anatomies; lineages, evolution branches, discoverable rare forms. |
| D-012 | LOCKED — user | 36 handcrafted starting backgrounds plus custom point-buy backgrounds; all 24 × 36 combinations available. |
| D-013 | LOCKED — user | Starting positive traits bought with points; optional disadvantages with capped refunds and compatibility. |
| D-014 | LOCKED — user | Species are asymmetrical yet broadly viable; compatible equipment substitutions, warnings. |
| D-015 | LOCKED — user | Major transformations persist by default; rare costly reversal; no silent equipment destruction. |
| D-016 | LOCKED — user | DCSS-like prioritized XP skill training; flexible talent points, hybrid prerequisites, discoveries. |
| D-017 | LOCKED — user | One primary and one secondary advanced specialization; limited talent respec. |
| D-018 | LOCKED — user | Extensive schools/spell mods/environmental interactions, not unrestricted spell programming. |
| D-019 | LOCKED — user | Tactical turn-based combat with systemic AI, anatomy, environment and polished touch controls. |
| D-020 | LOCKED — user | Handcrafted/rolled loot, unique artifacts, forging/enchanting and crafting. |
| D-021 | LOCKED — user | Dynamic gods, factions, limited companions, tamed pets and summons. |
| D-022 | LOCKED — user | Authored main quest plus structured procedural quests, optional bosses, alternate victory routes. |
| D-023 | LOCKED — user | Streamlined survival, different biological needs by species. |
| D-024 | LOCKED — user | Flexible run lengths: practical win route, extensive optional exploration. |
| D-025 | DELEGATED DESIGN DEFAULT | Godot 4.7.2 stable + typed GDScript + Compatibility renderer; change only for demonstrated technical need. |
| D-026 | DELEGATED DESIGN DEFAULT | No server/AI APIs; local records/preferences and run data; offline at all times. |
| D-027 | DELEGATED DESIGN DEFAULT | Eight-direction square grid; no diagonal corner cutting; one player input commits one command; all enemies use same turn scheduler. |
| D-028 | DELEGATED DESIGN DEFAULT | Skill training configurable whenever out of a resolving action; talents respec through authored opportunities. |
| D-029 | DELEGATED DESIGN DEFAULT | World-wide exploration is optional for victory; a main quest's reachable objectives are guaranteed before run begins. |
| D-030 | DEFERRED — nonblocking | Music identity; exact XP/talent formulas; final boss identity; any later non-Android platform. |
| D-031 | LOCKED — user | Final game and repository title: **Hollowfold**. Use in menu, project metadata, and player-facing text. |

**Interpretation of scope:** `24 species × 36 backgrounds = 864 combinations` is **design capacity**, not 864 bespoke scenes or hand-balanced preset kits. A procedural seed does not imply uncontrolled randomness: generated critical routes and needed services must validate. Different species need viable wins, not numerical parity or identical equipment.

---

# 3. Scope by stage and release strategy

| Stage | Product outcome | Representative content | Explicitly excluded until later |
|---|---|---|---|
| **P0 — first mobile playable** | Create → seed world → explore → fight → loot → survive → die/restart; actual APK. | 1–2 starter biomes, 1 village, 1 cave/short dungeon, 2 species/2 backgrounds initially, a handful of enemies, one simple boss, basic inventory. | Full factions, history, 24 species, 36 backgrounds, deep mutations, complete world simulation. |
| **P1 — vertical-slice roguelike** | Short complete run with reachable win condition, save/resume, two routes, polished core UX. | 4 species, 6 backgrounds, 3 lineages each where appropriate, 8–12 enemies, 2 dungeon archetypes, 2 spells schools with interactions, minimal quests, 1 boss. | Huge content catalogs, elaborate economies, distant-region simulation. |
| **P2 — systemic alpha** | Cohesive multi-region game and initial buildcraft depth. | ~8 species, ~12 backgrounds, 4–6 biomes, 3–4 dungeons, multiple factions, 2 gods, limited companions, meaningful crafting, first specializations. | 24/36 full roster, elaborate branching stories across all realms. |
| **P3 — content beta** | Full feature contracts are in place; content scales via definitions and tests. | Expand toward 24 species/36 backgrounds, all planned realms, secret evolutions, extensive skills/talents, authored story bank, bosses, art consistency. | New foundational systems without explicit review. |
| **P4 — finished personal game** | Balanced, performant, accessible, stable, replayable on real Android devices. | Polish, unique assets, tested seed corpus, compendium, refined pacing, optional post-win exploration. | Monetization, accounts, multiplayer. |

Content counts above are **targets/illustrative scope caps**, not evidence that these assets, stories, or balance work already exist. Never place the game-wide content explosion ahead of a real mobile release and tested save model.

---

# 4. Detailed feature architecture

Each feature is defined here; corresponding observable tests are specified in §19. Acceptance IDs are stable; packet IDs cross-reference §20.

| Feature | Description / invariant | Stage | Dependencies | First implementation |
|---|---|---|---|---|
| F-001 | New run, character creation and world seed; no account; defaults are viable. | Core | Definitions | I-006, I-009 |
| F-002 | Species/anatomy/lineage/traits; adapted equipment, meaningful weaknesses. | Core → P3 | F-001, F-008 | I-010, I-020 |
| F-003 | 36 starting backgrounds + equitable custom creator; no background locks. | Important | F-002, F-008 | I-010, I-020 |
| F-004 | Commands, tactical grid, 8-way movement, LOS, energy/action scheduler, action outcome events. | Core | None | I-003 |
| F-005 | Combat, defense, resistances, statuses, enemy behaviors, terrain reactions. | Core | F-004 | I-004, I-011 |
| F-006 | Seeded macro-world, local regions, seamless logical adjacency, fog discovery, world map. | Core | F-004 | I-002, I-008 |
| F-007 | Dungeons and realm links; generated exits, secrets, variation and guaranteed reachable objectives. | Important | F-006 | I-008, I-015 |
| F-008 | XP training priorities, skills, talent points, skill-gated talents, two advanced specs. | Core → Important | F-001, F-005 | I-010, I-012 |
| F-009 | Spell schools and composable, validated effect pipelines; spell modifications and hybrid effects. | Important | F-005, F-008 | I-012 |
| F-010 | Item generation, inventory, equipment, rolled modifiers, unique artifacts, incompatibility rules. | Core → Important | F-002, F-005 | I-005, I-013 |
| F-011 | Mining, gathering, crafting, runes/enchanting, limited terrain edits, hidden rooms. | Important | F-006, F-010 | I-014 |
| F-012 | Settlements, NPC roles and schedules, interactions, merchants/services, simple economy. | Important | F-006 | I-016 |
| F-013 | Faction/faith reputation, gods, divine requirements, political relations and reactive events. | Important | F-012 | I-017 |
| F-014 | Authored quest graph + validated procedural quest instances, consequences, main victory paths. | Core → Important | F-007, F-012 | I-018 |
| F-015 | Species-specific hunger/sustenance, fatigue, exposure, rest and camp. | Important | F-002, F-004 | I-015 |
| F-016 | Handcrafted creatures, procedural legal variants, ecology tags, smarter AI, unique bosses. | Core → Important | F-005, F-007 | I-011, I-019 |
| F-017 | Tamed allies, recruitable NPCs, limited persistent followers, temporary summons, auto-tactics. | Important | F-005, F-012 | I-019 |
| F-018 | Evolution branches, rare discovered transformations, mutations, reversals and fit fallback. | Important | F-002, F-008 | I-020 |
| F-019 | Safe resume, autosave, snapshot/diff persistence, death tombstone, run chronicle. | Core | F-001, F-006 | I-006, I-021 |
| F-020 | Portrait touch controls, tooltips, readable combat HUD, smart auto-explore, adjustable accessibility. | Core | F-004 | I-005, I-022 |
| F-021 | Codex, discoverability, run history, seed/debug diagnostics, content inspection. | Important | All | I-021, I-023 |
| F-022 | Hybrid sprite production, smooth animation, clarity-first VFX, ambient sound/haptics. | Core → Polish | F-020 | I-005, I-022, I-024 |
| F-023 | Deterministic content validators, reproducible seeds, performance profiling, save migrations. | Core | All | I-001 onward; I-023 |
| F-024 | Optional post-victory exploration and deliberate retirement, with completed-run status preserved. | Important | F-014, F-019 | I-018, I-021 |

### 4.1 Core loop and command rules

`Choose character → World created → Explore (move/inspect/interact) → Risk assessment → Tactical action → World/NPC turns → Combat/event result → Loot/train/craft/recover → Explore / main objective → Victory + optional continue / Death → Chronical record → Fresh world`.

**Command contract:** All state-changing world actions are typed commands (`Move`, `Attack`, `Cast`, `Use`, `Equip`, `Interact`, `Mine`, `Craft`, `Wait`, `Rest`, `Talk`, `CompanionOrder`, `Travel`, etc.) validated against current state. Invalid actions (blocked, insufficient resources, unavailable target) return a structured reason and **consume no turn unless explicitly designed as an attempted action** (e.g., failed theft). `Inspect`, inventory browsing, UI navigation, and tooltips do not consume turns. Resolve the player action atomically, schedule affected actors, update time/event queues, then emit domain events to UI. Animations never mutate game rules.

**Movement:** eight directions, one cell per basic move command, equal baseline time cost as a balance decision, diagonal movement blocked if it squeezes between two impassable orthogonal neighbors. Features changing action cost use scheduler energy rather than arbitrary frame delays. Every movement commit checks newly visible threats; auto-path stops on threat emergence, hazards, unidentified obstructions, scripted events, low resources, and region boundaries requiring confirmation.

### 4.2 Combat equation and fairness contracts

- Typed `AttackIntent` resolves accuracy/evasion, range/LOS, armor, penetration, resistance, shields, status modifiers, and damage type through a deterministic sequence; UI receives readable event text and VFX instructions only after state commits.
- Rolls use run-scoped, named RNG streams. An identical seed + action sequence + content version must resolve identically; changing animations must not affect the outcome.
- Effects have explicit tags (`fire`, `cold`, `shock`, `water`, `gas`, `poison`, `holy`, `decay`, `physical`, `force`, `spatial`, etc.), source/target/area, duration, stacking semantics, immunity/resistance rules, and conflict priority.
- An effect triggers at most once per relevant action/event key unless explicitly designed to chain with a bounded chain budget. This prevents infinite reactions such as lightning-water-lightning loops.
- Critical threats have telegraphs: description/animation/tile marker and inspection clues; no unavoidable off-screen lethal damage on a newly created starter region.
- Automatic routines stop before potentially lethal known threats. No default auto-attack into unknown enemies, irreversible rituals or suspicious allies.

### 4.3 Six representative player journeys

**J-001 — New character:** Title → New Run → species → lineage → background or custom → attributes → traits/drawbacks → preview with warnings → confirm → seed generated with verified nearby safety and progression route → spawn. If impossible trait kit, block confirmation with exact incompatibility and proposed alternatives; entered selections remain preserved.

**J-002 — Exploration:** Game HUD → tap tile/step control → highlight path and dangers → action resolves → fog reveals → local landmark added to map. If obstructed or path becomes dangerous, stop and explain rather than blindly reroute through hazards.

**J-003 — Fight and loot:** Enemy appears → inspect attack range/resistances → position, attack/cast/use item → enemy turn resolves → combat message and feedback → death/loot. If inventory full or anatomy incompatible, allow inspect, leave item in world, and offer alternative slots; never destroy loot.

**J-004 — Town and quest:** Discover settlement → enter → NPC service/dialogue → quest offer with stakes → accept → journal objective/marker → resolve through selected path → reputation and world-state change. If required NPC is killed by world events, quest resolution changes to reachable failover or clean failure with explanation.

**J-005 — Resume/permadeath:** Gameplay autosaves when state is stable; Android goes to background or process is terminated → next launch resumes committed state. Player receives lethal damage → mark run dead durably before rendering death summary → old active run becomes invalid → Chronicle persists; new run always gets fresh world.

**J-006 — Victory:** Earn required clues/objectives via different paths → verify endgame requirement → confront or circumvent finale through designated legal routes → mark run won → offer retire + chronicle, or continued exploration (subject to existing permadeath); dying after victory records victory and post-victory death distinctly.

---

# 5. Creative world bible: *The Fractured Concord*

## 5.1 Lore premise

Long ago the Concord bound several realms by way of ancient gates. A fracture scattered the gates and imprinted unstable histories into the world. At each new run, the sequence of collapses, surviving kingdoms, forgotten gods, and gate alignments differs. A player's central task is to uncover enough **Concord Seals** to choose an ending for the fractured network: reseal the Concord, reroute it through a mortal coalition, or end an ancient entity's hold on it. The names are working fiction, not immutable lore.

The main quest is **handcrafted at the causal level** but instantiated in generated sites. No single required god/faction/species/spell is necessary to win. Alternative methods use combat, infiltration, scholarship and negotiation; each route has real required costs or risks. Bosses are major optional or route-specific gates, not a fixed mandatory ladder.

## 5.2 Realm families and world resources

| Realm | Identity | Spatial / elemental rules | Content role |
|---|---|---|---|
| Mortal Expanse | Temperate kingdoms, deserts, mountains, jungles, shores | Baseline terrain and civilizations | First realm and travel hub |
| Gloam Below | Abyssal caves, fungi, flooded ruins, ancient miners | Darkness, spores, vertical passes | Underground labyrinths and rare ore |
| Ashen Dominion | Volcanic wastes, burning fortresses, infernal religions | Heat, lava, smoke, unstable ground | High-risk crafting and infernal factions |
| Verdant Reverie | Living woods, giant roots, druidic enclaves | Growth, pollen, tangled movement, shifting fauna | Biological materials, nature magic |
| Shardglass Expanse | Crystalline desert, resonant cities, lost observatories | Reflective magic, fracture hazards | Artifacts and rune systems |
| Umbral Verge | Shadow cities, ghost roads, abandoned shrines | Reduced visibility, spirit overlap | Necromancy, secrets, alternate paths |
| Astral Rifts | Floating remnants and unpredictable portals | Teleport rules, gravity-like tile modifiers | Advanced spatial magic, endgame routes |

**World-generation pipeline (seeded, ordered):** `RunSeed → macro elevation/hydrology → climate/biome grid → settlements/resource graph → faction cultures/territory → bounded history event tags → site/dungeon placement → realm gate graph → route/objective validation → region seed assignments → lazy local generation → mutation deltas`. Generated history uses a finite event grammar (founding, battle, diaspora, plague, cataclysm, pact, rediscovery), not hundreds of years of frame-by-frame NPC simulation.

**Invariants:** all critical quest nodes reachable without a single unique optional ability; starting settlement and first objective reachable without suicidal early-biome traversal; disconnected islands have legal travel mechanisms; portal pairs correctly link; every dungeon has a usable exit; cave and surface coordinates respect bounds; unique artifacts and named bosses have stable IDs; every run supports at least two victory-capable route strategies in generator tests. If constraints fail, retry local placement or deterministically repair and log the repair. Never quietly strand a world.

**Maps:** Macro cells contain biome, altitude, polity, road/river, landmark slots, danger bands and travel edges. Each local map contains terrain layers, structures, generated actors/loot, mutable flags, light/fog data and entrances. Generate by deterministic coordinates + world seed, then persist delta operations (`opened chest`, `mined rock`, `door unlocked`, `NPC moved`, `boss dead`); do not force all thousands of cells to reside in memory.

## 5.3 Dungeon grammar

- Archetypes: cave pocket, crypt, shrine, fort, mine, labyrinth, ruins, lair, submerged vault, realm gate chamber, legendary megacomplex.
- Parameters: intended depth/risk tier, connected levels, ecology and faction population, key/lock rules, loops and shortcuts, environmental hazards, hidden chambers, rare handmade setpieces.
- Guarantee entrance-exit connectivity, optional reward branches, no sealed required items, boss arena access, and a retreat/escape possibility when narrative doesn't deliberately deny escape with warning.
- Mineable walls are **tagged**; structural/progression walls cannot be removed if it breaks critical encounter scripting or leaves an unreachable exit. Digging consumes tools/resources/turns and may produce noise/terrain collapse risk when telegraphed.
- Handcrafted landmark rooms are templates selected and decorated by the generator; they should fit the biome history and not repeat in every run.

## 5.4 Living-world resolution

Detailed simulation is limited to player vicinity and active region. Remote regions use compact scheduled events: caravan arrived, bandits intercepted, mine collapsed, faction influence shifted, settlement stock changed. Every abstract event has allowed preconditions and a small, reviewable state delta; a remote event **cannot** kill the only main-quest NPC or remove all viable route links without a resolution route being produced. NPCs have role, schedule, reputation, needs, affiliations and 1–2 optional secrets; no persistent free-form chatbot.

## 5.5 Loot and encounter placement

Loot uses authored tables by ecology/biome/threat tier, seeded weights, scarcity caps and uniqueness registry. Unique artifacts have authored signature effects and may receive bounded procedural secondary modifiers. Rare drops must be signposted by bestiary/rumor/visual cues; avoid pure grind for mandatory progression. World events and secrets use rarity but can be rerouted through rumors, journals or exploration clues; nobody should need a wiki to discover the main progression.

---
# 6. Character design bible: 24 species, lineages and evolutions

## 6.1 Species contract and point-buy rules

A species definition has stable `species_id`, skeleton/body plan, metabolism, equipment-slot capabilities, innate actions, passive/active traits, senses, movement tags, basic skill aptitudes, starting constraints, legal lineages, rival-faction perception flags, and mutation compatibility. A lineage has `lineage_id`, inherited benefits/costs, an authored early ability, two **exclusive normal evolution branches**, and optional hidden transformations discoverable through clues. Species with no lungs do not inhale poison gas; they may have another exploitable weakness. A lineage is chosen during creation, not randomly revealed later.

**Body and equipment:** General slot categories are grip(s), head, torso, legs/tail, feet/talons, hands/appendages, neck, accessories, core/embedded, and natural armor. Slot *capabilities* belong to a body plan, not a hardcoded switch per species. Each item has `fits_body_tags`, `requires_slot_tags`, `grip_cost`, mass and proficiency restrictions; compatible alternatives fulfill similar tactics without guaranteeing numerical equality. Added arms unlock options with stamina and off-hand tradeoffs, **not free extra attacks**. Form changes store incompatible gear in a safe temporary carry bundle or drop it intact if carrying capacity is exceeded (with explicit warning), never erase it.

**Creation (delegated defaults, tunable through actual playtesting):** 8 discretionary positive trait points; drawbacks may refund at most 4 more, and cannot be stacked to circumvent an inherent species weakness. Attributes have a separate bounded pool. Handcrafted backgrounds are built against a common startup equipment/skill/spell budget; custom background uses that same budget. A negative trait is denied or discounted when the species already makes it irrelevant (e.g., poison susceptibility on an immune body). Reject conflicts and show reasons before consuming points. Every legal species/background receives an executable starting action kit.

**Evolution:** Lineage rank increases when both character progress and milestone conditions are met. Players choose one of the lineage's two ordinary branches. Rare discoveries may unlock a replacement or additional mutually exclusive choice, but require informed confirmation; never automatically overwrite a branch. Reversal is rare, costly, restricted by explicit prerequisites, and does not roll back unrelated trained skills or world events.

The following is the **approved 24-species foundation** with **proposed exact content definitions**. Names and balance numbers can be revised without changing the locked count and underlying contracts. Slash-separated evolution labels indicate alternative branches **for that lineage**, not automatic simultaneous powers.

## 6.2 Traditional fantasy (8)

| Species | Biology, play pattern, weakness / alternatives | Lineage → two evolution branches per lineage | Hidden transformation hook |
|---|---|---|---|
| **Human** | Standard equipment; broad training aptitude and versatile talents; few innate resistances. | Wanderborn → Pathfinder / Relic Seeker; Ironblood → Indomitable / Warcaller; Arcane-Touched → Spellweaver / Aether Vessel. | **Anomaly Vessel** from an unstable ley nexus; flexible spell alteration but brittle health. |
| **Elf** | Far sight, mana perception and finesse; lower starting toughness, poor poison tolerance. | Moon → Lunar Magus / Moonblade; Wild → Thorn Ranger / Grove Mystic; Umbral → Shadow Dancer / Living Illusion. | **Star-Eyed Oracle**, gained from a lost observatory; reveals hidden routes but causes glare sensitivity. |
| **Dwarf** | Stout, stone sense, mining and forging bonus; slow in open terrain, weak aerial options; excellent heavy gear. | Deepborn → Stonewarden / Tunnel Stalker; Runeforged → Sigil Knight / Forge Oracle; Ashen → Cinder Smith / Magma Guardian. | **Living Mountain** through a stoneheart forge; powerful defense, slower travel and unusual healing. |
| **Orc** | Ferocity and momentum; rage windows amplify attacks but expose defenses. | Bloodfang → Gore Champion / Ravager; Ironhide → Bulwark / Iron Ravager; Warborn → War Tyrant / Banner Warlord. | **Red Eclipse** from blood pact; furious power at increasing exhaustion risk. |
| **Goblin** | Small nimble scavenger; engineering, traps, cheap gear; poor heavy lifting and weak direct defense. | Tinkerer → Trapmaster / Scrapper; Caveborn → Tunnel Phantom / Rockrunner; Hexblood → Jinx Weaver / Curse Broker. | **Scrap Monarch** by assembling a forbidden machine; modular armor with loud signature. |
| **Halfling** | Small body, precision, evasion and luck tools; low reach and limited oversized gear. | Hearthborn → Fortunate Keeper / Hearth Sentinel; Shadowfoot → Phantom Duelist / Veil Runner; Wanderkin → Wayfinder / Fate Trader. | **Fateweaver** after altering a fated event; reroll choices at finite personal cost. |
| **Troll** | Large claws and regenerative metabolism; high food demand, restricted armor, vulnerable to persistent fire. | Mountain → Boulder Fist / Mountain Colossus; Mire → Bog Regenerator / Mire Eater; Cave → Deep Stalker / Feral Devourer. | **World-Eater** from a titanic cave heart; extreme reach/size with major sustenance cost. |
| **Gnoll** | Keen smell, tracking and coordinated attacks; some scent hazards disorient them. | Moonfang → Pack Herald / Night Howler; Dune → Sand Stalker / Nomad Leader; Bonehunter → Marrow Sage / Trophy Hunter. | **Ancestral Packmind** through spirit rite; links nearby allies, compromised independence. |

## 6.3 Beastfolk and draconic (6)

| Species | Biology, weakness / equipment adaptation | Lineage → two branches each | Hidden transformation hook |
|---|---|---|---|
| **Draconian** | Scales, claws, elemental breath; torso/tail armor tailored for physique; breath costs stamina or affinity charge. | Ember → Furnace Wyrm / Flamewing; Frost → Glacial Bulwark / Iceshard Hunter; Storm → Tempest Wyrm / Thunder Tyrant; Venom → Plague Drake / Venom Sovereign. | **Voidstorm Ascendant** from a fractured gate, spatial instability and powerful storm discharges. |
| **Serpentfolk** | Tail locomotion, constriction, venom depending on subtype; tail barding instead of boots/greaves, vulnerable to some cold terrain. | Viper → Venom Oracle / Fang Assassin; Constrictor → Coil Guardian / Titan Boa; Abyssal → Deep Coil / Dread Serpent. | **World Serpent** through buried shrine; enormous constriction, impaired narrow-space access. |
| **Insectoid** | Chitin, special appendages, pheromone communication; custom fitted arm/torso gear, molting downtime. | Mantis → Bladed Predator / Hive Sentinel; Beetle → Carapace Fortress / Burrow Juggernaut; Moth → Dreamwing / Dust Weaver. | **Chimeric Reaper** through bio-ritual, extra arm options at high metabolic cost. |
| **Avian** | Wings, talons, far vision; flight restricted by weight, interiors, exhaustion and ranged enemies. | Raptor → Sky Hunter / Talon Duelist; Corvid → Trickwing / Omen Speaker; Stormwing → Gale Harrier / Thunder Skimmer. | **Tempest Phoenix** through storm shrine; powerful aerial rebirth technique with resource debt, not extra lives. |
| **Amphibian** | Water mobility, toxin skin, amphibious senses; long dry exposure builds fatigue; wetness kits. | Marshborn → Mire Shaman / Bog Stalker; Reef → Tide Warden / Coral Guardian; Deepwater → Abyss Diver / Glow Hunter. | **Leviathan-Blooded** in abyss pool; huge aquatic power but land adaptation costs. |
| **Minotaur** | Horned charges, momentum, spatial control; large helm fit and vulnerable to confined positioning. | Labyrinth → Maze Warden / Wallbreaker; Ironhorn → Iron Juggernaut / Horn Duelist; Bloodmane → Berserk Champion / War Caller. | **Mazeheart Titan** after solving a legendary labyrinth; makes walls tactical assets while losing stealth. |

## 6.4 Undead and supernatural (4)

| Species | Biology, survival, weakness / equipment | Lineage → two branches each | Hidden transformation hook |
|---|---|---|---|
| **Vampire** | Blood hunger instead of common food; lifesteal, nocturnal senses, some sunlight/radiant penalties; normal gear. | Noble → Crimson Sovereign / Night Aristocrat; Feral → Beast Stalker / Sanguine Hunter; Sanguine → Blood Oracle / Scarlet Duelist. | **Eclipsed Ancestor** via ancient crypt pact; higher blood demands and great occult power. |
| **Revenant** | Undead sustenance and soul-essence recovery; poison/rot resistance, consecrated vulnerability; conventional humanoid slots. | Gravebound → Grave Marshal / Bone Knight; Ashen → Cinder Revenant / Ash Wraith; Soulbound → Spirit Channeler / Soul Devourer. | **Unbound Lich** by soul-vessel creation; high magic but vessel becomes a tactical liability. |
| **Demonkin** | Infernal affinities and bargain-based power; corruption tradeoffs and holy hostility. | Infernal → Hell Knight / Flame Apostle; Abyssal → Rift Fiend / Corruption Weaver; Hellforged → Chain Tyrant / Ember Forgemaster. | **Pit Sovereign** through infernal throne pact; powerful command and binding vulnerabilities. |
| **Celestial** | Radiance/divine perception; difficult forbidden-magic synergies and strong reaction from dark cults. | Dawn → Dawn Sentinel / Sun Healer; Starborn → Astral Herald / Meteor Adept; Fallen → Penitent / Eclipse Warden. | **Unsealed Seraph** from a celestial vault; radiant aura attracts hostile attention. |

## 6.5 Exotic and otherworldly (6)

| Species | Biology, survival, weakness / equipment | Lineage → two branches each | Hidden transformation hook |
|---|---|---|---|
| **Myconid** | Spore ecology, fungal sense and organic sustenance; fire weakness; symbiotic armor and porous tools. | Sporebound → Colony Shepherd / Spore Hunter; Rotborn → Blight Harvester / Corpse Gardener; Luminous → Beacon Mycologist / Radiant Bloom. | **Mycelial Sovereign** grows sensing colony at a mobility/channeling cost. |
| **Slimeborn** | Fluid anatomy, ingestion/absorption, corrosive potential; standard clothing/hand slots mostly absent, embedded relic slots instead. | Caustic → Acid Devourer / Corrosion Smith; Prismatic → Spectrum Heart / Reflective Veil; Gelatinous → Splitmind / Elastic Bastion. | **Oceanic Amalgam** after absorbing living ooze core; adaptive but huge hunger/size penalties. |
| **Runic Construct** | Artificial body powered by core charge; poison and disease immunity; repaired with material/spell, modules and plating instead of ordinary biological healing. | Stone → Granite Bastion / Earth Engine; Iron → Iron Legion / Warframe; Arcane → Rune Conduit / Aether Engine. | **Awakened Colossus** through ancient forge; powerful frame with repair burden. |
| **Crystalborn** | Resonance, stored spell charge and natural prism defense; vulnerable to sonic/shatter; crystal sockets instead of some fabrics. | Quartz → Harmonic Oracle / Clear Shield; Obsidian → Shard Titan / Night Prism; Aether → Aether Harp / Spell Reservoir. | **Living Cathedral** in a resonance vault; area buffs but brittle core. |
| **Voidkin** | Spatial senses and short-step warps; displacement mishap/corruption risk; regular equipment with anchor charms. | Astral → Astral Navigator / Star-Seer; Riftborn → Rift Dancer / Gate Hunter; Nullborn → Null Sovereign / Silence Weaver. | **Unmoored** via void-gate riddle; reality editing but unstable positioning. |
| **Shapeshifter** | Limited alternate body forms; form-tag gear preservation; high upkeep and timing penalties when shifting. | Feral → Chimera / Primal Stalker; Mimic → Perfect Mimic / Living Arsenal; Primordial → Manyskin / Origin Beast. | **Everform** through first-shape rite; rapid changes but amplified magic disruption. |

**Species implementation acceptance (all 24):** an automated test must iterate every species×lineage×background combination, produce a legal starting kit or an explicit adapted kit, simulate basic movement/combat/consumption, validate two exclusive lineage paths, and reject contradictory traits without crashing. A separate smoke seed must let each species reach/complete the main objective in a test-friendly controlled configuration; winning difficulty need not be identical.

---

# 7. Background bible: 36 handcrafted, class-agnostic starting kits

Each background consists of a starting skill-priority template, minimal kit categories, a starting technique or learned spell, one thematic knowledge tag, and a plain-language difficulty note. **Any species can select any background.** Starting kit adaptation operates by tactical role (`guard`, `ranged damage`, `dig`, `heal`, `focus`, `implement`) and equipment/body tags; if a species cannot hold a weapon, the substitute is a starting compatible natural technique or embedded focus, not an empty slot. Advanced specializations remain available to other backgrounds that meet requirements.

| Group | Background | Starting training focus | Starting kit / first tactic |
|---|---|---|---|
| Martial | **Fighter** | chosen weapon + Armor | basic weapon + armor + bandage; Guarded Strike |
| Martial | **Berserker** | melee + Athletics | heavy weapon or natural attacks + ration; controlled Rage |
| Martial | **Duelist** | blades + Evasion | finesse weapon + light armor; Parry/Riposte |
| Martial | **Guardian** | Shields + Armor | shield or compatible bulwark + mace; Intercept |
| Martial | **Martial Adept** | Unarmed + Evasion | wraps or natural limb gear; Stance Shift |
| Martial | **Reaver** | axes/blunt + Endurance | cleaving implement + restorative tonic; Sundering Blow |
| Stealth | **Rogue** | Stealth + Lockpicking | lock kit + short blade; Backstab |
| Stealth | **Ranger** | Archery + Survival | bow/compatible ranged tool + field kit; Mark Quarry |
| Stealth | **Assassin** | Stealth + Subterfuge | toxin dose + light blade; Expose Weakness |
| Stealth | **Trickster** | Illusion + Evasion | smoke tools/illusion focus; Feint Echo |
| Stealth | **Saboteur** | Traps + Artifice | trap kit + demolitions consumable; Rig Snare |
| Stealth | **Bounty Hunter** | Tracking + ranged/melee | restraint tool + tracker kit; Pinning Shot |
| Arcane | **Arcanist** | generic magic focus + 1 chosen school | focus + spell primer; Arcane Dart |
| Arcane | **Elementalist** | chosen elemental school | elemental focus + resist charm; Elemental Bolt |
| Arcane | **Spellblade** | weapon + spell school | weapon + focus + light guard; Enchant Strike |
| Arcane | **Runecaster** | Runecraft + magic school | inscription tools + ward; Place Rune |
| Arcane | **Summoner** | Summoning + Spiritcraft | binding token + focus; Minor Familiar |
| Arcane | **Illusionist** | Illusion + Subterfuge | phantasm focus + concealment gear; Decoy |
| Occult | **Necromancer** | Necromancy + Spiritcraft | bone focus + grim primer; Grave Grasp |
| Occult | **Blood Mage** | Blood Magic + Endurance | sacrificial focus + restorative; Blood Sigil |
| Occult | **Warlock** | Hexcraft + pact lore | covenant sigil + catalyst; Eldritch Brand |
| Occult | **Hexbinder** | Hexcraft + Illusion | curse focus + binding cord; Misfortune Mark |
| Occult | **Void Seer** | Spatial Magic + perception | anchor talisman + rune; Rift Glimpse |
| Occult | **Plague Doctor** | Alchemy + Survival | tinctures + protective mask/equivalent; Contaminate |
| Divine | **Cleric** | Divine Magic + Spiritcraft | holy implement + salve; Bless/Heal |
| Divine | **Paladin** | martial + Divine Magic | compatible guard + blessing item; Sacred Strike |
| Divine | **Inquisitor** | Subterfuge + Divine Magic | detector + restraint gear; Dispel Sigil |
| Divine | **Oracle** | Spiritcraft + perception | omen token + journal; Foretell Hazard |
| Divine | **Cult Initiate** | chosen occult school + lore | ritual component + basic pact; Rite of Passage |
| Divine | **Exorcist** | Spiritcraft + Hexcraft | sealing talisman + ward; Banish Shade |
| Nature/Craft | **Druid** | Transmutation + Survival | herb kit + focus; Vine Grasp |
| Nature/Craft | **Beastmaster** | Beast Handling + Tracking | bait + training whistle; Soothe Creature |
| Nature/Craft | **Shaman** | Spiritcraft + Survival | totem + ritual herbs; Spirit Mark |
| Nature/Craft | **Alchemist** | Alchemy + Craft | portable kit + flasks; Mix Catalyst |
| Nature/Craft | **Artificer** | Artifice + Runecraft | component pack + device; Deploy Gadget |
| Nature/Craft | **Delver** | Mining + Traps | pick + lamp + trap probe; Read Stone |

**No hard class locks:** All learned techniques belong to skills, mentors, discoveries, talents, and defined prerequisites. Some starting rituals require an item or teacher to learn later, not the original background label. An adapted background may be intrinsically more difficult and this is clearly indicated, but it must receive a legal opening kit and gameplay loop.

**Custom background:** select focus categories, starting skills, beginning knowledge, first technique/spell, and equipment within the same internal startup budget as preset backgrounds. Form preview shows exactly why an expensive combination is not legal. No custom kit can start with a quest-critical unique or secret-only artifact. Save and reuse a **build preset** locally between runs, but not character power/world progress.

---

# 8. Skills, talents, magic and specializations

## 8.1 Trainable skill families (36 initially)

The exact 36 trainable skills are a **delegated design baseline** and can be tuned without changing the player's locked training model:

| Family | Skills |
|---|---|
| Weapons (6) | Short Blades, Long Blades, Axes, Polearms, Maces, Unarmed |
| Ranged/defense (6) | Archery, Crossbows, Throwing, Shields, Armor, Evasion |
| Elemental magic (4) | Pyromancy, Cryomancy, Electromancy, Geomancy |
| Arcane/occult (6) | Necromancy, Summoning, Transmutation, Illusion, Hexcraft, Spatial Magic |
| Divine/spiritual (2) | Divine Magic, Spiritcraft |
| Subterfuge (4) | Stealth, Traps, Lockpicking, Subterfuge |
| Craft/knowledge (4) | Smithing, Alchemy, Runecraft, Artifice |
| Wilderness (4) | Survival, Mining, Tracking, Beast Handling |

**Balance note:** Early candidate “Firearms” is replaced by Crossbows to preserve the predominantly fantasy setting; firearms are not part of the baseline roster. `Blood Magic` is a magic *discipline/tag* supported by Necromancy, Hexcraft and/or talents, rather than a thirty-seventh base training gauge. `Endurance`, `Athletics`, perception and generic spellcraft are derived attribute/talent families, not additional trainable skill gauges until explicitly authorized. Background descriptions that say otherwise map to the closest skills in this canonical table. This resolves a potential mismatch in early proposals without removing their intended gameplay roles.

**XP training:** XP is awarded for bounded meaningful actions/events (threat-scaled combat, exploration discoveries, quest milestones, worthy crafting achievements). Trainable skills have enable/disable and priority weights; training budget is split proportionally then modified by species aptitude and global anti-farm diminishing rules. XP awards cannot be repeatedly collected for cycling through already-cleared adjacent regions, crafting and disassembling the same item, or killing infinitely summoned harmless creatures. Skill training priorities can be changed outside an action resolution. The summary always explains why a skill did/didn't improve. Death loses all training; the run chronicle retains a snapshot.

## 8.2 Attributes, talents and prerequisites

- **Attributes:** Might, Agility, Vitality, Intellect, Will, Perception, Attunement (seven distinct contributions); derived HP/stamina/mana, encumbrance, insight and resistance values are calculated, not separately allocated in character creation.
- **Talent points:** earned on character-level milestones and limited authored discoveries. Talent is selected from known catalog, requiring skill rank, attribute, tags, prior talent, species/evolution where **mechanically relevant**, or discovered lore. Requirements compose as AND/OR predicates with human-readable explanations.
- **Active/passive/modifier kinds:** active command, passive stat modifier, reaction trigger, known spell modifier, companion command extension, crafting recipe unlock. A status effect cannot stack indefinitely unless an explicit bounded stack cap exists.
- **Respec:** free priority changes; refund selected talent points using finite trainer, ritual or rare-token resource; respec validates downstream talent dependencies and previews all points/abilities removed. Primary/secondary specialization reversal follows additional restrictions; major transformation reversal is a separate rare quest, not normal talent respec.
- **Hybrid talents:** Soul Reaper (Axes + Necromancy), Stormstep (Evasion + Electromancy), Mycelial Legion (Summoning + Spiritcraft + appropriate fungal source), Runic Forgemaster (Smithing + Runecraft + Artifice), Gravitic Snare (Geomancy + Spatial Magic), Vapor Veil (Cryomancy + Illusion). Discoverable talents provide hints and missing-precondition feedback; do not conceal required mechanics behind impossible RNG.

## 8.3 Two specializations

Each character can commit to **one primary** specialization with its full pinnacle ability line, and **one secondary** specialization with a smaller complementary subset. A secondary may not gain its primary-exclusive pinnacle, but cross-specialization synergy talents can be unlocked by both. Specializations never require a particular original background. Proposed set:

| Specialization | Entry skills | Full-primary fantasy / useful secondary |
|---|---|---|
| Soul Reaver | Axes + Necromancy | Reap souls to empower melee / harvest-charge passive |
| Runic Bastion | Shields + Runecraft | Anchor and shape wards / shield-rune synergy |
| Rift Stalker | Evasion + Spatial Magic | Teleport strike chains / safe reposition techniques |
| Plague Sovereign | Alchemy + Necromancy | Infectious minion network / toxin conversion |
| Arcane Artillerist | Artifice + Pyromancy or Electromancy | Custom elemental devices / device efficiency |
| Primal Warden | Beast Handling + Survival | Pet tactics, evolution support / animal affinity |
| Blood Oracle | Divine Magic + Necromancy | Sacrifice for foreknowledge / omen reuse |
| Spellbreaker | Armor + Hexcraft | Magic-disrupting defensive field / disruption strikes |
| Storm Herald | Electromancy + Spiritcraft | Aerial storm presence / shock links |
| Umbral Harvester | Stealth + Necromancy | Stealthy soul assassination / spectral cloak |
| Forge Saint | Smithing + Divine Magic | Sanctified gear and battle blessings / crafting boons |
| Verdant Shaper | Transmutation + Survival | Growing structures and bioforms / root manipulation |

Other combinations are normal hybrid builds, not necessarily named specializations. Specialization catalog can expand only after prerequisites/effect systems support it.

## 8.4 Magic schools and effect vocabulary

**Primary spell schools:** Pyromancy, Cryomancy, Electromancy, Geomancy, Necromancy, Summoning, Transmutation, Illusion, Hexcraft, Spatial Magic, Divine Magic, Spiritcraft. **Secondary themes:** Blood, Fungal, Rune, Astral, Infernal, Crystal, and Void appear as modifiers, item tags, species abilities, or multi-school talents—avoids an explosion of near-duplicate skill gauges.

An authored `SpellDefinition` has known ID, school tags, learn conditions, resource cost, range and target filter, line-of-sight rule, execution shape, effect node list, level scaling, animation/audio presentation hint, friendly-fire semantics, targeting preview, legal modifiers and cooldown/action-time rule. A spell mod (range, element conversion, fork, linger, pierce) is data-defined and constrained by an effect compatibility table; do **not** ship general-purpose user-written programmable spells in P1–P4.

**Effect primitives:** `damage`, `heal`, `push`, `pull`, `teleport`, `summon`, `apply_status`, `modify_tile`, `spawn_hazard`, `shield`, `drain_resource`, `reveal`, `dispel`, `create_light`, `bind`, `invoke_event`. Every primitive must be independently testable.

**Core reaction matrix** (all require finite chain budgets):

| Condition | Reaction | Player feedback and limits |
|---|---|---|
| Shock reaches water-bearing connected tiles | Conduct in region determined by water adjacency | Preview conductive area, bounded propagation, ally damage rules. |
| Flame intersects combustible gas | Explosive area effect, consumes gas | Warn via gas icon; line-of-sight/shield rules apply. |
| Cold hits shallow water | Forms traversable ice for duration | Move/path costs change; ice can melt. |
| Fire hits ice | Melts to water; potential steam hazard | Update tile layers and pathing only after event resolves. |
| Earth impact hits marked weak wall | Breaks or cracks wall | Never silently removes structural progression barriers. |
| Fungal spores contact suitable corpse | Creates infestation/temporary growth | Respect corpse state, population cap and fire risk. |
| Blood ritual while health low | High risk or fails depending on spell | Explicit health-cost confirmation if lethal. |
| Holy effect strikes undead/possessed | Applies tag-specific interaction | Resistances not flat universal kill multipliers. |

**Spell content target:** P1 uses one damage spell, one control spell, one summon/utility spell, one movement ability plus two environmental reactions. P3 can aim for 80+ meaningful spells with combinable modifiers before pursuing hundreds. Duplicate numerical variants do not count toward qualitative depth.

## 8.5 Three example complete builds

1. **Rotborn Myconid / Spellblade / Soul Reaver + Verdant Shaper** — spore clouds conceal close-range soul harvesting; fire threatens both spores and body; living armor replaces some metal equipment; rare Mycelial Sovereign metamorphosis is an optional high-cost deviation.
2. **Iron Construct / Druid / Runic Bastion + Verdant Shaper** — roots block passages, rune wards protect companions; repair-based sustain complicates ordinary healing; no species/background exclusion despite strange concept.
3. **Storm Draconian / Delver / Rift Stalker + Storm Herald** — mobility, excavated shortcuts and lightning-water hazards; specialized tail armor, energy economy and grounding effects are meaningful counters.

---
# 9. Items, crafting, ecology, companions, religion and quests

## 9.1 Equipment and loot

**ItemDefinition** fields: `item_id`, label/localized description, kind, tags, slot rules, mass, rarity, base properties, material compatibility, affix pools, granted actions, durability flag if any, crafting recipe ID, stack rule, icon/sprite ref and unique flag. **ItemInstance** stores a generated instance ID, rolled affixes/seed, owner/location, charges, identified state, damage/curse flags and enchantments. A unique item may appear once per run by a per-run uniqueness registry. Never generate nonsensical combinations (e.g., a “+shield-block” property on a consumable or an armor affix requiring a missing slot).

**Loot tiers** are readability tiers, not monetized rarity ladders: ordinary, superior, enchanted, exceptional, legendary unique; randomized affixes combine authored pools with bounded synergistic combinations. A legendary has a handcrafted special mechanic and narrative provenance derived from world history; adding a randomly colored border is insufficient.

**Inventory:** filtered list with icons, stack counts, weight/volume, compatible equipment slots, long-press inspect, explicit Equip/Use/Drop/Mark controls. Stack splitting, dropping and pickup are commands; multiple objects on ground open a compact picker. No auto-destruction or silent dropping if the player's anatomy evolves. Crafting can consume only owned explicitly selected ingredients, with confirmation for unique/quest items.

## 9.2 Crafting, mining and survival

- **Resource tiers:** mundane wood/stone/herbs, biome metals/reagents, rare crystalline/biological materials, realm-aligned essences and legendary boss components.
- **Recipes:** prerequisites = known schematic or discovered experimental rule + stations/tools + ingredients + skill; output has deterministic validated properties. Learning recipes cannot be infinitely farmed for XP.
- **Branches:** basic camp recipes, cooking/tonics, blacksmithing, alchemy, rune enchanting, artifice/gadgets, species-specific symbiotic/embedded gear. Dungeons contain rare stations and recipes.
- **Mining:** only tagged terrain; checks tool, hardness, action cost, resource source and structural safety. Exposes previously generated hidden rooms rather than allocating random geometry mid-attack. The change is recorded as a region delta.
- **Survival resources:** satiety/sustenance, rest/fatigue, temperature/exposure, ongoing conditions. Species metabolism maps each to appropriate mechanics (blood, essence, arcane core charge, fungal nutrients, conventional rations). Avoid mandatory thirst or detailed nutritional macros in baseline. Weather and temperature affect preparation and spells, not frequent chores.
- **Camping:** only allowed on legal tiles; forecasts noise/ambush risk and recovers appropriate resources. Rest immediately stops on nearby danger, damage, event warning or a user cancellation command.

## 9.3 Factions, gods, history and economy

A **FactionDefinition** describes ideological tags, preferred biomes, governing style, rivalries, attitude to species/faith, allowable quests, trade specialization and hostility thresholds. **FactionState** tracks influence cells, known contacts, relation scores, resources at abstract level and outstanding incidents. **ReputationEvent** has a source action, affected witnesses/factions, value, propagation rule, and optional expiration. Killing an unwitnessed monster does not instantly broadcast across the planet; reputation travels via witnesses and world events unless a god has supernatural awareness defined in the content.

A **GodDefinition** has ethos, vows/taboos, piety actions, powers, costs, wrath states, shrine logic, exclusive allegiance flags and faction affiliations. Deities need mechanical uniqueness (e.g., sacrifice/exchange, natural preservation, rune-making, dueling honor), not merely damage flavors. Switching worship has explicit piety/relationship consequences; no invisible permanent lock without forewarning.

**Settlement template:** culture, architectural kit, economy, services, class/faith bias, resource need, settlement tier, NPC role slots, faction membership, history scars and local secrets. A town can offer a smith, inn/camp alternative, trainer, merchant, healer, notice board, guards and unique encounter templates. NPC dialogue is authored by intent, role, tags and current quest flags, with procedural interpolation of actual local names and events; do not send dialogue to an LLM at runtime.

**Economy limits:** individual shop stocks can respond to events, region production and reputation, but do not simulate thousands of transactions. Price variation is bounded and explained to players. A generated shortage cannot prevent obtaining universally necessary main-quest items.

## 9.4 Quest graph contract

**QuestDefinition** = premise, conditions, participants in abstract roles, step graph, alternatives, stakes, rewards, consequence entries, fallback behavior and author provenance. **QuestInstance** binds real NPC IDs, sites, objects, world history events and chosen branch. Accepting a quest captures its intended invariants. Each node has trigger, prerequisites, success, fail, alternate resolution, and guaranteed player-visible journal text.

Quest validation requires: every required actor/site exists or a valid fallback is generated; no endless unfinishable states when merchants die or towns are raided; not all alternate routes rely on a single lineage, god or hidden trait; choices have predictable preview of obvious consequences and later surprises tied to discoverable clues. **Main quest** authoring: three Concord Seals or equivalently tiered milestones distributed across different route types, followed by finale; exact milestone count is content tuning. Seed ensures at least one route is win-capable and tests attempt two structurally distinct paths. Side quests offer combat, negotiation, investigation, burglary, crafting and companion paths where reasonable. Not every mundane errand requires five dialogue branches.

**Event template:** `event_type`, region and schedule predicates, actors, spawn restrictions, outcome deltas, journaling policy, quest conflict policy, RNG stream and daily/offscreen evaluation limit. Active-region NPCs move one legal step/action at a time; remote events consume abstract time, not thousands of hidden actor turns.

## 9.5 Monsters, bosses and followers

**Creature archetypes** include classic humanoids, slimes, undead, subterranean predators, fungal swarms, elementals, infernal entities, constructs, flying beasts and intelligent faction patrols. A creature references the same stats/status/anatomy/effect systems as players, but uses an `AIProfile` with perception, pursuit, retreat, coordination, range preference, threat assessment, consumable usage and environmental affinity.

**Procedural variant safety:** monster templates can receive only tag-compatible modifiers with bounded encounter-threat budgets. No “infinite split” or inaccessible ranged enemy in starter encounters. Threat descriptions reveal standout capabilities. Bosses are handcrafted tactical setpieces that may spawn in variant venues; rare miniboss names and secondary modifiers are procedural.

**Followers:** one/two persistent companions at practical milestones plus a separately capped small number of summoned creatures (initial alpha target: 1 persistent + up to 2 summons, adjustable by testing; later target: 2 persistent). Their default AI is follow, protect, preserve life, avoid known hazards. Orders are explicit and queued into the normal action scheduler (`follow`, `hold`, `focus target`, `retreat`, `avoid area`). Permanent companions can have levelled skills and compatible gear where allowed; summons have duration/upkeep and avoid persistence beyond definition. If a companion dies, death is permanent within the run unless an explicitly acquired resurrection mechanic allows an exception. No globally free respawn. Enemies and allies use the same collision and friendly-fire rules.

---

# 10. Information architecture and screen map

## 10.1 Navigation model

The game itself is the **north-star screen**; everything else is a fast overlay or modal layered over it. Navigation favors quick return to play rather than switching between endless full-page tabs. Main menu hosts New Run, Continue (only for an active non-dead save), Chronicle, Settings and Help. During play, HUD buttons open Inventory, Character, Skills, Talent & Specialization, Journal, World Map, Companions and Game Menu; long-press inspection opens a bottom sheet. Modal navigations pause command processing and save dirty UI selections when appropriate.

## 10.2 Screen register

| Screen ID | Screen | Entry / exit | Primary role |
|---|---|---|---|
| S-001 | Main Menu | App launch; New/Continue/Chronicle/Settings | start/resume |
| S-002 | Character Creator | New Run → multi-step flow → world generation | build choices and warnings |
| S-003 | World Generation / Run Start | Creator confirmation → Explore | seed validation and intro |
| S-004 | Exploration & Combat HUD | Default after load → overlay/detail | NORTH-STAR gameplay |
| S-005 | Tactical Targeting / Inspect | Tap enemy/object or long press → HUD | precise target/ability preview |
| S-006 | World Map | HUD globe/map button → return to HUD | navigation and discovered lore |
| S-007 | Inventory / Equipment | HUD inventory → HUD | gear actions and constraints |
| S-008 | Character & Lineage | HUD portrait → HUD | stats, body plan, current form |
| S-009 | Skills Training | Character/quick key → HUD | XP priority changes |
| S-010 | Talents & Specializations | Character / level-up cue → HUD | unlock and respec overview |
| S-011 | Spellbook / Ability Deck | HUD hotbar → HUD | equip/cast and organize powers |
| S-012 | NPC Dialogue / Services | Tap interactable NPC → HUD | dialogue, trading, teaching |
| S-013 | Quest Journal | HUD journal → map or HUD | objectives and branching choices |
| S-014 | Craft / Camp | HUD action or station → HUD | survival, recipes, resting |
| S-015 | Followers & Orders | HUD companion chip → HUD | tactical follower commands |
| S-016 | Death / Victory / Chronicle | Lethal/game-end event → menu | accountable run resolution |
| S-017 | Settings / Controls / Help | Menu or pause → return | accessibility, touch layout |
| S-018 | Compendium / Lore | Menu or HUD discoverability → back | learned items, creatures, world facts |

## 10.3 Two UX design directions considered

**Direction A — “Luminous Caverns”:** colorful, bright, high-contrast world-first UI; sparse overlays; strong arcade readability and lively feedback. Risk: understated fantasy lore and a mobile HUD that feels too gamey for complex data.

**Direction B — “Runic Field Journal” (CHOSEN):** dark stone/iron framing, faint warm parchment/silver text, restrained teal/ember/amber accents, crisp colorful world sprites, fold-out map pages and layered codex sheets. Compact but understandable hierarchy, consistent horizontal HUD action dock, sliding inspection sheets. Risk: decorative material texture can reduce legibility; textures are prohibited behind small text.

**Direction C — “Cartographer's Codex”:** very dense tables and maps inspired by classic roguelikes; excellent expert inspection, poor initial touch comfort. Its information density becomes optional advanced views, not the default interface.

## 10.4 Portrait exploration composition

Top safe-area strip: compact current biome/region name, conditions/weather indicator, pause and map access. Under it: tiny status ribbon for HP/stamina/mana/sustenance and current buff/debuff icons; tap any opens explanation.

Middle majority: zoomable map, player near a deliberate lower-middle anchor when safe, contextual on-tile markers and combat telegraphs. Camera preserves location when menus close. A floating inspect action can be placed on the side configured for thumb reach.

Bottom control zone: 4–6 context-sensitive action slots (attack, cast, interact, pick up, camp/abilities, overflow), movement control (visible eight-way pad by default with an alternative tap-to-path mode), and expandable inventory/journal buttons. The low-height viewport sacrifices some tile visibility to keep controls actually reachable; collapse nonessential ribbon when safe. All layout stays inside cutouts, gesture-nav insets, and small-screen keyboard constraints.

The UI uses a **single modal stack**: HUD → (target sheet OR inventory OR map OR menu). No two full-height blocking overlays simultaneously. Game clock pauses while browsing, unless the player explicitly confirms a command in that overlay.

---

# 11. Per-screen interaction and recovery specifications

## S-001 Main Menu

**Layout:** game identity top; Continue if active run is valid, New Run prominent, Chronicle, Settings and Help below. Quiet moving pixel vista backdrop that can be disabled. **Actions:** New starts blank creator (never destroys an active run without a consequence-confirmation); Continue loads latest valid snapshot; Chronicle opens read-only run cards. **States:** first install hides Continue; corrupt save shows recover/cannot-resume explanation; deceased run shows Chronicle not Continue. **Acceptance:** one tap from valid title leads to unchanged running state; corrupted file cannot crash menu; accidental New can cancel.

## S-002 Character Creator

**Order:** Species → Lineage → Background/Custom → Attributes → Traits & Drawbacks → Review. Horizontally swipable progress tabs are accompanied by explicit Next/Back; selected values persist on back navigation. Lists have search/filter, sort by complexity, innate ability cards, anatomy silhouette, fit restrictions and starter difficulty explanation. Compare up to two species/backgrounds in a bottom sheet; show what creates a difficult combination. Preview explicitly lists starting actions, adapted gear, sustenance, lineage branch previews and trait conflicts. **Empty:** no list filter matches → clear filter; **blocked:** incompatible trait explains exact cause; **abort:** confirmation before discarding creator draft; **state:** no world seed generated until final confirmation, so reopening creator cannot burn seeds inadvertently.

## S-003 Generation / Intro

**Layout:** concise world title, seed option (random by default, user-entered for reproducibility), progress step labels, Cancel before committing run. Generator runs validation and may retry named stages. A successful seed is bound to the run. If generation fails on bounded attempts, present Try Another Seed / Inspect Diagnostic (advanced) and preserve character choices. Starting screen offers short tutorial toggle for first run. Content-dependent load does **not** run on the render loop.

## S-004 Exploration & Combat HUD (north-star)

**Input:** single tap adjacent tile = one step, distant explored legal tile = preview path with second tap or clear Go command (configurable), drag camera = pan, pinch = zoom within readable bounds, long-press entity = inspect, eight-way pad/keyboard/gamepad optional. No action can be committed twice by repeated taps while previous simulation command remains unresolved. Combat mode retains same scene but replaces contextual hotbar hints with threat-oriented actions, and highlights current target, reachability, splash and damage types. **Threat entry:** auto-explore halts and vibrates once if enabled, with readable event text. **Recovery:** if an action is rejected, keep input state, show short reason and don't consume turn; if actor killed, disable controls before committing tombstone. **Accessibility:** selectable left/right-handed controls, permanent visible movement alternative, no touch-only action, generous hit targets, readable labels and reduced-motion toggle. **Visual:** quick but optional interpolation and shake; simulation doesn't wait on particles. **Acceptance:** a hostile entering LOS stops auto-walk before the next queued hazardous step; pausing blocks new world turns; adjacent tap yields at most one move.

## S-005 Targeting and inspection

Tap inspect or long press to open a non-turn-consuming sheet: name, creature type, sensed equipment, defense hints, resistances known to player, danger flags, line-of-sight, action-cost and estimated damage ranges with uncertainty. Ability targeting displays area preview in contrasting color **and a shape/pattern**, ally hazards, missing resource error and confirm/cancel. If targeted actor moves/disappears before execution, revalidate and stop with user feedback instead of hitting an arbitrary replacement.

## S-006 World Map

Shows discovered macro geography, current region, reachable known edges, landmarks, roads, known settlement state, faction marks, and quest rumors. Unexplored sections are unknown; route planning never reveals hidden objectives. Selecting known location previews route and likely danger but can't teleport unless travel mechanic is unlocked, paid and safe. Cross realm arrows explicitly indicate gate endpoints. If route is blocked by new world event, cancel before consuming irreversible resources.

## S-007 Inventory and equipment

Tabbed/filtered inventory and body-slot diagram; equips use role-aware compatibility messages. Drag is optional; tap-item → action list is always available. Long descriptions scroll independently; unknown items marked unidentified. Provide compare sheets for stats, abilities, and restrictions. Equip warns when replacing gear disables talents or removes key resistances. For insufficient capacity, item stays on ground or in overflow bundle and player is notified. Bulk sorting and mark-favorite do not spend turns; equip/drop/use do when appropriate.

## S-008 Character and lineage

Shows attributes, derived resources, innate abilities, anatomy slot affordances, skills aptitude, current form, lineage track with prerequisites, available evolution branches and explicit irreversibility/cost warning. A hidden evolution does not appear with a spoiler label until discovered; silhouette/rumor hints can appear as lore. Unknown future transformations never silently override the current selection.

## S-009 Skill training

Scrollable list grouped by family with numerical current rank, progress, aptitude and chosen training weight. Enable/disable focus in one tap and change priority by accessible buttons/slider. Display projected percentage allocations and explain that focus is not a guarantee of direct XP awards. Warning if every skill is disabled; allow character to bank unallocated training XP temporarily up to a bounded cap instead of silently wasting it.

## S-010 Talents and specializations

List/grid of learned, eligible, locked, undiscovered (without spoilers) talents; tapping a locked known talent explains missing skill/attribute/prerequisite, not simply grey. Show `0/1 primary`, `0/1 secondary` slots. Commit talent requires confirm if irreversible; respec preview enumerates downstream effects and refund/cost before applying. Leaving screen preserves scroll, filters and selection.

## S-011 Spellbook / ability deck

Active spells/techniques grouped by learned school; sort mana, range, school and favorite. Player binds abilities to limited combat slots; unbound abilities remain accessible from expanded deck. A long press shows range/area/status/friendly-fire and alternate modifiers. Attempt to cast without target/resources returns actionable message, no unadvertised spent turn.

## S-012 NPC dialogue / merchant / trainer

NPC portrait/name/faction/routine, conversation choices, visible reputation stakes when known, items/services and trade compare pane. NPC state persists after modal closes. Different input routes (talk vs attack/theft) are distinct confirmable intents; dangerous dialogue choices preview clear high-level risk, not every plot consequence. Shop transaction is all-or-nothing and is validated against inventory/currency/state at confirmation time. NPC absent/dead provides journal fallback, not a phantom dialogue.

## S-013 Journal

Main, faction and side quests with current steps, clues, previous decisions and links to map if known. Journal text updates from actual quest-state events, not from generated placeholders unbound to locations. Failed/abandoned quests remain accessible in history with reason. A quest inaccessible due to a generated inconsistency is a reportable game bug, not an unfinishable silent objective.

## S-014 Craft and camp

Station-sensitive recipe browser with ingredients, missing materials, output preview, known consequences and cost. Show legal mining targets and tool hardness via inspection. Camp controls select rest duration/intent, visualize supplies and expected risks; interrupt on enemy arrival or event. Crafting failed due to changed inventory does not consume partially by default. Recipe discovery is recorded; dangerous transmutations require confirmation.

## S-015 Companions

Each follower has a card with location, health, loyalty/status, current command, equipment when relevant, separation route and effective active-slot count. Tap order opens explicit choices; press-and-hold shortcuts optional. If blocked by geometry and can't follow, follower chooses safe route or waits and announces state. Summon duration is visible. Dismissing or abandoning a unique companion requires explicit decision.

## S-016 End of run / chronicle

**Death screen:** final blow/source, location, level, build summary, important decisions, enemy or hazard cause, final turn count, known main-quest progress; Continue is absent. **Victory screen:** clear winning route and optional Continue Exploring or Retire. **Chronicle:** read-only cards, sortable by date, species, background, outcome, seed, cause. Sharing/export can output a text summary with no private account data. Closing app mid-death animation does not restore a living character.

## S-017 Settings and controls

Audio, visual effects intensity, frame cap modes, UI scale, zoom range, left/right controls, movement method, haptics, threat warnings, color-blind patterns, reduce motion, reset layout, help, privacy/storage summary, debug seed export for developer mode. Changing graphics settings does not reset a run. Calibration page overlays a safe dummy grid to try controls without consuming game turns.

## S-018 Compendium

Discovered species lore, identified equipment, monsters encountered, spells known, gods, faction summaries, event-history fragments and world clues. Spoilers filtered by discovery state; browsing never spends a turn. Empty state points to ways to uncover entries. Long descriptions and translations scroll safely.

---

# 12. Visual, audio, motion and accessibility design system

## 12.1 Art direction and production

**Art target:** top-down 2D, crisp pixel sprites, restrained outlines, expressive silhouettes, readable equipment details, 3–6 frame common actions where useful, distinct biome tiles and animated environmental particles. Avoid copying exact sprites/UI compositions or proprietary game assets from inspirations. Target pixel ratios, tile dimensions and scaling mode must be tested on physical phone before locking an art pipeline; a tentative 32×32 logical map tile is only a **prototype candidate**, not a mandated output resolution.

**Style pillars:** legibility at native portrait size; coherent top-down perspective; bold silhouette; limited material/species palettes; per-biome color identity; terrain walkability clarity. Nonpixel vector/text controls may be used to keep long text legible. Bosses can be multi-tile sprites, not simply oversized scaled small enemies.

**Hybrid workflow:** (1) maintain sprite bible: viewpoint, light direction, palette ranges, outline thickness, tile grid, animation axes and creature proportions; (2) purchase/download only appropriately licensed packs with saved provenance; (3) generate original concept art with AI; (4) pixel-clean, align grids and animate using editing tools/manual correction as needed; (5) test visibility on the target phone and color-vision simulations; (6) register sprite IDs and licenses in asset manifest. AI outputs are not guaranteed pixel-perfect or consistent; use them as starting material requiring inspection and edits. Never ship copyrighted sprites lifted from inspiration games or asset pack files whose redistribution license is unclear.

## 12.2 Theme tokens and typography

- `background`: charcoal/near black; `panel`: dark slate; `panelElevated`: iron gray; `textPrimary`: near-white parchment; `textSecondary`: desaturated cool gray; `accent`: muted teal; `accentWarm`: amber/brass; `danger`: controlled crimson; `magic`: vivid cyan/blue; `poison`: green with icon/pattern. Exact hex colors finalized through visual review, not invented here.
- Typography: readable screen sans for stats/menus, restrained fantasy display face only in title/section marks. Font licenses verified; UI scale setting and no clipped status labels at large text.
- Hierarchy: primary combat info > action affordance > status effects > ambient lore. Dense codex panels use structured headings and collapsible detail. Dark textures never sit directly beneath small text.
- Shapes: sharp/low-radius rune-edged panels, small solid icon buttons, thin separators; minimize diffuse blur/glass overlays because they harm mobile contrast.
- Equipment/type marks use a symbol AND color, not hue alone.

## 12.3 Motion/haptics contract

| Action | Motion | Interrupt behavior |
|---|---|---|
| Routine step | brief logical-cell interpolation, no full-screen zoom | new command can queue only after rule resolution; visuals can catch up |
| Melee hit | small hit-flash/directional push, optional haptic | never blocks next legal command longer than actual resolving state |
| Spell cast | readable path/area particle, limited chain count | skip/speed option, no simulation dependency |
| Critical danger | tile warning, clear log entry and single optional vibration | auto-travel immediately halts |
| Loot/evolution | concise icon pulse/one-time distinctive flourish | dismissible, not a forced long animation |
| Permadeath | fade/sigil break after durable tombstone write | no active-run restoration if animation interrupted |

**Accessibility:** Aim for physical touch targets **at least 48dp** in touch overlays unless a close-packed game-grid selection is supported by alternate accessible controls. Offer magnification, tile inspection, reduced motion, distinguishable threat shapes, text/icon cues alongside colors, readable battle-log history, control hand preference, audio/haptic independence, and keyboard/gamepad fallback where Godot supports it. Test on the target Android phone at larger font settings and with gesture navigation/safe-area cutouts.

## 12.4 Performance targets (targets, not claims)

Primary target is responsive input and consistently smooth motion on the first identified phone (a modern Galaxy-class Android device), with practical scaling to midrange phones. Start with a 60fps render **aspiration**, 30fps fallback configuration, and profile actual frame-time distributions on device. Separate heavy generation from frame rendering; cache nearby region data and limit live simulated actors/particles. Profile generation time, region transitions, tile redraws, save writes, actor AI turn resolution and battery. Do not assert exact memory/latency budgets until measured on an APK.

---
# 13. Data, serialization and state contracts

## 13.1 Sources of truth and lifetimes

| Data type | Owner | Persistence and lifecycle |
|---|---|---|
| Content definitions | Packaged game resource files (read-only, versioned) | Ship with APK; cannot be mutated by runtime save. |
| User settings / control preferences | SettingsStore | `user://` preferences, survives all runs, versioned. |
| Build presets | PresetStore | Local across runs; stores species/background choices, not unlocked permanent power. |
| Run seed / world descriptor | RunRepository | Created at new run; authoritative seed, content version and topology. |
| Current character / follower / quest / faction state | RunState | Mutated only by validated domain commands, persisted on action-safe checkpoints. |
| Local region deltas and discovered fog | RegionRepository | Persist discovered/modified regions within active run; deleted on death. |
| Chronicle, achievements, gameplay records | ChronicleStore | Read-only completed records; retained independently of active world; exportable. |
| Transient targeting, open modal, tooltip, camera | UIState | Generally in memory; harmless UI selections may be cached. |
| Render caches / visible tile scene objects | Renderer | Rebuilt from state, never source of truth. |

**Determinism envelope:** preserve `world_seed`, `content_schema_version`, RNG streams and their states, world-generation revision, `action_index`, simulation clock, world topology, in-region diffs, queued world events and relevant NPC/faction states. Load through verified schemas; never deserialize arbitrary runtime scripts/code from save data. If a game update cannot replay old seeds bit-for-bit due to content changes, load previously committed region deltas while maintaining main-quest reachability; make migration behavior explicit, don't pretend all versions are deterministic across patches.

## 13.2 Conceptual entities

| Entity | Identity and required fields | Relationships |
|---|---|---|
| `RunRecord` | run_id, seed, created_at, schema_version, content_revision, status, turn_index | has character, world, chronicle link |
| `CharacterState` | actor_id, species_id, lineage_id, background_id, attributes, resources, skill values, focus weights, traits, talent IDs, specialization slots, mutations, equipment refs, position | refers to definitions, region, items, followers |
| `BodyPlan` | body_plan_id, slot capabilities, appendages, locomotion, metabolism, resistances | species/form, compatible items |
| `LineageState` | lineage_id, progress rank, chosen branch, unlocked hidden IDs, reversal flags | belongs to character |
| `WorldDescriptor` | seed, realm graph, macro cell metadata, region seeds, history events, quest-node placements, placement/repair report | references regions and factions |
| `RegionState` | composite ID realm+coord+depth, generated revision, discovered fog, tile changes, local actors/items, entrances, events | belongs to world |
| `ActorState` | actor_id, archetype, position, faction_id, stats, statuses, AI memory, schedule flags | region, inventory, quest roles |
| `ItemInstance` | item_instance_id, item_def_id, roll seed/affixes, enchant state, location/owner, charges, known state | equipment/inventory/ground |
| `QuestInstance` | quest_id, quest_def_id, bound roles/site IDs, current node, decision flags, failover state | world history, actors, factions |
| `FactionState` | faction_id, relations, influence, witnessed incidents, stock/availability flags | settlements, gods, NPCs |
| `GodAllegiance` | god_id, piety, vows, violated taboos, wrath flags | character and faction state |
| `EventRecord` | event_id, type, scheduled_turn, target region/actor IDs, preconditions, effect payload | event queue |
| `CompanionState` | actor_id, owner_id, bond/loyalty, current order, active slot, duration if summoned | player party, region |
| `ChronicleEntry` | chronicle_id, run_id, date, result, build summary, cause, quest path, highlights, seed | independent permanent record |
| `Settings` | version, control layout, accessibility, audio, visual prefs, test/debug toggles | device local |

Use **stable string IDs** for authored content, `run_id` for run-specific state, and deterministic or persisted instance IDs for generated world actors/sites/items. Coordinates by realm-region-local location and depth, not one global 16-bit TileMap coordinate. No locale-sensitive string as an identifier. Save schema must explicitly distinguish missing optional fields from corrupted required fields.

## 13.3 Save state machine, permadeath and interruptions

**Run states:** `NONE → CREATING → ACTIVE → VICTORY_ACTIVE | DEAD | RETIRED → ARCHIVED`. `ACTIVE → DEAD` can happen at any simulation tick. `VICTORY_ACTIVE → DEAD` retains the prior victory outcome in chronicle; `VICTORY_ACTIVE → RETIRED` retires as victor. No `DEAD → ACTIVE` transition through normal UI. A manually copied device data file can be modified; the game enforces ordinary ironman behavior, **not tamper-proof anti-cheat**.

**Autosave strategy:** Snapshot on region exit/entry, after character creation, major quest/transformations, on Android pause/background where safe, and at bounded stable action checkpoints. If saving during an action resolution would create half-transactions, queue save until action completes. Use a versioned checkpoint plus delta journal, write to temporary file, validate length/checksum and replace committed save using an OS-appropriate atomic-ish rename with backup; test actual FileAccess/DirAccess semantics on the chosen stable Godot version and Android. Quarantine corrupt files rather than deleting them immediately. A save commit must include RNG state and turn sequence. On resume, replay only committed journal events and reject duplicate actions.

**Death integrity:** When an actor is lethally resolved, synchronously persist a `DEAD` tombstone/outcome in a dedicated status record before exposing death animation/Restart. `ACTIVE` save loading checks tombstone/status first and refuses to resurrect dead runs. Archive summarization is idempotent and can be retried after process kill; active world/snapshots/deltas are then purged after confirmed chronicle record. If a disk write fails at death, prevent resuming as alive, show recovery prompt on next start using highest committed status; test interrupted death writes and avoid false promises of perfect crash-proof permanence.

**Cancellation:** Generation can cancel before commit; once active run is created, New Run requires warning and archive as `abandoned`, clearly distinct from an in-game death. No user-exposed save-slot reload, manual rewind, “restore last checkpoint after death,” or server-sync loophole. User may separately export chronicle/settings/build presets; exporting active run as a restorable bundle is out of scope to preserve ironman integrity.

**Migrations:** schema upgrade is one-way on a copy; validate migration on a representative fixture from each earlier release; keep last good backup until successful load and stable checkpoint. If content removed/replaced, use explicit ID aliases/remap rules or present safe non-destructive error. Never load an incompatible format by silently dropping unknown quest/world links.

## 13.4 Example normalized content shape (informative, not final Godot resource file syntax)

```json
{
  "schema_version": 1,
  "species_id": "species.draconian",
  "body_plan_id": "body.draconic_humanoid",
  "metabolism_id": "metabolism.omnivore",
  "lineage_ids": ["lineage.draconian.ember", "lineage.draconian.frost", "lineage.draconian.storm", "lineage.draconian.venom"],
  "innate_ability_ids": ["ability.claws", "ability.breath_basic"],
  "slot_capabilities": ["grip.two", "torso.draconic", "tail.armor", "head.horned"],
  "tags": ["living", "draconic", "scaled"]
}
```

Canonical definitions are validated through import/build scripts; game rules never string-parse ability descriptions to execute effects. All content IDs are referenced consistently across definitions, save migrations, event rules and UI tooltips.

---

# 14. Technical architecture: a small deterministic engine inside Godot

## 14.1 Stack and reasons

| Layer | Selected choice | Why | Alternative intentionally not selected |
|---|---|---|---|
| Game framework | Godot 4.7.2 stable (pin patch until tested) | 2D scenes, Android export, open source, GDScript iteration | Unity/C# (heavier project), bespoke engine (too much framework work) |
| Language | Typed GDScript | Fast AI iteration, easy Godot integration, fewer Android C# edge cases | C# initially unnecessary; revisit only with measured bottleneck |
| Renderer | Compatibility 2D first | broad Android support and simple effects | Mobile/Vulkan only if a proven effect/performance need and device evidence |
| Build/export | Godot editor + Android SDK + JDK as specified by pinned version's stable docs | On-device APK early and often | Web wrapper or native Compose as gameplay renderer |
| Persistence | Local versioned snapshots + journals + region deltas under `user://` | no server, reliable resume and testable migrations | SQL server, account database, cloud save |
| Config/content | Typed Resources or validated JSON definitions for authored data, stable IDs | edit/extend/test content without branching code for every species | Runtime-generated code, unvalidated free-form AI text |
| Developer workflow | Git repository + small CI/headless tests + install/test on real Android phone | AI agent review, deterministic debug and regression checks | one-shot generation of entire game |

**Version verification, 2026-10-17:** Official Godot archive lists **4.7.2 stable (2026-08-18)**, whereas 4.8 is in beta; pin 4.7.2 for initial implementation, re-evaluate after a proven reason to migrate. Godot recommends JDK 17 and its Android export documentation supplies corresponding SDK setup. Latest documentation may describe unreleased features—use stable/release-pinned docs. Renderer documentation recommends Compatibility as a good 2D option. Source links appear in §23.

## 14.2 Runtime boundaries

```
Android touch / keyboard / gamepad
        ↓
Input Adapter → Command Queue / Validator
        ↓
Simulation Session (single writer)
        ├── TurnScheduler / ActorResolver
        ├── Combat + Effects + Statuses
        ├── WorldGraph / RegionManager / Terrain
        ├── AI / Events / Faction and Quest Rules
        ├── Skills / Talents / Items / Companion Rules
        └── Dedicated RNG stream manager
        ↓                             ↘
Domain Events / Read-only views       Checkpoint Writer → user://
        ↓
World Renderer (tiles/entities/effects) + HUD/state panels
```

**Core rule:** Scene nodes contain presentation and inputs; the simulation owns logical cells, entities, inventory, HP, turns and RNG. `ActorSprite` cannot directly damage another actor; its controller emits `AttackCommand` and reacts to returned `DamageEvent`. World generation is a pure/seeded pipeline as far as practical. The simulation's read model can be converted into view-friendly DTOs without exposing mutable entity references to UI.

**Bounded scheduler:** resolve player action → immediate reactions → initiative/energy-eligible actor turns → scheduled world/local events → victory/death check → checkpoint flag. Do not use Godot `_process(delta)` to increment turn-based world state. Time-of-day advances from committed simulation actions with actor/action costs. UI tweens use rendering time independently.

**Randomness:** RNG streams by `worldgen`, `combat`, `loot`, `events`, `NPC`, optionally per region/actor; save stream states. Presentation randomness (particles) uses a separate untracked visual source, never affects simulation. A seed should reproduce geography and initial placements; reproducing an entire run additionally requires the same action list and content revision.

**World generation threads/tasks:** avoid loading/generating whole world in one frame. Generate metadata first; schedule local region generation asynchronously only if thread-safe under Godot API restrictions, otherwise split into frame-budgeted pure data jobs and apply TileMap changes on main thread. Do not access scene-tree nodes from unsafely running worker threads. Cancellation guards protect generation from leaving partial persistent state.

**Tiles and actors:** tile state in compact arrays or dictionaries by chunk/region, rendered through `TileMapLayer` nodes for terrain/decor/hazards; one scene per visible actor/visual effect only. Pool frequently spawned visual effects. Avoid creating scene objects for every unvisited tile, NPC, or item; use pooled representations in active viewport.

## 14.3 Module responsibilities (start small)

- `game_session/`: RunState, command queue, domain events, turn scheduler, RNG registry.
- `combat/`: attacks, effects, AI, hazards, statuses and targeting validation.
- `world/`: macro generator, region generation, topology/pathfinding, fog, terrain delta persistence.
- `characters/`: species/body plans, traits, training/talents/evolution and companions.
- `content/`: versioned definition files and validators, not a directory full of one-off god scripts.
- `quests/`: event rule predicates, quest graph evaluator, faction/faith updates.
- `items/`: generated item instances, inventory rules, crafting and loot tables.
- `save/`: checkpoint, journal, migration, chronicle and status tombstone.
- `ui/`: HUD, character creator, modal screens, accessibility and input adapter.
- `visual/`: tile layers, actor sprite adapters, particles and audio/haptics integration.
- `tests/`: command fixture tests, seed sweeps, save roundtrips, headless scene boots.

Do not create 50 empty managers on day one. Add a module when its packet introduces actual functionality; shared contracts can begin as a small set of typed data classes. Prefer composition of effect/requirement primitives to deep inheritance trees.

## 14.4 Android lifecycle and native boundary

Android export in the first packet, including real APK installation and a repeatable build command. Handle pause/resume, process kill, screen rotation lock to portrait, app lost focus, safe area/cutouts, back navigation, input method changes and device storage failures. Minimum supported Android version should follow chosen Godot exporter requirements, tested on a real device, not guessed from an Android app-template tutorial. Prefer gamepad/physical keyboard support where convenient; no extra native plugin until needed.

Permissions: **none beyond standard local app access** for core gameplay; no account, camera, microphone, contacts, precise location, analytics or network access needed. Game files stay in app-local `user://`. Optional share/export via system picker can be introduced later with a minimal scoped platform adapter; not needed at P0. Release keystore never committed. Compile/render effects for Compatibility; if a proposed shader doesn't work, supply a low-cost sprite animation fallback.

## 14.5 Reference initial repository layout

```text
project.godot
README.md
LICENSES_AND_ASSETS.md
CHANGELOG.md
docs/
  plans/Hollowfold_Master_Blueprint_v1.md
  decisions.md
  progress.md
  content-bible.md
  test-seeds.md
assets/
  art/            # documented provenance, approved sprites only
  audio/
scenes/
  boot.tscn
  gameplay.tscn
  ui/
scripts/
  game_session/
  world/
  combat/
  characters/
  items/
  save/
  ui/
content/
  species/
  backgrounds/
  skills/
  abilities/
  world/
tests/
  headless/
  fixtures/
```

This is an **initial orientation**, not a demand to scaffold every empty subdirectory. Keep test source and gameplay content separate from runtime save data. Store generated debug seeds and test artifacts outside the shipped APK.

---

# 15. Failure model, privacy, offline rules and edge cases

## 15.1 Principles

All gameplay functions fully offline. User-generated state never leaves the device unless intentionally shared as a text chronicle by the user. No API keys, model subscriptions, authentication, advertisements, telemetry, or remote AI roleplay/chat. Files with game content or downloaded assets are untrusted until license/structure validated; definitions are read-only at runtime. Debug logs exclude personal identifiers; logs can include world seed and action trace **only after the user enables developer diagnostics**.

## 15.2 Edge-case matrix

| Situation | Required observable behavior |
|---|---|
| First install / no save | New Run primary; Continue absent; no empty-run crash. |
| New run with old run active | Warn precisely that old active character/world will be abandoned permanently; Cancel retains old run. |
| Impossible trait combination | Inline reason, selected choices preserved; cannot confirm invalid character. |
| Species can't wield background weapon | Preview legal alternative ability/item and warnings; never spawn unarmed without intended compensation. |
| A required quest site placed in unreachable terrain | Generator repair or seed retry before world commitment; no unfixable world. |
| NPC quest giver dies | Spawn/use legal successor clue, update branch or explicitly fail optional quest; main route stays solvable. |
| Player mines a tile behind a companion | Recompute passability/route, notify ally if stranded; valid exit preserved. |
| Transform removes equipment slot | Preview incompatibility, store gear in carry/ground safe container, undo only through defined reversal. |
| AI turn produces cascading terrain reactions | Finite effect queue; cap per-action chain and log truncation if a content bug appears. |
| Multiple touches / action spamming | At most one active command in queue until result, no duplicate pickup/equip/attack. |
| Android suspends/kills app mid-play | Load last committed consistent run state; warn if last uncommitted cosmetic action lost. |
| App killed just after fatal blow | Tombstone/status blocks revival; chronicle archiving resumes safely. |
| Save data corrupt / storage full | Show diagnostic/recovery menu; use valid backup if available; never silently reset active world; warn user. |
| Game update changes definition ID | Apply migration alias, test, or stop with recoverable incompatible-version message; never silently lose items. |
| Renderer can't support VFX | Display functional nonshader fallback and retain targeting outline. |
| Low memory / huge visited world | Evict distant scene/cache representations; retained saved deltas rehydrate, no lost world state. |
| User zooms text or uses gesture navigation | HUD and modals adapt; touch controls remain reachable; no overlap with camera hole/system bar. |
| Unknown legendary item and full inventory | Item remains in world; clear full inventory indicator and safe drop/compare option. |
| Companion lost across regions | Persist companion state and route/call-back; never duplicate follower on reload. |
| Post-win character dies | Victory recorded once, subsequent death recorded as post-win outcome, not retroactive loss of victory. |

---

# 16. Content design, balancing and QA instrumentation

## 16.1 Content constraints for AI-generated work

Each species/lineage/background/talent/spell/item/quest includes a compact spec: ID, gameplay identity, source of power, activation, constraints, interactions, counterplay, consequences, asset dependencies, test fixture, and compatibility tags. **Never generate 100+ items in one agent pass** without validators and representative in-game testing. Batch content by one family and run registry, duplicate-ID, orphan-reference, illegal-synergy and player-build smoke checks after each batch.

**Encounter budget:** scale by region tier and player opportunity rather than raw level alone. A lethal threat may exist early but should be telegraphed and escapable. No mandatory XP grinding loop; win paths should reward clever exploration and tactical play. Distinct builds should differ in *solutions*, not just damage output. Use controlled comparison runs to detect overpowered infinite summoning, permanent immunity loops, free healing/resource generation, trap farm XP, or invincible builds from equipment/body interactions.

## 16.2 Seed fixture corpus

Maintain permanent test seeds for: ordinary start, edge coast, mountain bottleneck, gate on island, severe biome conflict, all factions hostile, quest NPC death, near-full inventory, rare dungeon branch, high mutation load, large visited map, post-victory death, save migration. Extend with failure-seed regression fixtures, preserving exact content revision. On generated-world validation, test a bounded sample of seeds for route connectivity and objective placements; scale the corpus before content beta rather than assuming a single showcase seed proves correctness.

## 16.3 Minimum automated test taxonomy

- `T-CORE`: commands, deterministic scheduler, collision, LOS, damage and effect chains.
- `T-GEN`: world topology, region transitions, portal pairs, dungeon exits, critical route solvability, spawn safety.
- `T-BUILD`: all species × backgrounds legal, traits compatible, slot fit, specialization eligibility, no free powers.
- `T-SAVE`: roundtrip/checksum/migration/death/tombstone/interrupted and partial write cases.
- `T-QUEST`: graph integrity, alternative resolutions, NPC death fallback, reputation propagation.
- `T-AI`: active/offscreen actor turns, pathfinding, summon caps, friendly-fire restrictions.
- `T-UI`: main menu, creator, HUD tap/target, insets, modal pause, inventory, resume/death and screen reader labels where technically supported.
- `T-PERF`: render profiling, generation spikes, save write stalls, memory during region churn, active actor caps on device.
- `T-ASSET`: sprite atlas references, provenance manifest, visible high contrast, missing frame fallback.

Verification **must include physical-device manual tests**: APK install, first boot, uninterrupted 15-minute play, background kill/resume, fatal turn / relaunch, touch reach, zoom, effects and large-font mode. CI/headless tests support but do not replace those checks.

---
# 17. Implementation roadmap — incremental Android vertical slices

**Core operating rule:** Run only one packet at a time. The AI agent must inspect repository reality, make a short plan, edit only this packet, run actual checks and manual evidence, then commit after review. An incomplete packet is not a reason to start another. Every packet preserves successful earlier smoke tests. Implementation packets may be split further if an agent encounters a genuinely large diff; preserve the parent `I-ID` and add subparts such as `I-012a` without renumbering.

## Stage A — playable APK foundation

### I-001 — Fresh Godot project, Android build and visible boot (F-020, F-022, F-023; S-001)
- **Depends:** none. **Outcome:** brand-new version-controlled Godot 4.7.2 project boots to a functional titled menu on desktop and an installed portrait Android APK; New Run opens a placeholder playable launch panel and can return.
- **Work:** pin Godot version, empty-game entry scene and state, orientation/insets, Compatibility renderer, basic input paths, basic CI/headless launch test, Android export templates/SDK guidance, debug build documentation, Git ignore/export secret rules, skeleton change/progress logs. Add only minimal folders actually used.
- **Non-goals:** world generation, combat, full art, 24-species data.
- **AC-I001:** on Android device the signed debug APK installs, opens in portrait, shows New Run/Settings, enters and exits the placeholder without an exception; a documented command runs a headless project scene smoke check; repository is clean after commit and no signing secret tracked.
- **Verification:** Godot headless import/editor scene check, export to APK and `adb install`/launch, real-device screenshot for insets; report failures rather than claiming impossible checks passed.

### I-002 — One explorable deterministic region (F-006; S-004)
- **Depends:** I-001. **Outcome:** avatar walks around a visible generated region with walls, ground, water, entrance and blocked cells.
- **Work:** first seeded rectangular local map, pure terrain grid, coordinate transforms, tile layer renderer, actor display, camera, collision; regenerate same seed from debug control.
- **Non-goals:** combat/continent/history/streaming.
- **AC-I002:** repeated seed outputs same terrain passability and spawn; walking into solid rock does not change logical position; player cannot spawn inside wall; game still launches on phone.
- **Verification:** map hash fixture, blocked movement tests, 5-minute manual walkthrough.

### I-003 — Deterministic action and turn engine (F-004; S-004, S-005)
- **Depends:** I-002. **Outcome:** legal Move/Wait/Inspect commands advance game turns predictably, log results, and separate render from rules.
- **Work:** command types, validation outcome codes, single-writer state, turn scheduler, RNG streams, event dispatch, line-of-sight/fog basics, test harness replay.
- **Non-goals:** complex AI/faction/physics simulation.
- **AC-I003:** same seed + command list produces identical final world state hash; invalid blocked action consumes no turn; no duplicate action on fast repeated tap; inspected details don't advance turn.
- **Verification:** T-CORE seeded replay/invalid-command and Android input stress.

### I-004 — Tactical combat slice (F-005, F-016; S-004, S-005)
- **Depends:** I-003. **Outcome:** fight a small monster, take/give damage, receive warnings, die from lethal action.
- **Work:** attack/defense/resistances, action-cost rules, two AI behaviors (pursue/retreat), HP/stamina, status effect interface, combat log, simple hit feedback, deterministic death event.
- **Non-goals:** full bestiary/magic/animation catalog.
- **AC-I004:** an enemy outside LOS doesn't react as if seeing player; lethal HP yields death event exactly once; same action fixture gives same damage; ranged target behind wall is rejected.
- **Verification:** combat/range/AI fixture, physical attack input and feedback review.

### I-005 — Portrait combat controls, basic loot and HUD (F-010, F-020, F-022; S-004, S-005, S-007)
- **Depends:** I-004. **Outcome:** thumb-friendly tactical movement, inspect/target/attack, basic item pickup/equip/use in real APK.
- **Work:** status ribbon, touch movement pad, optional tap-to-cell, hotbar, bottom inspect sheet, inventory panel, item definitions and item instances, hit/loot VFX, pause overlay.
- **Non-goals:** elaborate affixes, crafting, all equipment anatomies.
- **AC-I005:** player can inspect and pick up item and equip compatible gear; incompatible gear stays safe; target selection/attack produces one command, stops for newly visible danger; all critical actions have visible button alternatives to gestures.
- **Verification:** T-UI button/overlap checks; real phone one-handed 15-minute exploratory test.

### I-006 — Real new run, save/resume and permadeath (F-001, F-019; S-001, S-002, S-016)
- **Depends:** I-005. **Outcome:** choose from two starter species/2 backgrounds, start a seed, quit/resume and permanently lose character/world on death.
- **Work:** minimal starter options, RunState and IDs, checkpoint/delta serialization, autosave policy, Android lifecycle events, checksum/backups, permanent-death tombstone and small Chronicle summary, New Run guard.
- **Non-goals:** complete character creator, deep trait/lineage content.
- **AC-I006:** kill app after committed action and Continue restores identical location/HP/inventory/RNG; fatal blow prevents Continue even after forced close; Chronicle shows one death record, not two; old run can be abandoned only after confirmation.
- **Verification:** T-SAVE forced process-kill before/after lethal step, bad/corrupt file test, device resume.

### I-007 — First short complete roguelike run (F-007, F-014, F-016; S-004, S-016)
- **Depends:** I-006. **Outcome:** explore a small hand-guided/generated dungeon, defeat or outmaneuver a boss, secure a quest item and win; death still ends run.
- **Work:** level transitions, simple boss behaviors, single quest graph, victory detector, basic world seed validation for this small route, winning Chronicle result.
- **Non-goals:** continent-scale generator, faction politics, multiple realms.
- **AC-I007:** same APK can complete a full victory in a playable test session; a blocked route is rejected before seed commitment; winning opens summary; death before win prevents completion; Chronicle correctly differentiates results.
- **Verification:** scripted victory and death paths on seed fixture, real-device complete playthrough.

> **Gate A — FIRST PLAYABLE APK:** Stop adding scope until I-001–I-007 pass on-device and the build feels responsive. This is the earliest rational moment for honest gameplay feedback and combat tuning.

## Stage B — systems-first vertical slice

### I-008 — Macro-world, regions, realm links and generated dungeons (F-006, F-007; S-004, S-006)
- **Depends:** I-007. **Outcome:** travel among neighboring seeded regions using a discovered world map; two realm links and two dungeon styles.
- **Work:** macro terrain/settlement planning skeleton, deterministic region IDs/borders, fog, travel graph, portal pairs, dungeon template graph, generator validator and region deltas.
- **Non-goals:** deep authored histories and functioning economy.
- **AC-I008:** exit east of region A enters correct west edge of B; return shows mined/looted changes; paired portal returns or warns of one-way design; 100 representative seeds (initial target) have reachable critical quest endpoints.
- **Verification:** T-GEN automated seed corpus + device map travel.

### I-009 — Real character creation and custom backgrounds (F-001, F-003; S-002, S-003)
- **Depends:** I-006, I-008. **Outcome:** polished portrait creator with preview, attribute allocation, trait summary and handcrafted-vs-custom selection.
- **Work:** component state, multi-step back/forward, filter/compare, equipment adaptation API, standardized starting-resource budget, saved build presets.
- **Non-goals:** full roster/content, elaborate lineage evolution.
- **AC-I009:** back/forward preserves selections; custom creator's budget matches preset baseline; invalid build explains and blocks; a chosen valid seed begins a playable run; active-run replacement warns.
- **Verification:** T-BUILD initial creator combinations, T-UI input persistence and error states.

### I-010 — Body plans, first four species, eight backgrounds, training (F-002, F-003, F-008; S-002, S-008, S-009)
- **Depends:** I-009. **Outcome:** biologically different player bodies, correct adapted starting kits, priority training, skill progress display.
- **Work:** Human, Draconian, Myconid, Runic Construct representative implementations, 8 backgrounds selected to cover body/role extremes, species lineages basic rank, anatomy slot rules, XP distribution and skill aptitudes.
- **Non-goals:** all lineages, talents, transformations.
- **AC-I010:** all 4×8 combinations spawn legally; Myconid/Construct sustain differs from Human; Draconian tail constraints are visible; training focus changes XP distribution deterministically; no empty unusable starter.
- **Verification:** T-BUILD matrix 32 combinations, T-CORE XP fixture.

### I-011 — Enemy AI, status effects and environmental reactions (F-005, F-016; S-004, S-005)
- **Depends:** I-010. **Outcome:** meaningfully different tactical encounters and two visible elemental reactions.
- **Work:** AI roles, hazard tiles, resistances, shock-water and fire-gas, bounded reactions, combat inspection, creature-compatible variant modifiers.
- **Non-goals:** ecology sim, huge monsters.
- **AC-I011:** water conductivity respects adjacency and finite chain limit; gas explosion consumes gas and damages legal actors; enemies display appropriate warning and avoid simple blocked routes; identical seed/commands produce same outcomes.
- **Verification:** T-CORE hazard-chain, AI pursuit fixtures; touch preview manual review.

### I-012 — Spells, talent graph and two specialization slots (F-008, F-009; S-010, S-011)
- **Depends:** I-010, I-011. **Outcome:** learn/gate/cast a small multi-school spell set, choose talents and combine primary+secondary specialization.
- **Work:** effect primitives, spell action pipeline, learn/prerequisite graph, talent point earning, hybrid talent example, slot exclusivity, preview/confirm.
- **Non-goals:** the full 80+ spell goal or all 12 advanced trees.
- **AC-I012:** locked talent states exact unmet requirement; one hybrid talent correctly checks two skills; secondary cannot use primary pinnacle; spell resource/cell validation and turn costs consistent; no recursive infinite effects.
- **Verification:** T-CORE effect/prereq fixtures, T-BUILD spec slot matrix, Android combat UI.

### I-013 — Procedural loot, artifacts and equipment fit (F-010; S-007)
- **Depends:** I-010, I-012. **Outcome:** find varied gear with legal magical properties; one named artifact changes a playstyle.
- **Work:** type/slot/tag-affix system, seeded loot, uniqueness registry, comparison, equipment fit and form-change bundle handling.
- **Non-goals:** complex crafting.
- **AC-I013:** unique artifact cannot duplicate in a run; illegal item/affix tags rejected; incompatible gear preserved on unequip/body change; reload reproduces exact rolled item instances.
- **Verification:** T-BUILD item combinations, T-SAVE item roundtrip.

### I-014 — Mining, harvesting and crafting (F-011; S-004, S-014)
- **Depends:** I-008, I-013. **Outcome:** mine flagged ore, uncover hidden chamber, gather reagents, craft useful tool or potion.
- **Work:** editable tile tags, harvesting nodes, recipe validator, inventory transaction, one simple station, hidden chamber logic.
- **Non-goals:** free-form base building, complex economy.
- **AC-I014:** mined tile remains changed after leaving/reloading region; craft with missing reagent refuses without loss; one recipe consumes ingredients exactly once; critical dungeon exit can't be destroyed.
- **Verification:** T-GEN modified-region roundtrip, T-CORE recipe atomicity.

### I-015 — Broader dungeon types, survival and camp (F-007, F-015; S-004, S-014)
- **Depends:** I-014. **Outcome:** small lair, ruined mine and layered dungeon, with hunger/essence/rest/weather distinctions.
- **Work:** tiered dungeon archetypes, danger warnings, camp interruption, species sustenance and survival status effects.
- **Non-goals:** all realms or advanced deity mechanics.
- **AC-I015:** alternative species sustenance operates without standard hunger item; camp interrupts on threat; dungeon generated exits remain reachable even if optional diggable walls mined.
- **Verification:** T-GEN dungeon fixtures, T-CORE camp/sustenance, real-device pacing review.

> **Gate B — SYSTEMIC ALPHA:** Combat, four distinct species, eight backgrounds, spells, limited specializations, loot, crafting, multiple regions, survival, save and death must work together in a real Android build before adding a simulated society.

## Stage C — lived-in world and complete procedural story

### I-016 — Settlements, NPC behavior and merchant services (F-012; S-012)
- **Depends:** I-008, I-015. **Outcome:** enter village, inspect named NPC schedules, buy an item, find local rumor.
- **Work:** roles/schedules, regional persistence, simple dialogue tree, shop stock/prices, NPC memory and fixed role slots.
- **Non-goals:** global economy simulator.
- **AC-I016:** the named merchant keeps trade state after region travel/resume; a sleeping NPC changes available dialogue/action; purchase updates currency/inventory atomically; offscreen NPC never duplicates.
- **Verification:** T-QUEST dialogue, T-SAVE NPC state, device trade path.

### I-017 — Factions, gods and world event deltas (F-013; S-012, S-013)
- **Depends:** I-016. **Outcome:** worship alters abilities, faction reputation affects trading/dialogue, caravan/event shifts local state.
- **Work:** two distinct gods, three faction templates, witness/incident propagation, remote-region event summaries and UI feedback.
- **Non-goals:** autonomous wars or hundreds of gods.
- **AC-I017:** witnessed action changes appropriate faction stance and shop behavior; unwitnessed private act doesn't broadcast without defined supernatural rule; breaking a vow triggers documented piety consequence; remote event cannot erase required main route.
- **Verification:** T-QUEST reputation event fixtures, T-GEN remote event invariants.

### I-018 — Layered history, authored/procedural quests, alternate victory routes (F-014, F-024; S-006, S-012, S-013, S-016)
- **Depends:** I-016, I-017. **Outcome:** one branching authored main quest, procedural side quests bound to actual world, two viable victory strategies and continue/retire after victory.
- **Work:** bounded history event tags, quest template role binding, node graphs and fallbacks, alternate win prerequisites and post-win state.
- **Non-goals:** endless narrative generation or LLM calls.
- **AC-I018:** two seeded legal paths to main objective; a missing/dead optional quest NPC resolves via documented fallback; victory status persists when continuing; post-victory death retains victory history; generated dialogue names refer to existing entities.
- **Verification:** T-QUEST branch graph sweeps, T-GEN route checks, full victory device playthroughs.

### I-019 — Companion AI and expanded bestiary (F-016, F-017; S-004, S-015)
- **Depends:** I-011, I-016, I-018. **Outcome:** tame beast, recruit NPC, summon minion, direct follower, fight boss/variants.
- **Work:** party owner/order API, summon lifecycle/caps, intelligent hazard avoidance, creature loot, several biome ecology tags, unique boss template and variant selection.
- **Non-goals:** full party RPG, population simulation, infinite army.
- **AC-I019:** active slot caps obey rules; companion persists across region/save with same ID; held ally doesn't follow; summons expire cleanly; NPC death remains dead; boss variant legal and bounded.
- **Verification:** T-AI follower/path/slot tests, T-SAVE follower transition, real encounter review.

> **Gate C — STORY ALPHA:** From a new seed, the player can make a customized character, find a village, pursue multiple objectives, grow in skills, acquire allies, descend into a dungeon, and win or permanently die. This is the real content-scaling starting point.

## Stage D — full content / presentation / reliability

### I-020 — Species/background roster and evolutions (F-002, F-003, F-018; S-002, S-008, S-010)
- **Depends:** I-010, I-012, I-013, I-018. **Outcome:** deliver all 24 species, all 36 backgrounds, lineages/branching evolutions, legal rare transformations and trait compatibility in manageable subbatches.
- **Work:** staged content definition batches, new effects only when required, body plan alternatives, special evolution locations/clues, reversal rituals with previews; retain seed regression fixtures.
- **Non-goals:** implement entire roster in one prompt/commit.
- **AC-I020:** validator confirms every 24×36 combination initializes and is controllable; every lineage has distinct branch previews; a rare transformation cannot trigger without discovery/consent; reversible paths apply cost and preserve incompatible gear; documented sample path exists for each species to win under controlled test fixture.
- **Verification:** T-BUILD exhaustive combination matrix, seeded species smoke, T-SAVE form migration.

### I-021 — Save resilience, chronicle, compendium, migrations (F-019, F-021; S-016, S-018)
- **Depends:** I-018, I-020. **Outcome:** durable ironman runs under larger world state, meaningful run history and discovered bestiary/lore.
- **Work:** save schema migration fixtures, backup/corruption flows, compendium discovery, chronicle exports, large-region-diff profiling.
- **Non-goals:** cloud backups that restore dead runs.
- **AC-I021:** valid previous-version fixtures migrate without losing quest/unique-item links; interrupted checkpoint loads last known safe state; deceased run not resumed; compendium hides undiscovered entries; large save remains playable on phone.
- **Verification:** T-SAVE full suite, forced Android kill tests, migration report.

### I-022 — UI/UX polish, VFX, accessibility and audio (F-020, F-022; S-001–S-018)
- **Depends:** I-019, I-020. **Outcome:** cohesive Caves-quality presentation goal; responsive combat and complete portrait flow.
- **Work:** original consistent sprites, animation sets, effect system, theme/surfaces, audio/haptic cues, threat markers, scaling, screen reader/alternative control checks and accessibility settings.
- **Non-goals:** animated every unique item in one pass; screen-specific custom render engines.
- **AC-I022:** key pathways are usable with reduced motion and haptics off; critical taps never rely on long press only; menu/hud preserve state under Android interruption; particle-heavy encounters can disable advanced effects without losing warning information.
- **Verification:** T-UI manual matrix, device capture, contrast/readability review, T-PERF scene stress.

### I-023 — Seed, balance and stability audit harness (F-021, F-023; S-017)
- **Depends:** I-020–I-022. **Outcome:** repeatable test suite detecting world-breakers, bad build combinations, giant-memory regions and save regressions.
- **Work:** automated seed sweep, generated item/legal talent validation, sanity bot pathing, replay logs, performance reports, failure-seed fixture database and integrity review.
- **Non-goals:** claiming perfect balance from synthetic tests.
- **AC-I023:** CI runs deterministic replay, data integrity, core seed sweep, save/death tests; each failure logs seed, revision, command list and reproducible step; Android benchmark report names hardware and actual measured timings.
- **Verification:** full automated suite + real-device longer play session.

### I-024 — Final personal release packaging and maintenance (F-022, F-023; S-001, S-017)
- **Depends:** I-023. **Outcome:** signed personal-use Android release APK and documented update/migration workflow.
- **Work:** export/release signing secrets, icon, permissions audit, credits/license manifest, README, regression checklist, versioning and release notes, tested install/update from earlier build.
- **Non-goals:** Play Store marketing, microtransactions, online accounts, automatic updater.
- **AC-I024:** release APK installs/launches on tested device; offline gameplay works in airplane mode; upgrade from prior APK preserves valid active runs under documented migration policy; no development signing keys in repo; licenses and asset provenance traceable.
- **Verification:** real APK install/upgrade, permission inspection, offline game smoke, full regression checklist.

---
# 18. Additional authored content specifications and expansion rules

## 18.1 Biome catalog (game-wide design targets)

| Biome | Signature terrain/resources | Encounters and discovery hook |
|---|---|---|
| Temperate wildwood | wood, herbs, thickets, streams | roaming hunters, standing stones, druid paths |
| Mossfen marsh | mud, water, spores, reeds | fungal nests, sunken shrines, toxic currents |
| Arid glass dunes | sand, glass, rare crystals, heat | burrowing predators, collapsed observatories |
| Frostbound highlands | snow, ice, ancient stone | frost beasts, buried watchtowers, unstable lakes |
| Ashen volcanic slope | lava, sulfur, ember ore | fire creatures, ancient foundries, magma veins |
| Verdant overgrowth | giant roots, vines, luminous fruit | mobile plants, living ruins, changing shortcuts |
| Shadow moor | black reeds, spectral fog | revenant patrols, abandoned pilgrimage roads |
| Crystal barrens | resonant clusters, brittle bridges | shard entities, echo traps, secret resonators |
| Limestone deep caverns | ore, stalagmites, groundwater | trolls, subterranean settlements, hidden mines |
| Ancient fungal underhalls | mycelium, spores, decomposition | symbiotic cities, hive networks, parasite vaults |
| Stormward coast | cliffs, salt spray, storm pools | lightning predators, shipwreck artifacts |
| Astral fissurelands | rift nodes, levitating rubble | void creatures, fractured gates, phase hazards |

Each biome defines `terrain_palette`, walkability/hazard categories, associated creature pools, resource matrix, settlement viability, visual/audio identity, potential world history events and first-visit landmark hints. Biomes are not merely palette swaps: at least one gameplay rule and one exploration opportunity must distinguish each.

## 18.2 Foundational pantheon: twelve distinct gods (content targets)

| Deity (working name) | Worship identity / offered power | Concrete restriction / wrath |
|---|---|---|
| **Auralis, Keeper of Dawn** | radiant barriers, purification and mercy | condemns cruelty toward surrendered innocents; loss of favor/temporary blessing lock |
| **Varkh, Iron Covenant** | durability, smithing and defensive oaths | punishes oathbreaking and betrayal of pledged allies |
| **Nyss, the Veiled Road** | stealth, secrets and passage between shadows | dislikes revealing entrusted secrets without cause |
| **Morwen, Last Lantern** | spirit guidance, burial rites and measured death | forbids desecration of protected graves; spirit hostility |
| **Thornmother Ilyra** | beasts, roots, regeneration and ecological reciprocity | punishes wanton destruction of sacred groves |
| **Zhur, the Ember Maw** | fire and sacrifice for temporary surges | demands significant offerings; wrath amplifies heat hazards |
| **Orun of the Scales** | justice, contracts and trade | breaking a witnessed pact damages piety and commercial favor |
| **The Many-Eyed Tide** | water, adaptation, obscure knowledge | punishes destruction of protected depths |
| **Sathriel, Broken Star** | forbidden insight, prophecy and magic instability | dangerous bargains escalate rift anomalies |
| **The Hollow Choir** | silence, anti-magic and ascetic power | sustained overreliance on uncontrolled casting displeases it |
| **Gravemason Korr** | ruin reclamation, earth and ancestral workmanship | wastes valuable relics at piety cost |
| **The Laughing Chance** | risk, trickery and limited fate revisions | predictable repeated exploits diminish reward; risky vows grant boon |

**Pantheon contract:** Each god gets authored piety event predicates, 3–5 distinctive actions/passives eventually, clear vows, visible piety messages and finite wrath consequences. Worship may alter faction reputation but never delete sole victory access. Initial alpha tests only two, with more added as validated data batches. God-aligned rare relics and shrines are world history placements, not mandatory universal spawns.

## 18.3 Faction families

Kingdoms/city leagues, deep-mining guilds, druid circles, wandering traders, necromantic colleges, holy orders, infernal courts, monster tribes, fungal confederacies, astral scholars, bandit bands, secret cults. Each faction definition needs a *reason to exist*, a territorial preference, preferred goods, two relations to other factions, at least one NPC/service effect, and a quest consequence. Generated named factions are parameterized instances of these templates; procedural names should not erase their behavioral identity.

## 18.4 Representative side-quest templates

1. **Lost caravan:** investigate path → rescue merchants / bargain with raiders / seize cargo; shifts trade routes, reputation and prices.
2. **Mine below the shrine:** discover weak wall → uncover old faction battle site → restore mine / seal tomb / offer relic to god; changes resource access and dungeon inhabitants.
3. **Plague of glass:** investigate disease vs crystal curse → alchemy cure / remove resonance device / exploit plague; changes local mutation hazards.
4. **The silent apprentice:** track vanished novice → reveal hidden trainer/secret spell school → recruit, betray or protect; produces talent discovery and NPC consequence.
5. **False prophet:** collect witness clues → challenge, expose or ally with a cult leader; changes god favor and settlement order.
6. **Hunt the colossal shade:** find signs → negotiate with spirit / lure beast to ward / defeat boss; unique loot and regional ecology changes.

**Quest quality gate:** each template must bind actual generated participants, yield at least one meaningful choice beyond “yes/no” where premise warrants, and have valid objective text and failure recovery. Optional branching varies by content and role availability, not every side quest must branch three ways.

## 18.5 Example main-quest finale routes

- **Wardens' Route:** investigate ruins and craft stabilizing runes; close core gate after defending ritual under pressure.
- **Concord Diplomat Route:** secure alliances/knowledge from two rival factions and negotiate control of a major gate; combat still possible in travel but final win needn't require same boss.
- **Veil Route:** infiltrate an astral fortress, recover counterseal, reroute gate through secret passage; high stealth and technical risk.

All routes share a limited set of mandatory world facts, not identical boss kills. In P1, begin with one literal win path and one non-combat solution; fully differentiated finales wait for I-018. These three routes are authored design proposals, not a guarantee of exactly three completed campaigns.

---

# 19. Traceability matrix: feature → journey → screen → state → packet → acceptance → test

The **AC-Ixxx** checks are spelled out in §17. Use these IDs in implementation reports. This matrix intentionally points to **first implementation**, not the only later enhancement.

| Feature | Journey | Screen(s) | State / entity | First I packet | Gate / test |
|---|---|---|---|---|---|
| F-001 New runs | J-001 | S-001, S-002, S-003 | RunRecord, CharacterState | I-006 | AC-I006 / T-SAVE, T-UI |
| F-002 Species | J-001, J-003 | S-002, S-008 | BodyPlan, LineageState | I-010 | AC-I010 and AC-I020 / T-BUILD |
| F-003 Backgrounds | J-001 | S-002 | background definitions, presets | I-009 | AC-I009 and AC-I020 / T-BUILD |
| F-004 Turns | J-002, J-003 | S-004, S-005 | action_index, scheduler, events | I-003 | AC-I003 / T-CORE |
| F-005 Combat | J-003 | S-004, S-005 | ActorState, statuses | I-004 | AC-I004, AC-I011 / T-CORE |
| F-006 World | J-002 | S-004, S-006 | WorldDescriptor, RegionState | I-002 | AC-I002, AC-I008 / T-GEN |
| F-007 Dungeons | J-002, J-006 | S-004, S-006 | dungeon topology | I-007 | AC-I007, AC-I015 / T-GEN |
| F-008 Progression | J-001, J-003 | S-008–S-010 | skill weights, talent IDs | I-010 | AC-I010, AC-I012 / T-BUILD |
| F-009 Magic | J-003 | S-005, S-011 | spells, effect events | I-012 | AC-I012 / T-CORE |
| F-010 Loot | J-003 | S-007 | ItemInstance, inventory | I-005 | AC-I005, AC-I013 / T-BUILD, T-SAVE |
| F-011 Craft/mining | J-002, J-003 | S-004, S-014 | region delta, recipes | I-014 | AC-I014 / T-CORE, T-GEN |
| F-012 NPCs | J-004 | S-012 | ActorState, settlement services | I-016 | AC-I016 / T-SAVE, T-QUEST |
| F-013 Factions/gods | J-004 | S-012, S-013 | FactionState, GodAllegiance | I-017 | AC-I017 / T-QUEST |
| F-014 Quests | J-004, J-006 | S-013, S-016 | QuestInstance, flags | I-007 | AC-I007, AC-I018 / T-QUEST, T-GEN |
| F-015 Survival | J-002 | S-004, S-014 | metabolism, conditions | I-015 | AC-I015 / T-CORE |
| F-016 Monsters | J-003 | S-004, S-005 | ActorState, AIProfile | I-004 | AC-I004, AC-I019 / T-AI |
| F-017 Companions | J-003, J-004 | S-015 | CompanionState | I-019 | AC-I019 / T-AI, T-SAVE |
| F-018 Evolutions | J-001, J-003 | S-008, S-010 | LineageState, mutations | I-020 | AC-I020 / T-BUILD |
| F-019 Save/death | J-005, J-006 | S-001, S-016 | RunRecord, ChronicleEntry | I-006 | AC-I006, AC-I021 / T-SAVE |
| F-020 Android UX | J-001–J-006 | S-001–S-017 | UIState, Settings | I-001 | AC-I001, AC-I022 / T-UI |
| F-021 Compendium | J-005, J-006 | S-016, S-018 | ChronicleEntry, discovery flags | I-021 | AC-I021 / T-SAVE, T-UI |
| F-022 Art/VFX | J-002, J-003 | S-004, S-005 | visual event queue | I-005 | AC-I005, AC-I022 / T-ASSET, T-PERF |
| F-023 QA | all | S-017 debug | seed/replay fixtures | I-001 | AC-I023 / full suite |
| F-024 Post-win | J-006 | S-016 | RunRecord.status | I-018 | AC-I018 / T-SAVE, T-QUEST |

---

# 20. AI-coding agent handoff and review protocol

## 20.1 Repository-wide rules for humans and coding agents

1. Read this blueprint and current `docs/progress.md`; inspect files and latest commits **before** editing.
2. Implement **one packet only**; call out any contradiction between actual repository, current user instruction and blueprint; never silently choose a different product scope.
3. Code small game-rule functions with typed inputs/outputs and a deterministic fixture. Keep rules independent of sprite animation and visual scene timing.
4. Add content only through validated definitions and stable IDs. Every new mechanic needs a failure test and a user-facing explanation/tooltip.
5. No “fully implemented” claims when only placeholder UI exists. Flag temp assets and incomplete mechanics explicitly.
6. Run actual import/headless smoke, focused tests, editor launch when relevant, Android export and on-device check when it changes Android behavior; record exact commands/results.
7. Maintain `docs/progress.md`: packet, acceptance rows, test evidence, known bugs, commit, next ready packet. Reviewer confirms changes before moving onward.
8. Preserve the authoritative file IDs and content schema IDs. If a later update changes locked mechanics, update decisions, affected features, screens, save schema and tests first.
9. No hidden Internet/API use at runtime. Keep keystores and private credentials out of Git. Keep precise asset licensing manifest.
10. On first repo setup and at each release gate, manually inspect portrait safe areas and control comfort on the actual phone—CI green doesn't prove mobile UX.

## 20.2 Customized first-packet kickoff prompt (copy exactly)

```text
You are the implementation agent for a new portrait Android 2D roguelike named Hollowfold.

Read docs/plans/Hollowfold_Master_Blueprint_v1.md in full, especially §§0–4, 10–15 and 17 (I-001), and inspect the current repository before editing any files. This is a brand-new project; if the repository already contains code, inventory it and report the smallest compatible plan first.

Implement I-001 ONLY: fresh Godot 4.7.2 stable project, Compatibility renderer, version-controlled setup, visible title menu (New Run / Settings), working placeholder New Run screen with Back, portrait orientation/inset-aware UI, headless scene smoke check, and a real debug Android APK export/install test when the machine/device permits. Never attempt species catalogs, dungeon generation, combat, save systems, or later roadmap packets yet.

Before editing, report:
1) existing files and Godot/Android SDK availability;
2) exact files you intend to add/change and why;
3) any contradiction or blocker;
4) commands and device actions you'll use to test.

Use Hollowfold as the Godot project name and visible app title. Derive a stable lowercase Android application ID from the actual GitHub repository owner (for example `io.github.OWNER.hollowfold`) and record the chosen ID in `docs/decisions.md`.

Architecture rules: typed GDScript where practical; no cloud/account/ads/Internet gameplay; use project-relative resources and simple scene structure; no unneeded managers; no template content unrelated to the packet; don't commit keystore secrets or binaries unless intentionally approved.

Implement and run the real tests you can. If Android export or physical-device testing cannot be performed, state UNVERIFIED rather than claiming it passed, and give the exact reproducible manual steps. Acceptance: the Godot project opens with no parse errors, main menu is functional, debug APK installs/boots in portrait on a test device when available, safe area is respected, and headless smoke check runs.

After work: show what changed, file paths, exact commands and pass/fail output, AC-I001 status item by item, screenshots or concise manual observations when possible, unresolved blockers and a final commit hash. Stop. DO NOT start I-002.
```

## 20.3 Review evidence rubric

For every packet, report:

```text
Packet: I-___
Changed files:
Built/ran: [command + result]
Automated tests: [name + result]
Physical device: [device/version + tested flows, or NOT TESTED]
AC-I___: [PASS | FAIL | UNVERIFIED] — evidence
Known issues / regressions:
Decisions or spec changes required:
Git commit:
Ready for review: Yes/No
```

Do not approve a packet with unverified **critical** acceptance criteria merely because no tests were attempted. Missing tools are a blocker to verify, not evidence of success. Plan fixes before unlocking subsequent packet.

---

# 21. Blueprint integrity audit — independent cold-reader pass

**Scope and requirement survival:** All accepted decisions are represented: 24 species; chosen lineages and hidden branches; 36 starting backgrounds; every combination legal; trait point-buy; focused skill XP; freely selected skill-gated talents; primary + secondary specialization; deep mobile tactical combat; magic/environment; heterogeneous equipment; digging/crafting; procedural world, settlements, history, realms, NPCs, factions/gods/quests; companion and monster variants; flexible run lengths and ironman death.

**Contradictions identified and repaired in this edition:**
- The earlier proposed 36-skill list included “Firearms” despite the overwhelmingly fantasy direction. The canonical 36-skill catalog uses **Crossbows**, while supernatural/technological curiosities may exist as rare items; this was not a user-locked individual skill.
- Earlier background prose contained training families like “Endurance,” “Athletics,” “Tracking,” or generic “Craft.” The authoritative skill table in §8 has **36 exact names**; those other words are thematic labels/derived attributes and map to the nearest real skills when authoring background data. Implement no phantom skill gauge.
- First playable release's tiny character roster and one dungeon do **not** negate the locked full-scale vision; they are staged implementation, not scope deletion.
- Permanent death and Android resume are not mutually exclusive: active-run resume is allowed, but lethal status tombstones prevent normal revive. A local user can tamper with app files; “ironman” is a game rule, not a security guarantee.
- A choice to continue exploring after a completed victory does not remove earned victory if a later death occurs.

**Remaining delegated assumptions (nonblocking for I-001):** graphical tile dimensions and animations, specific UI pixel/hex tokens, numerical skill/HP/damage equations, base content counts per release, game-time conversion, exact companion caps, pantheon and story names, whether to eventually support other devices, save file implementation details subject to pinned Godot API verification. No assumption should be treated as a user-locked preference merely because it appears in this plan.

**Deferred, deliberately not in first APK:** all 24 species, 36 backgrounds, multiplayer, unrestricted modular magic programming, full NPC economy/population simulation, reusable world after death, unrestricted player construction, paid AI conversation, permanent meta-power rewards and cloud accounts.

**Fresh-agent blind spots checked:** entry/exit and state ownership are specified; player command/turn model is separate from rendering; save/death edge cases are covered; initial Android device validation is required; quest/main-route seed invariants stated; content expansion uses definitions and validation; every F-ID maps to journey, screen, state, I-ID, acceptance and test.

**Risks requiring empirical proof:** Godot renderer/effect performance on specific Android GPU, UI readability in portrait at high density, generation cost as visited-map count grows, deterministic behavior after content migrations, AI-generated sprite consistency, balancing 864 opening combinations, and procedural quest failovers. These are explicitly verification tasks, not claimed solved.

**Audit result:** Ready to hand off **I-001**. Not a claim that full game is immediately implementable in one coding-agent session or that balance/art have been independently tested.

---

# 22. Glossary and feature-change procedure

- **Species:** fundamental physiology/anatomy and broad innate rules.
- **Lineage:** inherited subtype with authored abilities and selected progression branches.
- **Background:** unrestricted initial training/equipment/knowledge package; not permanent class.
- **Trait:** starting bought advantage/drawback with point/compatibility budget.
- **Mutation:** acquired change through gameplay; may affect anatomy, costs and species interactions.
- **Evolution:** lineage-linked milestone path; hidden branch requires discoverable conditions.
- **Skill:** trained proficiency receiving allocated meaningful XP.
- **Talent:** point-bought active/passive/modifier gated by skill and other requirements.
- **Specialization:** one primary full track plus one secondary complementary track.
- **Realm:** macro-world family with distinct geography/environment/factions and linked gates.
- **Region:** bounded, loadable local map with stable ID and persistent deltas.
- **Turn:** committed logical action/scheduler step, independent of rendered frame.
- **Chronicle:** permanent read-only record of completed/abandoned/dead/victorious runs.

**Change control:** When changing a rule: record old/new decision in `docs/decisions.md`; identify affected D/F/S/I IDs; update data definitions, save migrations, content requirements, UI and tests; ensure earlier fixtures still load and pass; include source and rationale in commit. Never silently rewrite past locked IDs, even if new content inserts between them.

---

# 23. Technical references and evidence boundaries (checked 2026-10-17)

Official sources used for the **technical recommendations**, not as claims about gameplay reference games:

1. Godot release archive, lists 4.7.2 stable and 4.8 beta: https://godotengine.org/download/archive/
2. Godot 4.7 stable release archive: https://godotengine.org/download/archive/4.7-stable/
3. Stable Godot Android export documentation, OpenJDK 17 / SDK / export setup: https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_android.html
4. Android Developers on APK vs AAB/keystore/export setup: https://developer.android.com/games/engines/godot/godot-export
5. Godot renderer selection and Compatibility for 2D: https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html
6. Godot TileMapLayer batching and runtime tile modification concerns: https://docs.godotengine.org/en/4.6/classes/class_tilemaplayer.html
7. Godot 2D scaling / multiple resolutions and integer scaling advice: https://docs.godotengine.org/en/4.6/tutorials/rendering/multiple_resolutions.html
8. Godot input touch and drag event types: https://docs.godotengine.org/en/latest/tutorials/inputs/inputevent.html (latest branch may differ from pinned stable version; verify at implementation)
9. Godot saving-games reference and `user://` use: https://docs.godotengine.org/en/latest/tutorials/io/saving_games.html (use pinned stable docs in actual code)
10. Godot typed GDScript style guide: https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html
11. Android form factors and differing aspect ratios: https://developer.android.com/games/engines/godot/godot-formfactor
12. Android touch-target accessibility guidance: https://developer.android.com/guide/topics/ui/accessibility/apps

**Evidence status:** Technical engine availability/docs verified via official sources at blueprint date. Actual chosen-phone FPS, APK success, export configuration, legal asset licensing, on-device accessibility, game feel and game balance remain **unverified until implementation**. The fictional world, creatures, item designs and mechanics are original authoring proposals derived from the user's locked feature choices, **not purported facts about the referenced games**.

---

**Next action:** Place this file at `docs/plans/Hollowfold_Master_Blueprint_v1.md` in the **new** repository and send the **I-001 kickoff prompt from §20.2** to the chosen coding agent. Review actual tests and device evidence before proceeding to I-002.
