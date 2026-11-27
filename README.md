# Swarm Autonomous Game Design

Five specialist ChatGPT instances collaborate through this repository: a game director, technical architect/integrator, gameplay engineer, art/audio creator, and independent QA evaluator.

**Little Ray GDD v2.0 is received.** The current direction is a Dragon City / Monster Legends-style island city, creature collector and three-versus-three RPG with cute elemental manta rays. Read the [full GDD](docs/design/GDD.md), [illustrated Word companion](docs/design/source/Little_Ray_GDD_v2.0.docx), [design baseline](docs/design/DESIGN_BASELINE.md), and [first playable slice](docs/design/FIRST_SLICE.md). Live phase and task readiness remain in config and the linked issues. [DIRECTOR-002 #22](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/22) records the user-authorized correction; v1 originals remain archived.

## Start here

1. Read the [experiment brief](docs/EXPERIMENT.md) and [shared operating rules](AGENTS.md).
2. Open the [message board and task index](docs/BOARD.md).
3. Paste each [kickoff prompt](prompts/README.md) into its own ChatGPT conversation. Each prompt performs startup work and creates or reuses exactly one hourly task for its role.
4. Read the [Little Ray design baseline](docs/design/DESIGN_BASELINE.md), then the [first-slice assignments](docs/design/FIRST_SLICE.md). Future GDD versions follow the [intake procedure](docs/GDD_INTAKE.md).

| Role | Instructions | Kickoff | Hourly minute, America/Chicago |
| --- | --- | --- | --- |
| Game director / producer | [Director](roles/director.md) | [Prompt](prompts/director.md) | :00 |
| Technical architect / integrator | [Architect](roles/architect.md) | [Prompt](prompts/architect.md) | :10 |
| Gameplay engineer | [Gameplay](roles/gameplay.md) | [Prompt](prompts/gameplay.md) | :20 |
| Art, animation, and audio creator | [Art/audio](roles/art-audio.md) | [Prompt](prompts/art-audio.md) | :30 |
| Independent QA / player experience | [QA](roles/qa.md) | [Prompt](prompts/qa.md) | :40 |

The schedules are launch instructions, not evidence that automations already exist. Successful creation is recorded with the automation ID in each role's startup issue. Task dependencies determine readiness; staggered minutes do not guarantee execution order.

## What is included

- Five role playbooks and five self-contained kickoff prompts.
- Explicit, versioned [GitHub skill sources](docs/SKILL_SOURCES.md), loaded by both kickoff and recurring runs.
- A shared [coordination protocol](docs/PROTOCOL.md), issue templates, PR template, and durable run-report template.
- Per-role cooperative leases on the `swarm-state` branch, using compare-and-swap updates to avoid duplicate active runs.
- A small Python helper and setup checks, with CI for the coordination files.
- The complete Little Ray GDD, current Word companion, archived v1 originals and [source record](docs/design/SOURCE.md), with a bounded first-slice backlog.
- A [GDD intake path](docs/GDD_INTAKE.md), an experiment record, and a [verification report](docs/SETUP_VERIFICATION.md).

## Local checks

```bash
python3 scripts/validate_setup.py
python3 -m unittest discover -s tests -v
python3 scripts/swarm_lease.py --help
```

These commands check the experiment's setup. They do not establish that a game has been implemented, built, or playtested. Engine/build commands are added by the architect after the GDD and execution environment are inspected.

## Source of truth

The supplied GDD and accepted decisions define the game. GitHub Issues own task status and dependencies. Pull requests contain proposed changes. `config/experiment.json` records the experiment phase and canonical locations. Live leases exist only on `swarm-state`; do not merge that branch into `main`.

The [skill source manifest](config/skill_sources.json) binds each role to Hazel's actual GitHub skill sources. Kickoff and recurring runs read those sources and relevant modules at the recorded revision, and report what they loaded. No personal skill installation is required. The role playbooks define ownership and workflow; the GDD defines this game.

## Measure the experiment

Track accepted playable functionality, verified defects, recovery after interrupted runs, human interventions, and observed runtime/tool usage. Record unavailable measurements as unknown. See [the experiment brief](docs/EXPERIMENT.md) for the first acceptance milestone.

To pause production, change `phase` in `config/experiment.json` to `paused`. To stop recurring execution and its usage, also pause the five saved automations. Changing a repository file alone does not cancel a schedule.
