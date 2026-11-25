# GAMEPLAY-002 opening city checkpoint

First bounded implementation of #12, under the director's 2026-11-25 P0 readiness revision. This is a separate Godot project for independent feature work, not the accepted architecture or production save schema.

## Run

Use the architect's verified Godot 4.7.2 stable editor. Open this directory as a project or run:

    godot --path game/city_checkpoint
    godot --headless --path game/city_checkpoint --script res://tests.gd

Name Blueberry in the text field (Enter), collect the one-time tutorial sample or wait 30 seconds for the first earned Gold, plant Sprout Kelp or Ribbon Kelp, wait its real 60/300 seconds, harvest, and feed in four pips per level. No time shortcuts are exposed to normal play. The CI native GUI fixture uses simulated native mouse events and waits the real 60 seconds before collecting earned Gold and harvesting; domain tests inject time explicitly. Screenshots and web export are retained on the exact-head CI run when successful.

## Boundary

GDD v2 §§4,7,9,13: opening 8x8 land, three prebuilt footprints at exact coordinates, 1,200 Gold, 240 Food, resident production in 240 ticks per Gold, single crop slot with exact costs/output/XP, sample receipt, feeding through level 10. Placeholder geometry is original; not mascot-approved. The snapshot adapter is memory-only, explicitly displayed as session-only; no persistence, offline resume or multi-tab guarantees. UI control positions and provisional domain schema are implementation choices. No adoption of unreviewed ARCH-002 data code. Reconcile transaction/time/revision/snapshot contracts with #9 before Review or integration.

Remaining: complete placeable/expandable land, all six records, compatible housing and moves, builder/upgrade timelines, fuller quest gates, persistence integration, ordinary-controls and exact-build QA, human testing. Separate breeding and battle stay in #23/#13. No merge or Done claim.

## Construction checkpoint

Choose a Small habitat, grotto, second farm or existing building in the placement menu. Enter zero-based X/Y (X runs down-right, Y down-left), inspect the footprint outline and confirm. The single builder charges once; completion happens automatically after 30/60 real seconds, grants 50 XP once, and enables the building. Cancel before completion for an 80% refund. Moving completed buildings is free and preserves their ID and farm jobs. Farm selection appears above crop controls when a second farm is completed at account level 3. The model's independent slot tests use an explicit test-only level-three XP fixture; the normal founder-hatch milestone needed to reach that gate is not implemented here. Empty new habitats produce zero; no founder purchase/housing transfer, upgrades, expansion or breeding jobs yet. Native GUI fixture additionally purchases a Light habitat and waits 31 seconds for construction. Preview checks placement geometry, not cost/gates; command errors are displayed. All data remain session-only.

## Resident and founder checkpoint

Six catalog records now provide ordered elements, rarity, role, source hints, integer-derived stats and rates. Each individual has a separate ID, name, level, feed pips, rank, acquisition receipt and habitat. Each Small habitat has two resident slots and its own 500-Gold bin. Select a ray to name/feed; select a habitat to collect or move the ray. Compatibility and capacity are validated before a command changes state; moves retain existing bin resources. The collection line lists all six targets, including hybrids that cannot be bought.

The lower shop controls provide a temporary deterministic founder-only hatchery slot: buy Sunbeam for 100 Gold, wait the one-time 30-second tutorial incubation, build/select Light habitat, place it for 200 milestone XP. Later founder eggs wait two minutes; Mossdrop requires account level 4. Training Blueberry and Sunbeam to level 4 and finishing a grotto grants the one-time 300 XP milestone. No random breeding, grotto egg transfer or second hatchery slot is implemented here: #23 must reconcile this narrow founder bridge into its separate hatchery implementation, not duplicate the slot. The snapshot schema is still an isolated memory-only checkpoint; accepted persistence, sale/storage, Large upgrades, expansion, remaining onboarding and representative art are outstanding. New GUI fixture buys and places the founder with native mouse events and a real timer, while destination selection is programmatic. Rare/hybrid placement in model tests uses a labeled internal test fixture, not a player acquisition shortcut.

## Large habitat checkpoint

Select an existing habitat and choose Large (600 Gold, account level 5, five minutes). The shared builder pauses only that habitat's income, retains residents and bin, permits collection and free relocation, then upgrades to four residents and 5,000 Gold storage and awards 25 XP once. Cancel before the deadline for 480 Gold and retain the original habitat. The domain's injected-delta tests exercise the GDD's 385-Gold sixty-minute reconciliation example, exact deadline/fractional production and cancellation. This is elapsed-time settlement in the isolated model, not a durable offline-resume implementation. The normal tutorial still requires later breeding/battle milestones to reach level five; no normal-play XP grant is added. Land, obstacle clearance, sale/storage safeguards and actual save integration remain pending.
