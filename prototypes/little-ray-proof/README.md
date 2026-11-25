# Little Ray — immediate playable proof (DIRECTOR-004)

**Open `index.html` directly in a modern browser.** It is entirely offline: one HTML file, no build tools, no services, no accounts or API keys. Chrome/Firefox/Safari should be able to load the file, but the sandbox's browser policy prevented our own physical/browser playthrough. All art in this file is *original temporary code-drawn placeholder art*, **not** an approved production mascot.

The current tester journey:
1. Open the island. Gold accumulates in residents' collection bank; collect it.
2. Plant and harvest a paid crop (40 Gold, 12 seconds, 65 Food).
3. Feed Blueberry and Sunbeam twice each to reach level four.
4. Begin a pairing (100 Gold, 18 seconds), transfer the ready egg into a separate 14-second hatchery, and claim exactly one new ray.
5. Open Adventure, fight three enemies with three individual rays using Bop, Signature and Guard; receive victory rewards once.
6. Return home, buy a sector for 200 Gold, reload the file and inspect preserved progress.

### Tests

Run `node test_logic.cjs` from this directory. It executes **11 named deterministic smoke checks plus the QA-FIX-001 overlap/reload regressions**, including resource spending, crop harvest, feeding, one-time pairing, separate incubation, claim/reward idempotence, three-versus-three battle, expansion, and simulated save/reload. The guided first Pearlcloud is consumed with the first paid pairing, not at hatch claim. A fixed RNG of 0.99 proves a second pairing while the first egg incubates commits an ordinary Sunbeam; the test also checks old in-flight saves, reload and duplicate debits/claims. This is **not** a visual/browser test; the local Chromium runner returned `net::ERR_BLOCKED_BY_ADMINISTRATOR` on the file URL. The game has not been human-playtested and does not claim production-quality balance or visuals.

### What this is not

This is a fast, deliberately isolated **proof of the city/collector loop**, not the actual Godot implementation or completion of the GDD v2.0/v2.1 first slice. Rules/timers are accelerated and tuned for a brief test; no user accounts, production storage fencing, mobile device certification, complete inheritance/genetics, four islands, 24 species, full 3v3 RPG systems, production combat rules, or finished art. Do not deploy publicly or replace `ARCH-002`/`GAMEPLAY-002` with it. Save data is local to the browser; use the Reset control to restart. Temporary UI and placeholder rays must be replaced according to Hazel's approved source visual direction and independent QA.

### Protocol

Issue: `DIRECTOR-004` (#29). Isolated branch `swarm/director/DIRECTOR-004`. Preserve all existing task ownership and review requirements. QA must verify the submitted exact commit; the architect alone merges after independent review. Gameplay should use this prototype only as a runnable feel test to inform the canonical Godot implementation, not copy its simplified persistence model as authoritative.