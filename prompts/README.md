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

Each instance reads the [operating instructions](../AGENTS.md), [protocol](../docs/PROTOCOL.md), [configuration](../config/experiment.json), [skill manifest](../config/skill_sources.json), [source-loading procedure](../docs/SKILL_SOURCES.md), its role playbook, and the [board](../docs/BOARD.md). It fetches its assigned GitHub SKILL.md files at pinned SHAs and the required/task-relevant modules at those same SHAs, then acquires its runtime lease and completes one bounded startup-or-resume unit.

Only after privately inspecting both existing automations and the repository registry does it create its one hourly automation, if no matching role/repository automation exists. It records the actual task ID in its own startup/registry issue. Existing matching tasks are reported, not duplicated. Tool or permission failures are reported as blockers rather than treated as success.

The full recurring procedure is embedded in every kickoff file so the scheduled task carries the repository, role, paths, coordination rules, evidence requirements, and boundaries with it.

## Resume from the received GDD

Little Ray GDD v1.0 is already received and DIRECTOR-001 #3 intake is complete. Read the configured GDD, [design baseline](../docs/design/DESIGN_BASELINE.md), [first-slice plan](../docs/design/FIRST_SLICE.md), and live issue dependencies for #9–#14. Reuse completed intake/capability evidence; do not request the attachment again. Only eligible assigned work proceeds, and a received GDD does not clear unrelated runtime, asset, or review dependencies.

Director and architect have primary bindings to the two verified GitHub skills. The remaining roles use relevant supporting modules and their own playbooks; no nonexistent dedicated skill repositories are assumed. Installed copies substitute only with verified matching repository/version/content provenance. Record sources, SHAs, actual module reads, and failures in the run report. Source retrieval failure permits bounded independent work with an honest limitation, not a claim that the unread skill was used.

## Authorized work and tool use

Use already authorized tools and subscriptions within existing permissions. Routine tracked file edits or deletions necessary for an assigned task are normal development work. These prompts introduce no additional approval step for that work.

New purchases, billing changes, additional paid services or spend beyond existing authorization, destructive repository/account deletion, public release or deployment outside the request, and external messages outside this repository remain outside scope. Keep unrelated automations unchanged.

## Review after setup

Use the real issue links in the board to verify all five registry entries, returned automation IDs, schedules, and startup evidence. If a chat reports that automation creation succeeded but registry recording failed, reconcile that returned ID before retrying. A later run must never create another schedule merely because an earlier comment is missing.
