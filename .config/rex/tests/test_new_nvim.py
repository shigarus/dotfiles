"""Run with: python3 -m unittest discover -s .config/rex/tests -v"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/new-nvim.sh"


class PickerTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.root = Path(self.temp.name)
        self.directory = self.root / "spaces ' quotes\nand newline"
        self.directory.mkdir()
        self.log = self.root / "calls.jsonl"
        self.env = {
            **os.environ,
            "PATH": f"{self.root}:{os.environ['PATH']}",
            "HOME": str(self.root),
            "REX_BIN_DIR": str(self.root),
            "TEST_DIRECTORY": str(self.directory),
            "TEST_LOG": str(self.log),
            "TEST_FZF_ARGS": str(self.root / "fzf-args.json"),
            "TEST_SESSIONS": "[]",
            "TEST_CANCEL": "0",
        }
        self.stub("fd", "#!/bin/sh\nexit 0\n")
        self.stub("nvim", "#!/bin/sh\nexit 0\n")
        self.stub("fzf", """#!/usr/bin/env python3
import json, os, sys
if sys.argv[1:] == ['--help']:
    print('--scheme=SCHEME' if os.environ.get('TEST_FZF_SCHEME', '1') == '1' else 'old fzf')
    sys.exit(0)
with open(os.environ['TEST_FZF_ARGS'], 'w') as args:
    json.dump(sys.argv[1:], args)
if os.environ.get('TEST_FZF_SCHEME') == '0' and '--scheme=path' in sys.argv:
    print('unknown option: --scheme=path', file=sys.stderr)
    sys.exit(2)
sys.stdin.buffer.read()
if os.environ['TEST_CANCEL'] == '1':
    sys.exit(130)
if os.environ.get('TEST_FZF_EXIT'):
    print('simulated fzf failure', file=sys.stderr)
    sys.exit(int(os.environ['TEST_FZF_EXIT']))
sys.stdout.buffer.write(os.fsencode(os.environ['TEST_DIRECTORY']) + b'\\0')
""")
        self.stub("rex", """#!/usr/bin/env python3
import json, os, sys
args = sys.argv[1:]
with open(os.environ['TEST_LOG'], 'a') as log:
    log.write(json.dumps(args) + '\\n')
if args == ['ls', '--json']:
    print(json.dumps({'sessions': json.loads(os.environ['TEST_SESSIONS'])}))
elif args[0] == 'new':
    print(json.dumps({'session_id': 'session:new'}))
elif args[:2] == ['window', 'new']:
    code = int(os.environ.get('TEST_CREATE_EXIT', '0'))
    if code == 0:
        print(json.dumps({'window_id': 'window:new'}))
    sys.exit(code)
""")

    def stub(self, name, text):
        path = self.root / name
        path.write_text(text)
        path.chmod(0o755)

    def run_picker(self, mode="window", client="client:origin"):
        return subprocess.run(
            ["bash", str(SCRIPT), mode, "session:origin", client],
            env=self.env, capture_output=True, text=True, timeout=10,
        )

    def calls(self):
        return [json.loads(line) for line in self.log.read_text().splitlines()] if self.log.exists() else []

    def test_tab_preserves_directory_and_arguments(self):
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [[
            "window", "new", "-s", "session:origin", "-c", str(self.directory),
            "--json", "--", str(self.root / "nvim"), "-c", "terminal", "-c", "startinsert",
        ], [
            "-C", "client:origin", "do", "session.select",
            "session_id=session:origin", "window_id=window:new",
        ]])

    def test_old_fzf_omits_scheme(self):
        self.env["TEST_FZF_SCHEME"] = "0"
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads((self.root / "fzf-args.json").read_text())
        self.assertNotIn("--scheme=path", args)

    def test_modern_fzf_uses_path_scheme(self):
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        args = json.loads((self.root / "fzf-args.json").read_text())
        self.assertIn("--scheme=path", args)

    def test_rex_bin_dir_restores_cli_missing_from_path(self):
        cli_directory = self.root / "bundled cli"
        cli_directory.mkdir()
        (self.root / "rex").rename(cli_directory / "rex")
        self.env["REX_BIN_DIR"] = str(cli_directory)
        result = self.run_picker("session")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[-1][-1], "session_id=session:new")

    def test_invalid_rex_bin_dir_keeps_existing_path(self):
        self.env["REX_BIN_DIR"] = str(self.root / "missing")
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[0][:2], ["window", "new"])

    def test_tab_requires_target_client(self):
        result = self.run_picker(client="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("target-server Rex client ID", result.stderr)
        self.assertEqual(self.calls(), [])

    def test_session_requires_target_client(self):
        result = self.run_picker("session", client="")
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("target-server Rex client ID", result.stderr)
        self.assertEqual(self.calls(), [])

    def test_cancel_creates_nothing(self):
        self.env["TEST_CANCEL"] = "1"
        result = self.run_picker("session")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls(), [])

    def test_fzf_failure_is_not_cancellation(self):
        self.env["TEST_FZF_EXIT"] = "2"
        result = self.run_picker()
        self.assertNotEqual(result.returncode, 0)
        self.assertIn("simulated fzf failure", result.stderr)
        self.assertIn("fzf failed with exit status 2", result.stderr)
        self.assertEqual(self.calls(), [])

    def test_fzf_no_match_is_cancellation(self):
        self.env["TEST_FZF_EXIT"] = "1"
        self.assertEqual(self.run_picker().returncode, 0)
        self.assertEqual(self.calls(), [])

    def test_fd_failure_does_not_discard_valid_selection(self):
        self.stub("fd", "#!/bin/sh\nexit 141\n")
        result = self.run_picker()
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[-1][-1], "window_id=window:new")

    def test_new_session_switches_invoking_client(self):
        result = self.run_picker("session")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(self.calls()[1][0], "new")
        self.assertEqual(self.calls()[-1], [
            "-C", "client:origin", "do", "session.select", "session_id=session:new",
        ])

    def test_existing_session_is_reused(self):
        label = self.directory.name.replace(".", "_").replace(":", "_")
        self.env["TEST_SESSIONS"] = json.dumps([
            {"label": label + "-other", "session_id": "session:wrong"},
            {"label": label, "session_id": "session:existing"},
        ])
        result = self.run_picker("session")
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(self.calls()), 2)
        self.assertEqual(self.calls()[-1][-1], "session_id=session:existing")

    def test_duplicate_labels_fail_without_switching(self):
        self.env["TEST_SESSIONS"] = json.dumps([
            {"label": self.directory.name, "session_id": f"session:{i}"} for i in range(2)
        ])
        result = self.run_picker("session")
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(self.calls(), [["ls", "--json"]])

    def test_creation_error_is_propagated(self):
        self.env["TEST_CREATE_EXIT"] = "1"
        self.assertNotEqual(self.run_picker().returncode, 0)
        self.assertEqual(len(self.calls()), 1)  # Never select after failed creation.

    def test_missing_directory_creates_nothing(self):
        self.directory.rmdir()
        self.assertNotEqual(self.run_picker().returncode, 0)
        self.assertEqual(self.calls(), [])


if __name__ == "__main__":
    unittest.main()
