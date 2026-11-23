# Little Ray design baseline

Version: intake of GDD v1.0, 23 November 2026. Owner: director. Source: [complete GDD](GDD.md), [provenance and original](SOURCE.md). Task: [DIRECTOR-001 #3](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3).

## Authority and design status

The user asked for cute manta rays in a Dragon City-style game and requested that the completed Little Ray GDD be added to this experiment. The GDD records the established baby-manta identity, the prior project/workbook and intended Godot/browser delivery. These are the supplied project foundations.

The GDD's detailed mechanics, economy, encounter scripts, production budgets and proposed rendering comparison form a **working production baseline**. They can support bounded implementation and tests, but are not individually human-approved or validated for fun. Use `received`, not `approved`, for this intake. Distinguish an explicit user requirement, a prior project foundation, a new design choice, and a measured result in future decisions.

## Experience and core loop

**Promise:** the little ray loved at the beginning can still contribute at the end. Preserve attachment, understandable discovery and gentle mastery. Rays retain the rounded baby silhouette as they grow; new varieties add choices without making favorite individuals obsolete.

The player names and homes individual rays, collects resources and trains favorites, chooses parents to discover another variety, records the new family member, prepares a small team, explores a short reef challenge, then returns to a visibly changed sanctuary. Individual identity, parents, names and acquisition history persist through movement and reloads. Decoration and resident grouping support expression without a mandatory efficiency layout.

The audience is hypothesized to enjoy cute collecting, expressive home building and approachable turn-based choices. Brief 5–15 minute visits and a roughly 2–3 hour campaign are design targets to measure, not observed player data or a release promise.

## Working MVP boundaries

| Area | GDD v1.0 baseline | Source |
| --- | --- | --- |
| Cast | Eight varieties: Blueberry, Sunbeam, Pearlcloud, Ripple, Mossdrop, Rosefin, Moonpool, Emberfin | §§2, 6 |
| Homes | Four types: Sunlit Shallows, Kelp Garden, Moonlit Cove, Warm Spring; six placed-home plots, two initially; capacity four, upgradeable to six | §§2, 7 |
| Breeding | One nursery slot; six launch recipe rules; guaranteed first Blueberry/Sunbeam Pearlcloud and Blueberry/Mossdrop Rosefin; outcome committed when pairing starts | §8 |
| Adventures | Three authored regions and guardians; 15 main nodes plus two optional nodes | §§5, 14 |
| Team challenges | Up to three individuals, one active per side; visible intent; Bop, Guard, signature and Swap; shared Energy per side | §10 |
| Progression | Levels 1–10, Pearls and Food, journal and campaign milestones | §§6, 9 |
| Expression | Naming, inherited cosmetic accents, personalities/buddy behavior and eight decoration types | §§6–8, 12 |
| Persistence | Versioned local saves, previous-good recovery and portable backup/import | §§13, 17 |

The opening has 100 Pearls and 30 Food. A feed spends five Food for 15 XP. Each placed home produces three Pearls per minute, independent of occupancy; the fixed free garden produces three Food per minute. Use the source tables for caps, level thresholds, recipes, costs and settlement rules. Do not substitute a parallel tuning spreadsheet or infer missing values from these examples.

Guest Cove preserves arrivals when homes are full. Moving residents and restoring stored empty homes must allow recovery without purchase or deletion. Food trains rays; absence does not cause hunger, illness or lost affection. Preserve ownership and rewards exactly once, including interrupted nursery reveals and battle settlements.

The MVP has a complete ending and continued sanctuary play. It excludes accounts/backend dependencies, paid currencies or skips, randomized purchases, compulsory daily calendars, PvP, trading, cloud sync and live events. The 24-variety/eight-habitat catalog is expansion scope, not the first release. Preserve existing `little_rays` and content identifiers despite the display title **Little Ray**.

## Platform and presentation

The supplied direction is Godot for desktop and touch browsers through the intended ChatGPT Site. The initial implementation choice is GDScript, Compatibility rendering and single-thread web export. The architect must verify and pin an actual stable editor and matching templates, then observe runtime, input, audio and persistence on the real intended host/embedding context. This intake does not establish that the host can run the export or that a current live build implements the GDD.

Keep content definitions separate from saved individuals and state. Commands validate and commit once; scenes and reactions cannot independently grant rewards. Settle elapsed time once, clamp negative time to zero, and cap resume credit at eight hours. Preserve saves on unsupported schema/import failure and prevent two tabs from silently overwriting one profile.

The mascot needs a soft snoot, large friendly near eye, broad floppy wing, pale underside and long thin tail. Compare one small pixel and one small cartoon Blueberry at the same play scale before selecting a treatment. The 96×96 canvas is a trial, not a mandatory display size. Record the chosen pivot/padding/filtering and asset provenance before multiplying variants. The GDD cover remains concept art.

Audio is gentle and readable: home, adventure and playful challenge families, soft calls and short feedback cues. Begin audio after a user gesture, retain volume settings and pair essential sounds with visible information. Required actions must work with keyboard and touch; clarity cannot depend only on color, motion or sound. Use reduced motion and stable readable controls.

## First acceptance priorities

1. **Delivery and identity:** one actual hosted runtime with input/audio/save/backup evidence, plus a Blueberry style trial that preserves the mascot at normal scale.
2. **Representative journey:** Blueberry, Sunbeam and Pearlcloud; two Sunlit homes; naming/feeding/first pairing; two free props; journal and Guest Cove; three-member party; Practice Pool; persistent return home.
3. **Recovery:** full homes, busy parents, zero resources, interrupted incubation/reveal, repeated claims/settlement, save/import failure and second-tab conflicts must have observable safe outcomes.
4. **Human evidence:** a fresh player should complete the loop using normal controls. Record interventions and confusion; a model simulation cannot establish affection, understandable choices or enjoyable pacing.

See [FIRST_SLICE.md](FIRST_SLICE.md) for task ownership, dependencies and the exact boundary. No additional campaign or expansion production is part of M0's initial slice.

## Decisions still to validate

- Rendering treatment and mascot quality at actual play scale: art/audio produces evidence; director records the recommendation and Hazel's preference where taste is material.
- Host compatibility, engine/template version, save behavior and supported device matrix: architect observes them; unsupported capabilities stay explicit.
- Challenge depth, guardian tuning, campaign duration, resource timing and production budgets: prototypes and real-player evidence must settle them before broader promises.
- The workbook is supporting context, not bundled execution state. GDD §19 lists revisions; this repository's task issues own current work. Obtain a specific missing reference only when a task actually needs it.

No unresolved choice requires inventing a different game or delaying independent capability work. All new production issues initially remain **Blocked** on named execution prerequisites. Existing capability issues remain **Ready**. The director changes the experiment phase from `bootstrap` to `active` once actual production work is Ready; automation registration is tracked separately and is not a gate for authorized interactive work.
