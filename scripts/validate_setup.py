#!/usr/bin/env python3
"""Validate the five-agent experiment's local setup; never claims a game was tested."""

from __future__ import annotations

import argparse
import json
from pathlib import Path
import re
import sys
from urllib.parse import unquote, urlsplit


ROLES = ("director", "architect", "gameplay", "art-audio", "qa")
REPOSITORY = "hazelfjeld/Swarm-Autonomous-Game-Design"
REQUIRED_FILES = (
    "README.md",
    "AGENTS.md",
    "docs/EXPERIMENT.md",
    "docs/GDD_INTAKE.md",
    "docs/PROTOCOL.md",
    "docs/BOARD.md",
    "prompts/README.md",
    "scripts/swarm_lease.py",
)
PLACEHOLDER = re.compile(
    r"\[(?:TODO|TBD)\b[^\]]*\]|\b(?:TODO|TBD)\s*:\s*(?:fill|replace|complete|write|add)\b",
    re.IGNORECASE,
)
INLINE_LINK = re.compile(r"!?\[[^\]\n]*\]\(\s*(<[^>]+>|[^\s)]+)(?:\s+[^)]*)?\)")


def _path(root: Path, value: object, label: str, errors: list[str]) -> Path | None:
    if not isinstance(value, str) or not value.strip():
        errors.append(f"{label} must be a nonempty repository-relative path")
        return None
    path = Path(value)
    target = (root / path).resolve()
    if path.is_absolute() or not target.is_relative_to(root):
        errors.append(f"{label} must stay inside the repository")
        return None
    if not target.is_file():
        errors.append(f"{label} points to a missing file: {value}")
        return None
    return target


def _object(value: object, label: str, errors: list[str]) -> dict:
    if not isinstance(value, dict):
        errors.append(f"{label} must be an object")
        return {}
    return value


def _without_code(text: str) -> str:
    """Ignore fenced examples and inline code when checking Markdown links."""
    result = []
    fence: tuple[str, int] | None = None
    for line in text.splitlines():
        marker = re.match(r"^\s*(`{3,}|~{3,})", line)
        if marker:
            token = marker.group(1)
            if fence is None:
                fence = (token[0], len(token))
            elif token[0] == fence[0] and len(token) >= fence[1]:
                fence = None
            continue
        if fence is None:
            result.append(re.sub(r"`[^`\n]*`", "", line))
    return "\n".join(result)


def _markdown_links(root: Path, path: Path, text: str, errors: list[str]) -> None:
    for match in INLINE_LINK.finditer(_without_code(text)):
        destination = match.group(1).strip("<>")
        parsed = urlsplit(destination)
        if parsed.scheme or parsed.netloc or not parsed.path:
            continue
        target = (path.parent / unquote(parsed.path)).resolve()
        if not target.is_relative_to(root):
            errors.append(f"{path.relative_to(root)}: relative link leaves repository: {destination}")
        elif not target.exists():
            errors.append(f"{path.relative_to(root)}: broken relative link: {destination}")


def validate(root: Path) -> list[str]:
    """Return actionable setup errors without making network calls or modifying files."""
    root = root.resolve()
    errors: list[str] = []
    for name in REQUIRED_FILES:
        _path(root, name, name, errors)
    config_path = _path(root, "config/experiment.json", "config", errors)
    if config_path is None:
        return errors
    try:
        config_text = config_path.read_text(encoding="utf-8")
        config = json.loads(config_text)
    except (OSError, UnicodeError, json.JSONDecodeError) as exc:
        return errors + [f"config/experiment.json is not readable JSON: {exc}"]
    if not isinstance(config, dict):
        return errors + ["config/experiment.json must contain an object"]
    if type(config.get("schema_version")) is not int or config["schema_version"] != 1:
        errors.append("schema_version must be integer 1")
    if config.get("repository") != REPOSITORY:
        errors.append(f"repository must be {REPOSITORY}")
    if config.get("phase") not in {"setup", "bootstrap", "active", "paused", "stopped"}:
        errors.append("phase must be setup, bootstrap, active, paused, or stopped")

    gdd = _object(config.get("gdd"), "gdd", errors)
    if gdd.get("status") not in {"awaiting", "received", "approved"}:
        errors.append("gdd.status must be awaiting, received, or approved")
    if "path" not in gdd:
        errors.append("gdd.path is required; use null while awaiting the GDD")
    elif gdd["path"] is not None:
        _path(root, gdd["path"], "gdd.path", errors)
    elif gdd.get("status") in {"received", "approved"}:
        errors.append("received or approved GDD requires an existing gdd.path")
    if config.get("phase") == "active" and gdd.get("status") not in {"received", "approved"}:
        errors.append("active phase requires a received GDD")

    role_config = _object(config.get("roles"), "roles", errors)
    if set(role_config) != set(ROLES):
        errors.append("roles must contain exactly director, architect, gameplay, art-audio, qa")
    minutes: list[int] = []
    for role in ROLES:
        role_data = _object(role_config.get(role), f"roles.{role}", errors)
        _path(root, role_data.get("path"), f"roles.{role}.path", errors)
        expected_path = f"roles/{role}.md"
        if role_data.get("path") != expected_path:
            errors.append(f"roles.{role}.path must be {expected_path}")
        prompt_path = role_data.get("prompt_path", f"prompts/{role}.md")
        _path(root, prompt_path, f"roles.{role}.prompt_path", errors)
        minute = role_data.get("schedule_minute")
        if type(minute) is not int or not 0 <= minute <= 59:
            errors.append(f"roles.{role}.schedule_minute must be an integer from 0 to 59")
        else:
            minutes.append(minute)
    if len(minutes) != len(set(minutes)):
        errors.append("roles must use distinct schedule_minute values")

    automation = _object(config.get("automation"), "automation", errors)
    if automation.get("timezone") != "America/Chicago":
        errors.append("automation.timezone must be America/Chicago")
    if type(automation.get("expected_count")) is not int or automation["expected_count"] != len(ROLES):
        errors.append("automation.expected_count must be 5")
    coordination = _object(config.get("coordination"), "coordination", errors)
    if coordination.get("state_branch") != "swarm-state":
        errors.append("coordination.state_branch must be swarm-state")
    if coordination.get("lease_path_template") != "coordination/leases/{role}.json":
        errors.append("coordination.lease_path_template must be coordination/leases/{role}.json")

    board = _object(config.get("board"), "board", errors)
    issue_numbers = {
        "message_board_issue": board.get("message_board_issue"),
        "decision_log_issue": board.get("decision_log_issue"),
    }
    role_issues = _object(board.get("role_issue_numbers"), "board.role_issue_numbers", errors)
    if set(role_issues) != set(ROLES):
        errors.append("board.role_issue_numbers must contain exactly the five role names")
    issue_numbers.update({f"role_issue_numbers.{r}": role_issues.get(r) for r in ROLES})
    valid_numbers = []
    for label, number in issue_numbers.items():
        if type(number) is not int or number <= 0:
            errors.append(f"board.{label} must be a positive issue number")
        else:
            valid_numbers.append(number)
    if len(valid_numbers) != len(set(valid_numbers)):
        errors.append("message board, decision log, and role issues must have distinct issue numbers")
    if not isinstance(config.get("milestones"), list) or not config["milestones"]:
        errors.append("milestones must be a nonempty list")

    if PLACEHOLDER.search(config_text):
        errors.append("config/experiment.json contains an unfinished placeholder")
    markdown = [root / "README.md", root / "AGENTS.md"]
    for folder in ("docs", "roles", "prompts"):
        markdown.extend((root / folder).rglob("*.md"))
    for path in sorted(set(markdown)):
        if not path.is_file():
            continue
        try:
            text = path.read_text(encoding="utf-8")
        except (OSError, UnicodeError) as exc:
            errors.append(f"{path.relative_to(root)} is not readable UTF-8: {exc}")
            continue
        if path.relative_to(root).parts[0] in {"roles", "prompts"} and PLACEHOLDER.search(text):
            errors.append(f"{path.relative_to(root)} contains an unfinished placeholder")
        _markdown_links(root, path, text, errors)
    return errors


def main(argv: list[str] | None = None) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", type=Path, default=Path(__file__).resolve().parents[1])
    args = parser.parse_args(argv)
    errors = validate(args.root)
    if errors:
        print("SETUP VALIDATION FAILED (no game/runtime tests were performed)", file=sys.stderr)
        for error in errors:
            print(f"- {error}", file=sys.stderr)
        return 1
    print("SETUP VALIDATION PASSED: five role definitions, kickoff files, config, and local links")
    print("Scope: repository setup only; no remote access, schedules, game build, or playtest verified.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
