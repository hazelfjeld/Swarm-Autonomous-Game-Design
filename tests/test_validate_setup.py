"""Contract tests for mistakes that could launch the wrong or incomplete experiment."""

from __future__ import annotations

import importlib.util
import json
from pathlib import Path
import tempfile
import unittest


SCRIPT = Path(__file__).resolve().parents[1] / "scripts" / "validate_setup.py"
SPEC = importlib.util.spec_from_file_location("validate_setup", SCRIPT)
assert SPEC and SPEC.loader
setup = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(setup)


class SetupContractTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        for name in setup.REQUIRED_FILES:
            self.write(name, "# Fixture\n")
        for role in setup.ROLES:
            self.write(f"roles/{role}.md", f"# {role}\nProduce and verify assigned work.\n")
            self.write(f"prompts/{role}.md", f"# Start {role}\nRead current repository instructions.\n")
        self.config = {
            "schema_version": 1,
            "repository": setup.REPOSITORY,
            "phase": "bootstrap",
            "gdd": {"status": "awaiting", "path": None},
            "roles": {
                role: {"path": f"roles/{role}.md", "schedule_minute": i * 10}
                for i, role in enumerate(setup.ROLES)
            },
            "automation": {"timezone": "America/Chicago", "expected_count": 5},
            "coordination": {
                "state_branch": "swarm-state",
                "lease_path_template": "coordination/leases/{role}.json",
            },
            "board": {
                "message_board_issue": 1,
                "decision_log_issue": 2,
                "role_issue_numbers": {role: i + 3 for i, role in enumerate(setup.ROLES)},
            },
            "milestones": [{"id": "M0", "title": "Establish the experiment"}],
        }
        self.save_config()

    def write(self, path, content):
        target = self.root / path
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(content, encoding="utf-8")

    def save_config(self):
        self.write("config/experiment.json", json.dumps(self.config))

    def errors(self):
        return setup.validate(self.root)

    def test_complete_bootstrap_is_valid_without_a_gdd(self):
        self.assertEqual([], self.errors())

    def test_missing_kickoff_prevents_incomplete_launch(self):
        (self.root / "prompts/qa.md").unlink()
        self.assertTrue(any("roles.qa.prompt_path" in e for e in self.errors()))

    def test_stale_or_duplicate_roles_are_rejected(self):
        self.config["roles"]["marketer"] = self.config["roles"].pop("qa")
        self.save_config()
        self.assertTrue(any("exactly director" in e for e in self.errors()))

    def test_schedule_collision_and_wrong_task_count_are_rejected(self):
        self.config["roles"]["qa"]["schedule_minute"] = 0
        self.config["automation"]["expected_count"] = 4
        self.save_config()
        errors = self.errors()
        self.assertTrue(any("distinct schedule_minute" in e for e in errors))
        self.assertTrue(any("expected_count" in e for e in errors))

    def test_cannot_enter_active_phase_while_awaiting_gdd(self):
        self.config["phase"] = "active"
        self.save_config()
        self.assertTrue(any("active phase" in e for e in self.errors()))

    def test_received_gdd_allows_active_phase_without_an_extra_approval(self):
        self.config["phase"] = "active"
        self.config["gdd"] = {"status": "received", "path": "docs/GDD.md"}
        self.write("docs/GDD.md", "# User-provided design\n")
        self.save_config()
        self.assertEqual([], self.errors())

    def test_approved_gdd_must_resolve_to_a_real_repo_file(self):
        self.config["gdd"] = {"status": "approved", "path": "docs/GDD.md"}
        self.save_config()
        self.assertTrue(any("gdd.path" in e for e in self.errors()))
        self.write("docs/GDD.md", "# Approved design\n")
        self.assertEqual([], self.errors())

    def test_path_cannot_escape_repository(self):
        self.config["gdd"] = {"status": "received", "path": "../outside.md"}
        self.save_config()
        self.assertTrue(any("stay inside" in e for e in self.errors()))

    def test_template_placeholder_is_rejected_but_explanatory_word_is_allowed(self):
        self.write("roles/qa.md", "# QA\nDo not count TODO comments as finished work.\n")
        self.assertEqual([], self.errors())
        self.write("roles/qa.md", "# QA\n[TODO: Add actual procedure]\n")
        self.assertTrue(any("unfinished placeholder" in e for e in self.errors()))

    def test_external_links_anchors_and_fenced_examples_are_allowed(self):
        self.write("docs/BOARD.md", """# Board
[Remote issue](https://github.com/example/repo/issues/1)
[This heading](#board)
[Instructions](../AGENTS.md)
```markdown
[Example only](not-a-real-file.md)
```
""")
        self.assertEqual([], self.errors())

    def test_broken_local_handoff_link_is_rejected(self):
        self.write("roles/gameplay.md", "[Handoff procedure](../docs/missing.md)\n")
        self.assertTrue(any("broken relative link" in e for e in self.errors()))

    def test_non_object_config_reports_error_without_crashing(self):
        self.write("config/experiment.json", "[]")
        self.assertTrue(any("must contain an object" in e for e in self.errors()))

    def test_reused_board_issue_does_not_pass_as_separate_roles(self):
        self.config["board"]["role_issue_numbers"]["qa"] = 1
        self.save_config()
        self.assertTrue(any("distinct issue numbers" in e for e in self.errors()))

    def test_boolean_is_not_a_minute_or_issue_identifier(self):
        self.config["roles"]["qa"]["schedule_minute"] = True
        self.config["board"]["message_board_issue"] = True
        self.save_config()
        errors = self.errors()
        self.assertTrue(any("schedule_minute" in e for e in errors))
        self.assertTrue(any("message_board_issue" in e for e in errors))


if __name__ == "__main__":
    unittest.main()
