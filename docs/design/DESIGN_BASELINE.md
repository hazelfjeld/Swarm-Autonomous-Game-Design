# Little Ray design baseline

Current working design: **GDD v2.1**, dated 25 November 2026 (mechanical baseline carried forward from v2.0, 23 November 2026). Owner: director. Revision: [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22). Read the [complete GDD](GDD.md), [source and archival record](SOURCE.md), and [first-slice assignments](FIRST_SLICE.md).

## Explicit direction correction

Hazel rejected the v1 cozy-sanctuary interpretation and requested a **Dragon City / Monster Legends-style clone using the cute manta rays**. The game is an expanding island city and creature collection RPG: breed desirable elemental species, hatch them, grow Food, develop stronger teams and beat increasingly difficult content. This instruction supersedes conflicting v1 requirements.

The working combination is Dragon City-style island economy and breeding with Monster Legends-style **three actors per side** in turn-based battles. Each actor has personal Stamina, equipped skills, cooldowns and Speed. The exact formulas, roster and staging are authored Little Ray proposals; they are not representations of undisclosed reference-game internals or measured balance.

The GDD status remains **received**. The user's correction authorizes the revision and this genre direction; it does not mean every new tuning number has been individually approved or human-playtested.

## Creative identity — DIRECTOR-003

The [creative-direction charter](CREATIVE_DIRECTION.md) is a required companion to the GDD. Little Ray must feel like a classic colorful isometric Dragon City / DragonVale / Monster Legends-style creature collector: a busy habitat city, timed breeding and hatchery, Gold/Food decisions, nurturing, leveling, discovery, 3v3 encounters and land growth. MouseHunt is inspiration for *inventive collectibles and charm*, not an alternate gameplay structure. All rays—including Legendary designs—retain the same baby-manta snoot, friendly eyes, broad floppy wings, pale underside and tapering tail, with distinctive color/motif and restrained accents. The production choice between pixel and cartoon render treatments is still pending ART-002 #10 and Hazel's visual choice.

**No reimplementation required by DIRECTOR-003:** v2.0 state contracts, economy/timer numbers, breeding probabilities, rarity power, battle mechanics, progression quantities, Godot/runtime scope and all role schedules are intentionally unchanged. The charter adds presentation and verification gates; existing role work and reviews remain valid for unaffected criteria. GDD v2.1 and this charter take effect after the required PR review and merge, not from an unreviewed draft branch.

## Governing experience and loop

The player chooses a collection or battle target, prepares its economic and breeding requirements, produces an egg, hatches it into suitable housing, trains it and uses the result to open the next target. The city is a functional production system. Cute individual names, faces and growth support the collector fantasy while rarity and investment create real power differences.

**Collect resident Gold → pay for timed crops → harvest Food → feed rays → breed a saved random egg → incubate in a separate hatchery → place in a compatible habitat → battle and expand → pursue stronger or rarer species.**

The intended horizon is continuing progression over repeated visits and days/weeks. A finite initial adventure map is one track within that game; it is not a two-hour ending. Timers, storage limits, duplicate decisions and expansion should create plans whose purpose players understand. Their actual pacing must be observed.

## Working product contracts

| Area | GDD v2 rule | Source |
| --- | --- | --- |
| City | Four planned 16×16 islands; each begins with four 4×4 sectors in an 8×8 block; buy adjacent sectors and place buildings | §4 |
| Housing | Eight element types; a ray must match at least one; actual residents generate Gold; empty habitats generate zero | §§4, 6–7 |
| Farming | Gold-funded crop choices with different durations/yields; one manual harvest per crop, no free passive garden | §7 |
| Collection | Initial target 24 species: 8 Common, 4 Uncommon, 6 Rare, 4 Epic, 2 Legendary; future catalog expansion | §§3, 5 |
| Rarity | Different Health/Power, income and level ceilings; lower-tier usefulness does not imply endgame power equality | §§5–6 |
| Breeding | Parent-element outcome pools, explicit named Legendary mode, disclosed discovery focus, one guided tutorial exception | §8 |
| Hatchery | Separate breeding and incubation jobs; full slots/habitats are safe explicit bottlenecks | §§4, 8 |
| Progression | Separate account XP, four-pip Food levels, element Temples, species cells/ranks and later runes | §§7, 9 |
| Combat | Three actors on each side; personal Health/Power/Speed/Stamina, four learned/equipped slots, Basic/Recover | §10 |
| Adventure | Four target regions, 40 nodes, bosses/escorts, Energy, stars and distinct first/repeat rewards | §11 |
| Arena | Labeled NPC Arena first; actual asynchronous attack/defense teams and seasons require a connected authoritative service | §12 |
| Continuing product | Catalog updates, recurring collection events and later teams/cooperative competition | §§3, 12 |

All initial 24 species have a permanent non-purchase route. Gold, Food and earnable Gems belong to the prototype. Real-money purchases, ads, payment integration and public deployment are not part of this revision task. Their eventual product decisions do not remove the defining gameplay systems.

## Opening contract and first slice

Start with 1,200 Gold, 240 Food, Blueberry, a Tide habitat, one farm and hatchery slot one. The budgeted tutorial purchases and two crops spend 1,040 Gold, leaving 160 before sample/passive/battle income. Feeding Blueberry, Sunbeam and Pearlcloud to level four costs 300 Food; initial Food plus two short crops leaves 20. Explicit quest XP opens each required building before it is requested.

The initial 8×8 placement fixture uses 3×3 Tide/Light habitats and grotto, with 2×2 hatchery and farms. All six required buildings fit without overlap before the first expansion. Use the exact coordinates and rounding/production/pool rules in the GDD; do not guess from this summary.

The representative slice contains Blueberry, Sunbeam, Mossdrop, Pearlcloud, Kelpskip and Rosefin; Tide/Light/Bloom housing; Common through Rare; two crop choices; separate breeding/hatching; Food levels through ten; three authored adventure encounters; first land expansion; and a persistent return. Emberfin is an opponent-only presentation in this slice. Ordinary random/duplicate results must work beyond the tutorial's guaranteed Pearlcloud.

The corrected first acceptance journey is **city production, breeding, hatching, a real six-actor battle and expansion**. The old Practice Pool and one-active-ray system do not satisfy it. See [FIRST_SLICE.md](FIRST_SLICE.md) for the eight task responsibilities and their actual issues.

## Presentation and runtime continuity

Preserve the recognizable baby-manta snoot, near eye, broad wing, underside and tail across hatchling/juvenile/adult presentations. The Blueberry pixel/cartoon comparison remains useful, but it must be judged against a functional city and six-actor battle interface. Retain original/generated asset provenance; the previous concept cover is a reference, not a shipped screenshot.

Continue the existing Godot/GDScript web-delivery work and verified engine/template pin. Reuse compatible input, audio, save, backup and recovery evidence. Actual-host support and performance remain measured gates. Local prototypes cannot prove real PvP, account security or server-authoritative transactions.

Persist stable individuals, jobs, committed outcomes, receipts and profile revisions. Reconcile deadline events chronologically; the old eight-hour cap is replaced with a seven-day reconciliation bound plus per-system caps so twelve-hour hatches can complete. Existing v1 save conversion requires actual fixtures; no destructive reset or invented migration is authorized by a paper revision.

## Supersession and readiness

GDD §19 explicitly replaces universal Tide housing, empty-home Pearls, automatic Food garden, cosmetic-only rarity, a single short nursery job, fixed home plots/unlimited Guest Cove, level-ten product ceiling, shared Energy/active-ray combat and a short final campaign. Historical v1 files remain archived and unchanged. Existing species keys and useful capability/runtime/art work remain valid.

ARCH-002 and ART-002 continue their compatible bounded work. ART-003, GAMEPLAY-002/003 and QA-002 receive revised criteria; GAMEPLAY-004 separates breeding/hatching and GAMEPLAY-005 integrates the larger journey. Do not duplicate historical intake or startup tasks. Live issue dependencies determine Ready/Working status, and current config determines phase. Preserve intervening phase changes; this revision does not alter automations, skill pins or coordination authority.

## Additional presentation gate

ART-002 proves and selects one Blueberry treatment at actual size; ART-003 then delivers the *six-ray same-scale lineup* and populated city/3v3 contexts; GAMEPLAY-005/QA-002 verify an actual-player-control opening journey with classic collector readability. Detailed checks and evidence types are in [CREATIVE_DIRECTION.md](CREATIVE_DIRECTION.md). A pleasing concept image, automated DOM assertions or model rating alone does not certify runtime visuals or Hazel's taste approval.

## Evidence still needed

The design has arithmetic and independent contract review; it has not been implemented or human-playtested by this revision. Remaining evidence includes actual-host behavior, species production effort, ordinary timer comprehension, repeated-visit economy, battle pacing/team alternatives and connected competition feasibility. Fix specific observed problems through recorded revisions while preserving the user's selected genre.
