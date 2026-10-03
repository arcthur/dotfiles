"""Exercise the shell helpers in a disposable Git repository."""

import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path


@unittest.skipUnless(shutil.which("git") and shutil.which("zsh"), "Requires Git and Zsh")
class WorktreeHelpersTest(unittest.TestCase):
    def test_worktree_lifecycle(self) -> None:
        root = Path(__file__).resolve().parents[1]
        source = (root / "zsh/.zshrc").read_text()
        helpers = source[source.index("ga() {") :]
        helpers = helpers.split("# =============================================================================", 1)[0]

        with tempfile.TemporaryDirectory(prefix="dotfiles-worktree-test-") as temp:
            base = Path(temp).resolve()
            helper_file = base / "helpers.zsh"
            helper_file.write_text(helpers)
            repo = base / "main-repo-with-hyphens"
            repo.mkdir()
            subprocess.run(
                ["git", "init", "-b", "main", str(repo)],
                check=True,
                capture_output=True,
            )
            subprocess.run(
                [
                    "git",
                    "-C",
                    str(repo),
                    "-c",
                    "user.name=Test",
                    "-c",
                    "user.email=test@example.com",
                    "-c",
                    "commit.gpgsign=false",
                    "commit",
                    "--allow-empty",
                    "-m",
                    "Initial",
                ],
                check=True,
                capture_output=True,
            )
            # Bypass only the interactive confirmation in this disposable repository.
            script = r'''
set -eu
source "$1"
cd -- "$2"
original_path=$PATH
if gd; then exit 1; fi
[[ $PWD == "$2" ]]
read() { return 0; }
mise() { return 0; }
ga feature/nested-name
[[ $PATH == "$original_path" ]]
wt=$PWD
print dirty > untracked.txt
if gd; then exit 1; fi
[[ $PWD == "$wt" && -f untracked.txt ]]
rm untracked.txt
git -c user.name=Test -c user.email=test@example.com -c commit.gpgsign=false \
  commit --allow-empty -m Unmerged
gd
[[ $PWD == "$2" && ! -d "$wt" ]]
git show-ref --verify --quiet refs/heads/feature/nested-name
ga feature/merged-name
wt=$PWD
gd
[[ ! -d "$wt" ]]
if git show-ref --verify --quiet refs/heads/feature/merged-name; then exit 1; fi
git worktree add --detach ../detached HEAD
cd ../detached
gd
[[ $PWD == "$2" ]]
'''
            result = subprocess.run(
                ["zsh", "-f", "-c", script, "check", str(helper_file), str(repo)],
                text=True,
                capture_output=True,
                timeout=30,
            )
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
