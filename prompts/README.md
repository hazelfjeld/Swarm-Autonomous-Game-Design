# Five kickoff prompts

Paste the complete contents of **one** file into each of five separate ChatGPT chats. Each chat receives a distinct role; do not paste all five into one chat. These files are instructions, not evidence that any automation already exists.

| Role | Kickoff prompt | Playbook | Hourly minute |
| --- | --- | --- | --- |
| Game Director / Producer | [director.md](director.md) | [Director](../roles/director.md) | :00 |
| Technical Architect / Integrator | [architect.md](architect.md) | [Architect](../roles/architect.md) | :10 |
| Gameplay Engineer | [gameplay.md](gameplay.md) | [Gameplay](../roles/gameplay.md) | :20 |
| Art / Audio Director and Asset Builder | [art-audio.md](art-audio.md) | [Art / Audio](../roles/art-audio.md) | :30 |
| Independent QA / Player Experience | [qa.md](qa.md) | [QA](../roles/qa.md) | :40 |

All schedules use **America/Chicago**. Minute offsets spread work out; they are not a synchronization guarantee. Live issue dependencies and the lease protocol control who may act.

## What each kickoff does

Each instance reads the [operating instructions](../AGENTS.md), [protocol](../docs/PROTOCOL.md), [configuration](../config/experiment.json), its role playbook, and the [board](../docs/BOARD.md). It then acquires its runtime lease and completes one bounded startup task.

Only after privately inspecting both existing automations and the repository registry does it create its one hourly automation, if no matching role/repository automation exists. It records the actual task ID in its own startup/registry issue. Existing matching tasks are reported, not duplicated. Tool or permission failures are reported as blockers rather than treated as success.

The full recurring procedure is embedded in every kickoff file so the scheduled task carries the repository, role, paths, coordination rules, evidence requirements, and boundaries with it.

## GDD gate

Hazel’s GDD is still required before substantive game work. The director records approved scope and marks narrowly defined feature issues Ready. The other roles may complete explicitly authorized capability/setup tasks while waiting. None should invent game requirements to keep an hourly task busy.

A complete installed skill can supplement a playbook. A missing or placeholder skill does not block the experiment: the repository playbooks contain the operating responsibilities. They are task-specific documents, not installable skill packages.

## Authorized work and tool use

Use already authorized tools and subscriptions within existing permissions. Routine tracked file edits or deletions necessary for an assigned task are normal development work. These prompts introduce no additional approval step for that work.

New purchases, billing changes, additional paid services or spend beyond existing authorization, destructive repository/account deletion, public release or deployment outside the request, and external messages outside this repository remain outside scope. Keep unrelated automations unchanged.

## Review after setup

Use the real issue links in the board to verify all five registry entries, returned automation IDs, schedules, and startup evidence. If a chat reports that automation creation succeeded but registry recording failed, reconcile that returned ID before retrying. A later run must never create another schedule merely because an earlier comment is missing.
