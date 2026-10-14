#!/usr/bin/env python3
"""Print the release a new one should be compared with, or nothing if there is none.

That is the newest version tag below VERSION, reachable from REF, whose wrappers pin the tag itself.
The last condition is what makes it a *completed* release. The Releases button creates its tag
before release.yml bumps anything, so a release that then failed leaves a tag on a commit whose
wrappers still pin the release before it. Comparing with that tag would treat everything merged
before it as already validated, when no release ever checked it.

Usage:
    previous_release.py VERSION [REF]     REF defaults to HEAD
"""

from __future__ import annotations

import re
import subprocess
import sys

VERSION = re.compile(r"^v(\d+)\.(\d+)(?:\.(\d+))?$")


def git(*args: str) -> subprocess.CompletedProcess:
    return subprocess.run(["git", *args], capture_output=True, text=True, check=False)


def key(tag: str) -> tuple[int, int, int]:
    major, minor, patch = VERSION.match(tag).groups()
    return int(major), int(minor), int(patch or 0)


def pins_itself(tag: str) -> bool:
    """Whether some wrapper in the tagged tree sources this repository at `?ref=<tag>`."""
    return git("grep", "--quiet", "--fixed-strings", '?ref=%s"' % tag, tag, "--", "frontend/modules").returncode == 0


def main() -> int:
    if len(sys.argv) not in (2, 3) or not VERSION.match(sys.argv[1]):
        sys.exit(__doc__)
    version, ref = sys.argv[1], sys.argv[2] if len(sys.argv) == 3 else "HEAD"

    merged = git("tag", "--merged", ref, "--list", "v*")
    if merged.returncode != 0:
        sys.exit("git tag --merged %s failed: %s" % (ref, merged.stderr.strip()))
    candidates = sorted(
        (t for t in merged.stdout.split() if VERSION.match(t) and key(t) < key(version)),
        key=key,
        reverse=True,
    )
    for tag in candidates:
        if pins_itself(tag):
            print(tag)
            return 0
        print("Skipping %s: its wrappers do not pin it, so that release never completed." % tag, file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main())
