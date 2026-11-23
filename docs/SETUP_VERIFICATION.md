# Setup verification

This record distinguishes coordination setup from game implementation and scheduled execution.

## Repository resources

- Repository was empty before setup.
- Message board, decision log, five role startup tasks, and M0 milestone issue have been created and their actual numbers recorded in `config/experiment.json`.
- Five role playbooks and kickoff prompts are present.
- GDD remains awaiting the user's submission.
- Hourly automations are created by the separate role kickoffs; none are created by this setup operation.

## Observed verification — 2026-11-23

- `python3 scripts/validate_setup.py`: passed, including all five role definitions, kickoff files, configuration, and local handoff links.
- `python3 -m unittest discover -s tests -v`: 29 tests passed. Coverage includes conflicting lease acquisitions, stale renew/release, expiry, bounded conflict retries, API failures, GDD readiness, role/schedule integrity, and broken handoff links.
- GitHub connector read/write: verified by creating the setup repository resources and reading back state.
- Live lease compare-and-swap: acquired the QA lease using its current blob SHA; a stale competing update received HTTP 409; readback retained the original owner; the owner then released the lease successfully. Acquisition commit: `0f0b2b0c3474b240365930c360676aba4219ab34`; release commit: `00ff7b1bb2e3843d47a10bb75a5416319037aae6` on `swarm-state`.
- Five live lease files were initialized on `swarm-state`; no production role is left running by the setup verification.
- The local GitHub CLI is installed but has no configured login in the setup environment. Its transport is covered by offline tests; a live authenticated CLI run was not claimed. The authenticated connector route was used and verified instead.
- GitHub Actions `actions/checkout@v7` and `actions/setup-python@v7` tags were resolved through GitHub before inclusion. Remote CI outcome is recorded in the workflow run after upload; local results above are independent of that outcome.

The role kickoff prompts remain unexecuted by setup. No hourly task ID or scheduled-run capability is claimed until a role actually registers and runs.

## Scope limits

No game engine decision, playable game, game build, human playtest, or actual scheduled execution is claimed by this setup. Runtime capabilities must be verified in each role's real execution environment.

Role separation and lease checks are cooperative workflow rules. Repository setup does not claim to have enabled branch protection, separate GitHub identities, or server-side fencing of all writes.
