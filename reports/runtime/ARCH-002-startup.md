# ARCH-002: first web-export checkpoint

- Role: architect.
- Task: [ARCH-002 #9](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/9).
- Run ID: `architect-kickoff-20261123T233802000Z-5cfc06a7`, lease generation 4.
- Date: 2026-11-23 UTC; acquisition at 23:38:02 UTC.
- Input commit: `08beacae99ea23394438cb2f61f8e7772b6ac47e`.
- Output: `swarm/architect/ARCH-002`; the linked PR and canonical issue record the submitted commit.
- Result: reproducible diagnostic project, native save checks, and an actual successful single-thread web export. Partial checkpoint; ARCH-002 is not complete.

## Scope and readiness

Reused accepted ARCH-001 #4 evidence and the received Little Ray GDD. The live director readiness decision on #9 explicitly satisfied its intake and execution-capability dependencies. The task moved from Ready to Working; no other issue's dependencies were waived. The phase was bootstrap, not paused or stopped. This run did not repeat GDD intake, select another engine, decide the final art treatment, or implement campaign content.

The checkpoint lives in [spikes/web_delivery](../../spikes/web_delivery/README.md). It separates content identity, a diagnostic individual/value, storage, and presentation. A Greet Blueberry button commits a value and triggers a short fixed audio sample. The original vector placeholder is temporary. Backup text can be exported, validated, previewed, and explicitly confirmed before replacement. Write failures remain visible and preserve the active value. The diagnostic profile is isolated from future production saves.

## Engine and template evidence

`godot --version` returned `4.7.2.stable.official.ed1daf0bf`. The [official stable archive](https://godotengine.org/download/archive/4.7.2-stable/) identifies this release. The initial template directory was empty. The standard archive was obtained from the [official build release](https://github.com/godotengine/godot-builds/releases/tag/4.7.2-stable), and its complete SHA-256 matched the release API's digest before extraction.

| Artifact | Identity |
| --- | --- |
| Standard template archive | `Godot_v4.7.2-stable_export_templates.tpz`, 1,281,349,702 bytes |
| Archive SHA-256 | `f298490b8d44d934be425a5a65a51bf15f422428b229a06a6e11d9ffea248011` |
| Template version file | `4.7.2.stable` |
| Nonthread release template SHA-256 | `d3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0` |
| Nonthread debug template SHA-256 | `08962aefef811b603541d7951ac67ef00413aad2d978855183c28adee98f626a` |

Only version.txt and the nonthread debug/release web templates were installed, under the standard `godot/export_templates/4.7.2.stable` data directory. The official download-service HEAD request returned HTTP 403; the separately available official GitHub release download succeeded and passed the checksum. No paid service, credential change, or network-policy override was used.

The project uses GDScript, Compatibility rendering and `variant/thread_support=false`, with extensions and PWA disabled. Current [web export guidance](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html) and [export options](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformweb.html) were inspected before setting the preset. They establish the configuration direction, not host compatibility. Browser storage can differ from native files; the Web UI says “Written — reload to verify persistence.”

## Executed checks

Commands below run from the repository root. Headless import and scene execution were performed by the implementation worker. The parent repeated the native store test and ran the prescribed setup checks on the resulting source. No proposed check is counted as executed.

| Check | Exact command | Result |
| --- | --- | --- |
| Project/script import | `godot --headless --path spikes/web_delivery --editor --import` | Exit 0 |
| Native store behavior | `godot --headless --path spikes/web_delivery --script test_store.gd` | Exit 0; `{"failures":[],"probe_store_tests":"pass"}` |
| Headless scene execution | `godot --headless --path spikes/web_delivery --quit-after 3` | Exit 0; no reported script/runtime errors |
| Actual Web release export | `godot --headless --path spikes/web_delivery --export-release Web build/index.html` | Exit 0; generated HTML, JavaScript, PCK, WebAssembly, image and audio worklet files |
| Setup integrity | `python3 scripts/validate_setup.py` | Passed |
| Existing coordination/setup tests | `python3 -m unittest discover -s tests -v` | 29 passed |

The 14 store checks include reconstruction through a fresh store object, preserved individual identity, a backup round trip, a previous-value copy, malformed/newer/negative-value rejection, preserved current bytes after failure, a real missing-directory write failure, and refusal to overwrite a newer existing schema. An initial reload comparison exposed JSON numeric normalization; the resulting source normalizes validated counts and schema version, and the subsequent tests passed. These checks demonstrate native file behavior, not browser durability or human interaction.

## Export identity

The generated build is ignored by Git. Rebuild from the submitted source with the pinned editor/templates. These hashes identify the actual local export from this checkpoint; there is no served URL or hosted build acceptance yet.

| File | Bytes | SHA-256 |
| --- | ---: | --- |
| index.html | 5,313 | `0a801f3696c46fd3f50f85e898c04e049d9f6ed0958543dbd29a83c21a8e1ce3` |
| index.js | 279,815 | `33c94cb3175f3333b82e2a3be5e8e86f77986f0aa2042b1631f6367a4e5bb6ba` |
| index.pck | 11,728 | `3f4bfaf27caa5f2b620de9cf633c2c2d08c97d99360e36827c57a5bf1287bc7d` |
| index.wasm | 39,514,754 | `fc74679e3b97f76878947fcd4fbe1268cbfa6188182a2e33bbc3f5dc9bfa57d0` |
| index.png | 21,443 | `3cb4495c0b98dfbe4b663cbf2b6836473572339beb66d902367893162a70be0e` |
| index.audio.worklet.js | 7,298 | `5b476a9c9ce642c0ee4256436d1bc31d9c38f868aca0f9a8e2a57c18d2dec2a3` |
| index.audio.position.worklet.js | 2,973 | `be33985bc7160d6bf9646f259cd86b259cd67b02ccb297ee5c44f8ac84327bc8` |

Raw sizes are not compressed download measurements or proof of the GDD performance budgets.

## Skill source evidence

| Source | Commit | Files actually read | Mode/result |
| --- | --- | --- | --- |
| `hazelfjeld/Technical-Architect-AI-Skill`, primary | `979756c7e7db6b1ac0f925ba94031b3ec05ced49` | `technical-architect/SKILL.md`; `references/architecture-workflow.md`; `references/data-and-reliability.md`; `references/review-playbook.md` | Complete canonical GitHub reads; no skill-source retrieval failure |

The installed Technical Architect skill was also read, but canonical source reads satisfy the repository binding. Requirements came from the live role/protocol, #9, the design baseline, first slice, and relevant GDD sections including platform, identity, input, stage zero and persistence. The data/reliability guidance shaped validation and recovery evidence; the architecture/review guidance kept the checkpoint small and separated observed results from remaining claims. A delegated read-only worker inspected the Sites skill and advertised static-deployment contracts; it performed no Site mutation.

## Remaining work and next owner

Architect continues this same issue and branch. Resolve or create the authorized Site identity through the normal Sites workflow, package the exported files with that Site's source provenance, and observe the exact hosted/embedding context. The advertised static-artifact interface is available; a successful Godot host is not yet established. No Site identity was selected and no deployment occurred in this checkpoint.

Still required: actual-host load/WebGL, normal mouse/keyboard/touch input, audible gesture playback, reload and persisted-value restoration, the visible backup round trip, storage failure behavior, tested viewport/device limits and build identity. Production writer ownership/revision checks, migrations, automatic previous-good recovery and full GDD state are not implemented by this diagnostic store. Do not release it as the production save system or unblock dependent gameplay solely from this export.

Submit this as a draft checkpoint for independent review. Do not merge it as a completed ARCH-002 baseline. Independent QA and the full applicable integration gates remain required. Human playtesting was not performed.

## Startup registration and coordination

The CLI lease helper was inspected and attempted; it returned an API error, and `gh auth status` confirmed no CLI login. A fresh connector read showed the lease still unowned. The authenticated connector then acquired generation 4 by exact blob-SHA compare-and-swap in commit `2c7de0a4fca9da21915d964f94584fde063ddacf`. Live owner/config checks guarded later repository writes. Cleanup release is recorded in the canonical issue outcome.

The actual automation ID, returned enabled state, verified schedule/prompt and first-scheduled-run status belong in the startup registry [ARCH-001 #4](https://github.com/hazelfjeld/Swarm-Autonomous-Game-Design/issues/4). This report does not invent or anticipate that service result. Interactive capabilities do not prove the environment of a future scheduled run.
