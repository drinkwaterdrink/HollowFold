# Coding-agent instructions

- Read `docs/plans/Hollowfold_Master_Blueprint_v1.md`, `docs/progress.md`, and the active `I-xxx` implementation packet before edits.
- This is a **new** Godot 4.7.2 stable + GDScript offline-first Android portrait roguelike. Preserve all prior locked game-design decisions.
- **Only implement the explicitly authorized packet.** Never start the next packet, unrelated refactors, or giant speculative scaffolding.
- First packet: `docs/agents/I-001_Godot_Agent_Kickoff.md`.
- Before edits: inspect repository, check Godot and Android build availability, and report the planned files and verification.
- Prefer small typed GDScript and simple scenes; no unnecessary architecture layers or runtime AI services.
- Keep game rules deterministic and independent of rendering/UI. Make each accepted change testable.
- Document commands and actual pass/fail results; label skipped or unavailable real-device checks **UNVERIFIED**.
- Maintain `docs/progress.md` with packet status, evidence, blockers and commit hash.
- Never commit secrets, private signing keys, keystores, Android SDK installations, or generated APK/AAB files.
- Stop and explain conflicts with the blueprint. Ask before replacing a locked decision.
