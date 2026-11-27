# Little Ray — creative direction and classic collector fidelity

Status: **Approved direction; visual production treatment pending review.**  
Authority: Hazel's explicit 25 November 2026 approval to implement DIRECTOR-003.  
Applies to: Little Ray GDD v2.1, its representative slice, all game art/UI, content, and quality review.

## One-sentence promise

Little Ray should **feel like playing a classic Dragon City / DragonVale / Monster Legends-era social creature collector**, with the memorable worldbuilding and collectible creativity associated with MouseHunt, **except every creature is an original, consistently adorable fantasy baby manta ray**. Preserve the genre's familiar city, breeding, hatching, feeding, battling, collecting, and island-expansion grammar. The ray family is the distinctive original identity, **not an excuse to replace the genre's mechanics**.

## Authority and scope

- **User-selected direction:** familiar colorful isometric island management; recognizable elemental habitats and resident income; Gold, paid crops, Food, feeding and leveling; choose parents, breed, transfer egg, hatch, house and discover; rarity/duplicates/collection; three-ray parties, strategic battles, progression and land expansion. Original manta presentation across all tiers. MouseHunt is a *creativity and charm reference*, not a separate mouse-catching/loot-system requirement.
- **Working design choices, not newly approved numerical commitments:** GDD v2.0's detailed probabilities, times, prices, 24-species target, 40 encounters, formulas and six-species vertical slice. DIRECTOR-003 does **not** change these mechanics, cardinalities, engine, or build schedule.
- **Unresolved visual choice:** the production rendering technique (pixel vs small-cartoon) remains subject to the existing Blueberry ART-002 comparison and Hazel's choice. Neither treatment is approved by this document.
- **Legal/creative boundary:** gameplay conventions and broad genre cues are references. Use original creatures, names, icons, text, layouts, effects, UI styling, music and assets. Do not trace, ship, reproduce or imply affiliation with Fish World, Dragon City, DragonVale, Monster Legends, Social Wars or MouseHunt IP. Reference screenshots must be labeled as external references and excluded from game/runtime assets.

## Non-negotiable creature family

**The first read must be “cute manta ray,” not “dragon with wings” or “generic fantasy creature.”** Every collectible—Common through Legendary, baby through adult—retains a shared anatomy and expression language:

1. A soft, slightly protruding rounded snoot/front edge.
2. A large, friendly near eye (plus paired-eye consistency in frontal views).
3. Broad, floppy manta wings with readable tips and gliding/flapping movement.
4. A rounded pale underside or equally legible belly-plane separation.
5. A long, tapering tail and compact, appealing baby-manta body proportions.

Treat Blueberry as the **anatomical style anchor**. Maintain a documented shared silhouette/pose rig or construction sheet, facial rules, eye scale, wing span, tail geometry, camera angles, palette/shading treatment, and animation timing. Common variants must not look like unrelated animal species; Epic/Legendary variants may gain visual ceremony, not lose the manta silhouette.

**Distinct species, coherent art family:** vary body colors, large surface motifs, small edge accents, fin markings, modest thematic accessories, material highlights and elemental VFX. One or two strong distinguishing signals per species at tiny habitat scale is more useful than visual clutter. MouseHunt-like creativity belongs in themes, names, lore, locations and encounters *within the common ray template*; it is not permission to add humanoid bodies, dragon limbs, realistic predatory manta adults or incompatible art styles.

Examples of allowable variation: Pearlcloud's gentle cloud/pearl markings, Mossdrop's leafy fin details, Sunbeam's warm light accents. These are descriptive targets, not approved final drawings.

## Classic social creature-collector presentation

The city should read immediately as a **lively, productive, colorful, isometric collectible-creature park**, not a sparse sanctuary, abstract strategy grid or empty ocean scene. At actual play zoom:

- Place multiple visible ray residents in distinctive element-matched habitats; allow crowded but legible placement.
- Show Gold collection bubbles, crops in growth/ready states, breeding grotto, occupied egg slots, obvious timers, building/upgrade affordances, purchased/locked sectors and attractive decorations.
- Keep the familiar management rhythm: tap/select habitat, collect, plant/harvest, feed, choose breeding pair, wait, transfer/hatch, assign habitat, form a team, battle and expand.
- Communicate resources, level, rarity and progression clearly. Key actions should be reachable from a coherent HUD and actionable building panels. HUD arrangement and art must be original, not traced from reference titles.
- A player's favorite rays should be visually identifiable while idling in a habitat, featured in a portrait, emerging from an egg and occupying one of six readable battle positions.
- Keep the established three-versus-three turn-based model, separate breeding/hatching queues, and existing GDD progression. No one-active-ray substitute, automatic Food garden or sanctuary-only reinterpretation.

**Coherence outranks novelty.** Before proposing a new mechanic or visual idiom, ask: does this reinforce the known classic collector experience with manta identity? If not, defer it as a separate post-slice design proposal.

## Art production contract

**Gate A — Blueberry choice (ART-002 #10):** present the existing pixel/cartoon trial at equal real gameplay scale, in a populated habitat and six-actor battle context, with provenance, silhouettes, motion and estimated production cost. QA records evidence; director recommends; Hazel selects or explicitly delegates the final taste choice. No status promotion from mock tests to real hosted-runtime evidence.

**Gate B — six-ray lineup (ART-003 #11, before roster scaling):** after Gate A is accepted and runtime interfaces are defined, show Blueberry, Sunbeam, Mossdrop, Pearlcloud, Kelpskip and Rosefin:
- as one side-by-side production-style lineup, at identical gameplay render size and view angle;
- as small residents in a populated elemental island habitat;
- as portraits/team slots and in a representative six-actor battle;
- with at least one hatch/feeding reaction where supported;
- with a species-by-species explanation of common anatomy versus distinguishing markings.

Evaluate *each ray* for the five anatomical anchors, *the set* for consistency, distinct identity at play scale, and city/battle readability. A six-image concept sheet alone is not a usable game presentation or proof of real engine integration. Record omitted animations and placeholders; do not secretly substitute a full roster for the trial.

**Gate C — recognizable first play loop (GAMEPLAY-005 #24 / QA-002 #14):** the integrated candidate must show actual Gold collection, crop planting, feeding, two-stage breed/hatch, owned ray placement, three-versus-three battle and first land purchase using ordinary player controls. A fresh genre-familiar player should be able to identify those actions and distinguish Little Ray's original characters without being instructed through developer-only shortcuts.

## Review evidence and decision rules

| Check | Required artifact | Do not misrepresent |
| --- | --- | --- |
| Shared manta anatomy | Same-scale lineup plus multi-pose silhouette comparison and asset provenance | One attractive single-ray concept as a unified roster |
| City genre readability | Screenshot/video from actual intended gameplay zoom showing residents, farms, occupied breeding/hatch slots, income and expansion | Decorative mockup as a working economy |
| Interface coherence | Representative HUD, Shop, Collection, Breeding, Hatchery, ray details and battle view | Generic polished screens with no functional navigation |
| Interactive classic loop | Exact-version executable and documented player sequence through city → hatch → 3v3 → expansion | Passing unit tests or GDD prose as observed gameplay |
| Human taste/comprehension | Hazel's style decision; optional neutral genre-familiar participant observations | AI critic scoring as human approval |

Report separately **designed**, **authored assets**, **static inspection**, **executed technical tests**, **observed runtime interaction**, **human-tested**, and **approved taste**. A failed criterion creates a specific correction. No arbitrary model score can override an unmet anatomical, interface or player-control requirement. The director may approve an explicitly scoped temporary placeholder but must retain any final quality debt in the relevant issue.

## Priority and compatibility

1. Do not restart or invalidate compatible host/save work in ARCH-002 #9.
2. Preserve ART-002 #10 as a **one-ray two-treatment trial**, not a sudden six-ray production mandate. Apply Gate B to ART-003 #11 once Gate A completes.
3. Preserve existing status, dependencies, task IDs and branch ownership for gameplay tasks #12/#13/#23/#24 and QA #14; add these presentation checks as future acceptance evidence rather than pretending their implementation is finished.
4. Do not change any economy, probability, pricing, combat, progression, timer, online/social, engine or automation behavior in DIRECTOR-003.
5. The linked GDD remains canonical for all detailed mechanics. This charter resolves creative ambiguity; any conflict with later explicit user direction must be versioned and routed through the director.

**Exit condition for this design change:** compatible v2.1 specification and issue handoffs have been reviewed and merged by the architect after independent QA. This **does not** equal Gate A/B/C completion or an accepted playable build.
