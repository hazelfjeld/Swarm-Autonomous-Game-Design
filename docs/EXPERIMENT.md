# Experiment brief

## Question

Can five independently scheduled specialist instances produce and improve a playable game from a supplied GDD, using a shared repository, explicit task ownership, and independent verification?

This is a practical production experiment. Record what happens and what requires intervention; do not claim a measured productivity advantage without a comparison.

## Starting conditions

- Repository: `hazelfjeld/Swarm-Autonomous-Game-Design`.
- Five roles: director, architect, gameplay engineer, art/audio creator, and QA.
- Each role launches from its own conversation and runs at most hourly under its saved task.
- Source GDD: awaiting the user's submission.
- Engine, platforms, visual style, genre, and release plan: determined from the GDD and actual tool availability. Godot is a candidate given the surrounding project context; it is not a fixed engine decision.
- Existing architecture/design skills are optional domain references. The repository role playbooks provide the shared execution contract.
- No additional paid infrastructure beyond existing authorization, or public game publication, is part of bootstrap. Normal authorized tool/subscription usage remains available.

## M0: establish the production loop

### Before the GDD

1. Verify each role can read the repository, follow its role instructions, and leave durable evidence.
2. Verify lease acquisition, concurrent rejection, renewal, and release.
3. Verify the actual scheduled environment and its tools. A successful interactive setup run does not establish capabilities of a future scheduled run.
4. Record the created automation ID and cadence for each role.

### After the GDD

1. Preserve the supplied source and create a concise baseline with source references, constraints, open decisions, and explicit assumptions.
2. Select the smallest playable journey that represents the game. The director defines observable acceptance criteria and assigns bounded tasks.
3. The architect establishes a runnable project and build checks in the selected environment.
4. The engineer implements the journey while the art/audio role supplies the required assets.
5. QA checks the exact candidate version, reproduces defects, and verifies corrections.
6. The architect integrates the accepted result and records how the user can run it.
7. The user plays the result and supplies creative feedback for M1.

The previously discussed feed/react/save/reload loop is an example only. The supplied GDD determines the actual first milestone.

## Acceptance evidence

M0 succeeds when a fresh execution can reconstruct the current task from the repository; duplicate active role runs are rejected by the lease helper; a task survives interruption without duplication; and the first GDD-derived playable journey reaches an independently reviewed build.

Keep separate statuses for coordination readiness, engine readiness, implemented functionality, automated verification, observed interaction, and human playtesting. The initial setup validates coordination only.

## Measurements

| Measure | Evidence |
| --- | --- |
| Accepted functionality | Issues meeting their criteria and linked merged PRs |
| Defects found and corrected | Reproduction steps, failing version, fix version, retest evidence |
| Time to accepted work | Recorded task start and acceptance timestamps |
| Duplicate or conflicting work | Concrete incident linked to its task and runs |
| Recovery quality | Interrupted task resumed with its prior branch and checkpoint |
| Human intervention | Decision or unblock request and why it was needed |
| Tool/runtime usage | Actual reported usage where exposed; otherwise unknown |
| Player experience | Human playtest observations; AI judgments clearly identified |

Commit counts, message counts, and self-assigned quality scores do not by themselves establish useful progress.

## Review and stopping

The director publishes a brief checkpoint at the end of a meaningful milestone. Repeated identical blockers should be escalated once, then held until conditions change. Pause work through `config/experiment.json`; pause the actual saved tasks as well to stop their recurring execution.
