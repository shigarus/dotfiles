"""Check Linux and macOS labels without requiring those directories to exist."""
from pathlib import Path
import subprocess
import unittest

HELPER = Path(__file__).resolve().parents[1] / "scripts/session-name.sh"


class SessionNameTest(unittest.TestCase):
    def test_home_relative_labels(self):
        cases = [
            ("/home/alice/projects/app/", "/home/alice", "projects/app"),
            ("/Users/alice/projects/app/", "/Users/alice", "projects/app"),
            ("/System/Volumes/Data/Users/alice/projects/app/", "/Users/alice", "projects/app"),
            ("/Users/alice/projects/app", "/System/Volumes/Data/Users/alice/", "projects/app"),
            ("/System/Volumes/Data/Users/alice/app", "/System/Volumes/Data/Users/alice", "app"),
            ("/Users/alice/", "/Users/alice", "~"),
            ("/System/Volumes/Data/Users/alice/", "/Users/alice", "~"),
            ("/Users/alice", "/System/Volumes/Data/Users/alice", "~"),
            ("/home/alice/", "/home/alice/", "~"),
            ("/Users/alice-other/app", "/Users/alice", "/Users/alice-other/app"),
            ("/System/Volumes/Data/Users/bob/app", "/Users/alice", "/System/Volumes/Data/Users/bob/app"),
            ("/var/projects/app", "/Users/alice", "/var/projects/app"),
            ("/Users/alice/my.app:dev", "/Users/alice", "my_app_dev"),
            ("/System/Volumes/Data/Users/alice/work ' space\n", "/Users/alice", "work ' space\n"),
            ("/", "/Users/alice", "/"),
            ("/", "/", "~"),
            ("/projects/app/", "/", "projects/app"),
        ]
        for directory, home, expected in cases:
            with self.subTest(directory=directory, home=home):
                result = subprocess.run(
                    ["bash", "-c", 'source "$1"; rex_session_name "$2" "$3"; printf "%s" "$REPLY"',
                     "session-name-test", str(HELPER), directory, home],
                    capture_output=True, text=True, check=True,
                )
                self.assertEqual(result.stdout, expected)


if __name__ == "__main__":
    unittest.main()
