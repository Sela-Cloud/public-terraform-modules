#!/usr/bin/env python3
"""`terraform init` + `terraform validate` every module a change touches, against itself.

Wrappers reach their child module by git ref of this same repository —
``source = "git::https://github.com/Sela-Cloud/public-terraform-modules//modules/aws/vpc?ref=…"``.
Validating a wrapper as written therefore validates it against whatever that ref points at: the
last release tag, or a developer's branch on the remote. Neither is the code in the change being
reviewed. A PR that renames a child module's variable and updates the wrapper to match would pass
against the old tag if the wrapper still pinned it, and fail against it if it did — the result
says nothing about whether the two halves *in the PR* agree.

So this validates a copy of the tree in which every such source is rewritten to a local path.
What is checked is exactly what will merge, whatever ``?ref=`` the developer wrote. Whether that
ref is acceptable is a separate question, answered by ``validate_metadata.py --ref-mode``.

Usage:
    validate_terraform.py                      every module
    validate_terraform.py --changed-since SHA  only what differs from SHA, plus every wrapper
                                               whose child module is among it
"""

from __future__ import annotations

import argparse
import os
import re
import shutil
import subprocess
import sys
import tempfile

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
PROVIDERS = ("gcp", "aws", "azure")

#: A reference to a module in this repository by git ref — what gets rewritten to a local path.
REPO_SOURCE = re.compile(
    r'(?P<lead>source\s*=\s*)"git::https://github\.com/Sela-Cloud/public-terraform-modules//'
    r'(?P<path>[^"?]+)\?ref=[^"]+"'
)


def module_roots(tree: str) -> list[str]:
    """`<tree>/<provider>/<id>` for every module present, as repository-relative paths."""
    roots = []
    for provider in PROVIDERS:
        base = os.path.join(ROOT, tree, provider)
        if not os.path.isdir(base):
            continue
        for name in sorted(os.listdir(base)):
            if os.path.isdir(os.path.join(base, name)) and not name.startswith("."):
                roots.append("%s/%s/%s" % (tree, provider, name))
    return roots


def children_of(wrapper: str) -> set[str]:
    """The child module roots a wrapper sources, as `modules/<provider>/<id>`."""
    found = set()
    directory = os.path.join(ROOT, wrapper)
    for name in os.listdir(directory):
        if not name.endswith(".tf"):
            continue
        with open(os.path.join(directory, name), encoding="utf-8") as handle:
            for match in REPO_SOURCE.finditer(handle.read()):
                parts = match.group("path").strip("/").split("/")
                if len(parts) >= 3:
                    found.add("/".join(parts[:3]))
    return found


def changed_paths(base: str) -> list[str]:
    result = subprocess.run(
        ["git", "-C", ROOT, "diff", "--name-only", "%s...HEAD" % base],
        capture_output=True,
        text=True,
        check=False,
    )
    if result.returncode != 0:
        sys.exit("git diff against %r failed: %s" % (base, result.stderr.strip()))
    return result.stdout.splitlines()


def select(base: str | None) -> list[str]:
    children = module_roots("modules")
    wrappers = module_roots("frontend/modules")
    if base is None:
        return children + wrappers

    paths = changed_paths(base)
    touched = {
        root for root in children + wrappers if any(p == root or p.startswith(root + "/") for p in paths)
    }
    # A wrapper is affected by a change to the child it sources, even when the wrapper itself
    # is untouched — that is the case a wrapper-only check would miss entirely.
    touched |= {w for w in wrappers if children_of(w) & touched}
    return [root for root in children + wrappers if root in touched]


def localise(copy_root: str) -> int:
    """Rewrite this repository's git sources to local paths, throughout the copy."""
    rewritten = 0
    for dirpath, dirnames, filenames in os.walk(copy_root):
        dirnames[:] = [d for d in dirnames if d not in (".git", ".terraform")]
        for name in filenames:
            if not name.endswith(".tf"):
                continue
            path = os.path.join(dirpath, name)
            with open(path, encoding="utf-8") as handle:
                text = handle.read()

            def local(match: re.Match) -> str:
                nonlocal rewritten
                rewritten += 1
                target = os.path.join(copy_root, match.group("path").strip("/"))
                relative = os.path.relpath(target, dirpath)
                # Terraform treats a source as local only if it begins with ./ or ../
                if not relative.startswith("."):
                    relative = "./" + relative
                return '%s"%s"' % (match.group("lead"), relative)

            updated = REPO_SOURCE.sub(local, text)
            if updated != text:
                with open(path, "w", encoding="utf-8") as handle:
                    handle.write(updated)
    return rewritten


def run(args: list[str], cwd: str) -> tuple[bool, str]:
    result = subprocess.run(args, cwd=cwd, capture_output=True, text=True, check=False)
    return result.returncode == 0, (result.stdout + result.stderr).strip()


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    parser.add_argument("--changed-since", metavar="SHA", help="only modules differing from SHA")
    args = parser.parse_args()

    targets = select(args.changed_since)
    if not targets:
        print("No modules changed; nothing to validate.")
        return 0

    workdir = tempfile.mkdtemp(prefix="validate-terraform-")
    copy_root = os.path.join(workdir, "repo")
    shutil.copytree(
        ROOT, copy_root, ignore=shutil.ignore_patterns(".git", ".terraform", ".terraform.lock.hcl")
    )
    rewritten = localise(copy_root)
    print(
        "Validating %d module(s); %d git source(s) pointed at the local tree.\n"
        % (len(targets), rewritten)
    )

    failures = []
    for target in targets:
        directory = os.path.join(copy_root, target)
        print("::group::%s" % target)
        ok, output = run(["terraform", "init", "-backend=false", "-input=false", "-no-color"], directory)
        if ok:
            ok, output = run(["terraform", "validate", "-no-color"], directory)
        print(output)
        print("::endgroup::")
        if ok:
            print("  ok     %s" % target)
        else:
            failures.append(target)
            print("  FAILED %s" % target)
            # A GitHub annotation, so the failure shows on the PR's Files tab against the module.
            summary = output.splitlines()[-1] if output else "terraform failed"
            print("::error file=%s::%s" % (target, summary.replace("\n", " ")))

    shutil.rmtree(workdir, ignore_errors=True)
    print("\n%d of %d module(s) failed." % (len(failures), len(targets)))
    for target in failures:
        print("  - %s" % target)
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
