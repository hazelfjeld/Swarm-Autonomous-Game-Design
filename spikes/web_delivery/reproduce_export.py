#!/usr/bin/env python3
"""Manually reproduce the ARCH-002 web export; no downloads or deployment.

Run from a fresh, clean checkout: python3 spikes/web_delivery/reproduce_export.py
Linux only; use --godot and --templates for non-default installations.
Verified templates are copied to a temporary isolated data home. Output is ignored
under build/<commit>; a failed attempt is retained for diagnosis, never reused.
"""
import argparse
import hashlib
import json
import os
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile

ENGINE = "4.7.2.stable.official.ed1daf0bf"
TEMPLATE_VERSION = "4.7.2.stable"
TEMPLATES = {
    "web_nothreads_release.zip": "d3ee2f08cef0cf3cf6678a6355a92a8db48ccdd35cbd2e8bfd5f0e8a0b4032a0",
    "web_nothreads_debug.zip": "08962aefef811b603541d7951ac67ef00413aad2d978855183c28adee98f626a",
}
EXPECTED = {
    "index.html", "index.js", "index.pck", "index.wasm", "index.png",
    "index.audio.worklet.js", "index.audio.position.worklet.js",
}


def digest(path):
    with path.open("rb") as source:
        return hashlib.file_digest(source, "sha256").hexdigest()


def run(args, cwd, env=None):
    return subprocess.run(args, cwd=cwd, check=True, text=True,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          timeout=300, env=env).stdout


def verify_templates(directory):
    if (directory / "version.txt").read_text().strip() != TEMPLATE_VERSION:
        raise ValueError("Wrong template version")
    for name, expected in TEMPLATES.items():
        if digest(directory / name) != expected:
            raise ValueError(f"Template digest mismatch: {name}")


def artifact_manifest(directory):
    paths = sorted(p for p in directory.iterdir() if p.is_file())
    if not EXPECTED.issubset({p.name for p in paths}):
        raise ValueError("Export is missing expected files")
    if any(p.stat().st_size == 0 for p in paths):
        raise ValueError("Export contains an empty file")
    return {p.name: {"bytes": p.stat().st_size, "sha256": digest(p)}
            for p in paths}


def reproduce(project, godot, templates):
    root = project.parent.parent
    commit = run(["git", "rev-parse", "HEAD"], root).strip()
    if len(commit) != 40 or any(c not in "0123456789abcdef" for c in commit):
        raise ValueError("Expected a full Git commit SHA")
    if run(["git", "status", "--porcelain", "--untracked-files=all", "--",
            str(project.relative_to(root))], root).strip():
        raise ValueError("Probe source is dirty; use an exact clean checkout")
    if (project / ".godot").exists():
        raise ValueError("Existing Godot import cache; use a fresh checkout")
    if sys.platform != "linux":
        raise ValueError("This reproduction helper targets Linux")
    binary = shutil.which(godot)
    if binary is None:
        raise ValueError(f"Godot executable not found: {godot}")
    godot = str(Path(binary).resolve())
    if any((Path(godot).parent / marker).exists() for marker in ("_sc_", "._sc_")):
        raise ValueError("Self-contained Godot installs are not supported by this helper")
    version = run([godot, "--version"], root).strip()
    if version != ENGINE:
        raise ValueError(f"Unexpected engine: {version}")
    verify_templates(templates)
    preset = (project / "export_presets.cfg").read_text().splitlines()
    if not {'custom_template/debug=""', 'custom_template/release=""',
            "variant/thread_support=false"}.issubset(set(preset)):
        raise ValueError("Expected standard single-thread Web templates")
    output = project / "build" / commit
    output.mkdir(parents=True, exist_ok=False)
    prefix = [godot, "--headless", "--path", str(project)]
    commands = [prefix + ["--editor", "--import"],
                prefix + ["--script", "test_store.gd"],
                prefix + ["--quit-after", "3"],
                prefix + ["--export-release", "Web", str(output / "index.html")]]
    evidence = []
    with tempfile.TemporaryDirectory(prefix="arch002-godot-") as isolated:
        home = Path(isolated)
        target = home / "data/godot/export_templates" / TEMPLATE_VERSION
        target.mkdir(parents=True)
        for name in (*TEMPLATES, "version.txt"):
            shutil.copyfile(templates / name, target / name)
        verify_templates(target)
        env = dict(os.environ, XDG_DATA_HOME=str(home / "data"),
                   XDG_CONFIG_HOME=str(home / "config"), XDG_CACHE_HOME=str(home / "cache"))
        for command in commands:
            log = run(command, root, env)
            print(log, end="" if log.endswith("\n") else "\n")
            if "SCRIPT ERROR:" in log or "ERROR:" in log:
                raise ValueError("Godot emitted an error; inspect the command output")
            if command[-1] == "test_store.gd":
                results = []
                for line in log.splitlines():
                    try:
                        results.append(json.loads(line))
                    except json.JSONDecodeError:
                        pass
                if not any(isinstance(result, dict) and
                           result.get("probe_store_tests") == "pass" and
                           result.get("failures") == [] for result in results):
                    raise ValueError("Native store test did not report a pass")
            evidence.append({"command": command, "exit_code": 0, "output": log})
    if (run(["git", "rev-parse", "HEAD"], root).strip() != commit or
            run(["git", "status", "--porcelain", "--untracked-files=all", "--",
                 str(project.relative_to(root))], root).strip()):
        raise ValueError("Probe source changed during export")
    manifest = {"source_commit": commit, "engine": version,
                "template_version": TEMPLATE_VERSION, "templates": TEMPLATES,
                "checks": evidence, "files": artifact_manifest(output),
                "hosted_runtime_verified": False}
    (output / "build-manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
    return output


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", default="godot")
    default = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
    parser.add_argument("--templates", type=Path,
                        default=default / "godot/export_templates" / TEMPLATE_VERSION)
    args = parser.parse_args()
    try:
        output = reproduce(Path(__file__).resolve().parent, args.godot, args.templates)
    except (OSError, ValueError, subprocess.SubprocessError) as error:
        print(f"Export failed: {error}", file=sys.stderr)
        if isinstance(error, subprocess.CalledProcessError) and error.stdout:
            print(error.stdout, file=sys.stderr)
        return 1
    print(f"Local build evidence: {output / 'build-manifest.json'}")
    print("Actual-host interaction and browser persistence remain unverified.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
