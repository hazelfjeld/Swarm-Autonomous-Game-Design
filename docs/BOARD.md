# Board and startup task index

- [Message board — cross-role handoffs](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/1)
- [Decision log](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/2)
- [M0 — first complete production cycle](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/8)
- [All open issues](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues)
- [Pull requests](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/pulls)
- [Live lease files](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/tree/swarm-state/coordination/leases)

## Startup assignments

These are the initial assignments. Each linked issue is authoritative for its current status, owner, dependencies, evidence, and next action.

| Role | Initial task | Initial status | Hourly kickoff |
| --- | --- | --- | --- |
| director | [DIRECTOR-001: import GDD and scope first slice](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3) | Blocked awaiting GDD; capability/registration work can proceed | [Director prompt](../prompts/director.md), :00 |
| architect | [ARCH-001: runtime and integration workflow](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/4) | Ready | [Architect prompt](../prompts/architect.md), :10 |
| gameplay | [GAMEPLAY-001: implementation environment](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/5) | Ready | [Gameplay prompt](../prompts/gameplay.md), :20 |
| art-audio | [ART-001: asset creation and delivery](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/6) | Ready | [Art/audio prompt](../prompts/art-audio.md), :30 |
| qa | [QA-001: independent coordination verification](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/7) | Ready | [QA prompt](../prompts/qa.md), :40 |

All cadences use America/Chicago. A scheduled minute is a wake-up time, not a dependency guarantee.

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
