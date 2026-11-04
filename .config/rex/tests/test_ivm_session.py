"""Test the Mac launchd session bootstrap without starting SSH or Rex."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / "scripts/ensure-ivm-session.sh"


class IvmSessionTests(unittest.TestCase):
    def run_bootstrap(self, labels=(), fail=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            log = root / "calls.jsonl"
            stub = root / "rex"
            stub.write_text("""#!/usr/bin/env python3
import json, os, sys
with open(os.environ['CALL_LOG'], 'a') as log:
    log.write(json.dumps({'args': sys.argv[1:], 'remote': os.getenv('REX_SERVER')}) + '\\n')
if sys.argv[1] == 'ls':
    if os.environ['FAIL_LIST'] == '1':
        sys.exit(1)
    print(os.environ['SESSIONS'])
""")
            stub.chmod(0o755)
            env = dict(os.environ, PATH=f"{root}:{os.environ['PATH']}",
                       CALL_LOG=str(log), FAIL_LIST=str(int(fail)),
                       SESSIONS=json.dumps({"sessions": [{"label": label} for label in labels]}),
                       REX_SERVER="remote-ivm")
            result = subprocess.run(["bash", str(SCRIPT), "/path with spaces/tunnel.sh"],
                                    env=env, capture_output=True, text=True)
            calls = [json.loads(line) for line in log.read_text().splitlines()]
            return result, calls

    def test_creates_local_session(self):
        result, calls = self.run_bootstrap(["other"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertTrue(all(call["remote"] is None for call in calls))
        self.assertEqual(calls[1]["args"], ["new", "IVM tunnel", "--window", "SSH",
                                         "--shell=none", "--", "bash", "/path with spaces/tunnel.sh"])

    def test_existing_session_is_not_duplicated(self):
        result, calls = self.run_bootstrap(["IVM tunnel"])
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(len(calls), 1)

    def test_duplicate_labels_fail(self):
        result, calls = self.run_bootstrap(["IVM tunnel", "IVM tunnel"])
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)

    def test_listing_failure_does_not_create(self):
        result, calls = self.run_bootstrap(fail=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)


if __name__ == "__main__":
    unittest.main()
