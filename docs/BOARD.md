# Board and startup task index

- [Message board — cross-role handoffs](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/1)
- [Decision log](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/2)
- [M0 — first complete production cycle](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/8)
- [All open issues](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues)
- [Pull requests](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/pulls)
- [Live lease files](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/tree/swarm-state/coordination/leases)

## Little Ray design intake

Little Ray GDD v1.0 is **received**. Read the [full GDD](design/GDD.md), [source record and original](design/SOURCE.md), [design baseline](design/DESIGN_BASELINE.md), and [first-slice assignments](design/FIRST_SLICE.md). DIRECTOR-001 is complete and closed after PR #15. Reuse the received working baseline; no original chat attachment or repeated intake is needed.

The next scoped tasks are ARCH-002 [#9](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/9), ART-002 [#10](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/10), ART-003 [#11](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/11), GAMEPLAY-002 [#12](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/12), GAMEPLAY-003 [#13](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/13), and QA-002 [#14](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/14). Their issue bodies own status and dependencies. They initially wait on the named role capability evidence and preceding slice work.

The phase is `active`: ARCH-001 #4 is Done after PR #16, and ARCH-002 #9 has passed the director's production-readiness gate for its scoped delivery/save spike. Its live issue owns the current execution status. Other issues retain their own live dependencies; M0 is not complete. Existing capability work can proceed. Hourly registration and scheduled-run verification remain separately recorded; neither is a new permission gate for authorized interactive work.

## Startup assignments

These are the initial assignments. Each linked issue is authoritative for its current status, owner, dependencies, evidence, and next action.

| Role | Initial task | Initial status | Hourly kickoff |
| --- | --- | --- | --- |
| director | [DIRECTOR-001: import GDD and scope first slice](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3) | Done; continue coordination and dependency review | [Director prompt](../prompts/director.md), :00 |
| architect | [ARCH-001: runtime and integration workflow](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/4) | Done; continue ARCH-002 #9 | [Architect prompt](../prompts/architect.md), :10 |
| gameplay | [GAMEPLAY-001: implementation environment](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/5) | Ready | [Gameplay prompt](../prompts/gameplay.md), :20 |
| art-audio | [ART-001: asset creation and delivery](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/6) | Ready | [Art/audio prompt](../prompts/art-audio.md), :30 |
| qa | [QA-001: independent coordination verification](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/7) | Ready | [QA prompt](../prompts/qa.md), :40 |

All cadences use America/Chicago. A scheduled minute is a wake-up time, not a dependency guarantee.

## Skill loading

All roles read [the versioned skill source manifest](../config/skill_sources.json) and [loading instructions](SKILL_SOURCES.md). The director uses Game Designer; the architect uses Technical Architect. Gameplay, art/audio, and QA use the mapped supporting modules and their own playbooks. Report the actual source revisions loaded, including any failed fetch.

## Next dependency handoffs

- ARCH-001 evidence is accepted; existing ARCH-002 #9 passed its dependency gate and belongs to the architect. Follow its live issue for execution status. Export/templates, hosted runtime and persistence/backup observations remain its acceptance work.
- Accepted ART-001 evidence independently unblocks existing ART-002 #10.
- ART-003 #11 needs #9 and #10; GAMEPLAY-002 #12 needs #5 and #9.
- GAMEPLAY-003 #13 needs #9, #11, and #12; QA-002 #14 needs #7 and #13.

Keep these existing issues and their acceptance criteria. The issue bodies own current status; do not mark a dependency complete merely because the GDD was received or a skill loaded.

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
