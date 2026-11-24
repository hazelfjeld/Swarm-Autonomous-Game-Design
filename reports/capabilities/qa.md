# QA-001 — independent startup assessment

- Role / task: `qa` / [QA-001 #7](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/7).
- Run ID / lease generation: `0c219604-508e-40fe-8e37-cd11de5297e4` / `3`.
- Run started: `2026-11-23T23:39:29Z`; executed-check timestamps are retained in the evidence metadata. Publication and cleanup outcomes belong in the canonical issue comment.
- Inspected and tested input: [`08beacae99ea23394438cb2f61f8e7772b6ac47e`](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/commit/08beacae99ea23394438cb2f61f8e7772b6ac47e).
- Output branch: `swarm/qa/QA-001`; the exact evidence commit and PR are recorded in #7 after publication.
- Result: **interactive coordination/evidence assessment passed within the coverage below; report submitted for review. Game acceptance and the first scheduled environment remain unverified.**

## Deliverable and scope

This report supplies the still-needed QA-001 execution evidence and the actual QA automation registration. It does not change the implementation, acceptance criteria, GDD, scope, or other roles' tasks. Requirements were inspected before the implementation reports where practical. Read-only delegated reviews checked the lease implementation and the first-slice evidence boundaries; they neither changed the repository nor supplied human playtest evidence.

The working checkout was isolated and clean at the input commit. The relevant requirements were `AGENTS.md`, `docs/PROTOCOL.md`, the live configuration and board, the QA role/kickoff, QA-001 and QA-002, the accepted design baseline, first-slice specification, and GDD sections concerning the opening, persistent identity, housing, pairing, controls, presentation, saves, validation, and invariants. The GDD is **received**. Intake is complete and is not a blocker.

## Skill source evidence

Every canonical file below was successfully read through the GitHub connector at the exact manifest pin. No source retrieval failed and no skill installation or source repository was modified.

| Supporting skill | Source repository and commit | Files actually read | Application |
| --- | --- | --- | --- |
| Game Designer | `hazelfjeld/Game-Design-AI-Skill` at `dc26ddb18adc18fbbe2221a8443a71a260de6022` | `game-designer/SKILL.md`; `references/production-and-collaboration.md`; `references/playtesting-and-evidence.md`; `references/game-feel-and-accessibility.md` within that package | Ownership and bounded handoff; separation of technical evidence and human experience; first-slice input/readability coverage |
| Technical Architect | `hazelfjeld/Technical-Architect-AI-Skill` at `979756c7e7db6b1ac0f925ba94031b3ec05ced49` | `technical-architect/SKILL.md`; `references/review-playbook.md`; `references/data-and-reliability.md` within that package | Exact-revision review; duplicate/stale execution; uncertain outcomes and recovery |

The complete installed `game-designer` skill and its playtesting/evidence and production/collaboration modules were also read as supporting guidance. The installed copy was **not** treated as a verified substitute for the canonical pinned reads. No dedicated QA skill repository is assumed.

## Executed evidence

Environment: Linux x86_64, Python **3.12.14**. Full runtime details and timestamps are in [executed-checks.json](qa-evidence/20261123-startup/executed-checks.json).

| Evidence class | Exact check or observation | Result | Retained evidence |
| --- | --- | --- | --- |
| Static inspection | Read `scripts/swarm_lease.py`, `scripts/validate_setup.py`, both test files, and the protocol at the input commit | No material coordination defect found in this bounded review | Implementation/test symbols discussed below; immutable input commit |
| Executed setup validation | `python3 scripts/validate_setup.py` | Exit 0; setup validation passed | [Validator log](qa-evidence/20261123-startup/validate_setup.log) |
| Executed automated tests | `python3 -m unittest discover -s tests -v` | Exit 0; **29 tests passed**: 15 lease/transport and 14 setup tests | [Unit-test log](qa-evidence/20261123-startup/unittest.log) |
| Live CLI capability | `python3 scripts/swarm_lease.py --help`; then `python3 scripts/swarm_lease.py acquire --role qa --ttl-minutes 30` | Help succeeded; acquire returned exit 1 / `api_error`. `gh auth status` confirmed no logged-in GitHub hosts | [Capability observations](qa-evidence/20261123-startup/service-observations.json) |
| Live authenticated connector | Read the free QA lease at generation 2, replace using its exact content SHA, and read back the same live run/generation | Acquired QA generation 3 with a 30-minute lease; live assertions succeeded before subsequent writes | Acquisition commit `38abe33c9741a96bdb6999e4fe0650e9f0a89a71`; capability observations |
| Live automation service | Inspect all returned saved-task prompts and the startup registry, create one exact repository/role task, and reread saved tasks | Exactly one matching QA task; enabled; schedule/timezone and the complete recurring prompt match | Registration below; capability observations |
| Game build | No build attempted | **Unassessed:** no submitted first-slice candidate in the inspected artifacts | Main tree and live #13/#14 state |
| Observed gameplay / actual-host interaction | No game launched or interacted with | **Unassessed** | No screenshot, input, browser-save, or audio-playback claim |
| Human playtesting | No participant or human session | **Unassessed** | No claim of fun, attachment, comprehension, or accessibility conformance |

### Lease and duplicate/stale-run coverage

`GitHubClient.write()` supplies the fetched content SHA, targets `swarm-state`, and sends JSON through subprocess stdin. `LeaseManager.execute()` rejects another live owner, resumes the same live run without extending it, increments generation on takeover, and rejects expired or replaced owners. A recognized 409 causes a fresh read and ownership check; the initial attempt plus three retries is bounded. An ambiguous API result is not automatically replayed.

The executed tests include live-owner rejection/idempotent resume, exact-expiry rejection and takeover, stale renew/release after takeover, a competing acquisition during compare-and-swap, bounded conflicts, malformed responses, and ambiguous-write handling. **Those tests use fake GitHub transports and controlled clocks.** They are real executed automated tests, not a live race against GitHub. This run's live evidence covers the authorized connector acquisition and subsequent ownership assertions; it did not disrupt or attempt takeover of another role.

The CLI failure was reconciled by reading the live lease before attempting the documented connector route: it was still unowned. There was no explicit policy rejection and no success was assumed from the failed command. The connector then acquired the lease with the fetched blob SHA `6035404dc02cfe1ad8d80b0bbc4e7f7b4709c00a`; the returned acquired-content SHA was `88cf4e5a0d959bac4e4d0dbe08f03556e86c2fcb`.

Leases remain cooperative. They do not fence later issue/commit/PR writes at the server, and a passing unit test does not change that limitation. Every writer must continue to assert its current lease and reread its target immediately before mutation.

## Findings and limitations

| ID | Classification / severity | Reproduction and observed result | Consequence and next owner |
| --- | --- | --- | --- |
| QA-001-L1 | Environment limitation; low with the verified fallback | On this checkout, run the acquisition command and `gh auth status`: acquisition fails and CLI authorization is absent. Read-only connector inspection shows the failed acquisition did not take ownership. | The authenticated connector CAS route works. Future QA runs must verify their own available route; CLI authentication is not claimed. |
| QA-001-L2 | Missing artifact / dependency; no game-test verdict | Inspect the tracked input tree and live GAMEPLAY-003 #13 / QA-002 #14: no Godot project, GDScript/scenes, web export, candidate manifest, or submitted #13 build was present in the inspected main tree. #13 and #14 remained Blocked. | Gameplay must deliver the exact #13 candidate and run instructions after its dependencies. QA then evaluates that artifact; no failed or passing game result is inferred. |
| QA-001-L3 | Evidence still pending; no defect severity | The created task has no completed scheduled run during this kickoff. | The first actual scheduled QA invocation must verify its capabilities and record them separately. Registration does not prove execution. |

No confirmed implementation defect or acceptance-criteria contradiction was found in the inspected coordination scope. Consequently, no speculative bug/fix issue was created and no implementation was patched during its own independent review.

## GDD and readiness assessment

The live inspection found DIRECTOR-001 #3 and ARCH-001 #4 Done; ARCH-002 #9 Working; ART-002 #10, ART-003 #11, GAMEPLAY-002 #12, GAMEPLAY-003 #13, and QA-002 #14 still Blocked on their named prerequisites. This is a timestamped observation, not a replacement board. Later issue bodies remain authoritative. Automation timing does not establish readiness.

QA-002 needs accepted QA-001 execution/evidence capability **and** the GAMEPLAY-003 exact candidate. Interactive capability evidence may satisfy the relevant dependency after review; neither automation registration nor waiting for the first scheduled run is an extra gate for otherwise authorized interactive production. The separately specified scheduled-environment check remains honestly pending.

When a candidate exists, preserve the first-slice contract: fresh-profile resources and feeding; guaranteed first Pearlcloud and stable parent/individual identity; Guest Cove/full-home recovery; busy-parent and insufficient-resource rejection; interrupted incubation/reveal; three-ray Practice Pool; return-home settlement once; backup/import/second-tab recovery; normal-scale presentation and supported input/audio; and real human comprehension evidence. Include QA-002's explicit zero-resource recovery check. Relevant nuances from the GDD are that the second home and Sunbeam arrive through the opening sequence, and incubating parents may still be named, fed, and greeted.

Functional tests alone cannot satisfy an actual-host, touch, animation, or saved-state observation. AI critiques and simulated walkthroughs cannot satisfy a human session. Human evidence must identify the candidate, participant context, actions, confusion, and assistance without inventing feelings or observations.

## Automation registration

- Actual service-returned task ID: **`Automation_4527118042448191af1133d26773a3bb`**.
- Title: **Swarm Game — Independent QA / Player Experience**.
- Repository: `https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design`; role ID: `qa`.
- Created, not reused. The complete pre-creation task listing had no exact repository/QA match and the startup registry had no registration. Post-creation listing confirmed one QA match. Other roles' registrations are independent.
- Enabled: **true**. Timing mode: `exact_schedule`; timezone: **America/Chicago**.
- Cadence: **hourly at minute 40, second 00**. First scheduled occurrence returned by the service: **2026-11-23 18:40:00 -06:00**.
- The saved prompt is an exact match to all **7,726 characters** of the recurring block in `prompts/qa.md`, source blob `63ec0a87f73f5d6ed76a247f68046b9c7573eae5`. No abbreviated continuation prompt was substituted.
- Interactive startup: the checks above are verified. **First scheduled-run capability: unverified**, to be recorded by that invocation.

```text
BEGIN:VEVENT
DTSTART;TZID=America/Chicago:20261123T184000
RRULE:FREQ=HOURLY;BYMINUTE=40;BYSECOND=0
END:VEVENT
```

## Handoff and acceptance

The evidence is ready for independent review and architect integration. QA-001 should remain **Review**, not be declared fully Done by its author. The architect can review the exact report commit and accept the bounded interactive capability evidence. The next actual scheduled QA run must verify its runtime and continue the existing issue rather than repeating this completed assessment or creating another automation.

QA-002 remains gated on its current dependencies and the exact playable candidate. The director owns readiness/design decisions, gameplay supplies the candidate, and the architect alone integrates reviewed changes. This QA run grants no game-wide acceptance and performs no merge or public deployment.
