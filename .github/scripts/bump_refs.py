#!/usr/bin/env python3
"""Pin every source that points into this repository at one release tag.

Rewrites ``?ref=`` on every ``git::https://github.com/Sela-Cloud/public-terraform-modules//…``
source, whatever the ref currently says — a previous tag, or a developer's branch left behind by a
merge. It does not try to tell tags from branches: guessing which strings are branch names is
fragile, and "every reference into this repo" is exactly the set that must move together.
Sources pointing anywhere else — the public registry, another repository — are left alone.

Run by the Release workflow *before* tagging, so the tag's own commit carries wrappers that pin
the tag. Tagging first and bumping after would leave the tag pointing at a commit whose wrappers
still name the old ref, which the publish workflow refuses.

Usage:
    bump_refs.py v0.8.0            rewrite in place, print what changed
    bump_refs.py v0.8.0 --check    change nothing; exit 1 if anything would change
"""

from __future__ import annotations

import argparse
import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
TREES = ("frontend/modules", "modules")
VERSION = re.compile(r"^v\d+\.\d+(\.\d+)?$")

#: A source into this repository. The ref is captured so it can be reported, then replaced.
REPO_SOURCE = re.compile(
    r'(?P<head>source\s*=\s*"git::https://github\.com/Sela-Cloud/public-terraform-modules(?:\.git)?//'
    r'[^"?]+\?ref=)(?P<ref>[^"]+)(?P<tail>")'
)


def bump(version: str, write: bool) -> dict[str, dict[str, int]]:
    """Rewrite refs to `version`. Returns {old_ref: {file: count}} for everything that moved."""
    moved: dict[str, dict[str, int]] = {}
    for tree in TREES:
        for dirpath, dirnames, filenames in os.walk(os.path.join(ROOT, tree)):
            dirnames[:] = sorted(d for d in dirnames if d not in (".terraform", ".git"))
            for name in sorted(filenames):
                if not name.endswith(".tf"):
                    continue
                path = os.path.join(dirpath, name)
                with open(path, encoding="utf-8") as handle:
                    text = handle.read()

                def replace(match: re.Match) -> str:
                    old = match.group("ref")
                    if old != version:
                        rel = os.path.relpath(path, ROOT)
                        moved.setdefault(old, {}).setdefault(rel, 0)
                        moved[old][rel] += 1
                    return match.group("head") + version + match.group("tail")

                updated = REPO_SOURCE.sub(replace, text)
                if write and updated != text:
                    with open(path, "w", encoding="utf-8") as handle:
                        handle.write(updated)
    return moved


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("version", help="the release tag, e.g. v0.8.0")
    parser.add_argument("--check", action="store_true", help="report only; exit 1 if stale")
    args = parser.parse_args()

    if not VERSION.match(args.version):
        print("error: %r is not a release version like v0.8.0" % args.version, file=sys.stderr)
        return 2

    moved = bump(args.version, write=not args.check)
    if not moved:
        print("Every source into this repository already pins %s." % args.version)
        return 0

    verb = "Would move" if args.check else "Moved"
    for old, files in sorted(moved.items()):
        count = sum(files.values())
        print("%s %d pin(s) from ?ref=%s to %s:" % (verb, count, old, args.version))
        for path in sorted(files):
            print("  %s" % path)
    return 1 if args.check else 0


if __name__ == "__main__":
    sys.exit(main())
