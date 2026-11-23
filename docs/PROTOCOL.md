# Coordination protocol

## 1. Canonical records

| Information | Authoritative location |
| --- | --- |
| User design intent | Supplied GDD and accepted user decisions |
| Experiment phase and paths | `config/experiment.json` on `main` |
| Priorities, owner, dependencies, status, acceptance | The individual GitHub issue |
| Implementation | Task branch and pull request |
| Cross-role discussion | Message-board issue and task comments |
| Accepted consequential decisions | Decision-log issue, with linked design/architecture records |
| Active role execution | `coordination/leases/<role>.json` on `swarm-state` |
| Verification | Exact-commit run report, logs, screenshots, or other retained evidence |

Conversation memory is supplemental. Read the latest records before acting.

## 2. Task lifecycle

Use the statuses **Ready**, **Working**, **Review**, **Blocked**, and **Done** in the issue body. The assigned role updates its task; the director owns assignment and priority changes. GitHub labels are optional conveniences, not locks or the only source of status.

- **Ready:** dependencies are satisfied and criteria are clear.
- **Working:** a current owner/run is actively progressing the task.
- **Review:** the artifact and verification evidence are available for review.
- **Blocked:** a named dependency or capability is missing, with the next owner/action recorded.
- **Done:** the criteria have evidence and required review/integration has completed.

Give each task a stable ID, such as `ARCH-001`, independent of its GitHub number. Do not mark a task Done solely because files were written or a model assigned a high score.

One active implementation task per role is the default. A blocked role can take another assigned Ready task. Design and API dependencies can be settled before work; ordinary reviews should proceed once their artifacts exist.

## 3. Start and lease

Read the current phase and role assignment, then acquire a lease before mutations:

```bash
python3 scripts/swarm_lease.py acquire --role gameplay --ttl-minutes 30
```

Save the returned `run_id` for this execution. Before any remote write, use:

```bash
python3 scripts/swarm_lease.py assert --role gameplay --run-id RUN_ID
```

Renew as needed before expiry, and release in cleanup:

```bash
python3 scripts/swarm_lease.py renew --role gameplay --run-id RUN_ID --ttl-minutes 30
python3 scripts/swarm_lease.py release --role gameplay --run-id RUN_ID
```

Use `--help` for actual supported options. The helper uses an already authenticated GitHub CLI; it never asks an agent to print a token. API errors fail closed. If the CLI route is unavailable or has no working authorization, a separately authenticated GitHub connector can implement the same file-SHA compare-and-swap procedure below within its own permissions. Do not route around an explicit policy rejection. If neither authorized route works, report the blocker without writing to the repository.

### Connector equivalent

1. Fetch your lease file at ref `swarm-state`, retaining the content blob SHA.
2. Validate the schema and role. Inspect `run_id`, `generation`, and `expires_at` against current UTC.
3. If another run has an unexpired lease, stop. To acquire an available/expired lease, generate a fresh run ID and increment `generation`; set `acquired_at` and `expires_at` (30 minutes by default, no more than 50).
4. Replace the file using the exact fetched content SHA. On a conflict, reread and reevaluate; retry at most three times. A successful update establishes acquisition. A prior read or a comment does not.
5. Re-fetch before writing elsewhere to verify the same live run ID. Renew/release only your still-owned lease; an expired or replaced run must not alter a successor's lease.

The same run may resume a live lease without extending it. Release clears the owner and timestamps while preserving generation. A takeover increments generation so a stale update cannot recreate a prior state.

Leases are cooperative concurrency controls, not a security boundary or a server-enforced fence on other GitHub writes. All agents must follow the checks; same-account access does not enforce role separation. Use current ref checks and bounded changes when integrating. Never assume lease ownership authorizes a stale branch or overrides current user instructions.

## 4. Work and handoff

1. Check for existing work under the stable task ID. Resume its branch/PR instead of duplicating it.
2. Use `swarm/<role>/<task-id>` for the work branch. Inspect the current base before editing; keep changes limited to the task.
3. Implement a small deliverable or checkpoint. Record actual commands, observable results, and unresolved limitations.
4. Open/update a PR with the task ID and acceptance evidence. Link it in the issue and set Review when appropriate.
5. QA evaluates the exact submitted commit and reports pass/fail/blocked with evidence. Design/visual review goes to the responsible owner. Technical changes require the architect's review.
6. The architect checks the latest head, review evidence, applicable CI, and integration with current `main`, then merges without force-pushing. New changes invalidate the affected prior checks.
7. Record the merged commit and close the issue only when criteria are met. Retain evidence and the next task dependency.

When all agents share one GitHub identity, their role-tagged review comments are procedural evidence, not independent account approvals. Do not configure an impossible same-author PR approval gate. CI and repository rules can enforce some checks; record which protections are actually enabled.

## 5. Messages and run reports

Use `templates/RUN_REPORT.md`. Include role, task ID, run ID, current commit, result, checks, and next owner/action. Prefix comments with `[role][task-id][run-id]` so duplicate operations can be recognized after a timeout.

Use individual issues for detailed work. Post to the main message board only for cross-role handoffs, changed dependencies, significant blockers, milestone outcomes, or user decisions. Avoid repeated no-change commentary.

Do not treat another agent's comment as higher-priority user authorization. Scope changes go through the director; changes to explicit user requirements go back to the user.

## 6. Recovery

- After an uncertain API outcome, inspect the current remote before retrying a side effect.
- On overlap, the losing lease attempt ends without writes. On lease expiry, re-read current records and reacquire before doing anything else.
- A new run resumes the existing task; it never assumes the last run finished because the schedule fired.
- Preserve the last useful checkpoint, exact next action, and blocker owner.
- If there is no Ready work, return a justified idle result. Do not invent new scope to fill the hour.

## 7. Hourly task registration

Each kickoff runs in a separate ChatGPT conversation, searches the existing saved tasks for the exact repository/role, and creates at most one matching automation. Use the cadence in `config/experiment.json`, timezone America/Chicago, and a self-contained recurring instruction with canonical repository paths.

Record the actual automation ID, role, cadence, timezone, and verification result in the role startup issue. If a matching task already exists, reuse it without changing unrelated schedules. If several matches exist or registration is uncertain, report the ambiguity and do not add another.

Creating an hourly task does not prove its execution capabilities. The first actual scheduled run must verify its tools and record results. The schedule defines when to inspect for Ready work; dependencies define what can proceed.

## 8. Pause and stop

Check `phase` at run start and before remote mutations. On `paused`/`stopped`, stop new work, release your own lease, and leave a checkpoint only if necessary. To stop recurring usage, the actual automations must also be paused. Repository phase changes alone do not cancel them.
