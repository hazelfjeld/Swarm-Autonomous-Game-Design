#!/usr/bin/env python3
"""Coordinate one live run per role using GitHub Contents API compare-and-swap.

This is a cooperative lease, not a security boundary or fencing enforced at
GitHub side effects. Assert ownership immediately before remote mutations.
An operator must first seed every role file on the existing swarm-state branch;
this helper never initializes a missing branch or file. gh uses existing auth.
"""

import argparse
import base64
import json
import re
import subprocess
import sys
import uuid
from datetime import datetime, timedelta, timezone

ROLES = ("director", "architect", "gameplay", "art-audio", "qa")
DEFAULT_REPO = "hazelfjeld/Swarm-Autonomous-Game-Design"
BRANCH = "swarm-state"
MAX_CONFLICT_RETRIES = 3
UTC = timezone.utc


class LeaseError(Exception):
    def __init__(self, code, message):
        super().__init__(message)
        self.code = code


class ApiError(Exception):
    def __init__(self, status=None):
        super().__init__("GitHub API request failed")
        self.status = status


def utc_string(value):
    return value.astimezone(UTC).strftime("%Y-%m-%dT%H:%M:%SZ")


def parse_time(value):
    if not isinstance(value, str):
        raise ValueError("timestamp must be a string")
    parsed = datetime.fromisoformat(value.replace("Z", "+00:00"))
    if parsed.tzinfo is None:
        raise ValueError("timestamp must include its timezone")
    return parsed.astimezone(UTC)


class GitHubClient:
    """Small transport; neither credentials nor raw API output are logged."""

    def __init__(self, repo=DEFAULT_REPO):
        if not re.fullmatch(r"[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+", repo):
            raise LeaseError("usage", "Repository must have the form owner/name.")
        self.repo = repo

    def request(self, method, endpoint, payload=None):
        command = ["gh", "api", "--hostname", "github.com", "--include",
                   "--method", method, endpoint]
        if payload is not None:
            command += ["--input", "-"]
        try:
            completed = subprocess.run(
                command, input=json.dumps(payload) if payload is not None else None,
                text=True, capture_output=True, timeout=30, check=False,
            )
        except FileNotFoundError as exc:
            raise LeaseError("setup_required", "Install gh and configure its existing authorization first.") from exc
        except (subprocess.TimeoutExpired, OSError) as exc:
            raise ApiError() from exc
        # --include supplies a status line followed by headers, then JSON.
        response = completed.stdout.replace("\r\n", "\n")
        headers, separator, body = response.partition("\n\n")
        match = re.match(r"HTTP/\S+\s+(\d{3})\b", headers)
        status = int(match.group(1)) if match else None
        if completed.returncode or status is None or not 200 <= status < 300:
            raise ApiError(status)
        try:
            value = json.loads(body) if separator else None
            if not isinstance(value, dict):
                raise ValueError("expected response object")
            return value
        except (ValueError, TypeError) as exc:
            raise ApiError(status) from exc

    def path(self, role):
        return f"repos/{self.repo}/contents/coordination/leases/{role}.json"

    def read(self, role):
        response = self.request("GET", self.path(role) + "?ref=" + BRANCH)
        try:
            if response.get("encoding") != "base64" or not response.get("sha"):
                raise ValueError("missing content or sha")
            raw = base64.b64decode(response["content"].replace("\n", ""), validate=True)
            return json.loads(raw), response["sha"]
        except (ValueError, TypeError, KeyError, AttributeError) as exc:
            raise LeaseError("invalid_state", "Lease file is not valid JSON content with a blob SHA.") from exc

    def write(self, role, record, sha, action):
        content = json.dumps(record, sort_keys=True, indent=2) + "\n"
        response = self.request("PUT", self.path(role), {
            "branch": BRANCH, "sha": sha,
            "message": f"swarm lease {role}: {action}",
            "content": base64.b64encode(content.encode()).decode(),
        })
        if not isinstance(response.get("content"), dict) or not response["content"].get("sha"):
            raise ApiError(200)  # A malformed reply must never imply success.


def api_failure(error, role):
    if error.status == 404:
        return LeaseError("setup_required", f"Lease file or branch is missing, or the repository is inaccessible. An operator must seed coordination/leases/{role}.json on {BRANCH}; check repository access. No initialization was attempted.")
    if error.status in (401, 403):
        return LeaseError("api_denied", "GitHub denied the request; check existing gh authorization and repository/branch permissions.")
    return LeaseError("api_error", "GitHub request failed or its result was unclear. No success is assumed; inspect status before retrying.")


def validate_record(record, role):
    try:
        if not isinstance(record, dict) or record["schema_version"] != 1 or record["role"] != role:
            raise ValueError("schema or role")
        if type(record["generation"]) is not int or record["generation"] < 0:
            raise ValueError("generation")
        if record["run_id"] is None:
            if record["acquired_at"] is not None or record["expires_at"] is not None:
                raise ValueError("unowned timestamps")
        elif not isinstance(record["run_id"], str) or not record["run_id"]:
            raise ValueError("owner")
        elif parse_time(record["expires_at"]) <= parse_time(record["acquired_at"]):
            raise ValueError("expiry")
    except (KeyError, TypeError, ValueError) as exc:
        raise LeaseError("invalid_state", "Lease schema is invalid; an operator must inspect the seeded file.") from exc


class LeaseManager:
    def __init__(self, client, clock=None):
        self.client = client
        self.clock = clock or (lambda: datetime.now(UTC))

    @staticmethod
    def result(action, role, record, now, **extra):
        state = "free" if record["run_id"] is None else (
            "active" if parse_time(record["expires_at"]) > now else "expired")
        return dict(ok=True, command=action, role=role, run_id=record["run_id"],
                    generation=record["generation"], expires_at=record["expires_at"],
                    state=state, **extra)

    def execute(self, action, role, run_id=None, ttl_minutes=30):
        if role not in ROLES or action not in ("acquire", "renew", "release", "status", "assert"):
            raise LeaseError("usage", "Unknown role or command.")
        if type(ttl_minutes) is not int or not 1 <= ttl_minutes <= 50:
            raise LeaseError("usage", "TTL must be an integer from 1 through 50 minutes.")
        if action == "acquire" and run_id is None:
            run_id = str(uuid.uuid4())
        if action != "status" and (not isinstance(run_id, str) or not re.fullmatch(r"[A-Za-z0-9][A-Za-z0-9_.:-]{0,127}", run_id)):
            raise LeaseError("usage", "Supply the current run ID; acquire can generate one when omitted.")

        for attempt in range(MAX_CONFLICT_RETRIES + 1):
            try:
                record, sha = self.client.read(role)
            except ApiError as exc:
                raise api_failure(exc, role) from exc
            validate_record(record, role)
            now = self.clock().astimezone(UTC).replace(microsecond=0)
            live = record["run_id"] is not None and parse_time(record["expires_at"]) > now
            if action == "status":
                return self.result(action, role, record, now)
            if action == "acquire":
                if live:
                    if record["run_id"] != run_id:
                        raise LeaseError("busy", "Another run owns this role's live lease.")
                    return self.result(action, role, record, now, resumed=True)
                updated = dict(schema_version=1, role=role, run_id=run_id,
                               generation=record["generation"] + 1,
                               acquired_at=utc_string(now),
                               expires_at=utc_string(now + timedelta(minutes=ttl_minutes)))
            else:
                if record["run_id"] != run_id:
                    raise LeaseError("not_owner", "This run does not own the current lease.")
                if not live:
                    raise LeaseError("expired", "This lease has expired; reacquire a new generation before doing work.")
                if action == "assert":
                    return self.result(action, role, record, now)
                updated = dict(record)
                if action == "renew":
                    updated["expires_at"] = utc_string(now + timedelta(minutes=ttl_minutes))
                else:
                    updated.update(run_id=None, acquired_at=None, expires_at=None)
            try:
                self.client.write(role, updated, sha, action)
            except ApiError as exc:
                if exc.status == 409:
                    if attempt < MAX_CONFLICT_RETRIES:
                        continue  # Reread state and recheck ownership before retrying.
                    raise LeaseError("conflict", "Lease changed repeatedly; the three conflict retries are exhausted.") from exc
                raise api_failure(exc, role) from exc
            return self.result(action, role, updated, now, **({"resumed": False} if action == "acquire" else {}))


class JsonArgumentParser(argparse.ArgumentParser):
    def error(self, message):
        raise LeaseError("usage", message)


def main(argv=None):
    parser = JsonArgumentParser(description=__doc__)
    parser.add_argument("command", choices=("acquire", "renew", "release", "status", "assert"))
    parser.add_argument("--role", required=True, choices=ROLES)
    parser.add_argument("--run-id", help="Persist the acquire result and reuse its run_id only for that logical run.")
    parser.add_argument("--repo", default=DEFAULT_REPO)
    parser.add_argument("--ttl-minutes", type=int, default=30, help="1–50; default 30. Used by acquire and renew.")
    try:
        args = parser.parse_args(argv)
        result = LeaseManager(GitHubClient(args.repo)).execute(
            args.command, args.role, args.run_id, args.ttl_minutes)
        print(json.dumps(result, sort_keys=True))
        return 0
    except LeaseError as exc:
        print(json.dumps({"ok": False, "error": exc.code, "message": str(exc)}, sort_keys=True))
        return 1 if exc.code != "usage" else 2


if __name__ == "__main__":
    sys.exit(main())
