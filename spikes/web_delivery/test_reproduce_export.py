"""Exercise export orchestration with fake Godot, never a runtime test."""
import contextlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest.mock import patch

sys.dont_write_bytecode = True
import reproduce_export as export


@unittest.skipUnless(sys.platform == "linux", "Linux reproduction helper")
class ExportTests(unittest.TestCase):
    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.root = Path(self.tmp.name)
        self.project = self.root / "spikes/web_delivery"
        self.project.mkdir(parents=True)
        (self.project / ".gitignore").write_text("build/\n.godot/\n")
        (self.project / "export_presets.cfg").write_text(
            'custom_template/debug=""\ncustom_template/release=""\nvariant/thread_support=false\n')
        self.git("init", "-q")
        self.git("add", "spikes")
        self.git("-c", "user.name=Fixture", "-c", "user.email=fixture@example.invalid",
                 "commit", "-qm", "fixture")
        self.templates = self.root / "templates"
        self.templates.mkdir()
        (self.templates / "version.txt").write_text(export.TEMPLATE_VERSION)
        hashes = {}
        for name in export.TEMPLATES:
            path = self.templates / name
            path.write_text(name)
            hashes[name] = export.digest(path)
        self.addCleanup(patch.stopall)
        patch.object(export, "TEMPLATES", hashes).start()
        self.binary = self.root / "fake-godot"
        self.fake_binary()

    def git(self, *args):
        return export.run(["git", *args], self.root).strip()

    def fake_binary(self, mode="pass"):
        self.binary.write_text(f'''#!{sys.executable}
import json, os, sys
from pathlib import Path
args = sys.argv[1:]
if args == ["--version"]:
    print({export.ENGINE if mode != "wrong-version" else "wrong"!r})
    sys.exit(0)
assert (Path(os.environ["XDG_DATA_HOME"]) / "godot/export_templates" / {export.TEMPLATE_VERSION!r} / "version.txt").is_file()
if "--script" in args:
    print(json.dumps({{"probe_store_tests": {"fail" if mode == "test-fail" else "pass"!r}, "failures": []}}))
if "--export-release" in args:
    if {mode == "exit-fail"!r}: sys.exit(7)
    if {mode == "log-error"!r}: print("SCRIPT ERROR: fixture")
    for name in {sorted(export.EXPECTED)!r}:
        if {mode == "missing-file"!r} and name == "index.wasm": continue
        (Path(args[-1]).parent / name).write_text(name)
''')
        self.binary.chmod(0o755)

    def reproduce(self):
        with contextlib.redirect_stdout(io.StringIO()):
            return export.reproduce(self.project, str(self.binary), self.templates)

    def manifest_path(self):
        return self.project / "build" / self.git("rev-parse", "HEAD") / "build-manifest.json"

    def test_success_and_no_reuse(self):
        output = self.reproduce()
        manifest = json.loads(self.manifest_path().read_text())
        self.assertEqual(manifest["source_commit"], self.git("rev-parse", "HEAD"))
        self.assertEqual(set(manifest["files"]), export.EXPECTED)
        self.assertEqual(len(manifest["checks"]), 4)
        self.assertFalse(manifest["hosted_runtime_verified"])
        for name, info in manifest["files"].items():
            self.assertEqual(info["sha256"], export.digest(output / name))
        with self.assertRaises(FileExistsError):
            self.reproduce()

    def test_wrong_version(self):
        self.fake_binary("wrong-version")
        with self.assertRaisesRegex(ValueError, "Unexpected engine"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_wrong_template(self):
        (self.templates / next(iter(export.TEMPLATES))).write_text("changed")
        with self.assertRaisesRegex(ValueError, "digest mismatch"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_dirty_source(self):
        (self.project / "export_presets.cfg").write_text("changed")
        with self.assertRaisesRegex(ValueError, "dirty"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_stale_cache(self):
        (self.project / ".godot").mkdir()
        with self.assertRaisesRegex(ValueError, "import cache"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_failed_store_result(self):
        self.fake_binary("test-fail")
        with self.assertRaisesRegex(ValueError, "did not report a pass"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_nonzero_export(self):
        self.fake_binary("exit-fail")
        with self.assertRaises(subprocess.CalledProcessError):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_logged_error(self):
        self.fake_binary("log-error")
        with self.assertRaisesRegex(ValueError, "emitted an error"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())

    def test_missing_export_file(self):
        self.fake_binary("missing-file")
        with self.assertRaisesRegex(ValueError, "missing expected files"):
            self.reproduce()
        self.assertFalse(self.manifest_path().exists())


if __name__ == "__main__":
    unittest.main(verbosity=2)
