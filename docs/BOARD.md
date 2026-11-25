# Board and startup task index

- [Message board — cross-role handoffs](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/1)
- [Decision log](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/2)
- [M0 — first complete production cycle](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/8)
- [All open issues](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues)
- [Pull requests](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/pulls)
- [Live lease files](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/tree/swarm-state/coordination/leases)

## Little Ray current design

- [DIRECTOR-003 — classic collector fidelity and unified cute manta identity](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/27): [creative-direction charter](design/CREATIVE_DIRECTION.md) and GDD v2.1 clarify visual/UI consistency without changing existing mechanical rules, issue statuses, prerequisites, or hourly schedules. The pixel-versus-cartoon treatment is still awaiting ART-002 evidence and Hazel's choice. This design task requires exact-head QA and architect review before any merge.

Little Ray GDD **v2.1 is received** (v2.0 mechanics preserved; DIRECTOR-003 presentation clarification). Hazel requested the Dragon City / Monster Legends-style direction correction in [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22). Read the [full GDD](design/GDD.md), [source/archive record](design/SOURCE.md), [baseline](design/DESIGN_BASELINE.md), and [first-slice assignments](design/FIRST_SLICE.md). V1 originals and completed DIRECTOR-001 intake remain historical; conflicting sanctuary rules are superseded.

The current loop is resident Gold, timed crops, Food feeding, random breeding, a separate hatchery, compatible elemental housing, three-versus-three adventure battles and island expansion. The corrected product has rarity/rank power and continuing collection/Arena progression.

Existing #9–#14 remain the role tasks with revised criteria where required. [GAMEPLAY-004 #23](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/23) separates breeding/hatching, and [GAMEPLAY-005 #24](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/24) integrates the complete journey. Issues own current status and dependencies. Compatible runtime, art-trial and capability work continues; no new intake or duplicated kickoff is required.

Live phase comes from config, not a historical paragraph. Hourly registration and scheduled-run verification remain separate from actual interactive capability. This design revision does not change schedules or coordination authority.

## Startup assignments

These are the initial assignments. Each linked issue is authoritative for its current status, owner, dependencies, evidence, and next action.

| Role | Initial task | Initial status | Hourly kickoff |
| --- | --- | --- | --- |
| director | [DIRECTOR-001: import GDD and scope first slice](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3) | Done; continue coordination and dependency review | [Director prompt](../prompts/director.md), :00 |
| architect | [ARCH-001: runtime and integration workflow](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/4) | Ready | [Architect prompt](../prompts/architect.md), :10 |
| gameplay | [GAMEPLAY-001: implementation environment](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/5) | Ready | [Gameplay prompt](../prompts/gameplay.md), :20 |
| art-audio | [ART-001: asset creation and delivery](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/6) | Ready | [Art/audio prompt](../prompts/art-audio.md), :30 |
| qa | [QA-001: independent coordination verification](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/7) | Ready | [QA prompt](../prompts/qa.md), :40 |

All cadences use America/Chicago. A scheduled minute is a wake-up time, not a dependency guarantee.

## Skill loading

All roles read [the versioned skill source manifest](../config/skill_sources.json) and [loading instructions](SKILL_SOURCES.md). The director uses Game Designer; the architect uses Technical Architect. Gameplay, art/audio, and QA use the mapped supporting modules and their own playbooks. Report the actual source revisions loaded, including any failed fetch.

## Next dependency handoffs

- Accepted ARCH-001 evidence continues to support existing ARCH-002 #9; preserve its current probe and branch.
- Accepted ART-001 evidence supports ART-002 #10's mascot treatment trial against the current city/battle presentation.
- Revised ART-003 #11 needs the v2 revision, #9 interfaces and #10 treatment.
- Revised GAMEPLAY-002 #12 needs the v2 revision, #5 capability and #9 interfaces; it owns the city/economy/feeding state.
- GAMEPLAY-004 #23 uses #12 for separate breeding/hatching; GAMEPLAY-003 #13 uses #12/#9 for three-versus-three combat.
- GAMEPLAY-005 #24 integrates #9, #11, #12, #13 and #23 into the normal-control journey.
- QA-002 #14 needs #7 capability and the exact #24 candidate.

The user-authorized v2 revision changes game requirements; issue histories retain earlier criteria and evidence. Do not mark dependencies complete merely because a design or skill was read.

## Automation registry

Repository setup creates no hourly task. Each kickoff searches for an existing task matching this exact repository and role, creates or reuses at most one, then records the actual automation ID in its startup issue. That comment is the authoritative registration evidence.

The registration comment must contain:

- Role and exact repository URL.
- Actual task ID returned or read from the automation tool.
- Title, cadence, timezone, and created/reused status.
- Interactive startup result and outstanding blockers.
- First scheduled-run verification status, initially unverified.

Never infer registration from this table or from a prompt file. Do not enter invented task IDs. If task capacity or permissions block registration, record the result and leave existing unrelated automations unchanged.

## Comment conventions

Start with `[role][task-id][run-id]`. Include a concrete result or decision, exact artifact/commit, evidence, blocker if any, and next owner/action. Use the task issue for details and the message board for cross-role changes.

See the [protocol](PROTOCOL.md) and [run report template](../templates/RUN_REPORT.md).
