# Little Ray first playable slice

Owner: director. Milestone: [M0 #8](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/8). Source: [GDD](GDD.md) §§4, 6–13, 14–15, 17, with [baseline](DESIGN_BASELINE.md). This scopes the representative slice; it does not claim an implemented or playtested build.

## Player-visible outcome

A fresh player meets Blueberry and Sunbeam in two Sunlit homes, names and feeds a favorite, starts the first guaranteed pairing, meets and names Pearlcloud, sees the discovery and family record in the journal, assembles the three rays, completes Practice Pool, and returns to a saved sanctuary. The same named individuals and committed results survive reload. Two free props make the home visibly personal; Guest Cove makes a full home recoverable.

This slice uses three varieties, two Sunlit homes, one nursery/first recipe, two props, one practice encounter and one return journey. It excludes the other five launch varieties, remaining habitat themes, guardians/full campaign, expansion recipes and online or paid systems.

## Readiness and assignments

The links below are authoritative for current status. At intake, all six production tasks are **Blocked** by the named prerequisites. The four existing execution-capability tasks remain **Ready**. Evidence of a working interactive environment can satisfy the relevant capability dependency; waiting for an hourly automation or first scheduled run is not required.

| Task | Accountable role | Named prerequisites | Observable deliverable |
| --- | --- | --- | --- |
| [ARCH-002 #9](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/9) | architect | DIRECTOR-001 intake; ARCH-001 execution capability | Pinned Godot/templates; repeatable export; actual-host input/audio/value persistence and backup round trip; small runtime/save interfaces |
| [ART-002 #10](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/10) | art-audio | DIRECTOR-001 intake; ART-001 asset capability | Two comparable Blueberry treatment trials at real scale; provenance/settings; recorded style choice |
| [ART-003 #11](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/11) | art-audio | ART-002 treatment; ARCH-002 runtime interface | Representative Blueberry/Sunbeam/Pearlcloud, two homes/props and key visual/audio reactions in runtime |
| [GAMEPLAY-002 #12](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/12) | gameplay | Intake; GAMEPLAY-001 execution capability; ARCH-002 interfaces | Normal-control home/feed/first-pairing loop with persistent identities, Guest Cove and recovery |
| [GAMEPLAY-003 #13](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/13) | gameplay | GAMEPLAY-002; ART-003; ARCH-002 hosted baseline | Three-ray party, Practice Pool and the complete representative return-home journey |
| [QA-002 #14](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/14) | qa | QA-001 execution/evidence capability; GAMEPLAY-003 exact candidate | Independent exact-version scenario evidence, defects and qualified acceptance; actual player evidence when obtained |

Director reviews scope and resolves design findings. Architect alone integrates reviewed PRs. A completed delivery spike does not close the whole slice; a QA pass on an older commit does not approve a newer candidate.

## Acceptance scenarios

| Scenario | Required observation |
| --- | --- |
| Fresh profile | The normal controls reveal two starters and homes, 100 Pearls, 30 Food and a free garden; a feed costs five Food and commits 15 XP once. |
| First discovery | Blueberry/Sunbeam pairing previews eligibility/cost/time, consumes one slot and commits the first Pearlcloud at start. Claim creates exactly one individual with the same saved parents and ID. |
| Full home | A claimed ray is owned and available in Guest Cove. Free relocation or restoration of an owned stored home resolves placement without deleting a ray or demanding a purchase. |
| Busy parent | Invalid pairing/party actions explain the actual conflict without charging resources or corrupting the existing job. |
| Interruption | Closing/reloading during incubation or reveal preserves the committed child, elapsed-time settlement and claim receipt; replaying presentation never grants a second ray. |
| Friendly challenge | The player assembles three individuals, reads one opponent's intent, uses Bop/Guard/signature/Swap and sees understandable safe outcomes. No favorite is consumed. |
| Return home | Encounter settlement occurs once; home/journal reflect committed results. Reload and repeated result input cannot create duplicate rewards. |
| Save recovery | A backup round trip restores the tested state. Invalid/unsupported import preserves the active profile. Failure is visible and a second tab cannot silently overwrite a newer save. |
| Presentation and access | Representative assets retain the mascot at normal scale; essential actions work by keyboard/touch; audio starts from a gesture; essential information has visible equivalents. |
| Human comprehension | Record a real player's route, confusion and interventions on the exact candidate. Attachment and enjoyable tactical choices remain unverified until observed; do not substitute simulated players. |

The source GDD remains authoritative for complete formulas, state transitions, times, caps and edge cases. These scenarios select verification priorities rather than replacing those rules.

## Evidence and completion

Retain exact source/content/build identities, reproducible commands, declared browser/device/embedding context, scenario results and relevant screenshots or logs. Separate static inspection, build success, automated execution, observed interaction and human play. An unavailable host/device or missing human session remains explicitly unverified.

M0 completes only after the bounded journey is reproducible and can be tried, blocking defects are corrected and independently reevaluated, architect integration is complete, and missing automation registrations are identified honestly. No game build, public deployment, scheduled-run execution or human playtest is established by the GDD intake.
