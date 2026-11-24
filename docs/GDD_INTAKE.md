# GDD intake

Little Ray GDD v2.0 is the current received design after the user correction in DIRECTOR-002 #22. Original v1.0 artifacts remain archived; historical DIRECTOR-001 intake stays complete. Read the [canonical full Markdown](design/GDD.md), [current Word companion](design/source/Little_Ray_GDD_v2.0.docx), [source record](design/SOURCE.md), [design baseline](design/DESIGN_BASELINE.md), and [first-slice assignments](design/FIRST_SLICE.md). The procedure below also applies to future supplied versions.

## When the user supplies it

1. Preserve the supplied original under `docs/design/source/` with a stable filename. Record its source name, date, and SHA-256 in `docs/design/SOURCE.md`. Keep source wording intact.
2. For a PDF or Word document, retain the original and create a readable Markdown transcription/summary as appropriate. Identify omitted figures, unreadable sections, or uncertain extraction. A summary must not be described as the full source.
3. Add `docs/design/DESIGN_BASELINE.md`: player experience, core loop, audience, target platforms, engine constraints, visual/audio direction, scope, and acceptance priorities. Mark explicit requirements separately from assumptions and proposals.
4. Set `gdd.status` to `received` and `gdd.path` to the canonical readable repository file in `config/experiment.json`. Record an optional `source_path` for the original. `approved` is used only when the user has explicitly approved that version.
5. Link the source and baseline in the director's startup issue and decision log. Turn the first vertical slice into a small set of assigned issues with observable acceptance criteria.
6. Update the phase to `active` when the first production tasks are ready. A received GDD can support routine implementation; do not invent an additional approval requirement for work the user has already authorized.

## Preserve design intent

Ask the user only about an ambiguity that materially changes the intended game. Continue independent infrastructure work meanwhile. Proposed changes to explicit GDD requirements must be clearly described and returned to the user for a decision; routine implementation choices belong to the responsible role.

Agents must be able to fetch the canonical design from the repository each run. Do not rely on an attachment living only in the original chat.
