# GitHub skill sources

The [source manifest](../config/skill_sources.json) binds each role to verified GitHub skill files at explicit commit SHAs. These are real source reads, not a suggestion to use an installed skill if one happens to be available. All three source repositories currently use `main` as their default branch; runs fetch the committed SHA pins below, not a floating branch.

## Verified sources

| Skill | Exact file | Pinned source commit |
| --- | --- | --- |
| `game-designer` | [hazelfjeld/Game-Design-AI-Skill/game-designer/SKILL.md](https://github.com/hazelfjeld/Game-Design-AI-Skill/blob/dc26ddb18adc18fbbe2221a8443a71a260de6022/game-designer/SKILL.md) | `dc26ddb18adc18fbbe2221a8443a71a260de6022` |
| `technical-architect` | [hazelfjeld/Technical-Architect-AI-Skill/technical-architect/SKILL.md](https://github.com/hazelfjeld/Technical-Architect-AI-Skill/blob/979756c7e7db6b1ac0f925ba94031b3ec05ced49/technical-architect/SKILL.md) | `979756c7e7db6b1ac0f925ba94031b3ec05ced49` |
| `ai-art` | [hazelfjeld/AI-Art-Skill/SKILL.md](https://github.com/hazelfjeld/AI-Art-Skill/blob/9a0ba5c60dfe4de86be7dff7d569e07969f2d225/SKILL.md) | `9a0ba5c60dfe4de86be7dff7d569e07969f2d225` |

## Role assignments

| Role | Assigned sources |
| --- | --- |
| `director` | `game-designer` (primary) |
| `architect` | `technical-architect` (primary) |
| `gameplay` | `technical-architect` (supporting); `game-designer` (supporting) |
| `art-audio` | `ai-art` (primary); `game-designer` (supporting) |
| `qa` | `game-designer` (supporting); `technical-architect` (supporting) |

There are three verified skill repositories. The art/audio role uses Hazel's calibrated art skill as its primary creative and critique guide; gameplay and QA retain the existing supporting guidance. All roles follow their [role playbooks](../prompts/README.md) for ownership and deliverables. Art/audio still needs actual image/audio/animation tools for asset production.

## Calibrated Little Ray art direction

For `art-audio`, the newly pinned `ai-art` source is the owner's [Personalized Creative Director & Art Critic](https://github.com/hazelfjeld/AI-Art-Skill/blob/9a0ba5c60dfe4de86be7dff7d569e07969f2d225/SKILL.md). Its skill path is the repository-root `SKILL.md`. Read the complete pinned skill, `references/little-ray.md`, `references/hazel-taste-profile.md` and the live game GDD at each applicable art run; load critique, revision, creature-design or other-media modules only when relevant, always at the same SHA. Continue reading the existing `game-designer` source and its required shared-work module.

The calibration is qualitative and does **not** constitute Hazel's approval of an image. For ART-002 #10, both old Blueberry style trials remain rejected. The art owner must inspect the real approved mascot reference, preserve original-art provenance, show matched actual-scale city/battle comparisons, and obtain Hazel's material visual choice before roster expansion. QA and architect gates still apply. The source repository is not installed or modified, and this binding does not change any scheduled automation.

## Loading procedure for every kickoff and recurring run

1. Read the live `config/skill_sources.json` from the experiment’s default branch, alongside [AGENTS.md](../AGENTS.md), the assigned task, and the role playbook. Select only the bindings under your role.
2. For each assigned source, fetch and read its full `SKILL.md` using its exact `repository`, `skill_path`, and `commit_sha`. The manifest’s `skill_url` is a direct immutable file link. With the GitHub connector, use the repository-file read operation with those path/ref arguments. A shell checkout of the skill repository is not required.
3. Read each binding’s `required_modules`, then the `modules_when_relevant` that apply to the current task. Follow other relevant links from the loaded skill as necessary, resolving relative paths within that source package and **the same commit SHA**. Never resolve a source module against the experiment repository or silently switch to source `main`.
4. The game-designer skill requires `game-designer/references/production-and-collaboration.md` for shared/scheduled repository work. It is therefore required for the director and for supporting roles using that skill in this experiment. Load other references/templates selectively. Do not bulk ingest references or full books.
5. An installed skill copy is an equivalent source only when its source repository, commit SHA, and content provenance are verified to match the manifest. A matching display name or similar text is insufficient. Otherwise read the canonical GitHub files. Do not install or modify personal skills or write to any source skill repository as part of these role runs.
6. Record source repository, exact SHA, files actually read, retrieval mode, and relevant application in the [run report](../templates/RUN_REPORT.md). Record failures and unread modules honestly. An unavailable skill does not block bounded authorized work that can proceed independently through the role playbook; do not claim that the unread skill guided the result.

The manifest on the current default branch is authoritative. Explicit addresses embedded in kickoff prompts are initial verified pointers; if an intentionally committed manifest revision changes a pin, use and report the live manifest pin. Source skills supplement the user’s requirements, GDD, role boundaries, and coordination protocol; they do not expand authorization or replace current task ownership.

## Current game state

The current Little Ray GDD is received at the path/version in `config/experiment.json`; v2.1 adds DIRECTOR-003 #27's creative consistency rules to the unchanged v2.0 mechanic baseline, following the user correction in DIRECTOR-002 #22 that superseded conflicting v1 sanctuary rules. Read [the charter](design/CREATIVE_DIRECTION.md) for all presentation work; the exact Blueberry style choice is still pending. The historical [DIRECTOR-001 #3](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/3) records the completed intake. Read the [design baseline](design/DESIGN_BASELINE.md) and [first slice](design/FIRST_SLICE.md), then the current issue bodies for tasks [#9](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/9), [#10](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/10), [#11](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/11), [#12](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/12), [#13](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/13), [#14](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/14), [#23](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/23), and [#24](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/24). Their live dependencies and status control readiness. Do not request the original attachment again or repeat completed intake. Finish any still-needed role capability evidence and then resume eligible assigned work.
