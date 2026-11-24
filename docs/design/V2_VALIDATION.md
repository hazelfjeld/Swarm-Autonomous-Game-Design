# Little Ray v2 design validation

Task: [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22). Source: [complete GDD](GDD.md) and [hash record](SOURCE.md). Date: 23 November 2026, America/Chicago. This record covers the specification and its document artifacts, not an implemented game.

## Direction and independent review

The user explicitly requested a Dragon City / Monster Legends-style clone using the cute mantas and rejected the earlier sanctuary interpretation. Official publisher support pages were read for habitat production, breeding pools, rarity, separate hatching, Temple/rarity levels, Adventure Map and multiplayer. GDD section 20 links them and separates external system descriptions from authored Little Ray values.

Independent design reviewers examined the full loop, all 24 species routes, the six-species slice, battle/state contracts and local-versus-connected scope. Concrete findings were corrected: the opening building footprint deadlock, later islands' starting sectors, ordinary versus named Legendary modes, discovery-focus lifetime, Poison/Stun/terminal boundaries and piecewise income through upgrade deadlines. The final design source is identified by its hash in SOURCE.md; exact Git head and review comments are recorded on the revision PR.

## Executed calculations

Exact Python rational arithmetic (`fractions.Fraction`, integer ceiling and explicitly defined rounding) checked the feeding curve, opening ledger, habitat rates and probability mixtures. An exhaustive footprint set check verified bounds/non-overlap. A survival-probability calculation evaluated the stated Rosefin focus distribution. These are model results under the GDD rules.

| Check | Result |
| --- | --- |
| Opening required purchases, breeding and two crops | 1,040 Gold; 160 remains before sample/passive/battle rewards |
| Three rays trained from level one to four | 300 Food; initial 240 plus 80 harvested leaves 20 |
| Food to levels 4, 10, 20, 30, 35, 40, 50 | 100; 1,512; 17,204; 80,632; 165,832; 337,192; 1,375,048 |
| Opening layout | Six specified buildings fit inside 8×8 with no overlap |
| Pearlcloud/Mossdrop mixture | 16.25%, 21.25%, 37.5%, 17.5%, 7.5%; total 100% |
| Rosefin discovery focus | Expected about 5.734 attempts; 90th percentile 12 under repeated eligible pairing |
| Level-four Blueberry/Sunbeam/Pearlcloud production | 15.75 Gold/minute before habitat caps |
| Two level-four Commons, five-minute upgrade, sixty-minute absence | 385 Gold after the deadline, assuming empty bin and no other rate change |
| Ordinary Tide/Light offspring resale expectation | 50 Gold, below its 100-Gold fee |
| Same founder pool at 50% focused Rare chance | 87.5 Gold expectation, below the fee; focus ends at discovery |

Independent review also checked the account-XP tutorial gates, positive-probability initial collection routes, reachable level-25 Legendary parents, skill cooldown examples and rank/Temple cap consistency. This is not a complete simulation of the campaign, a guarantee of long-term economic balance or observed human behavior.

## Document preservation and visual review

- Complete v2 Markdown: 20 sequential chapters, 15,304 words; hash and bytes in SOURCE.md.
- Word companion: 34 pages, 20 chapters and 20 tables; all 1,052 source text units and nine external hyperlink targets retained.
- DOCX ZIP integrity passed; every rendered page was inspected at full size for clipping, overlap, missing glyphs, tables, pagination and footer issues.
- The final island clarification changed only page six; it was re-inspected and the other 33 pages were pixel-identical to the fully inspected preceding render.
- The original v1 Markdown and Word were checked against their existing SHA-256 values and preserved unchanged.

The concept illustration was reused with updated v2 cover/context wording. It remains concept art. Rendered page images/PDF and transient audit JSON are internal verification artifacts; the full Markdown and Word companion are the deliverables.

## Repository and integration gate

Run the repository's current `python3 scripts/validate_setup.py`, `python3 -m unittest discover -s tests -v`, and `git diff --check` on the exact candidate. Record actual results and head SHA on the PR, obtain independent exact-head QA, inspect applicable CI and current main, then let the architect integrate through the existing lease protocol. Recheck preservation and setup on the merged result. This report does not predeclare those future results.

The source-skill binding used was `hazelfjeld/Game-Design-AI-Skill` at `dc26ddb18adc18fbbe2221a8443a71a260de6022`: SKILL.md, design foundations, systems/balance and production/collaboration. Canonical GitHub reads matched the installed content. No skill repository, pin, automation or coordination permission was changed.

## Evidence still outstanding

No gameplay code, exported candidate, hosted interaction, human playtest, full-roster balance, real Arena service or commercial outcome is established by this revision. Those are explicit downstream tasks. A readable and arithmetically coherent GDD is a specification for that work, not proof of its completion.
