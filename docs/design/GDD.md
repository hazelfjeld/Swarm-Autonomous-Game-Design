# Little Ray

Game Design Document

Version 1.0 · 23 November 2026

## 1 Game vision

**Little Ray is a gentle creature collection game about building a reef that feels like home to a family of tiny manta rays.** Players meet and name individual rays, arrange habitats, discover new varieties through breeding, and take a favorite team on short, friendly reef adventures. Every return home should bring a visible change: a new friend, a new place to rest, a newly understood behavior, or a story about a familiar ray.

The central promise is simple: **the little ray you love at the beginning can still be beside you at the end.** Training changes confidence, capability and expression while preserving the rounded baby silhouette. New varieties expand the collection and the team's choices. They do not make an old favorite obsolete.

This document turns the existing Little Rays planning workbook into a coherent design baseline for production. It preserves the established eight launch breeds, four habitat types, three campaign regions and stable content identifiers. It resolves missing rules for progression, combat, housing recovery and resource production. The workbook remains the execution backlog; the material revisions in Section 19 explain what must be reconciled before implementation. [S1]

### Experience priorities

1. **Attachment.** An individual has a name, recognizable appearance, consistent habits and a persistent family record. Players should be able to point to their Blueberry without opening a statistics screen.
2. **Discovery.** Pairing, exploring and observing reveal understandable possibilities. The next discovery should invite a plan, with reliable routes to the main cast.
3. **Gentle mastery.** Players learn to prepare a team, read an opponent and use a few complementary actions. Mistakes are recoverable and provide useful information.

Expression supports all three priorities. A player may keep a mismatched family together, make a shaded corner for Moonpool, or choose Sunbeam because its sleepy greeting makes them smile. Preferred habitats and decorative arrangements influence animation and atmosphere, without creating a mandatory efficiency layout.

### The distinctive design

The manta silhouette is the game's visual anchor. Broad wings, a soft snoot, a large friendly near eye, a cream underside and a long tapering tail remain recognizable across the roster. Variation comes from color blocks, motifs, small secondary accents and behavior. A new ray should read as another member of the same lovable family.

Breeding creates both a collection discovery and a named individual. A Pearlcloud keeps its own pearly identity while carrying subtle accents inherited from Blueberry and Sunbeam. Its parents remain part of the sanctuary. The journal records who they were, even after they are renamed.

The sanctuary, breeding and adventures form one connected game. Habitats give individuals a place to live; outings reveal new friends and pairing clues; training lets familiar rays tackle new challenges; new arrivals change the life of the reef. Avoid features that only add another counter or compulsory daily action.

### Audience and play setting

The primary audience is players drawn to cute creature collectors, expressive home building and approachable turn-based decisions. This is a design hypothesis, not a measured market segment. A secondary audience may enjoy breeding records, complete collections and efficient team planning. The first release must remain understandable without prior knowledge of Dragon City or role-playing games.

Design for brief visits of roughly 5–15 minutes and longer self-directed sessions. Players can stop at any stable screen, return without punishment and continue a saved adventure. The campaign's initial target is approximately 2–3 hours, including normal reading, discovery, decorating and learning. That duration must be measured. If the authored journey is satisfying sooner, retain the stronger pacing instead of adding waits.

### Design status

The player request, established creature identity and prior workbook are the project's foundations. All newly specified numbers and encounter scripts in this GDD are an initial production baseline to test. Arithmetic and model checks can verify reachability and rule behavior; human playtests must establish clarity, attachment, challenge quality and pacing. This document does not assert that the current published build already implements these rules.

## 2 Product definition and scope

### First release

| Area | Launch commitment |
| --- | --- |
| Format | Single-player 2D sanctuary and creature collector with authored node adventures |
| Delivery | Godot game for desktop and touch browsers, delivered through the intended ChatGPT Site |
| Main cast | 8 collectible manta varieties, with persistent individual identities |
| Homes | 4 habitat types; 6 placeable home plots; 4 residents per home, upgradeable to 6 |
| Breeding | 1 nursery slot; 6 recipe rules including same-breed pairing; first two new hybrids guaranteed |
| Adventures | 3 authored regions, each with a guardian milestone and optional discoveries |
| Challenges | Up to 3 rays per team; 1 active ray per side; readable alternating turns |
| Progression | Levels 1–10; two currencies, Pearls and Food; visible journal and campaign milestones |
| Expression | Naming, bounded inherited accents, 8 decorations, simple personalities and buddy interactions |
| Persistence | Versioned local saves, previous-good recovery, backup export and validated import |
| Ending | A reef celebration, continued home play, optional collection and practice |

The first two homes are Sunlit Shallows instances. Four habitat types does not mean four total home instances. Six plots allow the player to keep those original homes and still display every launch theme. Plot unlocks occur in pairs: two at the start, two after the first guardian, two after the second.

### Release boundary

The launch game has a complete beginning, middle and ending. It has no account dependency, paid currency, paid timer skip, randomized purchase, competitive ladder or compulsory daily reward calendar. Rays do not become hungry, sick, injured or unhappy because the player is absent. Food is a training resource.

Trading, online visits, PvP, cloud synchronization, live events, procedural worlds, elaborate family-tree visualization, accessory inventories and additional move loadouts belong to later decisions. The existing 24-variety, eight-habitat expansion catalog remains a roadmap. Only eight varieties count toward the launch collection display.

### Transfer from Dragon City

The reference supplies a useful collection structure: choose parents, discover offspring, house a growing collection and prepare a team. Official Dragon City documentation describes element-dependent breeding outcomes and habitat compatibility. Little Ray uses its own authored pair list, creature art, progression and challenge rules. [S4, S5]

| Familiar appeal | Little Ray implementation | Intended benefit |
| --- | --- | --- |
| An appealing creature collection | Eight distinct baby manta varieties with individual names and habits | Recognition and affection |
| Anticipating a hatch | Short, previewed pairings with saved results and a replayable reveal | Pleasant anticipation and understandable discovery |
| Building a home | Six flexible home plots, four themes and free decoration rearrangement | A sanctuary that reflects the player |
| Preparing a team | Three favorite individuals with complementary signatures | Approachable tactical planning |
| Unlocking new places | Three regional stories that bring visible changes home | A coherent reason to explore |

### Product decisions

The working display title is **Little Ray**, following the latest brief. Existing `little_rays` project keys and all `RAY`, `HAB`, `BRD`, `MOV`, `SYS-GP` and backlog identifiers remain stable. The MVP is a freely playable browser release for testing and sharing. Any future business model must be designed separately, with particular care for ownership, collection and access to already earned rays.

## 3 The player loop

### A complete cycle

A player returns to a recognizable home and notices that Pearlcloud has joined Sunbeam near the shell arch. They collect stored Pearls and Food, inspect a pairing clue, and choose whether to improve a home, train a favorite or prepare a new egg. They select three available rays and enter a reef route. A branch lets Blueberry reveal a curiosity, while a friendly challenge asks whether to attack, protect the team or swap. The route brings home a friend, a decoration or a useful clue. The player names the arrival, chooses where it belongs and sees the sanctuary change.

The immediate pleasures are selection, gliding animation, a responsive feed, a readable action and an expressive greeting. A session adds one meaningful change to the reef. The longer journey expands the collection, places and combinations the player understands.

### Decisions that matter

| Situation | Information shown | Player choice | Consequence |
| --- | --- | --- | --- |
| A new pairing clue appears | Exact eligible parents, cost, duration and candidate outcomes | Pair now or keep those parents available for an outing | A saved egg result or a different available team |
| A home fills | Residents, free spaces and free Guest Cove transfer | Keep a family together, move a resident, upgrade or create another home | A different visible neighborhood without losing a ray |
| An opponent gathers current | Next action, expected effect and the Charged badge | Guard, remove the charge with Sonar, attack or swap | A legible tradeoff between tempo and protection |
| A route offers a talent interaction | Required talent, alternative path and reward | Use the talent or take the ordinary route | A different little scene, with the main objective still reachable |
| A new breed is discovered | Its appearance, signature and family | Train it, house it with friends or keep the current team | Expanded possibilities without forced replacement |

Not every moment needs a strategic cost. Watching Mossdrop peek from a plant and choosing a pretty arrangement are valuable expressive activities. Required decisions should be understandable; optional expressive choices should remain welcoming.

### Session structure

On return, show one compact summary of completed eggs and stored resources, with a single Continue button. Do not interrupt with a sequence of reward popups. The home screen offers a current objective and three useful destinations: Rays, Nursery and Reef Map. Journal and Build remain visible but quieter.

Before departure, show whether any selected individual is pairing or visiting Guest Cove. Starting an outing takes no currency or energy ticket. Closing or pausing the game preserves the active run and its committed node. Choosing Return home ends that outing and releases its party reservations while preserving settled nodes, rewards, owned rays and training. Continue route starts a new run and party snapshot at the next unresolved node; an unresolved challenge restarts with its stated initial conditions.

After a route, one results screen shows what changed and offers **Meet your new friend**, **Return home** or **Practice again**, as applicable. The game never requires an extra reward claim to persist a campaign unlock. A full home sends the new individual to safe arrivals or Guest Cove while all other rewards settle.

## 4 Opening and learning

### The first fifteen minutes

The opening teaches one action at a time through a ray's response. Dialogue is short, skippable and rereadable. A small objective card remains available after a prompt closes. Fast players may reach the first hatch in under ten minutes; a player who lingers should never feel behind.

| Approximate window | Player action | Learning and feedback |
| --- | --- | --- |
| 0–2 minutes | Enter the sanctuary and select Blueberry | A nameplate, curious turn and profile establish an individual; sound starts from the entry gesture |
| 2–4 minutes | Name Blueberry and give one feed | The Food cost and resulting XP are visible before confirmation; a short happy flutter follows |
| 4–6 minutes | Place the granted second Sunlit home and welcome Sunbeam | A free preview teaches placement; Sunbeam's slower greeting contrasts with Blueberry |
| 6–8 minutes | Give the remaining feeds needed for both founders to reach level 3 | Two feeds per founder cost 20 Food in total; the profile says Ready to pair |
| 8–10 minutes | Preview and begin the first pairing | Pearlcloud is guaranteed; the screen shows 40 Pearls, 120 seconds and temporary parent unavailability |
| During incubation | Place the free shell arch, inspect the journal or observe the parents | A useful low-pressure activity occupies the short wait; returning later is also valid |
| 10–13 minutes | Reveal, name and house Pearlcloud | The new variety and the new individual receive distinct journal entries; the reveal can be skipped |
| 13–15 minutes | Feed Pearlcloud if desired and open the practice outing | Three actual portraits form the team; the first action preview introduces Bubble Bop |

These windows are teaching targets rather than timers, achievements or a fixed speedrun path. The earlier workbook's 10–25 minute first-discovery window is refined here to make the central breeding promise available sooner. Slow reading, renaming and decorating remain supported.

### Tutorial rules

The first feed costs 5 Food and grants 15 XP. The opening grant contains 30 Food. Two feeds each for Blueberry and Sunbeam use 20 Food and leave 10 Food, sufficient for two feeds for Pearlcloud. The first home and second-home voucher cost no Pearls. Starting with 100 Pearls leaves 60 after the first 40-Pearl pairing. Ordinary opening play therefore needs no passive income or lucky result.

The second home is taught before Sunbeam is granted, but a skipped placement prompt must remain resumable. The grant and placement use stable event IDs. Reopening the tutorial cannot create a second founder or consume another voucher.

The practice challenge first asks for Bubble Bop, then introduces a visible opponent intention and the ray's signature. Soft Guard and swapping appear when their consequences can be demonstrated. All commands remain available afterward. A player who selects the right action without reading the prompt should progress immediately.

### Hints and recovery

Hints escalate on request: highlight the relevant destination, explain the relationship, then show a suggested action. Do not auto-play a choice or repeat tutorial dialogue after every failure. A busy parent message includes the remaining incubation time and a route back to Nursery. A full home message opens the free Guest Cove transfer. An insufficient Food message opens the garden or an available free outing.

The opening succeeds when a new player can explain who their three rays are, what the pairing cost, why Pearlcloud appeared and how to leave home. A designer talking them through the interface does not satisfy that gate.

## 5 World and campaign

### Fiction and tone

The player is the reef's unseen keeper. A small sanctuary is becoming a gathering place for the little rays who live along its currents. Each region has a resident guardian who hosts a friendly challenge before opening the next gathering route. The journey builds toward a shared evening glide through the restored home reef.

The stakes are welcoming and local: find a sheltered route, help a shy friend cross a garden, learn the rhythm of a warm current and make room for arrivals. The game does not need a villain, ecological catastrophe or threat to the babies to make progress meaningful. Dialogue treats the rays as expressive creatures; short gestures, bubbles and journal captions carry much of the story.

The original guardian individual joins after its first clear. Repeat encounters are clearly labeled **Practice** and use separate visitor identities. A collected individual never appears simultaneously on both teams. All opponents remain varieties from the established manta catalog.

### Region structure

Each region uses a compact map of authored nodes. A node is a short illustrated interaction, a readable branch or a turn-based challenge. This is not a free-swimming action game. Exploration talents select authored outcomes; they do not require separate racing, stealth or physics systems. A talent option requires its ray in the current committed party. A newly recruited ray can participate after returning home and starting a new outing; the ordinary route remains available on the first visit.

Each region contains five main map nodes. Two optional discovery nodes appear across the campaign. Talent choices alter an existing node's interaction and converge on the same onward route. Every required objective has an ordinary route. A talent can add an expressive scene, never supply the only way to recruit its own breed. Homecomings present settled rewards and return the player to the sanctuary; they are not separate map nodes.

| Region | Emotional arc | Main lesson | Persistent result |
| --- | --- | --- | --- |
| Reef 1 Sunlit Shallows | A small family becomes confident enough to explore | Basic actions, visible intentions and a reserve swap | Ripple joins; two plots and the garden route open |
| Reef 2 Kelp Garden and Moonlit Cove | A timid stranger becomes part of the family | Protection, recovery and a familiar pairing clue | Mossdrop, Rosefin and Moonpool become reachable; two plots and Warm Spring open |
| Reef 3 Warm Spring | The player's chosen family completes a shared adventure | Combining known responses against a full opposing team | Emberfin joins; the reef celebration and continued sanctuary play open |

### Reef 1 Sunlit Shallows

**Sunlit Entry** establishes the party's arrival. At **Shell Path**, Blueberry notices a glint beneath an arch. A sonar option reveals Ripple's invitation to the practice pool and guardian ring; following a visible bubble trail reaches the same clue. The optional **Hidden Shell** detour offers an extra Smooth Resting Stone. Both paths continue to **Small Current**, where a brief choice introduces an ordinary route and Sunbeam's updraft vignette. Both lead to the same practice pool.

The **Practice Pool** uses one familiar-looking visiting ray, teaches a low-cost action and previews a Gather Current turn. **Ripple's Ring** is the guardian encounter against one level-3 Ripple. Its celebratory loop communicates playful competition. First clear recruits Ripple, unlocks Kelp Garden and the next two home plots, and grants the authored resource bundle. Returning home triggers one Ripple landmark loop, then gives control back.

### Reef 2 Kelp Garden and Moonlit Cove

At **Leaf Shelter**, the player meets Mossdrop through a guaranteed friend event. No Nature parent or combat win is needed to create the first Nature ray. A garden clue explains the Blueberry and Mossdrop pairing. Rosefin can be discovered immediately or later; the campaign does not require that breeding job to finish before the guardian.

At **Kelp Crossing**, a party containing Mossdrop can part a leafy passage for an expressive vignette. The ordinary path remains clearly visible and reaches the same objective. **Quiet Water** uses a safe practice preview to demonstrate capped recovery before the guardian's reserve team. It does not imply persistent damage between encounters. The **Moonlit Approach** is always available in its moonlit atmosphere; device time never gates it. **Moonpool's Clearing** pits the player against Moonpool at level 5 with a level-4 Mossdrop reserve. Its intentions reward protection and timing rather than fast input.

First clear recruits Moonpool, reveals Moonlit Cove construction, opens Warm Spring and the final two plots, and grants the second campaign bundle. The homecoming scene places a soft glow near the new arrival's chosen home. That ambience is decorative and has no timed collection obligation.

### Reef 3 Warm Spring

At **Warm Stones**, the team investigates a harmless rising current. At **Drifting Lanterns**, the player chooses a calm approach or a familiar talent vignette; an optional **Lantern Alcove** detour reveals an extra Glow Pebble. **Spring Bend** acknowledges the chosen party in a small discovery scene. **Gathering Pool** lets the player review the team, open existing Practice mode or return home freely before committing to **Emberfin's Circle**, the final challenge.

The final guardian team is Emberfin level 7, Moonpool level 6 and Ripple level 6. Their established signatures and visible charge cycle combine lessons the player already understands. No new currency, affinity or special control appears in the finale. A winning team can include Blueberry performing useful actions throughout.

First clear recruits Emberfin and triggers a short **Reef Gathering**. A series of existing sanctuary views shows the resident family in bounded groups, with a clear moment for the player's named starter and the final arrival. Show the completed three-region journey, then return to an interactive sanctuary. A player with fewer than eight varieties receives the remaining pairing clues without a false 100 percent collection claim.

### Route rewards and repeat visits

First-clear bundles, friend grants and decoration discoveries settle once per authored event. Repeat practice uses a separately defined reward. Replaying a story node may replay its scene, but cannot duplicate a unique recruit or first-clear currency. Do not attach a premium reward to abandoning and restarting a node.

The journal distinguishes the completed campaign, eight-variety collection and personal family history. These are separate achievements. Players can finish the story, complete a missing hybrid later, and continue breeding siblings without a daily schedule.

## 6 Ray collection and individual identity

### The launch cast

Breed names identify varieties. Nicknames identify individuals. A player may own two Blueberries named Bubbles; the game must still preserve their separate IDs, parents, experience and homes. Rarity is a discovery label, if used at all, and never multiplies stats or resource production.

| Breed and stable key | Visible identity | Character at home | First acquisition |
| --- | --- | --- | --- |
| Blueberry `blueberry` | Cyan back, cobalt wing edge, broad blue spots, cream belly | Curious approach, pause and peek around a new object | Guaranteed starter at level 1 |
| Sunbeam `sunbeam` | Butter yellow, orange freckles, broad sunburst motif | Slow greeting circle followed by a sun nap | Guaranteed opening friend at level 1 |
| Pearlcloud `pearlcloud` | Pale sky blue, broad pearl patches, white belly | Hesitates, then joins a group with a bubble trail | First Blueberry and Sunbeam pairing, level 1 |
| Ripple `ripple` | Teal body, broad ripple bands, clear tail stripe | Loops a landmark and pauses invitingly | First guardian clear, level 3 |
| Mossdrop `mossdrop` | Sage body, large leaf patches, pale fin tips | Peeks from leaves and tends a favorite plant | Guaranteed garden friend, level 3 |
| Rosefin `rosefin` | Peach back, pink fin edge, mint oval spots | Settles beside a resting buddy | First Blueberry and Mossdrop pairing, level 1 |
| Moonpool `moonpool` | Deep lavender, a few broad luminous crescents | Quiet hover, shaded rest, soft glow when greeted | Second guardian clear, level 5 |
| Emberfin `emberfin` | Coral body, golden cheeks, three ember-like spots | Plays through a warm current and circles back | Third guardian clear, level 7 |

Guardian recruits retain their authored guardian level. Mossdrop arrives already ready to pair so its discovery opens a clear new possibility. Set Ripple and Mossdrop to 25 XP, Moonpool to 85 XP and Emberfin to 185 XP. All bred offspring begin at level 1, XP 0. Each acquisition sets cumulative XP, not a separate editable level that can disagree with XP.

### Affinities and roles

All eight launch varieties include Tide for housing. A single primary affinity determines incoming challenge effectiveness. A second affinity describes theme and permitted move data; it does not create a second defensive multiplier.

| Ray | Housing affinities | Primary challenge affinity | Signature purpose |
| --- | --- | --- | --- |
| Blueberry | Tide | Tide | Remove a prepared charge and deal damage |
| Sunbeam | Tide and Light | Light | Clear, efficient elemental damage |
| Pearlcloud | Tide and Light | Light | Protect active and reserve teammates |
| Ripple | Tide and Storm | Storm | Attack and reposition the active team member |
| Mossdrop | Tide and Nature | Nature | Recover and withstand the following response |
| Rosefin | Tide and Nature | Nature | Restore multiple conscious teammates |
| Moonpool | Tide and Moon | Moon | Damage and soften the next opposing hit |
| Emberfin | Tide and Ember | Ember | Spend more energy for a larger attack |

The player does not need to memorize this table. Profiles show icons with text labels; action previews display the actual effectiveness against the current opponent. A preferred habitat is a behavioral invitation, not a stat bonus.

### Individual state and attachment

An owned ray stores a stable individual ID, breed ID, nickname, cumulative XP, cosmetic genotype, resolved appearance seed, parent IDs, acquisition event, current home or Guest Cove status, and its recorded interactions. Breed definitions remain immutable content. Names and display labels may change without rewriting those relationships.

Every individual has a primary routine style derived from its breed, a stable variation in idle timing and a preferred available rest anchor. Players can choose a **Favorite** flag for quick roster filtering. It has no mechanical power. A buddy interaction occurs between two available individuals sharing a home, uses a symmetric pair key, and never creates jealousy or a penalty for separation.

Launch attachment milestones are **Welcomed**, **First snack** and **Adventure companion**. They record the first housing, first successful feed and first completed outing involving that individual. They unlock journal captions or a greeting variation. Repeated greeting and idling do not generate combat power. A deep numerical relationship simulation and bond-unlocked move loadout are deferred.

The journal records facts that actually occurred: first arrival, parents, first outing and observed buddy interaction. It must not invent a family story or claim that a player performed a care action they skipped. The family view shows the selected individual and its two parents as simple cards; ancestry remains in data without requiring a large branching visualization.

### Journal rules

Track **Seen**, **Owned** and **Bred by you** separately. Seeing a guardian fills a silhouette and clue, but not ownership. Claiming an individual into a home or Guest Cove sets Owned. Claiming a completed breeding job also sets Bred by you. A repeated breed adds an individual without increasing the eight-variety counter.

Unknown or disabled expansion entries do not appear as missing launch collectibles. A new breed celebration happens once per breed. A new individual receives a shorter welcome with its name and parentage. The player may replay either reveal from its journal entry.

## 7 Sanctuary and housing

### Home layout

The sanctuary is one continuous reef scene with six authored build plots. Each home uses an 8 by 6 logical-cell footprint as the starting placement specification. Fine camera framing and art padding are settled in the visual spike. Habitat placement snaps to a valid plot; decoration placement uses the local home grid. The MVP does not require unrestricted terrain sculpting or an unlimited city grid.

Both opening plots and two Sunlit Shallows home vouchers are free. The first home is placed by the opening; the player places the second. Two more plots unlock after Reef 1 and the final two after Reef 2. Empty plots are visible as quiet landscape, without a purchase-pressure badge.

| Habitat | Unlock | Capacity | Visual and behavior identity |
| --- | --- | --- | --- |
| Sunlit Shallows | Opening | 4, upgrade to 6 | Pale sand, warm light, arches, open gliding and sun naps |
| Kelp Garden | Reef 1 clear | 4, upgrade to 6 | Layered leaves behind a clear foreground lane; peeking and leaf rests |
| Moonlit Cove | Reef 2 clear | 4, upgrade to 6 | Indigo rock shelter and localized glow; quiet hovering and shade |
| Warm Spring | Reef 2 clear | 4, upgrade to 6 | Rounded vent stones and gentle currents; warm rests and playful loops |

Each additional home costs 80 Pearls. A capacity upgrade costs 60 Pearls and increases capacity from four to six. There is one upgrade tier and no construction wait. Move an existing home between unlocked plots without cost; preserve its identity, residents, stored Pearls and upgrade. A move can use its own previously occupied footprint. Putting away a populated home is unavailable; the player can relocate residents or send them to Guest Cove first.

Putting away an empty home preserves that same instance in home inventory, including its tier, stored Pearls and fractional production progress. Stored homes produce nothing. Placing one again on an unlocked empty plot is free, so even a player with every ray in Guest Cove and zero Pearls can restore housing. At most six homes are placed at once. There is no permanent home deletion or paid repurchase of a stored instance.

All launch habitats accept every launch ray through the shared Tide affinity. A future habitat must explicitly list accepted affinities. Compatibility and capacity are separate checks. A home contains each resident ID at most once, and a resident occupies exactly one home.

### Guest Cove and safe arrivals

**Guest Cove is a free roster reserve.** It uses the existing ray cards and a Visiting filter, without a fifth habitat scene. A resident can visit when not reserved by incubation or an active outing. The transfer preserves name, XP, appearance, parents and journal history. Visiting rays do not enter parties or pair until returned to an available home.

Returning is free and checks compatibility and capacity. A home is not deleted when its last ray visits the cove. Moving all rays away therefore never removes the player's route back into play. The interface shows a direct Return home action and eligible space count.

A ready baby can be claimed into Guest Cove if the sanctuary is full. A guardian reward can do the same. This creates the individual and completes its acquisition exactly once. Campaign unlocks and currency rewards settle independently of the chosen housing destination. No ray must be sold, sacrificed or permanently released to continue.

### Production and arrangement

Each built and placed habitat has a pearl bed that produces **3 Pearls per minute**, independently of resident count, variety, level or occupancy. This deliberate rule lets players group buddies or visit Guest Cove without losing income. The two opening homes produce 6 Pearls per minute together; six placed homes produce 18. Capacity upgrades increase storage and living space, not production rate.

Habitats contain a suitable resting anchor in their base art. Purchased decorations add expressive arrangements and optional routine targets. They confer no battle, income or breeding multiplier. This prevents a pretty home from becoming a mechanically inferior home.

### The eight decoration types

| Prop | Home association | Interaction | Acquisition |
| --- | --- | --- | --- |
| Shell Arch | Sunlit Shallows | Curious approach or loop | Free during first incubation; extra copies 20 Pearls |
| Smooth Resting Stone | Sunlit Shallows | Rest or buddy settle | Free during first incubation and once at Hidden Shell; extra copies 20 Pearls |
| Leaf Shelter | Kelp Garden | Peek and rest | Garden friend milestone; extra copies 30 Pearls |
| Plant Cluster | Kelp Garden | Inspect and leaf tending | Garden shop unlock, 30 Pearls |
| Crescent Shell | Moonlit Cove | Quiet rest | Reef 2 clear; extra copies 40 Pearls |
| Glow Pebble | Moonlit Cove | Gentle glow response | Reef 2 shop unlock, 40 Pearls; one free copy at Lantern Alcove |
| Vent Stone | Warm Spring | Warm resting | Warm Spring arrival; extra copies 50 Pearls |
| Warm Ring | Warm Spring | Short current loop | Finale; extra copies 60 Pearls |

The paid decoration shop opens after the first breeding job starts, protecting the first 40-Pearl discovery from an accidental opening shopping spree. Inventory and placement are separate: putting a prop away returns the same item to inventory; rearranging costs nothing. Multiple copies do not stack invisible benefits.

## 8 Breeding and inherited appearance

### Pairing contract

Pairing requires two distinct owned resident individuals at level 3 or above, an enabled recipe, the required milestone, sufficient Pearls and an empty nursery slot. Neither parent can be reserved by another job or an active outing. No sex restriction is used. Selecting the same individual twice is invalid; two different siblings of the same breed are valid if the same-breed rule applies.

Recipe lookup first checks an exact unordered breed pair, then the same-breed fallback. Otherwise show **No pairing discovered for these two** with a route to known clues. Reversing parent order does not alter the pool, cost or duration. Browsing previews consumes no random state or currency.

The preview names the actual individual parents, shows their portraits, exact cost, remaining prerequisites, duration and candidate probabilities. An undiscovered candidate can retain a silhouette while its probability and clue remain visible. The first Pearlcloud and Rosefin previews explicitly say **Your first discovery is guaranteed**.

### Launch recipes

| ID | Parents | Outcomes | Cost | Time |
| --- | --- | --- | --- | --- |
| BRD-001 | Blueberry and Sunbeam | First: Pearlcloud 100%. Later: Pearlcloud 50%, Blueberry 25%, Sunbeam 25% | 40 Pearls | 120 seconds |
| BRD-002 | Blueberry and Mossdrop | First: Rosefin 100%. Later: Rosefin 50%, Blueberry 25%, Mossdrop 25% | 60 Pearls | 180 seconds |
| BRD-003 | Sunbeam and Moonpool | Sunbeam 50%, Moonpool 50% | 60 Pearls | 180 seconds |
| BRD-004 | Ripple and Emberfin | Ripple 50%, Emberfin 50% | 80 Pearls | 240 seconds |
| BRD-005 | Pearlcloud and Rosefin | Pearlcloud 50%, Rosefin 50% | 60 Pearls | 180 seconds |
| BRD-006 | Two individuals of the same breed | That breed 100% | 40 Pearls | 120 seconds |

BRD-001 unlocks with the founder friend. BRD-002 unlocks with the garden friend. BRD-003 and BRD-004 require Reef 2 and Reef 3 completion respectively. BRD-005 requires ownership of both named breeds. The same-breed rule becomes available after the first hatch. A later-copy recipe promises a sibling and inherited appearance, not another new core variety.

### Job lifecycle

The persistent states are **Incubating**, **Ready** and **Claimed**. Preview is interface state only. Starting a job atomically debits its cost, commits the effective candidate pool, samples the breed and cosmetic genotype, stores a phenotype seed, and reserves both parents. A failure changes none of those domains.

Incubating parents remain visible at home and can be named, fed and greeted. They cannot depart, visit Guest Cove or join another pairing. A visible nursery badge explains the restriction before commitment. The result never rerolls because the game closes, the recipe changes or the player delays the reveal.

At Ready, release both parent reservations immediately. The baby can wait without deterioration. Claiming creates one individual and moves it to a valid home or Guest Cove, then records the job as Claimed. Double taps and reopening a reveal cannot create another child. If a claim fails, preserve the Ready job and explain a valid destination. One nursery slot means a Ready unclaimed job occupies the slot; there is no hidden queue.

Committed jobs finish normally and cannot be canceled for a reroll. All previews can be canceled freely. The 120–240 second launch durations create a short anticipation beat, while home arrangement, observation or another available team can continue. No currency buys a skip.

### Cosmetic inheritance

Breed identity owns the base palette, broad motif and silhouette. Three small cosmetic loci control a secondary accent, secondary markings and a fin accent. For each locus, sample one of each parent's two alleles uniformly. Both copies of a homozygous allele naturally produce the same result. There are no mutations, hidden stat genes or rarity multipliers in the MVP.

Every enabled unordered allele pair has an authored resolution. The following table defines the complete three-allele resolution pattern for each locus. The letters are local to each locus and are documentation shorthand; saved records use the meaningful allele IDs such as cool, freckles and mint.

| Pair | Accent locus A cool B warm C leaf | Marking locus A dots B freckles C speckles | Fin locus A blue B gold C mint |
| --- | --- | --- | --- |
| AA | Soft cyan | Small dots | Blue |
| BB | Soft gold | Fine freckles | Gold |
| CC | Soft green | Soft speckles | Mint |
| AB | Subtle lavender | Small soft speckles | Teal |
| AC | Mint cyan | Sparse rounded speckles | Cyan mint |
| BC | Soft peach | Fine clustered speckles | Pale lime |

Founder profiles use stable seeds. Blueberry is AA at all three loci; Sunbeam is BB; Mossdrop is CC. Ripple uses AC accent, AA markings and AC fin. Moonpool uses AA accent, CC markings and AA fin. Emberfin uses BB at all three loci. Using those original founders, Pearlcloud receives AB at each locus and Rosefin receives AC. Every child, including a guaranteed first discovery, inherits the selected individuals' actual alleles. Selecting an inherited Blueberry sibling can therefore produce different accents. The guarantee fixes breed, not genotype.

The secondary appearance layer must stay inside authored masks and preserve the face and main motif. No inherited pattern creates a different breed ID. The preview explains inheritance with a simple parent accent comparison; it does not make genetics notation compulsory. Unknown legacy alleles resolve to the breed's safe default visual while their saved raw data remains recoverable for migration.

## 9 Economy and growth

### Resource ledger

Pearls purchase homes, capacity, pairings and decorations. Food grants training XP. Both use integer wallet balances. Neither decays, becomes debt or carries a real-money purchase route in the MVP. Stored production uses an internal fractional progress accumulator, so rounding each frame cannot destroy or create value.

| Resource or structure | Source or rate | Storage | Sinks or behavior |
| --- | --- | --- | --- |
| Starting Pearls | One grant of 100 | Wallet cap 999999 | Breeding, homes, capacity and décor |
| Starting Food | One grant of 30 | Wallet cap 999999 | Feed and batch training |
| Each placed home | 3 Pearls per minute | Tier 1 holds 180; tier 2 holds 300 | Collect All or individual collection |
| Free Food Garden | 3 Food per minute | Holds 180 Food | No planting cost, hunger or crop failure |
| Guardian first clear | Authored bundle below | Wallet | Once per encounter completion |
| Practice clear | 10 Pearls, 5 Food, 5 XP per participant | Wallet and individual XP | Once per completed run; free entry |

Production continues against the approved elapsed-time budget and stops at the structure's storage cap. At 3 units per minute, a 180-unit bin fills in 60 minutes; a 300-unit bin fills in 100 minutes. The eight-hour offline budget does not imply eight hours of uncapped production. One Collect All action transfers available whole units without increasing a rate or resetting uncollected fractions. If a wallet is full, retain any untransferred storage or unclaimed grant and explain the cap.

The Food Garden is a fixed free sanctuary facility and cannot be removed. Putting a home into inventory pauses its production without losing its stored amount. Replacing it resumes production from that preserved state, with no credit for its time in inventory.

Moving, emptying or upgrading a home does not reset its accumulated production. A grant, purchase or collection has a stable transaction ID and a reason. Costs are revalidated at commitment. Repeated requests cannot settle twice, and failed actions leave balances unchanged.

### Prices and training

| Action | Cost | Result |
| --- | --- | --- |
| Feed | 5 Food | 15 XP to one individual |
| Train twice | 10 Food | 30 XP; a batch of two feeds with the same efficiency |
| Build another home | 80 Pearls | One unlocked plot gains its chosen available habitat type |
| Upgrade a home | 60 Pearls | Capacity 4 to 6; storage 180 to 300 Pearls |
| Pair rays | 40–80 Pearls | One committed job according to Section 8 |
| Extra decoration | 20–60 Pearls | One reusable inventory prop |

Training is optional preparation, not a hunger obligation. Show the resulting level and XP before a feed. At maximum XP, disable further paid feeds and offer the free Greet reaction instead. Any feed or reward that passes a level threshold retains the surplus XP up to the level-10 cap.

### Level curve and stats

| Level | Cumulative XP | Stamina | Attack | Defense |
| --- | --- | --- | --- | --- |
| 1 | 0 | 24 | 4 | 2 |
| 2 | 10 | 27 | 5 | 2 |
| 3 | 25 | 30 | 6 | 3 |
| 4 | 50 | 33 | 7 | 3 |
| 5 | 85 | 36 | 8 | 4 |
| 6 | 130 | 39 | 9 | 4 |
| 7 | 185 | 42 | 10 | 5 |
| 8 | 250 | 45 | 11 | 5 |
| 9 | 325 | 48 | 12 | 6 |
| 10 | 410 | 51 | 13 | 6 |

All breeds use the same base-stat budget and growth. The formulas are `stamina = 24 + 3 * (level - 1)`, `attack = 4 + (level - 1)` and `defense = 2 + floor((level - 1) / 2)`. Signatures become available at level 3. Level is derived from cumulative XP. There is no adult transformation at any threshold.

### Campaign grants

| Event | Pearls | Food | Other grant |
| --- | --- | --- | --- |
| Reef 1 first clear | 25 | 20 | Ripple at level 3; 20 XP to each participating ray; garden route and two plots |
| Garden friend | 40 | 30 | Mossdrop at level 3; Leaf Shelter; BRD-002 clue |
| Reef 2 first clear | 45 | 35 | Moonpool at level 5; 35 XP to each participant; two plots and both later habitat types |
| Reef 3 first clear | 75 | 45 | Emberfin at level 7; 50 XP to each participant; ending and Warm Ring |

The table states the main economy grants. Decorative rewards and optional discoveries carry no additional Pearls, Food or XP in this baseline. The first guided Practice Pool advances its tutorial milestone without currency or XP; optional completed practice runs pay the practice bundle. A first guardian clear pays only its first-clear bundle, not that bundle plus practice. Participant XP goes to every individual in the committed party, including reserves and sidelined members. New guardian recruits receive their authored starting XP and are not retroactively counted as participants in the fight that recruited them.

### A route that does not depend on waiting

Starting with 100 Pearls and 30 Food, feed Blueberry, Sunbeam and the first Pearlcloud twice each. The six feeds consume exactly 30 Food and put each at 30 XP, level 3. BRD-001 costs 40 Pearls. Reef 1 adds 25 Pearls, 20 Food and 20 XP to each of the three, reaching 50 XP, level 4.

The garden friend adds 40 Pearls and 30 Food. Its level-3 Mossdrop can pair immediately with Blueberry; BRD-002 costs 60 Pearls and guarantees Rosefin. Reef 2 adds 45 Pearls, 35 Food and 35 XP to the original party, reaching 85 XP, level 5. Three feeds per original party member consume 45 Food and add 45 XP each, bringing all three to level 6. The final first-clear bundle then leaves the route with **185 Pearls and 85 Food**.

This calculation excludes all passive production, practice rewards, optional purchases and incidental time. It demonstrates an affordable sequence under the specified grants. It does not demonstrate that every player will choose it, that combat is interesting, or that the campaign lasts two hours. Two free homes provide eight initial spaces; Guest Cove handles extra siblings without an expense gate.

Buying a third home costs 80 Pearls and adds 3 Pearls per minute, giving a simple undiscounted payback of about 26.7 minutes if collected without losses to storage caps. This is optional expansion value, not a required investment. A capacity upgrade serves space and storage rather than faster income. Check voluntary decoration spending and missed collection in playtests before raising mandatory costs.

## 10 Friendly reef challenges

### The intended decision

Challenges give familiar rays something understandable to do together. The central question is **Which response helps this team against the action I can see coming?** The player can maintain pressure, protect a tired favorite, remove a charge, recover the team or bring forward another affinity. There is no input timer, accuracy roll, speed roll or critical-hit lottery.

A challenge uses up to three individual rays per side and one active ray on each side. The player acts first. Every encounter starts with full stamina, no statuses and three Energy per side. Stamina depleted to zero sidelines that individual for the encounter only. A new encounter restores it fully. No defeat removes ownership, XP, appearance or equipment.

### Turn sequence

1. At the beginning of a side's turn, add one Energy, capped at five, except on that side's first turn.
2. Present the legal action or resolve the already announced opponent intention. The player can inspect either team without consuming a turn.
3. Validate target, affordability and eligibility. A rejected choice changes no battle state.
4. Spend Energy, resolve the move in its authored order, clamp stamina and energy, and consume applicable one-use statuses.
5. Sideline any zero-stamina individual and perform a free forced replacement if one exists. If no conscious individual remains on a side, finish the encounter.
6. If both sides remain, pass the turn. A replacement does not generate an extra turn or an Energy refill.

Energy belongs to the side, not the individual. Switching cannot recover a fresh pool. A voluntary swap uses the action and no Energy; a forced replacement is free. A voluntary swap to the already active ray is invalid. The party may contain different individuals of the same breed, but never the same individual twice.

### Available commands

Bubble Bop and Soft Guard are permanent commands. A level-3 ray also has its breed signature. Swap sits beside the reserve portraits. This fixed layout replaces the workbook's unresolved move-slot proposal. MOV-11 Gentle Focus and MOV-12 Friendship Wave remain reserved content IDs for a later move-system decision; they are not launch dependencies.

| ID and move | Power and affinity | Energy | Effect |
| --- | --- | --- | --- |
| MOV-01 Bubble Bop | 6 Tide | 0 | Damage the opposing active ray; always available to a conscious active ray |
| MOV-02 Soft Guard | Support | 0 | Give self 60% protection against the next hit; immediately gain 1 Energy up to cap |
| MOV-03 Sonar Pulse | 8 Tide | 2 | Remove the opponent's Charge before dealing damage |
| MOV-04 Sunburst | 10 Light | 2 | Deal straightforward elemental damage |
| MOV-05 Kelp Hug | Support | 2 | Heal self by the larger of 10 or 35% maximum stamina rounded up; give 20% next-hit protection |
| MOV-06 Moon Drift | 7 Moon | 2 | Deal damage, then reduce the opponent's next damage-move power by 4 |
| MOV-07 Warm Flutter | 12 Ember | 3 | Deal a larger, more expensive attack |
| MOV-08 Pearl Veil | Support | 2 | Give every conscious teammate 35% next-hit protection |
| MOV-09 Rose Breeze | Support | 3 | Heal each conscious teammate by the larger of 6 or 20% of its own maximum stamina rounded up |
| MOV-10 Ripple Dash | 9 Storm | 2 | Deal damage; optionally swap to a conscious reserve as part of the same action |

Ripple Dash's destination is selected before commitment, with **Stay** as a valid choice. It grants no second attack. Healing caps at maximum stamina and never revives a sidelined ray. A support command that would change no stamina, protection or Energy is unavailable with a clear reason. A legal zero-cost Bubble Bop remains available.

### Damage and affinity

For damage moves, use the following implementation formula. Support moves bypass it and deal zero damage.

```text
effective_power = max(0, move_power - soften)
base = effective_power + attack - floor(defense / 2)
damage = max(1, floor(base * affinity * charge * (1 - guard)))
```

Normal `charge` is 1. A Charged attacker uses 1.5 on its next damage action, then clears Charge. Normal `guard` is 0; a protected defender uses the strongest current guard fraction, then consumes all its one-use protection. `soften` is 0 or the strongest active power reduction and is consumed by the affected individual's next damage action.

The affinity wheel is Tide over Ember, Ember over Nature, Nature over Storm, Storm over Moon, Moon over Light, and Light over Tide. A listed advantage uses 1.25, the reverse uses 0.8, and all other pairs use 1.0. The move's affinity is compared with the defender's single primary affinity. Same-affinity attacks are neutral. There is no hidden same-type attack bonus.

At level 5, a neutral Bubble Bop has base damage `6 + 8 - floor(4 / 2) = 12`. Soft Guard reduces the resolved hit to `floor(12 * 0.4) = 4`. A level-5 Kelp Hug restores 13 stamina before the incoming response; a level-5 Rose Breeze restores up to 8 to each conscious teammate. These comparisons motivate the revised support values; they remain tuning hypotheses.

### Status lifetime and targeting

Charge, protection and Soften belong to individuals. They remain on a conscious reserve after a swap. Reapplication retains the stronger effect rather than adding or multiplying it. A support action does not consume an incoming-hit protection, Charge or Soften. All statuses clear at encounter end or when their owner is sidelined. There are no poison ticks, confusion rolls, chained stuns or revival effects in the MVP.

A damage action consumes the attacker's Charge and Soften and the defender's protection even if flooring reduces damage to one. Sonar removes the defender's Charge before damage. Moon Drift applies Soften after damage only if its target remains conscious. Status icons include text such as **Next hit reduced by 60%** and **Next attack power reduced by 4**.

### Guardian intentions and scripts

Before every player decision, show the enemy's next action, target, Energy cost and expected effect. Planning includes the Energy the enemy will receive at the start of its coming turn. Commit that intention in battle state. Updating a preview after a guard, swap or charge removal changes the expected result, not the opponent's chosen action.

**Gather Current** is an opponent-only, zero-damage, zero-Energy preparation action. It adds a nonstacking 1.5 Charge for the next damage move. Its icon and animation are introduced before the first guardian. Blueberry's Sonar is useful because it removes this visible threat; all intentions are already visible without Sonar.

| Encounter | Roster | Initial behavior |
| --- | --- | --- |
| Practice Pool | One level-2 Sunbeam visitor | Bubble Bop, Gather Current, Bubble Bop, then repeat; clear escape and replay controls |
| Reef 1 guardian | Ripple level 3 | Signature, Gather Current, signature, Bubble Bop; repeat |
| Reef 2 guardian | Moonpool level 5; Mossdrop level 4 reserve | Same four-step cycle; Mossdrop uses its bounded healing exception |
| Reef 3 guardian | Emberfin level 7; Moonpool level 6; Ripple level 6 | Same visible cycle with each active breed's signature |

If a scripted action is unaffordable, unavailable or would make no valid change, announce Bubble Bop and advance the cycle normally. Mossdrop's ordinary signature positions use Bubble Bop. Kelp Hug is only a once-per-encounter exception when below 65% stamina, it can benefit and Energy permits. That replaces its next normal action; afterward it proceeds to Gather Current, Bubble Bop, Bubble Bop and repeats that damage cycle. If already Charged, its redundant Gather Current falls back to Bubble Bop. This prevents an endless healing loop or a no-op preparation. AI Ripple stays active after Ripple Dash in the launch scripts; the linked swap remains available to the player.

When the player sidelines an enemy before its announced action, the incoming reserve's response is always Bubble Bop, visibly announced before confirmation of the knockout action where possible. The replacement then starts at the Gather Current position of its own cycle. This fixed rule prevents an unexpected new signature attack from punishing a successful knockout. If no enemy remains, there is no response. A player forced to replace after an enemy action takes the next normal player turn.

The basic scripts are intentionally forgiving. Do not add health solely to make fights longer. If every action feels interchangeable, first improve the taught situation, the opponent's visible pattern or the support consequence. The campaign must remain completable by ordinary favorites while optional practice can demonstrate more exact tactical responses.

### Resolution and recovery

A victory produces one run result. A guardian's first clear checks a separate durable completion flag before awarding its unique bundle. Repeat results use practice rewards. Defeat or surrender awards no victory bundle and offers Retry, Prepare team and Return home. Previously settled noncombat discoveries stay settled. Retry creates a new run with full stamina and initial Energy.

Pause and close must resume at the last committed action boundary. If the last action committed but its animation did not finish, restore the resolved state and play a brief recap. Never apply the action again. The result screen is a view of saved settlement state, not an independent reward owner.

## 11 Interface and accessibility

### Screen structure

The sanctuary is the default destination. Its main controls are Rays, Nursery, Reef Map and Build, with Journal and Settings persistently reachable. A compact resource bar shows wallet Pearls and Food. The selected home's stored production is a separate value. A single objective card names the next useful action without locking other activities.

| Screen | Main action | Information that must be visible |
| --- | --- | --- |
| Ray profile | Feed, greet or choose home | Individual name, breed, level, XP, signature, current availability and parents |
| Nursery preview | Start pairing | Both actual parents, outcomes, probabilities, duration, cost and any failed prerequisite |
| Nursery ready | Meet the baby | Ready status, safe home or Guest Cove destination, saved outcome |
| Roster | Choose an individual | Resident and Visiting filters, favorite marker, breed and busy state |
| Build preview | Place or cancel | Footprint, valid space, price or free voucher, preserved residents when moving |
| Reef map | Continue or prepare | Region objective, settled nodes, available branches and next challenge |
| Challenge | Choose a response | Active and reserve stamina, shared Energy, enemy intent, target and exact effect preview |
| Journal | Discover the next possibility | Separate breed count, individual history, clues and parent links |
| Save and backup | Export or inspect import | Last saved state, save availability and explicit replacement preview |

### Input contract

All required actions work with a mouse, keyboard-only navigation and one-finger touch on supported devices. Selecting then placing is an alternative to dragging. Swapping uses selectable portraits with a confirmation preview. A pinch, hover, rapid press or sustained hold never carries an exclusive required action.

Use a visible keyboard focus indicator and return focus to the invoking control after a dialog closes. Escape or Back cancels an uncommitted selection. The interface prevents accidental double commitment during animations, while preserving responsive inspection and cancel actions where legal. Text entry uses an appropriate editable field, accepts repeated nicknames and preserves stable identity. Nicknames support 1–24 user-perceived characters; trim surrounding whitespace, reject an empty result and render text as text rather than markup.

As initial product targets, use touch controls of at least 44 by 44 CSS-equivalent pixels, ordinary text around 16 CSS-equivalent pixels or larger, and a scalable layout that keeps primary actions visible with the device keyboard open. These are design targets to verify, not a claim of accessibility certification. Do not shrink the desktop layout wholesale onto a phone.

### Perception and comfort

Use affinity icons and names in addition to color. Pair a changed number with a short label such as **15 XP gained** or **Next hit protected**. Important state never depends only on audio, a particle burst or a tiny expression. Maintain a clear selected-ray outline against all four backgrounds.

Provide independent music, effects and ambience volume, mute, reduced motion, reduced flashes, text scaling and faster or skippable repeat animations. Reduced motion replaces long camera pans and repeated bobbing with short fades and stable poses; it preserves information about actions and outcomes. Challenge decisions wait indefinitely. No flashing failure overlay or shaking baby communicates defeat.

At a narrow portrait viewport, the sanctuary uses a bottom navigation row and a scrollable selected-ray sheet. At wide widths, a side panel can remain open. Avoid mandatory rotation. Document the tested viewport and device range at release; investigate real keyboard, safe-area, zoom and touch behavior before claiming support.

### Useful error copy

Errors explain the actual constraint and offer the next valid action: **Blueberry is pairing for 42 more seconds**, **This home is full. Choose another home or Guest Cove**, **You need 5 Food. Your garden has 3 ready**, or **This backup uses a newer save version. Your current reef is unchanged**. Do not use a generic failure popup when the relevant recovery route is known.

Potentially destructive operations, including replacing a saved reef, show a preview and require explicit confirmation. Ordinary reversible actions do not need repeated warnings. A failed purchase or import leaves the prior valid state and selection intact.

## 12 Art sound and game feel

### Mascot identity

The recovered reference material establishes a specific face and silhouette: soft protruding snoot, one large friendly near eye in side view, broad floppy triangular wing, pale underside and long thin tail. Preserve this combination at real gameplay size. Generic diamond-shaped mantas, dragon horns, legs, external ears, realistic adult anatomy and threatening teeth would weaken the project's recognizable identity. [S1]

The cover illustrates Blueberry, Sunbeam and Pearlcloud together in a sanctuary. It is an original concept adaptation made for this GDD, not a shipped screenshot or a sprite sheet. Original Fish World reference images remain reference material and should not be copied into runtime asset folders. Record the provenance and permitted use of every production asset.

### Rendering treatment

The workbook's 96 by 96 sprite canvas is a trial. Compare one complete Blueberry interaction in a pixel treatment with a faithful small cartoon raster treatment, using the same actual on-screen size and environment. The accepted smooth reference makes the cartoon option a serious candidate. Choose one after checking identity, animation, readability and measured production effort; do not produce both full rosters.

A source canvas size is not an on-screen-size requirement. The tail and wing must fit atlas bounds in every frame. Freeze pivot, transparent padding, filtering, outline weight and cosmetic masks together before producing variants. The face has the highest contrast, the wing silhouette second, and the main breed motif third. Secondary inherited accents remain subordinate.

### Environment and interface

Sunlit Shallows uses pale sand, aqua water and warm shafts of light. Kelp Garden adds layered green shapes behind clear swim lanes. Moonlit Cove uses indigo shelter and localized broad glows while keeping faces readable. Warm Spring uses soft coral warmth, smooth stones and slow current loops. No environment requires darkness that obscures controls or effects that conceal a reaction.

Use broad color patches and a small number of legible markings. Background detail must fall away at normal zoom. The interface uses rounded, calm shapes and clear labels, with one primary action per panel. Decorative water animation stays behind text and interactive objects. A full habitat should look companionable, not like an unreadable pile of sprites.

### Animation and response

The nine shared animation groups cover swim, turn, idle and blink, greet, feed, rest, celebrate, recover and challenge action. Eight breeds can share the production structure, with posture holds, timing and routine weights providing character. Cosmetic masks remain aligned across all frames. At least the three slice rays must have complete representative interactions before the rest of the roster is multiplied.

Selection responds immediately with outline and attention. A feed synchronizes the accepted transaction, snack reaction and XP label. A hatch pauses long enough to see the child, parents and name, then gives control back. A successful guard shows the softened impact and reduced stamina change together. A sidelined ray safely glides to the reserve edge rather than collapsing.

As starting timing targets, show the input acknowledgement within 100 milliseconds under the supported performance budget; keep an ordinary home reaction around 0.6–1.2 seconds and a repeat reaction shorter; keep a full hatch reveal around 3–5 seconds with Skip available. These values are hypotheses for feel, with no simulation or reward dependent on animation completion.

### Audio

Use three compact musical families: home, adventure and challenge, with a short ending variation. Four restrained ambience layers distinguish habitats. A small interaction cue set covers selection, feed, pairing start, hatch, collect, guard, swap, success, safe retreat and error. Breed calls can vary within a shared soft vocal palette.

The nursery reveal has a brief recognizable musical phrase. Challenge music adds playful movement without suggesting danger to the babies. Start audio only after the player's initial input gesture and preserve volume settings. Every essential cue has an equivalent visible signal. Validate the actual exported browser audio rather than assuming editor playback is representative. [S6]

## 13 Technical design and persistence

### Platform baseline

Use Godot with GDScript, the Compatibility renderer and a single-thread web export as the initial implementation direction. Pin an actually verified stable editor and matching export templates in the project. Do not copy a proposed engine version from an old planning document without confirming it. Godot's current official web guidance requires WebAssembly and WebGL 2.0 and describes single-thread export and browser persistence limitations. [S6]

Prove the actual intended host with a minimal export before building the full campaign. A static page loading successfully does not prove that its Godot runtime, audio, input or saves work. Test the served game, including any embedding context, then record the URL and exact build identity. The current live implementation has not been audited as part of writing this GDD.

### Boundaries and ownership

Keep content definitions separate from saved player instances. A gameplay command validates a complete operation and commits its changes once. Scenes display state and collect input; they do not independently grant the same reward. Rendering and animation react to committed events without deciding ownership or currency.

Suggested implementation boundaries are collection and housing, economy, breeding, campaign and expeditions, challenge simulation, journal, save and platform integration, and presentation. These can be modules in one small project; they do not require services, networking or a generalized plugin framework.

An expedition owns its node settlement. A challenge returns a result to that owner when embedded in a route. Standalone practice owns its own settlement. Exactly one path grants each bundle. A result screen, homecoming animation or journal update cannot grant it again.

### Save contents

Persist the schema version, content version, profile revision, wallet, transaction receipts, home instances, stored production, garden progress, all owned individuals, nursery job and committed outcome, journal flags, campaign milestones, current route, battle state at an action boundary, settings and settlement receipts. Parent IDs and acquisition IDs survive renaming and transfer. Save dynamic facts rather than whole scene trees. Godot's saving guide provides serialization approaches; this project still needs its own explicit version and recovery contract. [S7]

Autosave after meaningful committed actions and at safe periodic intervals. Use a current save and previous-good copy with a validated write/replace process. Display **Saving**, **Saved** or **Save unavailable** where the player can inspect the state. Failure must not silently create a blank reef or claim successful persistence.

Export a portable backup from Settings and from a save-error notice. Import first parses and validates a candidate separately, then previews its reef, saved date and supported version. Replacing the active profile requires confirmation and retains a recovery copy. Reject malformed or newer unsupported formats without modifying the current profile. Never execute code or follow external instructions contained in a backup.

### Time and suspension

All timed systems consume one nonnegative approved elapsed-time budget. Active play uses monotonic elapsed time. On resume, use saved time markers to calculate an eligible gap, clamp negative elapsed to zero and cap the resume credit at eight hours. Breeding stops at its duration, and each production bin stops at its own storage limit. Persist the settled marker so repeating the same resume cannot award the interval twice.

Changing the device clock backward cannot reverse a job or remove stored resources. A large forward jump produces at most the allowed credit. This is a local single-player consistency policy, not an anti-cheat guarantee. Do not add a backend solely to police the local clock.

Browser storage and cache behavior vary with context. Timer progress while the page is closed is a separate feature from launching the whole game without a network connection. The MVP promises local saves and backup when supported, not cloud synchronization or guaranteed offline launch. Explain storage limitations in concise help and in an observed failure state. [S6]

### Concurrency and migrations

One open game instance owns the writer role for a profile. A second tab shows a read-only notice or an explicit takeover flow; it cannot quietly replace newer progress with a stale snapshot. Use revision checks when committing saves. An older build encountering a newer schema preserves it and explains the incompatibility.

Each supported migration runs on a copy, validates invariants and preserves a recovery backup before replacing the active save. Unknown content IDs remain represented as recoverable records. They must not be silently deleted or turned into newly granted assets. A migration should not reroll a committed egg or refund and recharge a settled purchase.

### Initial performance budgets

The following are release targets to measure on declared test devices, not observed results. Target 60 frames per second on the reference desktop and at least 30 on the reference touch device in the busiest ordinary sanctuary. Test six homes, 36 visible residents and a roster of 200 saved individuals. Off-screen routines can update less frequently without changing outcomes.

Target a compressed initial download of 25 MiB or less and an interactive entry within 15 seconds on a controlled 20 Mbps connection with an 80 ms round trip. If the exported runtime alone makes a budget unsuitable, record the measured result and revise the budget explicitly before promising it. Show honest loading progress and a readable unsupported-browser or runtime-load error. Include a mouse/keyboard desktop, an Android Chromium device and an iOS Safari device in the initial compatibility investigation; publish only support that the candidate build actually passes.

## 14 Content and production plan

### Authored content inventory

| Deliverable | MVP count | Reuse and boundary |
| --- | --- | --- |
| Core ray definitions | 8 | Shared body and animation contract; distinct motifs and signatures |
| Habitat art kits | 4 | Six instances reuse these kits; Guest Cove adds no environment |
| Decoration types | 8 | Reusable copies and behavior anchors; no power modifiers |
| Main route nodes | 15 | Five per region; short authored interactions and shared presentation |
| Optional route nodes | 2 | Cosmetic discoveries; branches rejoin the main route |
| Challenge encounter definitions | 4 | One practice and three guardians; rematches reuse rules with visitor IDs |
| Player move definitions | 10 | Two universal commands and eight signatures |
| Breeding recipe rules | 6 | Five exact pairs plus a same-breed rule |
| Cosmetic resolution entries | 18 | Six symmetric pairs for each of three small loci |
| Shared animation groups | 9 | Swim, turn, idle/blink, greet, feed, rest, celebrate, recover and challenge action |
| Music families | 3 | Home, adventure and challenge, with short transitions and ending variation |

Create the actual asset list from these counts after the mascot and export spikes. A shared animation group does not mean one finished file serves every breed without checking masks, silhouette and effects. Count the accepted work and its production cost before forecasting the remaining content.

### Campaign node manifest

| ID | Node | Function |
| --- | --- | --- |
| r1_01 | Sunlit Entry | Arrival and party context |
| r1_02 | Shell Path | Shared required clue through sonar or ordinary bubble trail |
| r1_03 | Small Current | Ordinary route or Sunbeam talent vignette |
| r1_04 | Practice Pool | Basic action, intention and swap teaching |
| r1_05 | Ripple's Ring | First guardian and region completion |
| r1_optional_01 | Hidden Shell | Optional Smooth Resting Stone copy; branches from Shell Path |
| r2_01 | Leaf Shelter | Guaranteed Mossdrop and pairing clue |
| r2_02 | Kelp Crossing | Ordinary route or Mossdrop talent vignette |
| r2_03 | Quiet Water | Safe capped-recovery preview without a reward farm |
| r2_04 | Moonlit Approach | Preparation and persistent moonlit ambience |
| r2_05 | Moonpool's Clearing | Second guardian and region completion |
| r3_01 | Warm Stones | Arrival and Vent Stone grant |
| r3_02 | Drifting Lanterns | Ordinary route or familiar talent vignette |
| r3_03 | Spring Bend | Small discovery acknowledging the chosen party |
| r3_04 | Gathering Pool | Preparation and access to existing Practice mode |
| r3_05 | Emberfin's Circle | Final guardian and ending trigger |
| r3_optional_01 | Lantern Alcove | Optional Glow Pebble copy; branches from Drifting Lanterns |

Optional nodes return to the next main node. A homecoming and the Reef Gathering are presentation sequences after settlement, not additional map nodes. Drifting Lanterns uses environmental lights rather than implying a ninth buildable prop. Quiet Water's demonstration creates no persistent damage or currency and is skippable if the player already understands it.

### Stage zero prove delivery and identity

Build one visible Blueberry, one input, gesture-started audio, one persistent value and a backup round trip on the actual host. In parallel, compare the two bounded rendering treatments at actual play scale. Select one style only after face, wing, tail, animation and interface remain readable together. Record the chosen engine and templates, deployed build identity and asset provenance.

Exit only when the actual hosted runtime responds, reloads and preserves the test value in the declared context. A deployment receipt or desktop editor test does not satisfy this stage. Map to GATE-01 and GATE-02 and the workbook's initial engineering and art spikes.

### Stage one complete the representative slice

Build Blueberry, Sunbeam and Pearlcloud; the two Sunlit homes; naming, feeding, collection and the first guaranteed pairing; two free props; journal; Guest Cove recovery; three-member party; Practice Pool; and persistent return home. Use representative creature art, key sound and real interaction feedback. The slice must demonstrate the actual appeal, not merely a chain of debug buttons.

A fresh player must be able to complete that loop through normal controls. Record confusion and interventions. Test a full home, a busy parent, interrupted incubation, an interrupted reveal and a save/reload. Measure accepted asset and scene work before estimating the full roster. This resolves GATE-03 and anchors GP-011 through GP-018, GP-061 through GP-078 and the first integrated challenge work.

### Stage two finish the whole campaign

Implement the remaining five varieties, habitats, node routes, guardian rewards, ending and repeat play. Use source-driven content definitions and shared scene components. Run a clean-profile completion before polishing optional cosmetic depth. Reconcile this GDD's decisions with workbook Systems, Economy, Combat, Progression, Assets and dependent backlog items.

Exit when every launch variety is reachable, a starter-inclusive team contributes meaningfully, free recovery works at zero currency, optional purchases do not create a hard lock, and the ending preserves the reef. Complete the applicable GATE-04 through GATE-07 checks. The S00–S15 workbook sequence describes work batches, not promised calendar weeks. Schedule only after actual completion evidence and team capacity are known.

### Stage three verify the release candidate

Freeze one candidate commit and content manifest. Verify the supported devices, fresh and previous saves, backup/import, actual served files, audio, input and complete journey. Check credits, asset provenance and concise player help. No release-blocking crash, irreversible save loss, required-route softlock or unusable required action may remain.

Record the actual live build identity and rerun a representative core loop after deployment. A pass on an earlier build does not automatically approve the candidate. Expansion starts only after the MVP is accepted and delivered. This corresponds to the workbook's final release gates and AG-017 through AG-020.

### Team and agent handoff

Each task names the player-visible result, owning specification, affected files, acceptance evidence and dependencies. A worker records its claimed scope and base commit before editing. Use isolated workspaces for overlapping changes and one owner for cross-cutting tuning data. A handoff includes what changed, why, exact tested build, results and remaining limits.

Automated agents can implement contracts, inspect state and run simulations. Human play remains the evidence for enjoyment, attachment and comprehensibility. Never mark a task complete solely because an agent says the scene looks good or a function returns without an error. Preserve other workers' changes, review integration conflicts and make the final reviewer verify the actual candidate.

## 15 Validation and release criteria

### What has been checked for this design

The opening Food arithmetic, campaign resource sequence, level table and expansion guarantee probabilities were calculated against the proposed values. An early deterministic battle model used the proposed stats and damage formula with a simplified preliminary opponent script. The original trio has a modeled route through those guardian seeds. The simplified model also wins at lower levels, which identifies a risk of shallow choices rather than proving the final balance is strong.

That model uses a preliminary three-action cycle and does not execute the final four-step AI, Mossdrop's bounded healing or the final reserve-response rule. It also omits the interface and player misunderstanding. It is not a Godot build test or human playtest. No measured claim is made here about retention, commercial demand, accessibility coverage or the 2–3-hour target. The release gates below supply the next evidence.

### Critical functional scenarios

| Case | Required result | Specification anchor |
| --- | --- | --- |
| Clean opening | Original grant can ready both founders and first Pearlcloud; no passive income required | Sections 4 and 9; PR-01/02 |
| First discoveries | First committed BRD-001 and BRD-002 produce their target and survive reload | Section 8; SYS-GP-04/05 |
| Full homes | Hatch and guardian reward survive; Guest Cove permits free recovery and campaign continues | Section 7; IN-027 |
| Busy favorite | Starting incubation invalidates an affected party with an explained recovery path | Sections 8 and 10; SYS-GP-09 |
| Duplicate names | Two same-named siblings retain distinct ownership, parents and homes | Section 6; GP-002/003 |
| Repeated input | One accepted transaction produces one debit, job, child or settlement | Sections 8–10; SYS-GP-02/11 |
| Zero resources | Stored homes can be placed free, guests can return, and free practice and garden recovery remain available | Sections 7 and 9; GATE-04 |
| Status timing | Protection, Soften and Charge follow exact use, swap, stacking and replacement rules | Section 10; GP-097/100 |
| Favorite team | Blueberry performs useful actions across all guardians under an ordinary training budget | Section 10; GP-094 |
| Clock and suspension | Progress is nonnegative, capped and monotonic; a settled interval cannot pay twice | Section 13; SYS-GP-07 |
| Save failure | An unavailable write is visible; invalid import preserves the active reef | Section 13; GATE-05 |
| Two tabs and old build | A stale writer or older schema cannot silently overwrite newer progress | Section 13; EN-045 |
| Input and comfort | Full loop works with declared inputs, mute and reduced motion; essential meaning remains | Sections 11–12; GATE-06/07 |
| Ending and return | Homes, individuals, lineage, missing hybrids and practice survive ending and reload | Section 5; IN-028 |

Each result must name the build and evidence. Where a scenario includes animation, touch or a saved state, inspect that behavior in the actual running candidate. Function-level checks alone cannot establish it.

### Human playtests

Begin with 5–8 fresh qualitative participants across creature-collection and cozy-game interests, including people who use the intended touch and keyboard paths. This is a practical discovery sample, not a statistical estimate of the audience. Record device, prior familiarity, assistance, stopping point and build. Ask them to make themselves at home and discover another ray without explaining the interface.

Observe whether they recognize Blueberry, understand the two parents and the outcome, distinguish a breed from an individual, find a full-home recovery and choose a response to a visible intention. After play, ask what they expected, whom they would take again and which moment felt confusing or empty. Voluntarily naming or returning to a ray can support an attachment hypothesis; it does not reveal a player's feelings by itself.

For the full campaign, separate active decisions, reading, voluntary home arrangement, repeated failures and idle waiting. Test an original-trio route, a different favorite team, decorative spending and missed collections. A total session time alone cannot tell whether the pace is good. If the player waits because every useful action is blocked, repair the gate before adding more content.

### Design experiments

| Question | Small experiment | Decision supported |
| --- | --- | --- |
| Does the mascot survive production scale | Compare the two Blueberry treatments in the same running scene | Freeze one art pipeline |
| Does breeding communicate family | Compare the child reveal with and without clear parent accents and cards | Keep the clearest reveal with the smallest visual burden |
| Do support moves create useful choices | Author one charged-hit setup and one wounded-team setup in Practice | Adjust effect, presentation or scenario before adding moves |
| Does a route feel like an outing | Test a complete short node sequence with ray reactions and homecoming | Improve interaction consequences before increasing node count |
| Does the home encourage recognition | Observe named rays with two distinct routines and one buddy interaction | Expand only the behaviors players can perceive |

Change one main experience hypothesis at a time when diagnosing uncertainty. A crash or irreversible save issue is fixed immediately. Record the observation, plausible cause, change and result. Avoid a universal numerical fun score or a release claim based on simulated players.

## 16 Expansion path

The existing broader plan contains 24 total varieties and eight habitat types. The 16 later varieties remain deliberately disabled in the launch journal and recipe resolver. Expansion adds a guaranteed founder before any recipe requiring its new affinity. It also needs a complete affinity decision for Frost and Stone; they must not inherit an accidental default weakness table. [S1]

### Later homes and founders

Frost Shelf introduces Tidalglass through a guaranteed arrival. Pebble Lagoon introduces Pebble through a guaranteed encounter. Current Basin introduces Drizzle through a guaranteed exploration milestone. Starwater Grotto supports the later Light and Moon collection. These are planned content directions without a promised release date.

### Preserved later recipe catalog

Each row keeps its existing ID, exact parents, cost and duration. Base outcomes are 60% target and 20% of each parent breed. The target is guaranteed on the third committed attempt without that target for this recipe. Increment or reset the counter when the result is committed, not when revealed.

| ID and target | Parents | Pearls | Seconds |
| --- | --- | --- | --- |
| BRD-007 Aurora | Moonpool and Tidalglass | 100 | 300 |
| BRD-008 Obsidian | Emberfin and Pebble | 100 | 300 |
| BRD-009 Sherbet | Tidalglass and Sunbeam | 100 | 300 |
| BRD-010 Dapple | Mossdrop and Sunbeam | 90 | 240 |
| BRD-011 Stardrop | Moonpool and Pearlcloud | 100 | 300 |
| BRD-012 Cloudcurl | Ripple and Sunbeam | 90 | 240 |
| BRD-013 Cinderblush | Emberfin and Mossdrop | 100 | 300 |
| BRD-014 Inkspot | Blueberry and Moonpool | 90 | 240 |
| BRD-015 Honeyglow | Sunbeam and Emberfin | 100 | 300 |
| BRD-016 Seaglass | Mossdrop and Pebble | 90 | 240 |
| BRD-017 Plumdream | Moonpool and Mossdrop | 100 | 300 |
| BRD-018 Frostberry | Tidalglass and Mossdrop | 100 | 300 |
| BRD-019 Sunset | Stardrop and Sunbeam | 120 | 360 |

The 13 recipe targets plus Tidalglass, Pebble and Drizzle make the 16 later varieties. Together with the launch eight, the catalog totals 24. Cosmetic appearances do not add to that number.

With the third-attempt rule, the first-success probabilities are 60% on attempt one, 24% on attempt two and 16% on attempt three. Expected attempts are 1.56. For a 100-Pearl, 300-second row, that is 156 expected Pearls and 468 expected seconds of nursery time, with maxima of 300 Pearls and 900 seconds. This arithmetic describes the rule; whether that anticipation feels good still needs observation.

Expansion should add a fresh place, behavior or team relationship before simply increasing numbers. Reassess plots, reserve usability, collection presentation and save migrations against the larger catalog. Trading, online events and monetization require separate product decisions and are not implicit consequences of having more rays.

## 17 Implementation contracts

### Minimal content and save records

The following compact record definitions communicate ownership and invariants. They are schema guidance, not a requirement to adopt a particular class framework or database.

```text
BreedDefinition:
  breed_id, enabled_release, affinities, primary_affinity,
  motif, base_stats, growth, signature_move, habitat_tags

RayInstance:
  ray_id, breed_id, nickname, cumulative_xp,
  genotype, phenotype_seed, parent_ids, acquisition_event_id,
  location_kind, habitat_id, attachment_milestones

BreedingJob:
  job_id, parent_ids, recipe_id, recipe_version,
  committed_pool, committed_breed, committed_genotype,
  phenotype_seed, cost_transaction_id, duration_seconds,
  credited_seconds, state, claimed_ray_id

BattleState:
  run_id, encounter_id, participant_snapshots,
  active_indices, stamina, statuses, side_energy,
  side_turn_counts, intent, script_cursors,
  phase, action_sequence, result, settlement_key

SaveEnvelope:
  schema_version, content_version, profile_revision,
  time_markers, wallet, habitats, garden, individuals,
  nursery, campaign, journal, active_run, receipts, settings
```

### Nonnegotiable invariants

A unique acquisition event creates at most one individual. A settled transaction changes the wallet once. A resident has one valid home; a visitor has no resident slot. Resident count cannot exceed capacity. A parent is reserved by at most one Incubating job. Ready releases that reservation even before a baby is claimed. Every claimed job references exactly one child.

A party contains owned, resident, available individuals and no repeated individual ID. An active run uses its committed participant snapshot; training elsewhere cannot change a combatant mid-action. Only one outing or standalone challenge can be active. An embedded challenge belongs to its existing outing. Opening standalone Practice from a route first ends that outing through Return home, preserving settled nodes and releasing the party, then starts a new practice run. Away individuals can be inspected and renamed, but cannot be fed, transferred or paired until the run ends or is safely abandoned.

Campaign prerequisites are acyclic and every mandatory unlock has a guaranteed ordinary route. No required parent is available only through a recipe that already requires that parent. A node or encounter has one reward owner. Completed milestones remain completed after a repeat run or replayed scene.

### Command results

Gameplay commands return an accepted flag, a specific reason if rejected, changed entity IDs and presentation events. Examples are FeedRay, TransferRay, StartPairing, ClaimBaby, StartOuting, ChooseAction and SettleNode. A rejected command has no partial payment or state mutation. The presentation responds to the result rather than guessing whether it succeeded.

Record action sequence and settlement keys in the durable domain state. A short recent-transaction log may support diagnostics, but pruning that log must not erase the permanent completion markers needed to prevent duplicate unique grants. Keep content identifiers stable across display-name edits.

## 18 Risks and decisions to validate

### The main risks

| Risk | Why it matters | Evidence or response |
| --- | --- | --- |
| The rays lose their recognizable face | The project depends on affection for a specific silhouette | Approve the actual-scale animated slice before roster production |
| The collection feels shallow | Eight breeds and short recipes may reveal the whole system quickly | Measure memorable discoveries and home interactions before expanding the catalog |
| The challenges are automatic | Forgiving seeds can make defensive choices irrelevant | Test charged-hit and wounded-team situations; adjust context before adding rules |
| The campaign is shorter than its target | Current arithmetic cannot establish 2–3 hours of worthwhile play | Measure active content; accept a satisfying shorter journey rather than pad waits |
| Cosmetic siblings overwhelm the roster | Individual attachment can become inventory management | Test filters, naming, Guest Cove and duplicate recognition with larger saved collections |
| Save loss breaks attachment | A collection has value only if the player's history persists | Ship observed save states, backup and recovery with the first slice |
| The backlog outruns integration | Many completed tasks can still fail to form a playable game | Review one complete loop and candidate build at each gate |

### Decisions that remain open

Choose the final rendering treatment after the two-style Blueberry spike. Choose the supported device and browser matrix from actual export evidence. Tune guardian difficulty and action pacing from human sessions. Confirm the campaign's natural completion range from full-route play. Review the final title before public marketing; the singular working title does not require a save-schema rename.

These questions have concrete next tests and do not block the design baseline. They should not become an invitation to reopen every established creature, currency or scope choice.

### Cut order if production is too costly

First simplify optional cosmetic variation, extra prop copies in presentation, elaborate buddy scheduling and repeated reveal flourishes. Keep stable parent data, basic secondary inheritance and one observable companion interaction. Next reduce optional node presentation and secondary effects while retaining each region's purpose.

Protect the identifiable eight-ray cast, the first guaranteed discovery, readable challenge responses, viable favorites, free housing recovery, safe saves and a complete three-region ending. If those cannot be delivered together, explicitly replan the release scope and its backlog instead of silently calling missing features complete.

## 19 Changes from the planning workbook

This GDD preserves the user's manta-only direction and the workbook's core release boundary. It makes the following material decisions explicit so the implementation team can update the corresponding specifications once. The source workbook itself has not been modified.

| Area | GDD decision | Reason and affected specification |
| --- | --- | --- |
| Display title | Little Ray; existing project and content keys retained | Follow latest brief without breaking saves; BR-06 |
| Opening pace | First hatch targeted within the first 10–15 minutes | Reveal the core promise early; PR-01/02 |
| Home instances | Six plots with two free Sunlit homes | Accommodate four themes while preserving original homes; SYS-GP-03 |
| Safe reserve | Guest Cove promoted into MVP as a roster feature | Free recovery without deleting favorites; SYS-GP-01/03 |
| Production | Each placed home yields 3 Pearls/minute; one free garden yields 3 Food/minute | Specify real sources and preserve expressive resident grouping; Economy |
| Growth | Complete ten-level curve and exact campaign grants | Fund a demonstrable ordinary path; SYS-GP-08 and Progression |
| Action layout | Bop, Guard, breed signature and Swap | Resolve move-slot ambiguity; CB-07 |
| Information | Enemy intentions visible; Sonar removes Charge | Make choices readable while keeping the starter useful; MOV-03 |
| Support tuning | Stronger Guard, scaled healing, stronger Veil and Soften; Dash can swap | Create plausible defensive and team decisions; MOV-02/05/06/08/09/10 |
| Energy and statuses | Shared side Energy, explicit first-turn rule and one-use status lifetime | Prevent contradictory implementations; SYS-GP-10/11 |
| Attachment | Recorded milestones and bounded buddy behavior; extra combat unlocks deferred | Keep individuality affordable; SYS-GP-08/13 |
| Content presentation | Fifteen main nodes, two optional nodes and eight prop types | Bound authored scope and connect the regional arc; Assets and Progression |
| Rendering | Compare faithful cartoon raster with the provisional pixel trial | Preserve the accepted reference at actual scale; Art Direction |

Retained without a new design change are the eight launch breeds, four habitat themes, three guardian rosters, six launch recipes, 13 later recipes, first-hybrid guarantees, committed breeding results, temporary parent reservations, baby proportions, equal stat budget, two currencies, 100-Pearl and 30-Food opening grants, 5-Food feeds, 120-second first pairing, 80-Pearl extra homes, capped elapsed time, recoverable defeat and continued play after the ending.

## 20 Sources and design provenance

**S1 Existing project plan.** [Little_Rays_Agile_Game_Development_Plan.xlsx](https://chatgpt.com/library?file_id=libfile_8fd1807d00808191a7c4e2805ab50680&account_id=personal), planning baseline dated 23 November 2026. Read the actual workbook, including Product Brief, Systems, Rays, Breeding, Habitats, Economy, Progression, Combat, Art Direction, Assets, Quality Gates, Architecture, Hosting and Agent Handoff. It contains 25 sheets and the prior implementation backlog. The embedded original blue and tropical ray references are reference-only; the accepted enlarged blue image informs the identity brief.

**S2 Current project brief.** Hazel's request to use the Game Designer skill to design Little Ray around cute manta rays in a Dragon City style game. New creative names, interaction details and tuning in this GDD are original proposals for that brief.

**S3 Game Designer skill.** [Game Design AI Skill](https://github.com/hazelfjeld/Game-Design-AI-Skill), published baseline commit `dc26ddb18adc18fbbe2221a8443a71a260de6022`. Applied its experience-to-rules workflow, explicit system contracts, bounded production, accessibility, evidence labeling and human playtesting procedures. The skill contains original synthesis with its own source bibliography; this GDD does not reproduce book chapters or claim access to complete texts.

**S4 Dragon City breeding reference.** Socialpoint, [How does breeding work](https://socialpoint.helpshift.com/hc/en/7-dragon-city/faq/4220-how-does-breeding-work/), accessed 23 November 2026. Used to identify the parent-selection and offspring-discovery appeal. Little Ray's exact recipe rules are its own design.

**S5 Dragon City habitat reference.** Socialpoint, [What are the different Types of Habitats](https://socialpoint.helpshift.com/hc/en/7-dragon-city/faq/4226-what-are-the-different-types-of-habitats/), accessed 23 November 2026. Used for the collection-and-housing comparison, not to copy that game's content or progression.

**S6 Godot web export.** Godot Engine documentation, [Exporting for the Web](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html), accessed 23 November 2026. Consulted for browser requirements, rendering and threading constraints, audio initiation, background processing and persistence limitations. Product performance targets in this GDD are proposed requirements, not claims made by that documentation.

**S7 Godot persistence.** Godot Engine documentation, [Saving games](https://docs.godotengine.org/en/stable/tutorials/io/saving_games.html), accessed 23 November 2026. Consulted for serialization context. Little Ray's exact save schema, revisions, migration and settlement contracts are project requirements.

**Concept illustration.** Generated for this document using the accepted enlarged blue-ray direction as an image reference. The prompt specified Blueberry, butter-yellow Sunbeam and pale Pearlcloud in a gentle original sanctuary scene, preserving the rounded snoot, near eye, broad wing, cream underside and long tail. It is visual direction for review, separate from final animation and production-asset approval.




