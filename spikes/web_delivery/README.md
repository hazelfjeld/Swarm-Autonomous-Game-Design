# ARCH-002 delivery probe

This disposable checkpoint isolates the export/input/save path. It is **not the production game or its save schema**. It does not pass ARCH-002's hosted-runtime acceptance gate by itself.

## Run and export

Observed editor candidate: `4.7.2.stable.official.ed1daf0bf`. Use matching `4.7.2.stable` export templates; a verified installation and actual build evidence are recorded by the parent task report. Compatibility renderer, GDScript, single-thread `Web` preset, no extensions or PWA.

From the repository root:

```bash
godot --headless --path spikes/web_delivery --editor --import
godot --headless --path spikes/web_delivery --script test_store.gd
godot --path spikes/web_delivery
mkdir -p spikes/web_delivery/build
godot --headless --path spikes/web_delivery --export-release Web build/index.html
python3 -m http.server 8000 --directory spikes/web_delivery/build
```

The local HTTP server is only for development. Keep exported filenames together. Serve the same hashed export through the intended authorized Site route before claiming host support.

## What is implemented

`content.gd` contains a probe-only Blueberry identity; `probe_state.gd` defines the disposable individual/value envelope; `probe_store.gd` owns validation and writes; `main.gd` presents ordinary controls. Greet Blueberry increments the value only after a successful write and starts a fixed PCM audio sample from that gesture. The original vector placeholder and synthetic test tone have no third-party asset source and do not decide the final rendering treatment.

Export copies the current probe envelope to the text box. Save that text, change the value, paste it back, preview, and explicitly confirm replacement. The prior valid file is retained as `.previous`. Invalid JSON, unsupported schema/content/identity, and invalid counts are rejected without replacing the active save. A write failure leaves the in-memory value unchanged and displays a reason. The failure toggle is explicitly simulated; the native test also exercises a real missing-directory write failure. Unreadable/unsupported existing files are preserved and block writes; automatic recovery is not implemented here.

The custom user-data directory isolates this probe from the eventual `little_rays` game. Do not import these probe IDs or files into production.

## Evidence still required

Native tests establish native file behavior only. Browser `user://` durability, storage denial/eviction, iframe restrictions, reload, real touch/keyboard interaction, gesture audio, backup workflow, narrow-view layout, and actual Site embedding remain unverified until observed. The Web UI says “Written — reload to verify persistence,” because a local write does not establish durable browser storage.

Use one tab. Writer ownership, cross-tab revision checks, migrations, full GDD saves, automatic previous-good recovery, and a file-download/import picker are intentionally outside this checkpoint. These remain explicit work for ARCH-002 or the production save contract. This spike must not be promoted as satisfying those invariants.

## Guidance used

Canonical `hazelfjeld/Technical-Architect-AI-Skill` at `979756c7e7db6b1ac0f925ba94031b3ec05ced49`: complete `technical-architect/SKILL.md` and `references/data-and-reliability.md`. Repository GDD §13 and stage-zero requirements govern the scope.

Official engine references: [web export](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_web.html), [Web export options](https://docs.godotengine.org/en/stable/classes/class_editorexportplatformweb.html), and [4.7.2 stable archive](https://godotengine.org/download/archive/4.7.2-stable/). Current host observations, not these documents, must settle actual compatibility.
