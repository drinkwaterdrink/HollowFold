# I-001 — Godot Android project bootstrap

**Use with:** `Hollowfold_Master_Blueprint_v1.md`. This prompt implements only the first packet.

---

You are the implementation agent for **Hollowfold**, a new portrait Android 2D roguelike.

Read docs/plans/Hollowfold_Master_Blueprint_v1.md in full, especially §§0–4, 10–15 and 17 (I-001), and inspect the current repository before editing any files. This is a brand-new project; if the repository already contains code, inventory it and report the smallest compatible plan first.

Implement I-001 ONLY: fresh Godot 4.7.2 stable project, Compatibility renderer, version-controlled setup, visible **Hollowfold** title menu (New Run / Settings), working placeholder New Run screen with Back, portrait orientation/inset-aware UI, headless scene smoke check, and a real debug Android APK export/install test when the machine/device permits. Never attempt species catalogs, dungeon generation, combat, save systems, or later roadmap packets yet.

Before editing, report:
1) existing files and Godot/Android SDK availability;
2) exact files you intend to add/change and why;
3) any contradiction or blocker;
4) commands and device actions you'll use to test.

Use Hollowfold as the Godot project name and visible app title. Derive a stable lowercase Android application ID from the actual GitHub repository owner (for example `io.github.OWNER.hollowfold`) and record the chosen ID in `docs/decisions.md`.

Architecture rules: typed GDScript where practical; no cloud/account/ads/Internet gameplay; use project-relative resources and simple scene structure; no unneeded managers; no template content unrelated to the packet; don't commit keystore secrets or binaries unless intentionally approved.

Implement and run the real tests you can. If Android export or physical-device testing cannot be performed, state UNVERIFIED rather than claiming it passed, and give the exact reproducible manual steps. Acceptance: the Godot project opens with no parse errors, main menu is functional, debug APK installs/boots in portrait on a test device when available, safe area is respected, and headless smoke check runs.

After work: show what changed, file paths, exact commands and pass/fail output, AC-I001 status item by item, screenshots or concise manual observations when possible, unresolved blockers and a final commit hash. Stop. DO NOT start I-002.
