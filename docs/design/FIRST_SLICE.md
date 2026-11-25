# Little Ray first playable slice

Current source: [GDD v2.1](GDD.md), plus [the creative-direction charter](CREATIVE_DIRECTION.md). Owner: director. Revision: [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22). Milestone: [M0 #8](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/8). This replaces the v1 sanctuary/Practice Pool acceptance scope.

## Player visible outcome

A fresh player collects Gold from Blueberry's habitat, buys/hatches Sunbeam, builds appropriate housing, grows paid crops, feeds the parents to level four, breeds a saved Pearlcloud egg, transfers it into a separate hatchery, places and trains the hatchling, wins a three-versus-three adventure battle and purchases land. The next visible collection goals are Mossdrop, Kelpskip and Rosefin, using ordinary random pools and duplicate outcomes. Reload preserves the city, individuals, jobs and settled rewards.

## Classic collector fidelity and unified ray art

The required gameplay loop is unchanged. Presentation must feel like a classic colorful isometric social creature collector, with active habitat residents, income bubbles, farms, breeding grotto, distinct hatchery slots, visible timers, shop/collection/HUD paths, six readable battle actors and unlockable land—not an abstract grid or mostly empty sanctuary.

Before roster-scale art, **ART-002 #10** retains its one-Blueberry, two-treatment comparison at matched actual display scale, independent QA and Hazel's final rendering choice. **ART-003 #11** then supplies the original six-ray same-scale lineup and city/portrait/battle contexts. Every ray uses one baby-manta anatomy/art family. **GAMEPLAY-005 #24** incorporates those accepted assets through ordinary game controls; **QA-002 #14** evaluates genre/readability and runtime evidence separately. The [charter](CREATIVE_DIRECTION.md) defines five anatomy markers, the visual acceptance gates, original-asset restrictions and evidence labels. No approved new costs, formulas, species count or schedule change is implied.

## Scope boundary

Include six collectible species, three player housing elements, Common/Uncommon/Rare, the first island's four starting sectors plus one purchased sector, two farms and the one/five-minute crops, Small/Large habitats, one breeding grotto, one hatchery with its Gold-funded second slot, account/feeding through the opening level-ten cap, three encounters and persistent return. Emberfin appears as an explicitly opponent-only battle record/presentation.

The full 24-species catalog, other islands/regions, Lab/runes and connected Arena remain product targets after this slice. Temporary presentation may support subsystem learning, but final slice acceptance requires representative collectible art and normal controls. A one-active-ray fight, debug-granted rare creature or automatic free-Food garden is not this slice.

## Dependencies and assigned issues

The linked issues own live status. Existing capability tasks #5–#7 and their reviews remain valid work. ARCH-001 #4 is historical accepted capability evidence. Automation registrations and scheduled-run checks remain separate records; they do not substitute for or unnecessarily block actual interactive capability.

| Task | Owner | Dependencies and output |
| --- | --- | --- |
| [ARCH-002 #9](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/9) | architect | Continue received runtime task: actual-host Godot/input/audio/timer/save/backup evidence and small interfaces; retain existing branch/probe |
| [ART-002 #10](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/10) | art-audio | ART-001 capability; Blueberry treatment/readability against city and six-actor battle contexts |
| [ART-003 #11](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/11) | art-audio | v2 revision, ART-002 and runtime interface; six collectibles/opponent Emberfin, functional city structures, eggs/crops and battle cues |
| [GAMEPLAY-002 #12](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/12) | gameplay | v2 revision, GAMEPLAY-001 and runtime/save interface; grid/land, elemental housing, resident Gold, crops, account gates and feeding |
| [GAMEPLAY-004 #23](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/23) | gameplay | v2 revision and GAMEPLAY-002 state; ordinary pools/focus, separate breed/transfer/hatch jobs and exact ownership |
| [GAMEPLAY-003 #13](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/13) | gameplay | v2 revision, GAMEPLAY-002 ray records and runtime; six-actor combat, skills/statuses and first three encounters |
| [GAMEPLAY-005 #24](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/24) | gameplay | City, breeding, combat, representative art and actual-host baseline; normal-control opening journey, expansion and saved return |
| [QA-002 #14](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/14) | qa | v2 revision, QA-001 capability and exact GAMEPLAY-005 candidate; independent scenario and player evidence |

The director sets readiness from actual dependency evidence. Review/integration continues through the existing protocol; architect remains merge owner. No completed capability task should be recreated merely because the game's scope changed.

## Concrete acceptance scenarios

| Scenario | Required observation |
| --- | --- |
| Physical opening | The GDD's six-building coordinate fixture fits inside 8×8. Farms/hatchery are 2×2; habitats/grotto are 3×3. |
| Budget and gates | The required purchases/two crops spend 1,040 of 1,200 Gold. Training three rays to level four spends 300 Food; starting 240 plus 80 harvested leaves 20. XP gates open before required actions. |
| Productive city | Empty habitat income is zero. Resident level/rarity affects its bin. Collection, cap, fractional ticks, relocation and upgrades settle correctly. |
| Real farms | Gold is paid at planting; Food and crop XP arrive on one harvest. Ready crops remain, no hidden free cycles occur. |
| Random breeding | Guided Pearlcloud is labeled and limited to one job. Ordinary pools match previews, allow duplicates and preserve one committed outcome across reload. |
| Hybrid and focus | Pearlcloud/Mossdrop mixture has the documented probabilities; eligible focus adjusts the final distribution once and preserves its counter/lifetime. |
| Separate queues | Breeding releases parents at deadline but holds its egg until transfer; hatchery starts a distinct timer; full/incompatible housing blocks placement safely. |
| Six actor battle | All three allies and three opponents use individual Stamina/skills/cooldowns and Speed turns. Elements, statuses and KO rules follow the current GDD. |
| Progression result | First-clear/repeat/star rewards and entry costs settle once. The player buys the first sector and sees another collection or city goal. |
| Return and recovery | Normal reload, long absence, upgrade completion, twelve-hour timer fixture, corrupt import, duplicate commands and second tab retain valid ownership/state. |
| Actual presentation | The city conveys farms/habitats/eggs/expansion and the battle shows all actors. Required controls work in declared mouse/keyboard/touch contexts with visible audio equivalents. |
| Classic collector identity | Actual-scale productive island screen demonstrates dense colorful isometric habitats, Gold bubbles, crop/hatch/breed states, menu affordances and expansion; not a sparse sanctuary. |
| One manta art family | Six original collectible rays at the same size/camera angle retain the five Blueberry anatomy anchors and remain distinct through coherent, readable color/motif differences; review small habitat and six-actor battle contexts. |
| Source and taste truth | External game/Fish World images remain reference-only; new art is original/provenanced, creative treatment remains pending Hazel's explicit visual choice, and concept/mockup/tested runtime/human observations are labeled separately. |
| Human understanding | Record what a real player understands about the next target, two queues, duplicate choice and combat. Model simulations do not supply this evidence. |

Use injected RNG and accelerated clocks only for explicitly labeled deterministic tests. Also observe the ordinary real-time tutorial. The intended first team is Blueberry, Sunbeam and Pearlcloud at level four; a just-hatched level-one Pearlcloud is not the same fixture.

## Evidence and handoff

Retain exact source/content/build identities, run/export commands, browser/device/embedding context, logs and useful screenshots. Separate document review, source tests, actual runtime, interaction and human play. Missing platform or human evidence remains unverified.

M0 is not complete because this GDD was rewritten. Completion still requires a reproducible candidate the user can try, independent verification/corrections and architect integration. The wider progression and connected product have later gates. The new document changes the accepted game direction while preserving the repository's coordination, skill bindings and existing work.
