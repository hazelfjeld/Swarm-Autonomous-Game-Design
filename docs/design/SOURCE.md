# Little Ray design source record

## Current governing version

**Little Ray Game Design Document v2.1**, dated 25 November 2026, is the approved-direction working source. [DIRECTOR-003 #27](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/27) records Hazel's explicit request to retain the classic creature-collector gameplay while making all creature designs a consistent family of cute manta rays. The [creative-direction charter](CREATIVE_DIRECTION.md) is a normative supplement to the [complete Markdown GDD](GDD.md). MouseHunt informs creativity; it does not displace Dragon City / DragonVale / Monster Legends-style management, breeding and combat.

The **full readable Word companion** is at [source/Little_Ray_GDD_v2.1.docx](source/Little_Ray_GDD_v2.1.docx). It was reauthored from the complete v2.1 Markdown with 20 top-level chapters, 20 tables and 13 explicit Markdown hyperlink targets; the cover is text-first rather than repeating the v2.0 concept illustration. The original **illustrated v2.0 Word** remains intact below. The Word v2.1 file passed OOXML/ZIP structure, per-entry CRC, hyperlink/section and document-completeness checks; **full page rendering and visual inspection have not yet been performed** and must be done during review before accepting Word layout quality.

GDD status is **received**, not proof of approved numerical tuning, production art, playability, accessibility or human-player experience. The exact pixel/cartoon production treatment still requires review of [ART-002 #10](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/10) and Hazel's taste choice. **All v2.0 mechanical, numeric, engine and automation contracts are unchanged.** Actual game reviews must continue independently.

## Exact v2.1 working artifacts

| Artifact | Bytes | SHA-256 | Git blob SHA |
| --- | ---: | --- | --- |
| [Full v2.1 Markdown](GDD.md) | 102,269 | `55d43ab2e48073ee555cf521981ea7ca9b9311fc7517d12989566ce75c884005` | `602197d618fa183789f1e3e7e0c2a8b3afc2ec03` |
| [Full v2.1 Word companion](source/Little_Ray_GDD_v2.1.docx) | 400,417 | `4989451b520ef4a844c6fcc0283ba99ab23d8409e9f1fe4b9d57fef88e6e1441` | `f4f5e87f6ef81b74fb3fa5dadc58c0e67fba03ed` |
| [Creative-direction charter](CREATIVE_DIRECTION.md) | See Git object | Verify against exact reviewed commit | See exact reviewed commit |

The v2.1 hashes were computed from the fetched canonical Markdown and the GitHub-stored Word bytes. DOCX ZIP parts used uncompressed ZIP entries, which permits independent part/CRC checks but differs from the original v2.0 package compression. No visual page-render pass is claimed.

## Preserved v2.0 version and provenance

v2.0 was the full Dragon City / Monster Legends mechanics correction approved through [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22), merged in [PR #25](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/pull/25). Its exact main Markdown is now additionally archived at [source/Little_Ray_GDD_v2.0.md](source/Little_Ray_GDD_v2.0.md), with its illustrated Word file retained unchanged; the full 34-page illustrated visual review and 1,052-text-unit source validation belong to **v2.0 only**, not automatically to the new v2.1 Word.

| Artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| [Archived full v2.0 Markdown](source/Little_Ray_GDD_v2.0.md) | 97,804 | `00948230313376ee33e10b7b9950446f4418fca7b2953a846a5230b87b826af6` |
| [Original illustrated v2.0 Word](source/Little_Ray_GDD_v2.0.docx) | 1,815,085 | `7d965f27378043d46a4bdc6b39b19e750669eec5a4cb859f90124a8fa9c2727d` |

`config/experiment.json` points to current v2.1 Markdown and Word; preserved v2.0 and v1.0 artifacts remain historical. The design baseline and first-slice plan are derived specs, not replacement GDDs. This version update is a clarification, not a new completed game build.

## Preserved historical version

V1.0 was originally imported by [PR #15](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/pull/15) and [DIRECTOR-001 #3](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3). Both original artifacts remain byte-for-byte intact. Its original canonical Markdown is now archived alongside the original Word file.

| Historical artifact | Bytes | SHA-256 |
| --- | ---: | --- |
| [Original v1 Markdown](source/Little_Ray_GDD_v1.0.md) | 96,306 | `9e4731bc0ad9bf4db8e761cec0f3f3d85dd3404051cf200e3789ffa3aaad6117` |
| [Original v1 Word](source/Little_Ray_GDD_v1.0.docx) | 1,817,773 | `8587b8484c05ec3ad9238551819fca86fd41bc36db98469c1c1d519ed7c8dfae` |

V1 references the prior Little Rays planning workbook and other project material. That workbook and original Fish World reference images are not bundled; their original Library references may require owner access. V2 is self-contained for the current design. Do not retrieve contradictory old workbook/v1 values to override the latest user correction.

## Revision and evidence rules

GDD v2.0 section 19 explicitly supersedes the conflicting economy, housing, nursery, rarity, progression and combat rules. Preserve stable species/individual identifiers and compatible runtime/capability work. Earlier intake reviews establish preservation of v1, not acceptance of v2 mechanics. The v2.0 revision has its own [validation record](V2_VALIDATION.md) and exact-head review/integration evidence.

Subsequent approved changes (including DIRECTOR-003) must update the source pointer, summaries and affected task criteria together while retaining history. Actual game behavior, human comprehension, pacing and online fairness still require their own evidence. No public deployment, schedule change or game implementation is performed by this document revision.


## Word link correction — 25 November 2026

Independent QA on PR #28 identified four external relationships (rId5–rId8) targeting the wrong sibling path. All four now target the exact reviewed creative charter at [commit 691d3be3caf4](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/blob/691d3be3caf4f345fb14652122b4a3c3bd8dba08/docs/design/CREATIVE_DIRECTION.md); the immutable URL is usable before and after integration. The charter itself is unchanged. Rebuilt only the stored ZIP relationship entry and ZIP metadata; all eight other package entries are byte-identical, all nine CRCs and central directory checks pass, and the original input SHA-256 matched the previous record. Updated the Word digest, byte count and blob above. The new draft still needs actual Word hyperlink-click and full page-layout inspection; no local render or final acceptance is claimed.


## Pagination correction — 26 November 2026 (QA-FIX-005 #40)

At previous exact head `f31befda8559b97709640e4f3ace2aa51a607d44`, independent QA observed sparse overflow pages, continued tables without headers and split task rows. This candidate changes only Word layout: retain first chapter page break after cover, remove 19 subsequent forced chapter breaks, retain Heading1 keep-with-next, repeat all 20 table headers and set cantSplit on all 186 rows. Connector-side stored ZIP checks passed 9/9 local/central CRC and size checks, input SHA-256 matched, original ZIP round-tripped byte-for-byte, reversing only the formatting insertions/removals exactly reproduces original document.xml, and the other eight entries (including relationships) are byte-identical by SHA-256. 13 hyperlinks remain. New Word SHA-256 `4989451b520ef4a844c6fcc0283ba99ab23d8409e9f1fe4b9d57fef88e6e1441`, 400417 bytes, blob `f4f5e87f6ef81b74fb3fa5dadc58c0e67fba03ed`. No Markdown GDD, archived source, mechanics, or link destination change. Exact-head CI render and independent page inspection (including row fit and overflow) remain required; interactive Word links not tested. This is a correction candidate, not document acceptance.
