"""Offline tests: all GitHub requests are fake; no credentials or network needed."""

import base64
import copy
import importlib.util
import io
import json
import subprocess
import unittest
from contextlib import redirect_stdout
from datetime import datetime, timedelta
from pathlib import Path
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "swarm_lease", Path(__file__).resolve().parents[1] / "scripts" / "swarm_lease.py")
lease = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(lease)
START = datetime(2026, 11, 23, 12, 0, tzinfo=lease.UTC)


def seed():
    return dict(schema_version=1, role="gameplay", run_id=None, generation=0,
                acquired_at=None, expires_at=None)


class FakeClient:
    def __init__(self):
        self.record = seed()
        self.version = 0
        self.writes = 0
        self.before_write = None
        self.read_error = None
        self.write_error = None

    def read(self, role):
        if self.read_error:
            raise self.read_error
        return copy.deepcopy(self.record), str(self.version)

    def write(self, role, record, sha, action):
        self.writes += 1
        if self.before_write:
            hook, self.before_write = self.before_write, None
            hook()
        if self.write_error:
            raise self.write_error
        if sha != str(self.version):
            raise lease.ApiError(409)
        self.record = copy.deepcopy(record)
        self.version += 1


class LeaseTests(unittest.TestCase):
    def setUp(self):
        self.client = FakeClient()
        self.now = START
        self.manager = lease.LeaseManager(self.client, lambda: self.now)

    def run_command(self, action, run="run-a", ttl=30):
        return self.manager.execute(action, "gameplay", run, ttl)

    def rejected(self, code, action, run="run-a", ttl=30):
        with self.assertRaises(lease.LeaseError) as error:
            self.run_command(action, run, ttl)
        self.assertEqual(error.exception.code, code)

    def test_acquire_generates_id_and_default_expiry(self):
        result = self.run_command("acquire", None)
        self.assertEqual(str(lease.uuid.UUID(result["run_id"])), result["run_id"])
        self.assertEqual(result["generation"], 1)
        self.assertEqual(result["expires_at"], "2026-11-23T12:30:00Z")
        self.assertEqual(result["state"], "active")

    def test_live_other_run_is_rejected_and_same_run_resumes_without_extension(self):
        first = self.run_command("acquire")
        self.now += timedelta(minutes=10)
        self.rejected("busy", "acquire", "run-b")
        resumed = self.run_command("acquire")
        self.assertTrue(resumed["resumed"])
        self.assertEqual(resumed["expires_at"], first["expires_at"])
        self.assertEqual(resumed["generation"], first["generation"])
        self.assertEqual(self.client.writes, 1)

    def test_expiry_boundary_and_takeover_preserve_monotonic_generation(self):
        self.run_command("acquire")
        self.now += timedelta(minutes=30)
        self.assertEqual(self.run_command("status")["state"], "expired")
        for action in ("assert", "renew", "release"):
            self.rejected("expired", action)
        acquired = self.run_command("acquire", "run-b")
        self.assertEqual(acquired["generation"], 2)
        for action in ("assert", "renew", "release"):
            self.rejected("not_owner", action)
        self.assertEqual(self.client.record["run_id"], "run-b")

    def test_same_run_reacquire_after_expiry_is_a_new_generation(self):
        self.run_command("acquire")
        self.now += timedelta(minutes=31)
        result = self.run_command("acquire")
        self.assertFalse(result["resumed"])
        self.assertEqual(result["generation"], 2)

    def test_renew_and_release_then_next_acquire(self):
        self.run_command("acquire")
        self.now += timedelta(minutes=10)
        renewed = self.run_command("renew")
        self.assertEqual(renewed["expires_at"], "2026-11-23T12:40:00Z")
        self.assertEqual(renewed["generation"], 1)
        self.assertTrue(self.run_command("assert")["ok"])
        self.assertEqual(self.run_command("release")["state"], "free")
        self.rejected("not_owner", "assert")
        self.assertEqual(self.run_command("acquire", "run-b")["generation"], 2)

    def test_overlapping_acquisition_rereads_winner_after_cas_conflict(self):
        other = lease.LeaseManager(self.client, lambda: self.now)
        self.client.before_write = lambda: other.execute("acquire", "gameplay", "run-b")
        self.rejected("busy", "acquire")
        self.assertEqual(self.client.record["run_id"], "run-b")
        self.assertEqual(self.client.record["generation"], 1)

    def test_unrelated_blob_change_can_retry_acquisition(self):
        self.client.before_write = lambda: setattr(self.client, "version", 1)
        acquired = self.run_command("acquire")
        self.assertEqual(acquired["run_id"], "run-a")
        self.assertEqual(self.client.writes, 2)

    def test_old_release_and_renew_cannot_overwrite_takeover_after_read(self):
        for action in ("release", "renew"):
            with self.subTest(action=action):
                self.setUp()
                self.run_command("acquire")
                def takeover():
                    self.now += timedelta(minutes=31)
                    other = lease.LeaseManager(self.client, lambda: self.now)
                    other.execute("acquire", "gameplay", "run-b")
                self.client.before_write = takeover
                self.rejected("not_owner", action)
                self.assertEqual(self.client.record["run_id"], "run-b")
                self.assertEqual(self.client.record["generation"], 2)

    def test_conflict_retries_are_bounded(self):
        self.client.write_error = lease.ApiError(409)
        self.rejected("conflict", "acquire")
        self.assertEqual(self.client.writes, 4)  # Initial attempt + three retries.
        self.assertIsNone(self.client.record["run_id"])

    def test_api_failure_never_reports_success_and_does_not_retry_ambiguous_write(self):
        self.client.read_error = lease.ApiError(503)
        self.rejected("api_error", "acquire")
        self.assertEqual(self.client.writes, 0)
        self.client.read_error = None
        self.client.write_error = lease.ApiError()
        self.rejected("api_error", "acquire")
        self.assertEqual(self.client.writes, 1)

    def test_missing_state_and_invalid_state_fail_closed(self):
        self.client.read_error = lease.ApiError(404)
        self.rejected("setup_required", "acquire")
        self.assertEqual(self.client.writes, 0)
        self.client.read_error = None
        self.client.record["generation"] = True
        self.rejected("invalid_state", "acquire")

    def test_ttl_bounds(self):
        for invalid in (0, 51, 1.5, True):
            self.rejected("usage", "acquire", ttl=invalid)
        result = self.run_command("acquire", ttl=50)
        self.assertEqual(result["expires_at"], "2026-11-23T12:50:00Z")

    def test_cli_outputs_machine_readable_failure(self):
        with patch.object(lease, "GitHubClient", return_value=self.client), redirect_stdout(io.StringIO()) as output:
            self.client.read_error = lease.ApiError(404)
            result = lease.main(["acquire", "--role", "gameplay"])
        self.assertNotEqual(result, 0)
        self.assertEqual(json.loads(output.getvalue())["error"], "setup_required")


class TransportTests(unittest.TestCase):
    @patch.object(lease.subprocess, "run")
    def test_write_supplies_expected_sha_branch_and_json_via_stdin(self, process):
        process.return_value = subprocess.CompletedProcess([], 0,
            'HTTP/2.0 200 OK\r\nContent-Type: application/json\r\n\r\n{"content":{"sha":"next"}}', "")
        lease.GitHubClient().write("gameplay", seed(), "expected-sha", "release")
        args, kwargs = process.call_args
        self.assertIn("--input", args[0])
        self.assertNotIn("shell", kwargs)
        payload = json.loads(kwargs["input"])
        self.assertEqual(payload["sha"], "expected-sha")
        self.assertEqual(payload["branch"], "swarm-state")
        self.assertEqual(json.loads(base64.b64decode(payload["content"])), seed())

    @patch.object(lease.subprocess, "run")
    def test_http_failure_and_malformed_success_are_not_success(self, process):
        client = lease.GitHubClient()
        process.return_value = subprocess.CompletedProcess([], 1, "HTTP/2.0 409 Conflict\n\n{}", "private stderr")
        with self.assertRaises(lease.ApiError) as error:
            client.write("gameplay", seed(), "old", "release")
        self.assertEqual(error.exception.status, 409)
        process.return_value = subprocess.CompletedProcess([], 0, "HTTP/2.0 200 OK\n\n{}", "")
        with self.assertRaises(lease.ApiError):
            client.write("gameplay", seed(), "old", "release")


if __name__ == "__main__":
    unittest.main()
