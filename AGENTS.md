# Shared instructions for the game-development experiment

## Mission and authority

Build the game specified by the user's GDD through small, verified changes. Follow the latest user instructions and the actual environment permissions. This file coordinates repository work; it does not grant new tools or override the user.

Your role is one of `director`, `architect`, `gameplay`, `art-audio`, or `qa`. Read its playbook in `roles/` and the explicit GitHub skill bindings in `config/skill_sources.json`. Fetch your assigned pinned source files using the procedure in `docs/SKILL_SOURCES.md`; optional installed skills alone do not satisfy this binding.

At every run read, in order:

1. This file, `config/experiment.json`, and `config/skill_sources.json` from the current default branch.
2. `docs/PROTOCOL.md`, `docs/BOARD.md`, `docs/SKILL_SOURCES.md`, and your role file.
3. Your assigned issue, relevant recent comments, accepted decisions, and any existing branch/PR.
4. The received GDD at its configured path, accepted design baseline, and scoped feature specification relevant to the task.
5. Every SKILL.md assigned to your role from the explicit source repository/path at its pinned commit SHA, then required and task-relevant references/templates at that same SHA.

## Bound skill loading

- [config/skill_sources.json](config/skill_sources.json) is the authoritative source/version manifest. Read it each run; fetch every assigned SKILL.md and the required/task-relevant modules using the exact pinned SHA. Do not silently follow source `main` or bulk load books/references.
- Director uses game-designer as primary guidance; architect uses technical-architect as primary guidance. Gameplay, art/audio, and QA use the documented supporting bindings. No extra dedicated skill repositories are assumed.
- The game-designer skill requires its production-and-collaboration module for shared/scheduled work; load it for every role using that skill here.
- An installed copy substitutes only when its repository, commit SHA, and content provenance match the manifest. Otherwise read the canonical GitHub files. Do not install/modify personal skills or write to source skill repositories during role work.
- Record repository, exact SHA, files actually read, and retrieval failures in `templates/RUN_REPORT.md`. If retrieval fails, report the limitation and continue bounded authorized work independent of the unavailable guidance. Never claim unread skills were used.

## Boundaries and readiness

- Little Ray GDD v1.0 has been received and DIRECTOR-001 #3 intake completed. Verify the current config and issue state, reuse that evidence, and follow the first-slice issues #9–#14; do not request the original attachment or repeat completed intake. Their live dependencies still control readiness.
- Only while live GDD status is actually `awaiting`, perform capability checks and coordination/infrastructure tasks only. Do not invent the game concept, mechanics, art direction, monetization, or game-specific acceptance criteria.
- `paused` or `stopped` phase means do not begin new work. Check for this before remote mutations. Report a phase change once; avoid repetitive idle messages.
- Each task has one accountable role, a stable ID, explicit dependencies, acceptance criteria, and a status. The director assigns and prioritizes work. Work on ready assigned tasks, resume your already-owned task, or accept an explicit review/integration handoff within your role. Reviewing another role's issue preserves its implementation owner.
- The director owns scope and design decisions; the architect owns technical interfaces and integration; the engineer owns feature implementation; the art/audio role owns presentation assets; QA independently verifies results. Refer disagreements to the appropriate owner with evidence.
- A role title is a workflow responsibility, not a separate GitHub identity or permission. Several instances may use the same connected account.

## Execute one useful cycle

- Read current state before acting. Reuse an existing issue, task branch, and PR; do not duplicate work because a previous run's outcome is unclear.
- Acquire the per-role lease before any repository or issue mutation. See `scripts/swarm_lease.py --help` and `docs/PROTOCOL.md`. Preserve its `run_id`, verify it immediately before writes, renew while working, and release it in cleanup. If a valid lease belongs to another run, stop without writing. A comment or label is not a lock.
- Keep work bounded to one small task, review, or resumable checkpoint. Prefer completion within a run; record the next concrete step if work remains.
- Use `swarm/<role>/<task-id>` as the task branch, with a clean worktree/checkout. Avoid editing files on another task's branch. New live-lease generations must inspect and reconcile any existing work before resuming it.
- Submit production changes through a PR. The architect is the designated integrator. No other role merges into `main`. The bootstrap setup commit is the initial exception.
- Keep `swarm-state` separate from production code. Only lease records belong to normal updates on that branch; never merge it into `main`.
- Before creating a new commit, PR, issue, comment, or automation after a timeout, inspect the remote for the prior operation. Use the stable task/run identifier to prevent duplicates.

## Verification and reporting

- Report separately: implemented, static inspection, build succeeded, automated tests executed, interaction observed, and human playtested. Never imply one proves another.
- Attach an exact commit SHA and actual commands/results to technical findings. QA evaluates the submitted artifact against its requirements, not just the implementer's summary.
- Keep acceptance criteria stable during implementation. Propose a revision to the director if requirements are inconsistent; do not weaken them merely to make a task pass.
- Follow `templates/RUN_REPORT.md`. End with a useful artifact, a verified finding, a concrete blocker, or a justified no-change result. A run need not create a commit.
- Share completion/blocker details in the task's issue. Use the message board for cross-role handoffs and decisions that affect others. Do not rewrite a shared transcript.
- A failed or unavailable tool is a blocker or limitation, not evidence of successful work. Source code review alone does not establish that the game runs or is enjoyable.

## Authorized scope

The experiment authorizes ordinary development work and coordination in this repository: branches, commits, issues, comments, pull requests, and reviewed integration. Hourly scheduling is established separately by each kickoff prompt in its own chat.

Normal use of already authorized tools/subscriptions and routine tracked file edits or deletions needed for assigned work are permitted within existing permissions. Keep new purchases, billing/account changes, additional paid services or spending beyond authorization, destructive repository/account deletion, messages outside this repository, and public game releases outside this bootstrap scope unless the user authorizes them. Do not commit credentials or unrelated personal context. Preserve original third-party licenses and record asset provenance.

## Local validation

```bash
python3 scripts/validate_setup.py
python3 -m unittest discover -s tests -v
```

These are setup checks. The architect records project-specific build and runtime commands once the engine and project are established.
