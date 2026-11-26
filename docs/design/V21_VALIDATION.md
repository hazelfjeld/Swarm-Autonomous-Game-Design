# DIRECTOR-003 — v2.1 static verification and review handoff

**Task:** [#27](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/27)  
**Role/run:** director / `director-DIRECTOR-003-20261125-b7c39d5f` (lease generation 35)  
**Scope:** documentation and acceptance gates only; no engine/gameplay/asset or scheduled-task changes.  
**Status:** static source/Word structural checks passed; independent QA, Word visual rendering and architect integration **pending**.

## Files and provenance

- [Complete GDD v2.1](GDD.md) — 102,269 UTF-8 bytes; SHA-256 `55d43ab2e48073ee555cf521981ea7ca9b9311fc7517d12989566ce75c884005`; Git blob `602197d618fa183789f1e3e7e0c2a8b3afc2ec03`.
- [Full v2.1 Word companion](source/Little_Ray_GDD_v2.1.docx) — 400,417 bytes; SHA-256 `4989451b520ef4a844c6fcc0283ba99ab23d8409e9f1fe4b9d57fef88e6e1441`; Git blob `f4f5e87f6ef81b74fb3fa5dadc58c0e67fba03ed`.
- [Creative direction](CREATIVE_DIRECTION.md) — new normative presentation charter.
- [SOURCE.md](SOURCE.md) — versioned source record; exact v2.0 Markdown archived separately, illustrated v2.0 Word and both original v1 artifacts untouched.

## Checks actually executed

| Check | Method | Actual observation |
| --- | --- | --- |
| Original v2.0 Markdown archived byte-for-byte | Connector fetch from `main`, compare branch archive text/blob | **PASS** — exact same Git blob `6954c3a89272ce2275cbbca2f46395a62918af3e` |
| Scope: no original GDD lines lost | Exact-line subsequence comparison, ignoring version line only | **PASS** — all v2.0 lines preserved in order; new v2.1 rules are insertions |
| Mechanical data preservation | Compare all Markdown table rows `main` vs branch | **PASS** — all 206 table-formatted lines identical; 20 tables and 20 numbered chapters before/after |
| Config scope and automation preservation | JSON object comparison with only `gdd.version` and `gdd.source_path` updated | **PASS** — phase `active`, all five role offsets and coordination fields unchanged |
| Explicit quality criteria | Static document inspection | **PASS** — GDD, creative charter, first slice, baseline and AGENTS now reference coherent classic-collector/manta identity and the pending style choice |
| Word container integrity | Binary retrieved from GitHub, ZIP header/central directory and CRC32 for all stored entries | **PASS** — 9 parts, all entries verified |
| Word XML structure | Simple stack-based XML element balance check for XML parts | **PASS** — all nine package entries present; 20 chapter headings, 20 tables, 13 source links recorded |
| Word source hashes | SHA-256 of fetched Markdown UTF-8 and GitHub Word bytes; self-test SHA-256(empty) | **PASS** — values shown above and in SOURCE.md |

The DOCX is a text-first, complete reformat of the canonical Markdown. Its predecessor's illustrated cover is **not** included in the v2.1 Word; the original illustrated v2.0 Word is still preserved. The recorded parser checks prove ZIP/XML completeness only, **not** visual rendering, exact Word pagination, clickable-link UX, or source-by-source visual comparison.

## Tests not executed here — required review work

- `python3 scripts/validate_setup.py` and `python3 -m unittest discover -s tests -v`: **not executed**; no authenticated local clone/checkout was available in this interactive environment. Run on the exact submitted PR head in QA/CI.
- Word page rendering and visual inspection: **not executed**. QA should render `source/Little_Ray_GDD_v2.1.docx` and inspect pagination, 20 wide tables, headers/footers, external links, missing content and any line overflow. Fix layout before a final claim of Word quality.
- Godot build, browser/actual-host interaction, screenshot verification, human comprehension, visual style choice, QA playtesting: **not executed or claimed**; they remain on the existing owned tasks.
- Role schedule or automation changes: **none**.

## Gate A/B/C handoff

**A — ART-002 #10:** retain current one-Blueberry pixel/cartoon trial and independent review; obtain Hazel's choice. Do not falsely mark a treatment selected.

**B — ART-003 #11:** after A and runtime-interface readiness, produce six-ray same-scale lineup with shared anatomy, populous habitat, portrait/team and 3v3 readability, art provenance and representative original game assets; this is separate from A.

**C — GAMEPLAY-005 #24 / QA-002 #14:** retain real controls and the exact Gold/crops/food/breed/hatch/3v3/expansion functional route. Add original classic collector city/HUD presentation and one recognizable manta family as evaluated quality criteria. No debug shortcut or mocked screenshot can replace actual play.

## Integration rules

- Review new docs in the **exact submitted PR head** and confirm every old design decision/issue dependency remains intact.
- Treat new presentation gates as effective after reviewed merge; preserve #10's Review and #11/#14/#24's Blocked statuses until their own evidence clears.
- QA should record independent, qualified findings first; architect checks latest head and existing required CI/review before integrating.
- **Director is not the merge owner. Do not merge this branch without the required reviews.**


## Word link correction — 25 November 2026

Independent QA on PR #28 identified four external relationships (rId5–rId8) targeting the wrong sibling path. All four now target the exact reviewed creative charter at [commit 691d3be3caf4](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/blob/691d3be3caf4f345fb14652122b4a3c3bd8dba08/docs/design/CREATIVE_DIRECTION.md); the immutable URL is usable before and after integration. The charter itself is unchanged. Rebuilt only the stored ZIP relationship entry and ZIP metadata; all eight other package entries are byte-identical, all nine CRCs and central directory checks pass, and the original input SHA-256 matched the previous record. Updated the Word digest, byte count and blob above. The new draft still needs actual Word hyperlink-click and full page-layout inspection; no local render or final acceptance is claimed.


## Pagination correction — 26 November 2026 (QA-FIX-005 #40)

At previous exact head `f31befda8559b97709640e4f3ace2aa51a607d44`, independent QA observed sparse overflow pages, continued tables without headers and split task rows. This candidate changes only Word layout: retain first chapter page break after cover, remove 19 subsequent forced chapter breaks, retain Heading1 keep-with-next, repeat all 20 table headers and set cantSplit on all 186 rows. Connector-side stored ZIP checks passed 9/9 local/central CRC and size checks, input SHA-256 matched, original ZIP round-tripped byte-for-byte, reversing only the formatting insertions/removals exactly reproduces original document.xml, and the other eight entries (including relationships) are byte-identical by SHA-256. 13 hyperlinks remain. New Word SHA-256 `4989451b520ef4a844c6fcc0283ba99ab23d8409e9f1fe4b9d57fef88e6e1441`, 400417 bytes, blob `f4f5e87f6ef81b74fb3fa5dadc58c0e67fba03ed`. No Markdown GDD, archived source, mechanics, or link destination change. Exact-head CI render and independent page inspection (including row fit and overflow) remain required; interactive Word links not tested. This is a correction candidate, not document acceptance.
