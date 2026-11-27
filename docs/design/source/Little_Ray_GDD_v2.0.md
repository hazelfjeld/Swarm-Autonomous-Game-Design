# Little Ray

Game Design Document

Version 2.0 · 23 November 2026

## 1 Product direction and authority

**Little Ray is a Dragon City and Monster Legends style creature collection RPG in which the player builds an expanding island city, breeds cute elemental manta rays, grows food, develops increasingly powerful creatures, and fights with a team of three.** The city is an economic machine as well as a place to show the collection. New species, higher rarities, stronger teams, larger habitats, additional islands and league progression give the player continuing goals.

Hazel explicitly corrected the previous design: the intended game should be close to a Dragon City or Monster Legends clone. This revision therefore changes the underlying systems, progression and production plan. The reference games supply the structural blueprint; Little Ray supplies its own manta species, artwork, world, interface treatment and authored content.

The chosen combination is **Dragon City style city building, elemental housing and breeding, with Monster Legends style three versus three tactical battles**. All three team members are present on each side, and actors take individual turns. There is no active-ray swap system. Four equipped skills, the initiative formula and all numerical tables below are Little Ray design choices, not claims to reproduce unpublished reference-game internals. Official documentation supports the reference systems summarized in Section 20. [S1–S7]

### What the player is trying to do

The player wants to see a desirable ray in the collection book, work out how to breed or earn it, prepare the required parents and buildings, wait for the result, hatch it into a compatible habitat, train it and use it to beat something previously too difficult. Their growing collection generates more Gold, which finances farms and expansion, which supports more Food and stronger creatures. This cycle should remain recognizable even with placeholder art.

Cute mantas are the game's identity. Their soft faces, broad wings, pale undersides and expressive movement should survive every rarity and growth stage. Cuteness does not remove rarity differences, battle losses, production limits, crop decisions or the pursuit of stronger creatures. Familiar starters remain useful as breeders, workers and early fighters; there is no promise that every Common will equal a Legendary at maximum investment.

### Authority and evidence

The clone-like genre direction and cute manta premise are explicit user requirements. The selection of a coherent battle model, particular economy values, a 24-species initial content target, progression thresholds and production stages are proposed implementation decisions in this revision. Treat them as the working baseline to build and test. Receiving this document is not human validation of the numbers or an assertion that a current build implements them.

Version 2.0 supersedes conflicting v1.0 rules. Preserve v1.0 as historical source; do not blend its universal Tide housing, occupancy-independent Pearls, autonomous Food garden, cosmetic-only rarity, single incubation job, level-10 ceiling or shared team Energy into this version. Section 19 lists the migration decisions explicitly. Existing runtime, save-recovery and provenance work should be reused where it remains compatible.

## 2 Player experience and progression loops

The target audience is players who enjoy Dragon City or Monster Legends style collection, management and combat progression. They should recognize the city, breeding building, hatchery, farms, food feeding, rarity ladder, adventure map and arena without needing a new explanation of the genre. This audience definition is a design hypothesis; no market or retention study has been performed for Little Ray.

### The main loop

1. Collect Gold from occupied elemental habitats.
2. Spend Gold on timed farm crops, buildings, upgrades and new land.
3. Harvest Food and feed selected rays to increase their levels, income and battle strength.
4. Choose eligible parents and start a breeding job with a visible outcome pool.
5. Move the resulting egg into a separate hatchery slot and wait for incubation.
6. Hatch the ray into a compatible habitat, or keep the finished egg waiting until space exists.
7. Build a stronger three-ray team, defeat adventure encounters and improve arena results.
8. Use rewards and account unlocks to pursue rarer species, higher level caps, larger production and more islands.

The loop contains real tradeoffs. Feeding a strong fighter consumes Food that could prepare another breeding parent. Occupying the only hatchery slot with a long egg delays a short collection goal. Upgrading a habitat stores more production between visits, while another farm offers more Food if the Gold economy can support it. A duplicate can become a productive resident, a second team member, Gold through sale, or species cells for ranking after the Lab unlocks.

### Three timescales

During a short visit, the player collects, harvests, restarts production, feeds a chosen ray and queues a breeding or hatch. A longer session adds several battles, land arrangement and a collection plan. Across days and weeks, the player unlocks elements and islands, reaches higher rarity tiers, develops ranks and equipment, completes adventure regions and improves arena standing.

The first-time session must include a complete breed-to-battle cycle. Later waits should become long enough to support returning with a plan. This is an ongoing progression game; finishing the initial adventure map does not end collection, city development or arena play. Do not impose v1.0's two-to-three-hour completion target or a final sanctuary celebration as the product endpoint.

### Experience priorities

- **Desirable collection:** the book shows recognizable creatures and understandable acquisition routes, including targets beyond the player's current reach.
- **Visible growth:** feeding, rarity, rank, buildings and land each make a noticeable, attributed difference.
- **Connected planning:** city production, breeding choices and battle needs reinforce one another.
- **Tactical team building:** elements, Speed, roles, Stamina and skill cooldowns make several team compositions useful.

Measure whether players can explain their next target, the missing requirement and the action that will move them toward it. Session length alone does not demonstrate that the game has achieved these priorities.

## 3 Product scope and delivery stages

### Full product direction

The intended product includes an expandable city, a growing catalog, timed breeding and hatching, crops and feeding, meaningful rarity, account and creature progression, three-versus-three PvE, an arena, recurring collection events and social team features. These remain part of the product direction even when a first implementation ships fewer creatures or starts with local saves.

The initial complete content target is **24 species, eight elements, five rarity tiers, four home islands and 40 adventure nodes**. After the core economy and battle loop have evidence, expand the collection toward 60 or more species through authored updates. These are scope targets, not estimates of how quickly the current agents can produce accepted art and balanced content. The first 24 must work as a connected collection graph, not as a large set of isolated reskins.

### Build stages

| Stage | Playable scope | Required proof |
| --- | --- | --- |
| Delivery spike | One visible ray, input/audio, one timed state, save and backup on intended host | Actual served Godot runtime and recovery observations |
| Representative slice | Six collectible species, three housing elements, Common through Rare, the first island and one purchased sector, farms, separate breeding/hatching and three authored encounters | A normal player completes the economic and breed-to-battle loop |
| Initial progression build | 24 species, eight habitats, four islands, 40 nodes, temples, Lab/ranks, basic runes and NPC Arena | Every target reachable, economy paced across repeated visits, actual full-path tests |
| Connected competition | Accounts/cloud progression, authoritative economy, asynchronous defense-team Arena and seasons | Server validation, account recovery, real-player match and settlement evidence |
| Continuing collection | New species, themed events and teams/cooperative competitions | Sustainable content production and actual player evidence |

NPC Arena is explicitly labeled **NPC Arena**. It can prove rewards, team selection and opponent variation while the connected layer is built. It must never display fabricated human players, rankings or live matchmaking. Real PvP remains a full-product feature with a separate delivery gate; a local AI simulation does not complete it.

The first implementation uses the existing Godot/GDScript direction and intended browser delivery through the ChatGPT Site. The architect owns the verified editor/templates and host findings. Do not independently select a conflicting engine or promise platform support before the export works in the actual target context.

### Monetization and currency scope

Gold, Food and Gems are designed from the beginning. Gems support optional timer completion and later premium offers; the prototype earns them through authored quests and achievements. Real-money purchases, payment integration, advertising and commercial price points are not authorized or specified by this design revision. They may be designed separately without removing the city, rarity, timer or collection systems that define this game.

All 24 initial species have a permanent non-purchase acquisition route. Event rewards can include early access, additional copies, cells and cosmetic variants. A later monetization proposal must state how it affects those routes and competitive power. Do not silently treat an earnable-Gem prototype as a tested commercial economy.

## 4 Island city and buildings

The home screen is a zoomable isometric reef archipelago. It presents functional habitat districts, farms, the breeding grotto, an egg-filled hatchery, upgrade buildings and land waiting to be purchased. Rays visibly occupy their habitats, Gold bubbles signal stored production, crop plots show growth, and construction changes the skyline. Decoration is available, but functional city progression receives the primary screen space.

### Land and placement

Each of four planned home islands uses a 16×16 placement grid divided into sixteen 4×4 sectors. The first island begins with four sectors unlocked in a 2×2 group, an 8×8 area. Purchasing each later island also grants its four starting sectors in that arrangement. A new sector must share an edge with owned land. The first three purchases cost 250, 500 and 1,000 Gold. For sector purchase index n from 4 through 12, cost is `2,000 + 500 × (n − 4)` Gold. The twelve-purchase index resets on each island. These costs are multiplied by the square of the island number on later islands. A purchase is permanent; removing a building never returns land cost.

Island two requires account level 8, the first adventure boss and all first-island sectors; it costs 25,000 Gold. Island three requires level 14, the second boss and the previous island's sectors; it costs 100,000 Gold. Island four requires level 20, the third boss and the previous island's sectors; it costs 400,000 Gold. First-island expansion is sufficient for the representative slice. Later thresholds are balance hypotheses to test against actual production.

Habitats and the grotto occupy 3×3 cells. Farms, hatchery, Temples and the Rune Forge occupy 2×2; the Lab occupies 3×3. Rotation and moving are free. Placement cannot overlap, use locked cells or leave a building partly outside an island. A move preserves building ID, stored resources, upgrade level and jobs. Habitats with residents cannot be stored or sold. Storage requires no residents, job, ready output or required active Temple cap. Eligible empty buildings can be stored without a refund; a stored building performs no work or production.

The opening layout must physically fit before its first expansion. A valid zero-based top-left fixture in the initial 8×8 land is Tide habitat (0,0), Light habitat (3,0), grotto (0,3), hatchery (3,3), farm one (5,3) and farm two (3,5). Use their stated footprints to verify bounds and non-overlap. Decorations cannot permanently occupy required tutorial placement space; allow free rearrangement.

One builder processes one construction or upgrade job at a time. Breeding, hatchery and crops have their own queues and do not occupy the builder. Costs are paid atomically when construction starts. Cancellation is allowed before completion and returns 80% of the Gold paid, rounded down; it never returns account XP because completion XP has not been awarded. Completed construction awards its one-time XP receipt once. Moving a completed building does not award XP again.

### Elemental habitats

There is one ordinary habitat type for each element. A ray may live in a habitat when at least one of its listed elements matches the habitat element. The first element remains its defensive battle element; residence does not change that. Empty habitats earn zero Gold. The resident rays determine income; the habitat determines capacity and the shared storage cap. This preserves the housing/economic relationship of the reference genre. [S1]

| Habitat tier | Ray capacity | Gold cap | Upgrade cost | Build or upgrade time | Account gate |
| --- | ---: | ---: | ---: | --- | ---: |
| Small | 2 | 500 | Base element price | 30 seconds | Element unlock |
| Large | 4 | 5,000 | 600 Gold | 5 minutes | 5 |
| Grand | 6 | 50,000 | 6,000 Gold | 1 hour | 10 |
| Monumental | 8 | 250,000 | 50,000 Gold | 4 hours | 15 |

Tide, Light, Bloom and Ember Small habitats cost 200 Gold. Stone costs 600, Storm 900, Frost 1,500 and Shadow 2,000. One Tide Small habitat is prebuilt at start. These prices affect city planning; choosing where a dual-element ray lives changes which storage bin fills. An upgrade pauses that habitat's income but retains its residents and stored Gold. Collect remains available while upgrading. Relocating a ray first settles both affected habitats to the current time.

### Building functions and gates

| Building | Function | Initial cost and gate | Upgrade direction |
| --- | --- | --- | --- |
| Farm | Pay Gold, grow a chosen crop, harvest Food | First free; later Small farms 200 Gold and 30 seconds | More crop choices and additional account-gated farm count |
| Breeding Grotto | Reserve two parents and produce one egg | 400 Gold, 60 seconds, account level 2 | Second breeding building at account level 12; no hidden odds bonus |
| Hatchery | Incubate eggs independently of breeding | First slot prebuilt | Slot 2 at level 5 for 1,000 Gold; slot 3 at level 10 for 50 Gems; slot 4 at level 15 for 100 Gems |
| Element Temple | Raise the trainable level ceiling for that element | Level 4 account; first tier 500 Gold and 5 minutes | Caps of 10, 20, 30, 40 and 50 through four paid upgrades |
| Ray Lab | Convert duplicates to species cells and rank individuals | 5,000 Gold, 30 minutes, account level 8 | One extraction/rank queue; later crafting and event recipes |
| Rune Forge | Equip and improve combat runes | 10,000 Gold, 1 hour, account level 10 | Basic deterministic rune improvement |
| Collection Book | Species, sources, parents and goals | Interface unlocked immediately | Discovery milestones and complete-set rewards |

The default trainable ray cap is 10 even without a Temple. A Temple begins at tier 1, also cap 10, and upgrades to tier 2/3/4/5 for 2,000/10,000/50,000/200,000 Gold with 10-minute/1-hour/4-hour/8-hour timers. All elements on a dual-element ray must satisfy its intended level cap. A Temple cannot reduce an existing ray's earned level if stored; storing is disabled while it supplies a required cap to an owned ray.

Farm count caps are one at account level 1, two at level 3, four at level 6, six at level 10 and eight at level 15. A second Breeding Grotto costs 20,000 Gold and takes two hours. Hatchery slot upgrades take 5/30/60 minutes respectively; occupied slots continue their existing jobs while a new slot is added. All upgrade prices and timers require balance validation.

### Full habitats and inventory

A completed hatch waits in its hatchery slot until there is compatible space. It does not disappear and does not auto-sell. The screen offers Upgrade habitat, Build compatible habitat, Move an eligible resident and Review duplicates. Showing this bottleneck is part of the city game. There is no free unlimited Guest Cove that bypasses housing capacity in the slice.

Do not permit an economy dead end: the player's last owned ray cannot be sold or extracted, a habitat containing a ray cannot be removed, and moving buildings is free. A valid resident therefore keeps producing Gold without requiring more Food. Later a storage Vault may provide non-productive reserve slots as an earned building; it is not needed to complete the slice and cannot be silently treated as a free starting inventory.

## 5 Ray collection and rarity

Each species has a fixed content ID, one or two ordered elements, rarity, base stat profile, Gold rate, learnable skill set, breeding routes and presentation data. Each owned individual has its own ID, nickname, level/feed progress, rank, equipped skills/runes, parent references, acquisition receipt and current habitat. Renaming never changes identity. Keep the existing species keys for the eight original names.

### Initial catalog

| Species key | Display name | Elements in defensive order | Rarity | Battle role | Main route |
| --- | --- | --- | --- | --- | --- |
| blueberry | Blueberry | Tide | Common | Attacker | Starter; founder shop |
| sunbeam | Sunbeam | Light | Common | Attacker | Founder shop |
| mossdrop | Mossdrop | Bloom | Common | Tank | Founder shop |
| emberfin | Emberfin | Ember | Common | Attacker | Founder shop |
| pebbleback | Pebbleback | Stone | Common | Tank | Founder shop |
| voltfin | Voltfin | Storm | Common | Controller | Founder shop |
| frosttip | Frosttip | Frost | Common | Controller | Founder shop |
| inkling | Inkling | Shadow | Common | Support | Founder shop |
| ripple | Ripple | Tide and Storm | Uncommon | Attacker | Tide × Storm |
| kelpskip | Kelpskip | Tide and Bloom | Uncommon | Support | Tide × Bloom |
| cindershell | Cindershell | Ember and Stone | Uncommon | Tank | Ember × Stone |
| cloudlet | Cloudlet | Storm and Light | Uncommon | Support | Storm × Light |
| pearlcloud | Pearlcloud | Tide and Light | Rare | Support | Tide × Light; guided first breeding |
| rosefin | Rosefin | Bloom and Light | Rare | Support | Bloom × Light |
| steamfin | Steamfin | Tide and Ember | Rare | Attacker | Tide × Ember |
| briarback | Briarback | Bloom and Stone | Rare | Tank | Bloom × Stone |
| snowglide | Snowglide | Frost and Storm | Rare | Controller | Frost × Storm |
| duskfin | Duskfin | Shadow and Tide | Rare | Controller | Shadow × Tide |
| moonpool | Moonpool | Shadow and Frost | Epic | Controller | Shadow × Frost |
| auroray | Auroray | Frost and Light | Epic | Support | Frost × Light |
| thornflare | Thornflare | Bloom and Ember | Epic | Attacker | Bloom × Ember |
| thunderstone | Thunderstone | Storm and Stone | Epic | Tank | Storm × Stone |
| solstice | Solstice | Light and Ember | Legendary | Attacker | Light × Ember with advanced eligibility |
| abyssal_bloom | Abyssal Bloom | Shadow and Bloom | Legendary | Support | Shadow × Bloom with advanced eligibility |

The six slice species are Blueberry, Sunbeam, Mossdrop, Pearlcloud, Kelpskip and Rosefin. This tests three elemental habitats, three rarities and both desired and duplicate breeding results. The remaining entries are a defined initial production target, not a claim that their finished skill kits or artwork already exist. A species cannot enter a release manifest until its full content record, acquisition path, art and battle tests are accepted.

### Rarity has consequences

| Rarity | Health and Power factor | Base Gold per minute at level 1 | Base level cap before ranks | Intended collection role |
| --- | ---: | ---: | ---: | --- |
| Common | 1.00 | 2 | 20 | Accessible founders and early economy |
| Uncommon | 1.12 | 3 | 25 | First hybrid improvements and useful role coverage |
| Rare | 1.28 | 5 | 30 | Desirable early and middle progression teams |
| Epic | 1.50 | 8 | 35 | Strong specialized teams and advanced targets |
| Legendary | 1.80 | 12 | 40 | Long-term breeding and team goals |

Rarity can add distinct learnable skills and stronger passive traits in accepted content, as well as the stated stat and cap differences. Speed does not receive a blanket rarity multiplier. A faster lower-rarity controller can therefore matter without requiring numerical equality across all species. The reference genre uses rarity as a power/progression distinction; v1.0's cosmetic-only rule is retired. [S3]

The Collection Book shows a silhouette, rarity, elements and permanent source hint for every initial species. Owned entries show discoveries, individual copies and breeding history. Never display all species as equally obtainable from every pair. A desired target can be pinned to the home objective card, which names the missing parent level, element, building, account gate or hatchery space.

## 6 Elements and battle attributes

Elements connect habitats, breeding outcomes, temples and combat. They must be shown with icon, name and color; color alone is insufficient. Use eight elements: Tide, Ember, Bloom, Stone, Storm, Frost, Light and Shadow. The old Nature and Moon labels become Bloom and Shadow in v2 content definitions, with explicit aliases if an old save actually needs migration. Species identity remains separate from an element rename.

### Effectiveness

The six-element cycle is Tide beats Ember, Ember beats Bloom, Bloom beats Stone, Stone beats Storm, Storm beats Frost, and Frost beats Tide. In the forward direction a damaging skill deals 1.5 times damage; in the reverse direction it deals 0.5 times damage. All other pairs in that group are neutral. Light and Shadow deal 1.5 times damage to one another; neither has a half-damage reverse because both directions are strong. Light/Shadow against the six-element cycle are neutral.

Use the skill's element against the target species' **first listed element**. The second species element provides habitat/Temple/breeding membership and access to skills, but does not multiply defense again. This is a deliberate simple Little Ray rule. The selection preview displays the actual modifier and estimated damage. There is no elemental immunity in the initial ruleset, so an imperfect team can still act.

| Attack against defense | Tide | Ember | Bloom | Stone | Storm | Frost | Light | Shadow |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Tide | 1 | 1.5 | 1 | 1 | 1 | 0.5 | 1 | 1 |
| Ember | 0.5 | 1 | 1.5 | 1 | 1 | 1 | 1 | 1 |
| Bloom | 1 | 0.5 | 1 | 1.5 | 1 | 1 | 1 | 1 |
| Stone | 1 | 1 | 0.5 | 1 | 1.5 | 1 | 1 | 1 |
| Storm | 1 | 1 | 1 | 0.5 | 1 | 1.5 | 1 | 1 |
| Frost | 1.5 | 1 | 1 | 1 | 0.5 | 1 | 1 | 1 |
| Light | 1 | 1 | 1 | 1 | 1 | 1 | 1 | 1.5 |
| Shadow | 1 | 1 | 1 | 1 | 1 | 1 | 1.5 | 1 |

### Stat calculation

| Role profile | Base Health | Base Power | Base Speed | Typical contribution |
| --- | ---: | ---: | ---: | --- |
| Attacker | 100 | 30 | 24 | Efficient single-target pressure |
| Tank | 150 | 22 | 16 | Absorb attacks and protect allies |
| Support | 120 | 24 | 22 | Healing, shields and recovery |
| Controller | 110 | 25 | 26 | Disrupt priority targets |

At level L and rank r, before runes, `Health = round(baseHealth × rarityFactor × (1 + 0.12 × (L − 1)) × (1 + 0.10 × r))`. Power uses the same formula with basePower. Speed is `round(baseSpeed + 0.4 × (L − 1) + r)`. Round positive .5 upward consistently in every client, test and server implementation. Maximum personal Stamina is 100 for all initial species. Runes apply after these calculations.

These shared profiles reduce initial content work. Accepted species records may override a base stat only through a reviewed balance change; visual rarity or large artwork never supplies an implicit bonus. With the formulas above, a level-4 Common attacker has 136 Health, 41 Power and 25 Speed. A level-4 Rare support has 209 Health, 42 Power and 23 Speed. These are arithmetic examples, not proof of balanced fights.

## 7 Gold Food Gems and farming

### Resource ledger

| Resource | Sources | Sinks | Storage and settlement |
| --- | --- | --- | --- |
| Gold | Housed-ray production, battles, quests, selling eligible duplicates | Crops, construction, expansion, breeding, extraction/ranking and rune upgrades | Wallet has no design cap; habitat bins have tier caps |
| Food | Completed farm crops, authored battle/quest rewards | Four feed pips per ray level | Wallet has no design cap; harvest once per crop |
| Gems | Authored quests, achievements, later verified event/season rewards | Optional finish-now actions and extra hatchery slots | Earnable in prototype; no real-money purchase flow |
| Account XP | Accepted quest milestones, first battle clears, completed buildings and harvested crops | Never spent | Cumulative account level; separate from ray training |
| Species cells | Lab extraction of eligible duplicates; authored later rewards | Ranking the same species | Inventory keyed by species; no universal conversion in initial design |
| Adventure Energy | Time, explicit quest grants | PvE entry | Maximum 10; one unit regenerated per 10 minutes |
| Arena tickets | Time, explicit rewards | Arena entry | Maximum 5; one ticket regenerated per 30 minutes |

The opening state is 1,200 Gold, 240 Food, zero Gems, full Adventure Energy, one level-1 Blueberry, one Tide Small habitat, one Small farm and hatchery slot one. The tutorial later awards 20 Gems once; the ordinary opening route spends none. Wallets and transaction arithmetic use integer units. No balance may become negative through a partial operation.

### Habitat production

For a housed ray at level L, `Gold per minute = rarityBase × (1 + 0.25 × (L − 1))`. Sum the rates of eligible residents. Rank affects income only indirectly when it permits higher earned levels; it has no additional income multiplier. A breeding reservation, selected party or active encounter does not remove the ray's production contribution. A Lab-reserved extraction candidate does stop contributing once the extraction job starts and cannot be used elsewhere.

Store fractional production without repeated rounding loss. One suitable exact representation is 240 income ticks per Gold: each whole elapsed second grants `rarityBase × (L + 3)` ticks per resident. Retain unspent fractional ticks and subsecond time remainder. Collection transfers whole Gold and leaves the fraction. Cap ticks at `habitatGoldCap × 240`; capped production does not queue another hidden payout.

Settle the old rate to the current time before a feed, resident move, extraction or upgrade changes it. An empty habitat produces zero. A level-4 Blueberry and Sunbeam each produce 3.5 Gold/minute; a level-4 Pearlcloud produces 8.75. Their combined rate is 15.75 Gold/minute before bins fill. Two level-4 Commons fill a Small habitat's 500-Gold bin in about 71.4 minutes. The higher storage tiers are necessary as the economy grows.

### Crop choices

| Crop | Time | Gold cost | Food yield | Food per minute | Farm tier |
| --- | --- | ---: | ---: | ---: | --- |
| Sprout Kelp | 1 minute | 20 | 40 | 40 | Small |
| Ribbon Kelp | 5 minutes | 100 | 180 | 36 | Small |
| Coral Berries | 30 minutes | 450 | 720 | 24 | Large |
| Sun Plankton | 2 hours | 1,800 | 2,520 | 21 | Large |
| Moon Plankton | 8 hours | 6,000 | 7,200 | 15 | Grand |

A Large farm upgrade costs 2,000 Gold, takes ten minutes and unlocks at account level 5. A Grand upgrade costs 10,000 Gold, takes one hour and unlocks at level 10. A farm can upgrade only while no crop occupies it. Short crops trade frequent interaction for better rate and conversion efficiency; long crops serve a planned absence. Finished crops do not rot, auto-harvest or automatically start another cycle.

Plant validates the selected recipe, farm tier, empty slot and Gold, then commits the debit and job once. Harvest grants Food and crop XP once, then frees the farm. The harvest XP values in recipe order are 5, 15, 40, 100 and 250. Completed jobs remain until claimed. A normal crop cannot be canceled for a refund after planting; show cost, duration and yield before confirmation.

### Feeding cost and growth demand

Four feed pips advance one level. Partial pip progress is saved. At current level L, a pip costs `ceil(5 × 1.5^(L − 1))` Food for L1–9, and `ceil(193 × 1.15^(L − 10))` for L10–49. Use exact decimal/rational arithmetic or a generated integer table so floating-point approximations do not change ceilings across clients. The per-pip cost depends on current level, not rarity. A level-up button previews all four remaining pip costs before committing; it cannot spend beyond the current legal cap.

| Target level from level 1 | Total Food |
| --- | ---: |
| 4 | 100 |
| 10 | 1,512 |
| 20 | 17,204 |
| 30 | 80,632 |
| 35 | 165,832 |
| 40 | 337,192 |
| 50 | 1,375,048 |

At six Grand farms running the eight-hour crop continuously, three timely daily harvests produce 129,600 Food/day for 108,000 Gold/day. That is a theoretical upper bound requiring the facilities, Gold and visits; it is not an observed player schedule. Three level-50 rays consume about 31.8 days of that ideal output from level one. Measure the real progression funnel before committing to a public completion-time promise.

### Gems and timer completion

The prototype has a visible 20-Gem tutorial completion grant and a finite achievement manifest. Do not award a grant again after reload or replay. Finish now costs `ceil(remainingSeconds / 120)` Gems for one selected breeding, hatching, crop or construction job. Display the exact price and affected job; confirm before spending. If a job has already completed when the command reaches settlement, charge zero. Finish-now changes completion time only; it never rerolls an egg or adds an extra reward.

Extra hatchery slots are convenience/capacity progression. The first two are available through Gold; a player who spends every earned Gem can still breed, hatch, grow Food and reach all 24 initial species with the ordinary queues. Payments, paid randomized offers and ad rewards require separate commercial and technical design before implementation.

## 8 Breeding eggs and the hatchery

Breeding is a recurring collection pursuit with meaningful uncertainty. The selected parents, their elements and the unlocked recipe determine a visible possible-offspring distribution. The player can pursue a desired hybrid, accept duplicates as useful resources, or broaden the pool with hybrid parents. Dragon City's official description connects parent elements to an offspring pool; Little Ray's exact probabilities and discovery adjustment below are authored rules. [S2]

### Parent eligibility and the ordinary pool

Parents must be two distinct owned individuals, each level 4 or above, placed in a compatible habitat, and free of another breeding reservation, extraction or pending destructive transaction. They may remain in a battle party and continue producing Gold while breeding. No player must bench their only useful team for an eight-hour breeding job. Pairing requires a free grotto and the displayed Gold fee. Parents are never consumed by breeding.

For ordinary pairings, consider one listed element uniformly from each parent. Average the conditional unordered element-pair tables across every combination, then merge identical offspring IDs. This produces one final probability distribution. If both sampled elements match, that element's Common founder is the only outcome. If a distinct pair has no eligible hybrid recipe, split the outcome 50/50 between its Common founders.

For an eligible Uncommon pair, the hybrid has 35% and each Common founder 32.5%. For an eligible Rare pair, the hybrid has 20% and each founder 40%, except Rosefin uses 15% with 42.5% per founder. For an eligible Epic pair, the hybrid has 8% and each founder 46%. Rarity is not rolled independently a second time. Ordinary species-to-element pairs are the catalog routes in Section 5.

Uncommon recipes require account level 3; Rare recipes require level 4. Epic recipes require account level 10, both parents level 15 and the relevant element Temple caps at least 20. Before these gates, the hybrid's probability is zero and the founder fallback applies; the preview names the unmet gate. Pure-element founders are deliberately useful for precise targeting. Hybrid parents broaden possibilities, rather than receiving a hidden rarity bonus.

| Slice pairing | Normal final outcome probabilities |
| --- | --- |
| Blueberry × Sunbeam | Blueberry 40%; Sunbeam 40%; Pearlcloud 20% |
| Blueberry × Mossdrop | Blueberry 32.5%; Mossdrop 32.5%; Kelpskip 35% |
| Sunbeam × Mossdrop | Sunbeam 42.5%; Mossdrop 42.5%; Rosefin 15% |
| Pearlcloud × Mossdrop | Blueberry 16.25%; Sunbeam 21.25%; Mossdrop 37.5%; Kelpskip 17.5%; Rosefin 7.5% |

The tutorial's first Blueberry/Sunbeam breeding is explicitly guided and produces Pearlcloud with 100% probability, a 60-second breed and 120-second hatch. It requires both parents level 4 and the tutorial milestone. Only that job receives the exception. The preview labels it Guided first breeding; later attempts use the ordinary tables. Buying a founder egg is also deterministic and is clearly a shop purchase, not breeding.

### Legendary recipes

Legendary recipes are explicitly selected named pairings that override ordinary element sampling. Solstice uses Auroray plus Thornflare; Abyssal Bloom uses Moonpool plus Rosefin. Both parents must be level 25, account level at least 18, and their relevant Temple caps at least 30. For those parents, the screen offers Ordinary elements and Legendary recipe as distinct modes. Ordinary mode remains available under ordinary eligibility. Legendary mode shows the complete named table and its unmet gates; attempting a locked mode is rejected without payment. Never silently switch modes, pools or fees.

Solstice's pool is Solstice 3%, Auroray 8%, Thornflare 8%, Sunbeam 40.5% and Emberfin 40.5%. Abyssal Bloom's pool is Abyssal Bloom 3%, Moonpool 8%, Rosefin 8%, Inkling 40.5% and Mossdrop 40.5%. These are permanent routes. The advanced parental chain makes earlier Rare/Epic breeding materially useful. No other pairing gains these Legendary outcomes merely by sampling the same two elements.

### Prices and two distinct timers

| Offered pool | Gold fee | Breeding time | Hatch time by actual offspring |
| --- | ---: | --- | --- |
| Same-element or ordinary Common/Uncommon/Rare pool | 100 | 5 minutes | Common 2 minutes; Uncommon 10 minutes; Rare 30 minutes |
| Pool containing an eligible Epic | 1,500 | 2 hours | Common 2 minutes; Epic 4 hours; any lower hybrid uses its rarity time |
| Named Legendary recipe | 10,000 | 8 hours | Common 2 minutes; Rare 30 minutes; Epic 4 hours; Legendary 12 hours |
| Guided first Pearlcloud | 100 | 60 seconds | 120 seconds, once |

Use the highest eligible tier in the final offered pool to select fee and breeding duration. The preview displays this before starting. A high-tier failed attempt still used the same breeding time; the actual hatch duration depends on the committed offspring. Ordinary Common shop eggs use a two-minute hatch, with Sunbeam's tutorial purchase shortened to 30 seconds. There is no second Food cost to hatch.

### Job lifecycle

At Start breeding, validate everything and commit the fee, two reservations, final distribution, selected outcome, appearance seed, future hatch duration and transaction ID together. A committed breeding job cannot be canceled to obtain another roll. The UI can conceal the offspring until the egg is ready, but the save cannot.

At the breeding deadline, release the parents. The ready egg remains in the grotto until transferred to a free hatchery slot; it still blocks another breeding in that grotto. Transfer starts a new hatch job and frees the grotto. At the hatch deadline, the egg is ready to place. Claim requires a compatible free habitat slot and creates one individual with one acquisition receipt. The hatchery frees only after that claim, or an explicitly confirmed sale of the ready hatch. A full hatchery and full habitats are intentional bottlenecks, with clear recovery controls.

Reward eggs may wait in a non-productive egg inbox until a hatchery slot is available. They are not owned battle-ready rays and cannot generate income, breed, rank or satisfy a requirement for an owned individual. Both reward and breeding eggs preserve their predetermined identity. No egg decays because the player is absent. The distinction between breeding and hatchery jobs is central to the reference genre. [S4]

### Discovery focus

The player may select one still-undiscovered species with a positive normal probability for this exact pairing. Discovery focus gradually raises that target's chance after misses. This is an explicit player-facing system, not an undisclosed guarantee. The target must meet its normal eligibility requirements. The collection ledger remembers successful production, so selling a ray or its ready hatch cannot make that species a first discovery again.

For attempt n for the selected target, let p0 be its final base probability for this pairing. Set `p = max(p0, min(cap, p0 + step × max(0, n − grace)))`. Rescale every other outcome to `oldProbability × (1 − p) / (1 − p0)`. A probability-one pool does not use focus. Display the resulting final percentages and the focus contribution before the player commits.

| Target tier | Grace attempts | Added chance per later eligible miss | Maximum focused chance |
| --- | ---: | ---: | ---: |
| Uncommon | 4 | 5 percentage points | 60% |
| Rare | 6 | 2.5 percentage points | 50% |
| Epic | 10 | 1 percentage point | 25% |
| Legendary | 20 | 0.5 percentage points | 15% |

Counters are keyed by species. Changing targets pauses the old counter; an ineligible pairing neither benefits nor advances it. Commit the chosen focus, effective distribution, outcome and counter transition with the job. Only one actively breeding focused job for the same target may exist across multiple grottos. At its breeding deadline, reveal the egg result and release that focus reservation. After a miss, another job may focus that target while the earlier egg is hatching. A successfully produced target permanently closes its focus even before hatching; selling its egg cannot reopen it. Resolve the final distribution with one categorical draw; do not resample parent elements afterward.

For a first Rosefin discovery with its 15% base pairing, this rule gives an expected approximately 5.73 attempts and a 90th-percentile count of twelve, under repeated eligible pairings and the stated focus settings. A hypothetical undiscovered 20%-base target would average 4.63 attempts with a 90th percentile of ten; a normal tutorial profile cannot use Pearlcloud as that example because its guided success already closes Pearlcloud focus. These calculations describe the authored lottery, not players' willingness to wait or evidence of good retention.

## 9 Levels growth ranks and duplicates

### Account progression

Account XP unlocks buildings, elements and modes. It is distinct from ray Food and never increases a ray's level directly. The cumulative threshold for account level k is `50 × k × (k − 1)`, starting at level 1 with zero XP. Level 2/3/4/5/10/20 therefore require 100/300/600/1,000/4,500/19,000 XP. Level-up screens identify specific unlocked choices rather than forcing every newly available purchase.

Tide and Light founders/habitats are available from the start. Bloom unlocks at account level 4; Ember 5, Stone 7, Storm 9, Frost 11 and Shadow 13. Common founder eggs cost 100/100/100/200/500/750/1,000/1,500 Gold respectively in that order. Unlocks make permanent shop sources visible. The guided tutorial grants the necessary account XP before asking for gated buildings or breeding; Section 13 specifies that sequence.

### Ray levels and visual growth

Ray level is derived from completed feed pips. The legal cap is the minimum of the species' rarity cap plus two levels per rank and every relevant element Temple cap. Without any relevant Temple upgrade, the cap is 10. Rank is an integer from zero through five. Even a rank-five Legendary cannot exceed level 50 under the initial Temple system.

New rays begin at level 1 with zero feed pips, unless a specific reward record explicitly says otherwise. Hatching does not secretly grant a battle-ready level. Levels 1–3 use a hatchling presentation, levels 4–9 a juvenile presentation and level 10 onward an adult presentation. All retain the cute manta silhouette. Growth may add size, wing markings and expressive confidence; it does not turn the cast into sharp-toothed monsters. For the slice, scale and a few authored accents can share a rig while preserving clear stages.

Learnable skill slots unlock at levels 1, 4, 7 and 10. Each species ultimately has at least six authored learnable skills, with four equipped at a time outside battle. Later learned alternatives arrive at levels 15 and 20. The slice must author its first three skills per species through level 7 and expose the fourth-slot requirement honestly. Do not fill locked slots with pretend abilities. A neutral basic and Recover are always available outside those four slots.

### Selling and ranking

Selling an eligible individual grants 25/50/150/750/3,000 Gold for Common/Uncommon/Rare/Epic/Legendary. Level and prior feeding do not increase resale value. Preview the exact individual, name and consequences, and require confirmation. Favorites must be deliberately unmarked before sale or extraction. A ray in a breeding reservation, current battle, Lab job or unresolved transaction cannot be removed. The last owned income-producing ray is protected.

After the Lab unlocks, extracting a duplicate consumes that individual and grants ten cells of its species. Extraction takes ten minutes and 100 Gold. A normal extraction can be canceled before completion, restoring the same reserved individual and refunding no fee. Committed completion removes it once and adds cells once; retained parent references remain historical records. Never replace those references with another individual that happens to have the same name.

Rank upgrades consume 10, 20, 40, 80 and 160 species cells for ranks one through five. Each rank increases the individual's Health and Power factor by ten percentage points, Speed by one and rarity level ceiling by two. Upgrade Gold costs are 500, 1,500, 5,000, 15,000 and 50,000, with durations 10 minutes, 30 minutes, two hours, four hours and eight hours. One Lab job runs at a time. A rank job reserves its target, charges once, preserves the target's ID and returns it with the added rank; no second consumption path accepts raw duplicates directly.

The expected resale value of an ordinary Tide/Light breeding is 50 Gold, below its 100-Gold fee. At 50% focused Rare chance it is 87.5 Gold, still below the fee. Focus ends on successful discovery. These limits prevent a repeatable breeding-and-sale Gold faucet while leaving useful duplicate decisions. Test all future outcome tables before adding them.

### Runes

The initial Rune Forge supports Health, Power and Speed runes. Each ray has slots unlocked at levels 5, 10 and 20. A tier-1 through tier-5 rune adds 2%, 4%, 6%, 8% or 10% to its chosen final stat; bonuses of the same type add before one final rounding. Stamina remains 100. A tier-1 rune costs 1,000 Gold; improving a rune by one tier costs three additional runes of its current type/tier plus 1,000/3,000/10,000/30,000 Gold for the resulting tiers two through five. The selected rune retains its ID; ingredients are consumed once.

Equipping and removing runes outside battle is free in the initial design. Snapshot equipment when a battle starts and prohibit changing that snapshot mid-encounter. This gives later team-build depth without adding another random stat-roll economy. Runes and Lab progression follow the representative slice; they are defined product systems, not substitutes for getting the basic city and combat loop working.

## 10 Three versus three battles

Combat is a central progression system. The player selects three distinct owned rays, arranges their slots and chooses their equipped skills. All three allies and all three opponents appear on the field. Each has individual Health, Power, Speed, 100 Stamina and independent skill cooldowns. No team-wide Energy meter, active/reserve swap command or universally telegraphed opponent script remains from v1.

### Turn sequence

At battle start, snapshot both teams' level, rank, skills, runes and derived stats. Reset battle Health, Stamina, statuses and cooldowns. Seed deterministic tie resolution and any authored AI variation; save the seed and state. No combat outcome edits the source species definition or consumes the owned individual.

At each round start, sort living actors by effective Speed descending and use a saved shuffled order for exact ties. Every living actor receives one scheduled turn; Speed changes order, not the number of turns. Speed changes during a round affect the following round's order. An actor knocked out before its scheduled turn is skipped. The initial content has no revival or extra-turn effects, avoiding hidden exceptions to this contract.

At an actor's turn, apply start-of-turn effects, then check whether the actor is still conscious or Stunned. A conscious unstunned player actor selects a legal action and target. Resolve costs, damage/healing, effects and cooldown changes atomically. Process cooldown passage and status expiry for that actor, then advance the saved action boundary. Do not wait for animations to decide a rule or grant a reward.

Basic is always available: neutral single-target damage equal to 0.6 × Power, zero Stamina and zero cooldown. Recover consumes the turn and restores 50 personal Stamina, up to 100. These actions sit beside the four equipped skill slots. A depleted or poorly matched team retains a legal choice without a compulsory consumable.

### Damage healing and cooldowns

Damage is `max(1, round(effectivePower × skillCoefficient × elementModifier))`, rounded once at the end. Effective Power includes the current Power Down once; do not also apply it as a second damage multiplier. The first version has no random critical hit or accuracy roll. Single-target attacks honor Taunt; an area attack still affects all legal living targets. A shield absorbs damage before Health. Healing is `round(casterEffectivePower × healingCoefficient)` and cannot exceed the target's maximum Health. Healing has no elemental multiplier.

A skill with cooldown N cannot be used for N subsequent turns of that actor. At action cleanup, decrement every other positive skill cooldown by one, then set the chosen skill to N. A Stunned actor still passes a turn and decrements all cooldowns. Example: a cooldown-two skill used on turn T0 is unavailable on T1 and T2 and available on T3. Use UI labels that match this rule. The initial content has no cooldown-reset effects.

### Initial effect rules

| Effect | Rule | Lifetime and stacking |
| --- | --- | --- |
| Shield | Flat damage absorption | Retain the larger current/new amount; do not add; expire after the target's next two completed turns |
| Taunt | Opposing single-target hostile actions must select a conscious taunter | One subsequent completed turn of the taunting actor; if several exist, choose among them |
| Power Down | Reduce target Power by 25% before action calculation | Two completed target turns; refresh duration, never stack magnitude |
| Speed Down | Reduce effective Speed by 20% | Two completed target turns; next-round ordering; no magnitude stacking |
| Poison | Deal 8% maximum Health at start of target turn | Three ticks; refresh to three, not additive |
| Stun | Skip one target action | Cannot refresh while already Stunned; afterward immune to Stun through the next completed normal turn |

A newly applied effect does not expire in the cleanup of the action that created it. Track application action ID and target turns, not animation seconds. Poison deals `max(1, round(maximumHealth × 0.08))` directly to Health, bypassing shields; it is non-elemental, can knock out a ray and consumes one of its three ticks. A cleanse removes negative statuses, including Stun/Poison/Power Down/Speed Down, but not an ally's shield, taunt or control immunity. Removing Stun by cleanse grants the same immunity through the next completed normal turn as resolving its skipped action. Effects on a knocked-out actor are removed. No shield or heal can produce Health above maximum or restore a knocked-out actor under the initial rules.

### Six species skill contract

Each row is a learned skill, with the element indicated for damaging actions. Cost is personal Stamina; CD is the cooldown defined above. A skill may be equipped only after its level requirement. The four initial skills per species support the first progression build; later level-15/20 alternatives need separate accepted content records.

| Species and level | Skill | Effect | Cost | CD |
| --- | --- | --- | ---: | ---: |
| Blueberry 1 | Tide Bolt | Tide single target, 1.1 × Power damage | 15 | 0 |
| Blueberry 4 | Tail Splash | Tide all enemies, 0.55 × Power damage each | 25 | 2 |
| Blueberry 7 | Current Jolt | Tide single target, 0.85 × Power damage; remove 20 target Stamina | 25 | 2 |
| Blueberry 10 | Tide Surge | Tide single target, 1.6 × Power damage | 35 | 3 |
| Sunbeam 1 | Sun Spark | Light single target, 1.15 × Power damage | 15 | 0 |
| Sunbeam 4 | Warmth | Heal one living ally, 1.0 × Power | 25 | 2 |
| Sunbeam 7 | Radiant Ray | Light single target, 1.0 × Power damage and Power Down | 25 | 2 |
| Sunbeam 10 | Solar Flash | Light all enemies, 0.75 × Power damage each | 35 | 3 |
| Mossdrop 1 | Vine Bash | Bloom single target, 1.0 × Power damage | 15 | 0 |
| Mossdrop 4 | Root Guard | Self Taunt and shield of 1.2 × Power | 25 | 2 |
| Mossdrop 7 | Leech Current | Bloom single target, 0.9 × Power damage; heal self for half actual Health lost by target | 25 | 2 |
| Mossdrop 10 | Verdant Stand | Heal living allies for 0.5 × Power each and apply self Taunt | 35 | 3 |
| Pearlcloud 1 | Pearl Bolt | Tide single target, 0.9 × Power damage | 10 | 0 |
| Pearlcloud 4 | Cloud Mend | Heal one living ally for 1.2 × Power | 30 | 2 |
| Pearlcloud 7 | Pearl Veil | Shield all living allies for 0.8 × Power each | 35 | 3 |
| Pearlcloud 10 | Stamina Wave | Restore 50 Stamina to each other living ally | 35 | 3 |
| Kelpskip 1 | Kelp Wisp | Bloom single target, 0.9 × Power damage | 10 | 0 |
| Kelpskip 4 | Sea Snack | Restore 35 Stamina to one other living ally | 20 | 2 |
| Kelpskip 7 | Clean Current | Cleanse one living ally and heal 0.6 × Power | 25 | 2 |
| Kelpskip 10 | Tangle Shot | Tide single target, 0.85 × Power damage and Speed Down | 30 | 3 |
| Rosefin 1 | Rose Ray | Light single target, 1.0 × Power damage | 10 | 0 |
| Rosefin 4 | Bloom Mend | Heal one living ally for 1.5 × Power | 30 | 2 |
| Rosefin 7 | Blossom Pulse | Heal all living allies for 0.7 × Power each | 35 | 3 |
| Rosefin 10 | Thorn Ward | Shield one living ally for 1.5 × Power | 30 | 3 |

The selected action shows valid targets, element effectiveness, estimated damage/heal and resulting Stamina. Inspecting an enemy reveals elements, stats, statuses and equipped skills. The player does not automatically see the enemy's next choice. An early tutorial can explain a predictable demonstration, but that cannot become a permanent all-enemy-intents rule.

### AI and encounter resolution

The initial AI uses visible legal rules: attempt an immediate knockout when available; otherwise heal a critically injured ally if useful, apply protection/control to a relevant threat, then choose effective damage. Content may supply weighted priorities and deterministic seeded ties. It cannot read the player's next input or obtain hidden damage/turn bonuses. Record the policy version for reproducible QA.

Resolve every target and consequence of an action before checking termination. Also check termination after the complete start-of-turn status batch, before offering an action; a Poison knockout cannot leave an empty team waiting for input. When all opponents are knocked out and an ally remains, the player wins. All allies knocked out is defeat; simultaneous elimination is also PvE defeat. A victory during round 30 is valid; if both teams remain after round 30, timeout is defeat. All owned rays remain owned, and later battles begin with full battle Health/Stamina. Defeat consumes the entry resource but no creature, Food or equipment.

Pause and save at action boundaries. Resuming continues the same battle and seed rather than refunding entry or rerolling a reward. Abandon is a confirmed loss. A battle result is settled by exactly one encounter owner; a result screen, animation or return-home screen cannot pay it again.

## 11 Adventure map quests and account unlocks

The Adventure Map has four regions of ten nodes each. Every node presents an enemy team, energy cost, first-clear rewards, repeat rewards and star conditions. Node five in each region is a miniboss team; node ten is a guardian plus two escorts. All use the same three-versus-three turn contract. A guardian's difficulty must come from disclosed stats, skills and team composition, not invisible extra turns.

| Region | Initial enemy-level range | Team emphasis | Main progression purpose |
| --- | --- | --- | --- |
| Sunlit Coast | 3–8 | Basic damage, healing, first elemental counter | First hybrids, farms, first city expansion and island-two gate |
| Verdant Shoals | 8–16 | Tanks, shields, mixed elements | Temple upgrades, Rare collection and first Lab/ranks |
| Stormglass Reach | 16–26 | Speed, control, Stamina planning | Epic breeding and rune decisions |
| Midnight Trench | 26–38 | Coordinated advanced teams | Legendary preparation, high-tier city and continuing Arena goals |

The initial 40-node target is not yet 40 authored encounter records. Production must supply each exact team, levels, skills, AI policy, reward receipt and star budget. Do not generate arbitrary higher enemy levels as a substitute for encounters that teach and test a clear choice.

### First three encounters

Encounter one uses level-3 Common Blueberry, Emberfin and Mossdrop opponents, each with its first learned skill. The intended entrant is Blueberry, Sunbeam and Pearlcloud at level 4, with all legal learned slots equipped. This teaches selecting an element and deciding when to heal. Encounter two uses level-4 Blueberry, Sunbeam and Mossdrop and includes the level-4 skills. Encounter three uses level-5 Mossdrop, level-4 Kelpskip and level-4 Blueberry, introducing a protected support. Neither a newly hatched level-1 Pearlcloud nor debug-only stats count as this intended entry fixture.

The opposing Emberfin's slice skill is Ember Dart: Ember single-target damage at 1.1 × Power, cost 15, CD0. Its level-4 alternative is Flare Sweep: Ember all-enemy damage at 0.55 × Power each, cost 25, CD2. Emberfin is an opponent-only content record in the six-collectible slice and must have an actual temporary or representative battle sprite; it is not silently counted as a seventh collectible.

### Energy rewards and stars

Normal encounters cost one Adventure Energy; miniboss and boss encounters cost two. Entry is charged only when a valid encounter starts. Maximum Energy is ten, with one regenerated per ten elapsed minutes. Entry refusal consumes nothing. A failed battle or intentional abandonment does not refund Energy. Practice mode is free and grants no economic rewards, account XP, quest credit or stars.

The first three nodes each grant 150 Gold, 40 Food and 100 account XP on first clear. Subsequent clears grant 25 Gold and ten Food, with no additional first-clear XP. For later nodes, use an explicit authored reward manifest; initial default budgets are first-clear Gold `150 + 25 × (nodeIndex − 1)`, Food `40 + 10 × (nodeIndex − 1)` and 100 XP, with boss rewards doubled. Default repeats pay one sixth of the first-clear Gold and one quarter of Food, rounded down. Actual manifest values override defaults visibly. No battle grants direct ray levels.

One star means win. A second requires all three allies surviving. A third additionally requires completing within six rounds. These conditions are shown before entry and may be overridden for a specific authored encounter only with an explicit visible objective. Each star milestone reward is claimed once. Replays remain useful for stars, modest resources and tactical experiments while farms and habitats remain the production backbone.

### Quests and continuing play

The main quest chain teaches the full city/breeding/battle loop and points toward the next account unlock. Collection goals ask for specific species or element families; achievement rewards are finite, receipt-backed and visible. Daily objectives can reward ordinary farming, breeding and battles, but their reward budgets and reset times must be stated in content data. Do not invent a second hidden daily progression requirement in an implementation task.

Clearing the fourth region unlocks a completion reward and continuing challenges. It does not remove the city, reset the roster or declare the product finished. Repeat bosses, stars, ranks, missing species, bigger production and Arena progression supply ongoing goals; later content extends those tracks.

## 12 Arena teams and recurring events

### NPC Arena in the initial progression build

NPC Arena unlocks at account level 8 and uses authored AI teams. It shows an explicit NPC label, actual team details and a separate local rating. Wins grant 20 local rating, 100 Gold and 20 Food; losses remove ten rating down to zero. An entry costs one Arena ticket. Tickets cap at five and restore one per 30 minutes. A free no-reward practice rematch remains available.

Offer three authored opponents near the current progression band and record the chosen snapshot at entry. A roster refresh is available every fifteen minutes and changes no active match. NPC Arena is useful for build testing and local progression; its rating is never imported as a verified online leaderboard score.

### Connected asynchronous Arena

The connected product has separate attack and defense team slots, three rays each. Defense is a saved snapshot controlled by AI when challenged. Use different individuals across the two assignments in the initial online rules, encouraging a broader roster. Ordinary city income and breeding remain available. Match starts validate ownership, equipment, costs and the selected defense revision on the server. The client cannot declare a win or choose its own rewards.

Use a proposed 28-day season with Bronze, Silver, Gold, Pearl, Diamond and Master bands beginning at 0, 500, 1,000, 1,500, 2,000 and 2,500 rating. A provisional Elo-style update uses K24 and the recorded pre-match ratings. Clamp rating to zero at the bottom. The server settles attacker/defender changes and any protection rules once, with visible results. Final reward amounts and protection duration must be approved in a separately tested season manifest before this mode launches.

Matchmaking should consider rating and available team power while providing a choice of opponents. The exact bands need observed queue population and fairness evidence. Do not promise live synchronous battles from an asynchronous defense system. Live PvP is a later distinct mode with its own networking and turn-time design. Official Monster Legends multiplayer documentation distinguishes team selection, attack/defense assignments, trophies and tournament rewards; these are the structural references, not a verified Little Ray service. [S7]

### Events and teams

Recurring collection events can introduce a themed breeding pool, earnable eggs, cells or skins through normal city/battle actions. The event panel states start/end time, eligible actions, point caps, reward thresholds and the permanent route for any initial-roster species. An egg already produced retains its committed contents after the event ends. Event expiry cannot remove a purchased/earned ray or retroactively reroll a job.

Teams and cooperative competitions follow connected Arena. Initial team goals should combine verifiable battles and collection contributions, with shared milestones and a clear contribution ledger. Team Wars require an authored preparation/attack/reward schedule and server-backed settlement. Exact team sizes, chat features, event budgets and social reward values remain separate content/service decisions; they do not block the offline representative slice.

An optional seven-claim login calendar may provide modest resources and a final cosmetic reward. Missing a day does not erase earlier claims. This is a proposed supporting feature, not a replacement for collection or a requirement for building the first city loop.

## 13 First session interface and onboarding

### A budgeted first cycle

The player starts with Blueberry and the prebuilt Tide habitat, farm and hatchery, 1,200 Gold and 240 Food. Each tutorial milestone is claimed once. Additional generic completion/harvest XP can unlock something earlier; the milestone sequence below supplies a guaranteed lower bound so no required gate depends on an unavailable activity.

| Step | Player action and visible change | Unlock or committed reward |
| --- | --- | --- |
| 1 | Select/name Blueberry and collect a sample production bubble | 100 account XP; level 2 makes the grotto available |
| 2 | Buy Sunbeam's 100-Gold egg, hatch it in 30 seconds, build a 200-Gold Light habitat and place it | 200 milestone XP; at least level 3 and second farm access |
| 3 | Feed both founders to level 4 and construct the 400-Gold grotto | 300 milestone XP; at least level 4, ordinary Rare recipes and Bloom unlocked |
| 4 | Start the labeled 100-Gold guided pairing, then transfer its egg to the separate hatchery | 60-second breeding and 120-second hatch demonstrate two queues |
| 5 | Build a second 200-Gold farm, grow two 20-Gold one-minute crops, hatch Pearlcloud and feed it to level 4 | 150 milestone XP; three legal level-4 teammates |
| 6 | Equip available skills and win encounter one, then inspect the first land expansion | First clear 150 Gold, 40 Food and 100 XP; tutorial completion 150 XP and 20 Gems |

Generic building completion awards 50 account XP per newly purchased building and 25 per upgrade, once per receipt. Tutorial prebuilt facilities do not award construction XP. The sample production bubble in step one is exactly ten Gold, a one-time tutorial receipt independent of elapsed-time production; it is not required by the opening affordability calculation below.

The listed purchases, first breeding and two crops cost 1,040 Gold, leaving 160 before production, tutorial sample or battle rewards. Feeding all three rays from level 1 to level 4 costs 300 Food; 240 starting Food plus 80 harvested Food leaves 20. The first battle makes at least 310 Gold available before passive income, enough for the first 250-Gold sector and its 50-Gold starter obstacle clearance. Clearing that obstacle takes 60 seconds and awards ten account XP. Later obstacle records use explicit footprint/cost/time data and never respawn for repeat XP.

This is a calculation of affordability, not a measured claim that every player finishes within a particular minute. The target is a clear first complete cycle in roughly 15–30 minutes, followed by the visible goals of Mossdrop, Kelpskip/Rosefin, larger storage, more land and a second hatchery slot. A player pursuing all six slice species uses the ordinary probabilities and may need multiple visits.

### Home and system screens

The home HUD shows Gold, Food, Gems and account level, with a current goal, Build/Shop, Collection, Breeding/Hatchery, Adventure and Arena destinations. Timed jobs have recognizable building states and a compact queue overview. Tapping a finished building claims only that building's completed output; Collect all can unlock as a quality-of-life feature after the basics are understood.

The ray detail screen emphasizes portrait, rarity, ordered elements, level, four feed pips, Gold rate, battle stats, skill loadout and rank. Parent history and nickname remain available below these core progression controls. The breeding screen compares two parents, displays all possible offspring, actual probabilities, focus adjustments, fee, breeding duration and possible hatch durations. The hatchery shows separate slots with eggs and their remaining incubation.

The build screen filters by type, element and unlocked status. It previews footprint, price, storage/capacity and upgrade gains. It must explain whether a hatch is blocked by element mismatch, a full compatible habitat, occupied hatchery or insufficient land. Do not return a generic error when the actual next action is known.

### Input and accessibility

Use direct tap/click selection and drag placement with explicit confirm/cancel; supply keyboard focus and move controls as alternatives to dragging. Required controls have visible labels and touch targets of at least 44 CSS pixels in the served layout. Show element names with icons/colors, rarity names with frames and statistics, and battle effects with text/icons as well as animation. No essential information depends on sound alone.

Support readable text scaling, reduced motion, volume settings and paused turn selection. Timers advance with elapsed time, not with animation speed. A faster battle-animation setting cannot give extra actions or improve reward odds. Keep the first session focused on one new system at a time, but allow the player to inspect the collection and future unlocks without forcing a long tutorial dialog sequence.

## 14 Art animation audio and presentation

### Mascot and city identity

The cast remains cute manta rays: a soft protruding snoot, one large friendly near eye in side view, broad floppy wings, a pale underside and a long tapering tail. Distinguish species through silhouette accents, large readable motifs, color blocks and elemental effects. Rarer rays should be more elaborate and desirable while still belonging to the same recognizable manta family. Avoid converting higher tiers into unrelated dragons, humanoids or realistic predatory adults.

Use the established Blueberry/Sunbeam/Pearlcloud concept cover as reference for creature identity, not as a specification for a low-density sanctuary-only game. The city must look like a creature-collection management game: multiple productive habitats, growing crops, eggs in visible slots, a conspicuous breeding building, Gold collection bubbles, construction and locked expansion land. Representative screenshots need to communicate those functions immediately.

The existing Blueberry pixel-versus-small-cartoon trial remains useful. Compare both at the same actual gameplay size against the city HUD and a crowded habitat. Select one treatment before multiplying the roster. The 96×96 source canvas is still a trial, not a mandatory on-screen dimension. Record pivots, padding, filtering, palette, growth-stage treatment, cosmetic masks and export settings together. Creature portraits must support rarity/element frames and clear team selection.

### Environment and rarity readability

Tide uses aqua water and flowing channels; Light uses warm pale stone and sunlit surfaces; Bloom uses kelp and rounded living coral; Ember uses warm vents and orange stone; Stone uses broad gray rock shapes; Storm uses cool energized structures; Frost uses pale ice-glass forms; Shadow uses deep violet pools with readable highlights. Do not turn darker elements into unreadable UI backgrounds.

Rarity has named frames and icons as well as increasing visual ceremony. A Rare hatch receives a stronger reveal than a Common, and an Epic/Legendary reveal celebrates a real progression event. Skip is available after the ownership transaction commits. Skipping changes only presentation; closing a reveal never loses an egg or grants it twice. Common duplicates still need fast, legible Keep/Sell/Lab-next-goal information without repetitive lengthy celebration.

### Animation requirements

Shared groups cover city swim/idle, turn, greeting, feeding, level-up/growth, breeding start, egg readiness, hatch, attack cast, impact, shield/heal, knockout and victory. A knocked-out ray leaves the action clearly and returns intact after battle. Battle poses and VFX should make all six combatants, targets and effects readable simultaneously. Do not reuse a single active-ray camera that hides two teammates.

Selection acknowledges immediately, feeding synchronizes the accepted Food debit with a pip/stat change, and a habitat collection clearly moves stored Gold into the wallet. Construction and crop progress are readable from a distance. Ordinary reactions target approximately 0.5–1.2 seconds; a special hatch can use 3–5 seconds with Skip. These are feel hypotheses; every rule and reward remains independent of animation length.

The representative slice requires the six collectible species plus an opponent-only Emberfin battle presentation. Temporary opponent art must be labeled in the asset manifest. The six collectibles need representative hatch, feed, city and battle behavior; a debug rectangle cannot establish whether their collection appeal works.

### Sound and music

Use distinct city, adventure-map and battle musical families. Battle music can be energetic and competitive while the creatures remain cute. Give breeding start, egg transfer, hatch rarity, crop harvest, Gold collect, level-up, skill impact, control effects and victory recognizable cues. Preserve a visible equivalent for every rule-bearing sound.

Unlock audio after a user gesture and retain volume preferences. Test multiple simultaneous effects, paused/resumed tabs and the actual web export. An editor-only sound audition is insufficient evidence for hosted audio. Record source/generation provenance and permitted use for every shipped asset. Original reference-game screenshots and Fish World reference images remain references, not runtime files.

## 15 Technical state persistence and delivery

### Existing runtime work

Continue the architect's Godot/GDScript web-delivery spike and verified engine/template pin. The initial direction remains Compatibility rendering and a single-thread web export, subject to the actual host's behavior. Reuse successful input, audio, local-save, backup and deployment-probe work. This GDD revision does not authorize discarding another role's branch or claiming its unobserved runtime criteria are complete.

The architect must observe the served game in its actual embedding context and record exact source/export/build identity. A static page, uploaded archive or deployment receipt does not establish that WebAssembly, input, audio, storage and recovery work. Performance targets begin at 60 fps on a declared desktop and 30 fps on a declared touch device, with measured budgets revisited after a representative city and six-actor battle exist. Do not state a download-size or device-support result without measurement.

### Separate content and owned state

Content records define species, elements, stat profiles, skills, breeding tables, crops, buildings, account gates, quests, encounters and reward bundles. Player records define owned individuals, buildings and sectors, wallets, collection flags, cells/runes, jobs, quest receipts, energy/tickets, battle snapshots and settings. Keep the old species keys; new species receive new stable keys. A balance patch must not change an existing individual's identity or reroll a committed egg.

Use small commands that validate a complete operation and commit once: Collect habitat, Plant, Harvest, Feed, Build, Expand, Start breeding, Transfer egg, Hatch, Sell, Extract, Rank, Start encounter, Act and Settle result. Each accepts an operation ID, expected profile revision and explicit target IDs. Scenes show committed events; they cannot independently award the same output.

### Timers and offline settlement

Use one reconciled nonnegative elapsed-time budget across the profile. Active play uses monotonic elapsed time. On resume, compute an eligible wall-clock gap, clamp negative elapsed to zero and cap a single reconciliation at seven days. That accommodates all initial multi-hour jobs; habitat bins, energy and tickets stop at their own caps. Crops and eggs complete at most once and remain waiting; there are no automatic extra farm or breeding cycles.

The v1 eight-hour aggregate credit cap is retired because it would conflict with a twelve-hour hatch. Persist the reconciled time marker and remainders so repeating the same resume cannot pay again. Clock rollback cannot reverse a finished job or remove earned resources. A large local clock jump can advance the local prototype under this policy; it is not an anti-cheat system. Connected competition must use authoritative server time and validated transactions.

Settle deadline events in chronological order and integrate production piecewise between them. Construction/upgrades take effect automatically at their deadline, including their one-time completion XP; they do not wait for a collection tap. A habitat upgrade pauses production only until its completion time. Two level-4 Commons at seven Gold/minute, starting an empty-bin five-minute upgrade and returning after sixty minutes, produce 385 Gold during the remaining fifty-five minutes. Applying either the paused or upgraded state to the entire absence would be incorrect. Crops, ready eggs and hatches still wait for their explicit collection/transfer/placement actions.

Energy and ticket regeneration discard overflow when at cap. Preserve only the eligible fractional interval below cap; spending from a full meter starts its next regeneration interval from the spend time. A long absence at full energy cannot become an invisible bank that instantly refills later entries.

### Save integrity and interrupted actions

Autosave committed economic actions and stable battle action boundaries. Keep a validated current save and previous-good recovery copy with schema/content version and profile revision. Show Saving, Saved or Save unavailable honestly. Never overwrite an unreadable save with a blank city without an explicit recovery choice. Export and import a portable backup; validate a candidate and preview it before replacing the active profile.

Persist both breeding and hatchery jobs, parent reservations, offspring identity, exact distributions/focus snapshot, receipts and deadlines. A transfer is one transaction removing the ready egg from one facility and adding the hatch job to another. A hatch claim creates an individual and clears its slot once. Result/reveal UI can be replayed, but an acquisition or battle reward cannot.

One open tab owns writes for a local profile. A second tab is read-only until an explicit takeover. Check revisions so a stale tab cannot silently replace progress. Backups are data, not executable code. Unsupported newer schema or unknown content IDs require preservation and an honest explanation, not deletion or free replacement rewards.

### Local and connected profiles

The first representative slice is local single-player. Connected Arena needs accounts, server-authoritative progression/time, validated battle settlement and recovery; these are separate production tasks. Do not trust an arbitrary local save as proof of competitive ownership, Gem balance or ranked wins. Retain local play when connected services are unavailable. Any migration or founder grant into online profiles must have an explicit verified policy; do not promise unrestricted import before that policy exists.

### Version one migration

First inspect actual saved fixtures and deployed evidence. The repository previously contained a design, not proof of a released v1 economy. Do not invent a user migration for a nonexistent build. If v1 profiles exist, preserve their backup and stable individual/name/parent records, map their known levels through the old XP table to v2 feed state, and review housing/currency conversion deliberately.

A provisional conversion can retain numeric Pearls as Gold, retain Food, preserve ownership and place old homes on enough granted grid sectors to fit. Retire old Guest Cove into an explicit migration holding state that grants no income and requires no deletion. Reconcile any old nursery job into a predetermined v2 egg without rerolling. These conversion choices need real fixtures and tests before execution; an unsupported profile must remain exportable. GDD archival preservation is required regardless of whether a save migration is needed.

## 16 Content production and balance ownership

### Required records

The content manifest must be sufficient to build the game without recovering rules from an old chat. Each species record includes stable key, display name, ordered elements, rarity, stat profile, income tier, growth art, learned skills, source routes and asset provenance. Each breeding recipe includes mode, eligibility, final-table construction, fee, breed duration, hatch rules and content version. Each building/crop/encounter record includes its complete cost, time, output and unlock conditions.

One designated gameplay data owner maintains shared tuning. Art files do not grant stat bonuses, UI labels do not determine rarity, and a scene cannot substitute a guessed crop reward. Validate that all probabilities sum to one, every initial species has a reachable route, every required element has a founder source and habitat, all prerequisites are acyclic, and every referenced skill/asset/content ID exists. Keep source IDs and saved individual IDs distinct.

### Production groups

The first group is the six-species representative slice and one opponent-only Emberfin presentation. The next group adds Ember/Stone/Storm founders and their early hybrids, region two and the first Lab/Temple depth. The third adds Frost/Shadow and the Epic chain, later regions and runes. The fourth completes both Legendary chains, remaining node/star budgets and the initial 24-species progression build.

Before multiplying art, measure accepted effort for one complete species: portrait, city idle/swim, growth treatment, hatch, feed, battle action, damage/knockout and export integration. Before estimating forty encounters, measure one accepted regular team, one support/control team and one guardian team. Report real rework and integration time. Do not convert an AI's ability to list names into an assumed daily content throughput.

### Balancing order

First establish that the city physically fits and the onboarding can afford its required actions. Then establish the breed/hatch pipeline and first three-ray battle. Next test income/crop demand, duplicate value and account unlock pacing across repeated visits. Only then tune the full rarity/Temple/rank ladder and competitive budgets.

Track Gold produced/collected/capped, crop spend and harvest, feed spend, creature level distribution, breeding attempts/outcomes/focus, hatchery blocked time, compatible housing shortages, encounter entries/results/rounds and future connected match results. Define the unit and denominator for every metric. Simulated sessions are useful for identifying deadlocks or runaway resources but cannot establish engagement or acceptable waiting.

If the content budget is too high, reduce the initial number of species, islands or authored nodes while preserving all defining systems in a smaller sample. Do not cut resident income, farms, separate queues, meaningful rarity or multi-unit battles and still describe the result as the requested clone-like game. Any material product-scope reduction should be recorded as a proposed revision, not silently substituted by an implementation agent.

## 17 Representative slice and team handoff

### Minimum faithful playable outcome

A new player builds the early city, collects ray-generated Gold, plants and harvests crops, feeds two founders to breeding level, starts a breeding job, transfers its egg to a distinct hatchery, places and trains Pearlcloud, assembles three rays, wins an actual three-versus-three adventure encounter and buys the first land expansion. The same profile then supports ordinary uncertain breeding toward Kelpskip and Rosefin, with Mossdrop as the third founder.

The slice includes six collectible species, three player housing elements, Common/Uncommon/Rare, four initially owned sectors and one purchased sector, two farms with the one/five-minute crops, ordinary Small/Large habitats, one grotto and one hatchery slot with the Gold-funded second-slot upgrade. Account/feeding caps through level 10 and the three authored encounters are enough to prove the opening. A full 24-species implementation, Lab/runes, network accounts and real PvP are later stages.

Pearlcloud's tutorial guarantee is not sufficient proof of the breeding system. QA must exercise at least one normal random pool, a duplicate result, an undiscovered target, the hybrid-parent mixture and a blocked hatchery. The successful first battle must use all three actors on each side under the specified turn model. A one-active-ray Practice Pool does not satisfy the new acceptance criteria.

### Existing and revised tasks

Keep existing work and stable task IDs where the responsibility remains useful. Detailed issue bodies and the current first-slice map own live status. The design revision itself is DIRECTOR-002; historical DIRECTOR-001 intake stays complete.

| Task | Owner | Revised deliverable and dependency |
| --- | --- | --- |
| ARCH-002 | architect | Continue actual-host Godot/input/audio/timer/save/backup proof; expose small content/state interfaces compatible with two job types and the city |
| ART-002 | art-audio | Preserve Blueberry identity and choose one treatment at actual scale against functional city and six-actor battle presentation |
| ART-003 | art-audio | Six collectible presentations, opponent Emberfin battle art, elemental buildings/crops/eggs and representative battle cues; needs chosen style and runtime interfaces |
| GAMEPLAY-002 | gameplay | City grid/land, compatible habitats and resident Gold, farms, wallets, account gates and Food feeding; needs runtime/state interfaces and capability evidence |
| GAMEPLAY-004 | gameplay | Random breeding, focus, separate transfer/incubation, habitat-gated hatch and exact-once ownership; needs city/individual records |
| GAMEPLAY-003 | gameplay | Three-versus-three simulator, skill/state UI and first three adventure encounters; needs ray records and runtime interfaces |
| GAMEPLAY-005 | gameplay | Integrate the ordinary-control onboarding, representative assets, breeding/city/battle loop, expansion and saved return; needs the preceding slices |
| QA-002 | qa | Independent exact-candidate checks and actual-player observations; needs the integrated candidate and QA capability evidence |

GAMEPLAY-004 and GAMEPLAY-005 split the larger corrected scope into bounded tasks; they are not a second competing implementation of GAMEPLAY-002. The director updates existing issue criteria and links the new tasks. Capability work, reviewed engine setup, source-skill bindings and valid automation registrations remain intact.

### Acceptance boundary

The user must be able to operate the loop through game controls on the declared test context. A debug command that creates a Rare, directly grants Gold or wins a battle cannot substitute for the economic or combat path. Test-only clocks and injected RNG seeds may speed deterministic QA, but report their use and also observe the normal real-time tutorial.

Keep one exact candidate identity across the game files, content manifest, screenshots and test report. Independent QA reports defects and unresolved human evidence; architect integrates the reviewed revision. A corrected GDD is design work, not evidence that any of these game features are already implemented.

## 18 Validation and acceptance evidence

### Checks of this design

The opening Gold/Food ledger, feed-cost totals, stat examples, probability mixtures, focus expectation examples and basic resale sinks were calculated against the stated rules. Independent design review found that the earlier proposed 3×3 footprint for every opening building could not fit into the 8×8 starting area; farms and hatchery now use 2×2 and an explicit non-overlapping fixture is provided. Review also clarified Legendary mode selection, focus reservation lifetime and piecewise offline upgrade income.

These are calculations and design reviews. They do not establish that a running build is correct, that the battle roster is balanced, or that waiting for a rare egg is enjoyable. Document/render checks establish a readable specification, not a playable game. Record actual code tests, runtime observations and human playtests separately as they become available.

### Critical functional scenarios

| Scenario | Observable acceptance |
| --- | --- |
| Opening layout and budget | All six required buildings fit before expansion; required purchases total 1,040 Gold and feeding/crops leave positive balances |
| Resident production | Empty habitat earns zero; moves/feeds settle the old rate first; Gold caps and fractions remain correct through reload |
| Upgrade while absent | Income pauses until the actual upgrade deadline, then resumes at the accepted state for the remaining elapsed interval |
| Farming | Payment once, one crop per farm, correct harvest/XP once, ready crops retained and no hidden auto-replant |
| Element housing | A dual-element ray can use either matching type; a mismatched habitat refuses placement without consuming the hatch |
| Ordinary breeding | Displayed probabilities equal the committed distribution; hybrids mix tables once; no reload reroll |
| Legendary mode | Explicit named mode checks account/parent/Temple prerequisites and its separate pool/fee; ordinary mode stays distinct |
| Discovery focus | Only eligible undiscovered targets change odds; counter survives reload/target changes; success or egg sale cannot reset discovery |
| Separate queues | Ready breed blocks its grotto until transfer; hatching has its own slot/timer; full habitat blocks placement safely |
| Duplicates and rank | Favorite/last-producer/reserved protections hold; extraction and rank consume exact IDs/cells once and preserve retained identity |
| Battle rules | Six actors, correct round order/ties, individual Stamina, exact cooldown passage, elements, Taunt, shields and Stun immunity |
| Encounter settlement | Entry charged once, defeat/abandon handled, result paid once, repeat/first-clear/star rewards remain distinct |
| Long absence and recovery | Twelve-hour hatch completes after a valid absence; repeated resume does not duplicate progress; rollback does not reverse state |
| Save failure and second tab | Active/previous-good profile preserved, corrupt import rejected, stale writer cannot silently overwrite |
| Actual host and controls | Required mouse/keyboard/touch actions, audio gesture, readable city/battle UI and save/backup observed on the declared host |

### Player observation

Test the representative slice with people who recognize the reference genre and with a smaller number unfamiliar with it. Give a goal such as breed a new ray, strengthen a team and unlock more land, then observe without coaching. Record what they notice, which screen confuses them, whether they understand separate breeding/hatching, which duplicate decision they make and whether they can explain the reason for their next goal.

Observe at least one ordinary repeat visit after a real timer interval. Ask what they expected to be ready, what they wanted to collect next and whether the bottleneck felt like a useful plan or an unexplained obstruction. Test longer progression with actual saves across sessions before increasing waits. Report the number and context of participants; simulated personas are not human observations.

Battle tests should record team/levels/ranks/skills, rounds, Stamina use, target choices and reasons for losses. Test a three-support team for excessive sustain, controllers for stun lock, pure attackers for dominant focus fire, and elemental counters for whether they outweigh sensible investment. A 30-round timeout prevents an infinite encounter but does not make a slow encounter enjoyable.

### Release decisions

Do not accept a candidate with irreversible save loss, duplicate economic settlement, an unreachable required species, an ordinary progression dead end or unusable required controls. Require correct source/build identity and a representative normal-control route on the actual host. Broader supported devices, full roster balance, human enjoyment, server fairness and commercial fit remain separate evidence categories.

If tests show a problem, record the mechanism, the proposed change and its expected consequence. Revise the specific rule or scope with a versioned decision. Do not quietly restore the old sanctuary design because it is easier to implement; the user has explicitly selected the collection/city/combat genre.

## 19 Changes from version one and repository migration

This is a major direction correction authorized by Hazel's explicit feedback. Archive the original v1 Markdown and Word files without changing their bytes, publish v2 as the canonical readable GDD and current Word companion, and record hashes in the source record. Historical intake and review evidence remains historical; it does not approve the new mechanics automatically.

| v1 rule or emphasis | v2 governing rule |
| --- | --- |
| Gentle sanctuary adventure with a short finished campaign | Continuing city, creature collection, power progression, adventure and Arena |
| Eight launch varieties as the whole release identity | Six-species representative slice, 24-species initial progression target, expandable catalog |
| All rays carry Tide and homes accept essentially everyone | Eight meaningful elements with compatible habitats, breeding, Temples and combat |
| Empty homes earn Pearls independently of residents | Occupied compatible habitats store Gold generated by their actual rays |
| Free fixed Food garden with automatic production | Gold-funded timed crops selected and harvested on farms |
| Rarity does not affect power or production | Rarity changes Health/Power, income, level cap and content desirability |
| One nursery/incubation slot and short guaranteed discoveries | Separate breeding and hatchery facilities, disclosed normal pools and one tutorial exception |
| Six fixed home plots and unlimited free Guest Cove | Placeable expanding island grid, habitat storage/capacity and safe blocked hatch placement |
| Level ten as the game's ceiling | Food pips, account gates, Temple caps, rarity ceilings and ranks up to initial level fifty |
| One active combatant per side, shared team Energy | All three actors per side with personal Stamina, learned skills, cooldowns and Speed order |
| Practice Pool and friendly scripted guardians define combat | Authored PvE teams, bosses, stars, repeat progression and Arena |
| Duplicates mainly preserve family expression | Productive residents, additional teams, sale and species-cell ranking |
| Starter favorite promised endgame parity | Lower-tier usefulness with real rarity/power ceilings and stronger future collection goals |
| Online competition and events excluded from the product | Defined connected Arena/social/event stages after the local core |
| Eight-hour aggregate offline credit limit | Seven-day reconciliation bound with per-system caps and multi-hour hatch completion |

Preserve the cute manta identity, names and stable species keys, individual ownership, source provenance, accessible controls, deterministic settlement and robust save recovery. Preserve useful engine/asset/capability branches and the repository's review, lease and integration protocol. The revised design changes what the team should build, not how to bypass another agent's work.

Update the design baseline, first-slice map, source metadata and GDD pointer together. Rewrite affected existing feature issue criteria with a visible v2 revision note and link to DIRECTOR-002. Add the separated breeding and integration tasks. Do not close historical DIRECTOR-001 as a failure, reopen its intake, delete prior review evidence or duplicate startup automation registrations.

The actual experiment phase and task readiness must follow current live evidence. Compatible architecture and art trials may continue while v2 is reviewed; v1-dependent city/breeding/battle acceptance waits for the revised scope. A phase transition already reviewed by another role must be reconciled rather than overwritten with an old checkout. The current GDD version remains `received` until there is explicit approval of that exact version; the user's direction correction already authorizes this revision work.

## 20 Sources and design provenance

The external references below were inspected on 23 November 2026. They support the structural comparison with Dragon City and Monster Legends. They do not establish Little Ray's numerical balance, engine behavior, market demand or player enjoyment. The exact formulas, prices, roster, pools, skills, progression gates and staging in this document are authored proposals.

**S1 Dragon City habitats.** Socialpoint's official [What are Habitats](https://socialpoint.helpshift.com/hc/en/7-dragon-city/faq/1211-what-are-habitats/) describes creature housing, Gold production and upgrades. Little Ray uses explicit resident rates and habitat storage/capacity rules.

**S2 Dragon City breeding.** Socialpoint's official [How does breeding work](https://socialpoint.helpshift.com/hc/en/7-dragon-city/faq/4220-how-does-breeding-work/) describes selecting parental elements and an offspring pool. Little Ray's tables, named recipes and discovery focus are its own design.

**S3 Dragon City rarity.** Socialpoint's official [What are dragon rarities](https://socialpoint.helpshift.com/hc/en/7-dragon-city/faq/635-what-are-dragon-rarities/) connects rarity with relative power and identifies its rarity tiers. Little Ray uses five initial tiers with independently proposed multipliers and caps.

**S4 Monster Legends breeding and hatching.** Socialpoint's official [Hatching and Breeding Timer](https://socialpoint.helpshift.com/hc/en/3-monster-legends/faq/3998-why-is-the-hatching-and-breeding-timer-increasing/) distinguishes the breeding and hatchery stages/timers. Little Ray's job state machine, times and capacity rules are authored here.

**S5 Monster Legends levels and Temples.** Socialpoint's official [How do I level up my Monsters](https://socialpoint.helpshift.com/hc/en/3-monster-legends/faq/36-how-do-i-level-up-my-monsters/) links level ceilings with rarity and element Temples. Little Ray uses its own smaller initial cap/feeding model.

**S6 Monster Legends Adventure Map.** Socialpoint's official [Adventure Map](https://socialpoint.helpshift.com/hc/en/3-monster-legends/faq/3889-what-is-the-adventure-map-how-does-it-work-1653578771/) describes PvE nodes, islands, entry resource, bosses and stars. Little Ray's regions, enemies and reward budgets remain its own content plan.

**S7 Monster Legends multiplayer.** Socialpoint's official [Multiplayer Mode](https://socialpoint.helpshift.com/hc/en/3-monster-legends/faq/1150-what-is-multiplayer-mode/) describes three-monster teams, attack/defense assignments, trophies, tournaments and rewards. No Little Ray online mode has been validated by this design work.

**S8 Game Designer skill.** Applied [Game Design AI Skill](https://github.com/hazelfjeld/Game-Design-AI-Skill/tree/dc26ddb18adc18fbbe2221a8443a71a260de6022/game-designer) at pinned commit `dc26ddb18adc18fbbe2221a8443a71a260de6022`: full SKILL.md, design foundations, systems and balance, and production/collaboration. The procedures connect the user's intended experience to explicit rules, scope, evidence and handoff; no claim is made that the skill guarantees a breakout game.

**S9 User direction.** Hazel's original cute manta/Dragon City premise and explicit correction requesting a Dragon City/Monster Legends clone govern this revision. The prior cozy-sanctuary interpretation was an assistant design choice and has been replaced where it conflicted.

**S10 Historical project design.** [Little Ray v1 source record and archives](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/blob/main/docs/design/SOURCE.md) preserve the prior GDD and its workbook provenance. The earlier workbook is supporting context; its conflicting rules and the v1 design do not override the latest user instruction. The repository's current issues, GDD pointer and accepted decisions own ongoing production state.
