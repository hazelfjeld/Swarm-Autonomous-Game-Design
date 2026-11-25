# GAMEPLAY-002 opening city checkpoint

First bounded implementation of #12, under the director's 2026-11-25 P0 readiness revision. This is a separate Godot project for independent feature work, not the accepted architecture or production save schema.

## Run

Use the architect's verified Godot 4.7.2 stable editor. Open this directory as a project or run:

    godot --path game/city_checkpoint
    godot --headless --path game/city_checkpoint --script res://tests.gd

Name Blueberry in the text field (Enter), collect the one-time tutorial sample or wait 30 seconds for the first earned Gold, plant Sprout Kelp or Ribbon Kelp, wait its real 60/300 seconds, harvest, and feed in four pips per level. No time shortcuts are exposed to normal play. The CI native GUI fixture uses simulated mouse events; domain tests inject time explicitly. Screenshots and web export are retained on the exact-head CI run when successful.

## Boundary

GDD v2 §§4,7,9,13: opening 8x8 land, three prebuilt footprints at exact coordinates, 1,200 Gold, 240 Food, resident production in 240 ticks per Gold, single crop slot with exact costs/output/XP, sample receipt, feeding through level 10. Placeholder geometry is original; not mascot-approved. The snapshot adapter is memory-only, explicitly displayed as session-only; no persistence, offline resume or multi-tab guarantees. UI control positions and provisional domain schema are implementation choices. No adoption of unreviewed ARCH-002 data code. Reconcile transaction/time/revision/snapshot contracts with #9 before Review or integration.

Remaining: complete placeable/expandable land, all six records, compatible housing and moves, builder/upgrade timelines, fuller quest gates, persistence integration, ordinary-controls and exact-build QA, human testing. Separate breeding and battle stay in #23/#13. No merge or Done claim.
