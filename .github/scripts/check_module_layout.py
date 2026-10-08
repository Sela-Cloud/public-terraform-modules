#!/usr/bin/env python3
"""Check that every module sits where the platform will look for it, for the cloud it claims.

The platform finds modules by path — ``modules/<provider>/<id>`` for the Terraform, and
``frontend/modules/<provider>/<id>`` for the wrapper and its ``ui-metadata.json``. A module
anywhere else is invisible to it, and a module under the wrong cloud is offered to the wrong
customers. None of that fails any Terraform or schema check, which is why it has its own.

Four rules:

L1  Every module directory is exactly ``<root>/<provider>/<id>``, for a known provider.
L2  Every wrapper's ``//modules/...`` source names a child module that exists in this tree.
L3  ...and that child belongs to the same cloud as the wrapper.
L4  A module declares only its own cloud's providers — a module under ``aws/`` requiring
    ``hashicorp/google`` has been filed under the wrong cloud, or copied without adapting.

Exit status is non-zero on any error.
"""

from __future__ import annotations

import os
import re
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

PROVIDERS = ("gcp", "aws", "azure")

#: Each cloud's own Terraform providers. A provider not in *any* list — random, null, time, tls —
#: is cloud-neutral and allowed everywhere; only another cloud's provider is an error.
CLOUD_PROVIDERS = {
    "gcp": {"google", "google-beta"},
    "aws": {"aws", "awscc"},
    "azure": {"azurerm", "azuread", "azapi"},
}

#: A reference to a child module in this same repository, by git ref.
CHILD_SOURCE = re.compile(
    r'source\s*=\s*"git::https://github\.com/Sela-Cloud/public-terraform-modules(?:\.git)?//'
    r'(?P<path>modules/[^"?]+)\?ref=[^"]+"'
)
REQUIRED_PROVIDER = re.compile(r'source\s*=\s*"(?:registry\.terraform\.io/)?hashicorp/(?P<name>[a-z0-9-]+)"')


def _strip_comments(text: str) -> str:
    """Remove `#`, `//` and `/* */` comments, but only outside string literals.

    Outside strings is the whole point. A module source reads `…public-terraform-modules//modules/
    aws/vpc?ref=…`, and a stripper that cuts at any `//` truncates every source line — which made
    the L2 and L3 rules silently unable to match anything until a mutation test showed it.
    """
    out = []
    i, n = 0, len(text)
    in_string = False
    while i < n:
        c = text[i]
        if in_string:
            out.append(c)
            if c == "\\" and i + 1 < n:
                out.append(text[i + 1])
                i += 2
                continue
            if c == '"':
                in_string = False
            i += 1
            continue
        if c == '"':
            in_string = True
            out.append(c)
            i += 1
        elif c == "#" or text.startswith("//", i):
            while i < n and text[i] != "\n":
                i += 1
        elif text.startswith("/*", i):
            end = text.find("*/", i + 2)
            i = n if end == -1 else end + 2
        else:
            out.append(c)
            i += 1
    return "".join(out)


def _tf_files(directory: str):
    for name in sorted(os.listdir(directory)):
        if name.endswith(".tf"):
            path = os.path.join(directory, name)
            with open(path, encoding="utf-8") as handle:
                yield path, handle.read()


def _module_dirs(root: str, marker) -> list[str]:
    """Directories under `root` that are modules, by the marker test, skipping caches."""
    found = []
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = sorted(d for d in dirnames if d not in (".terraform", ".git"))
        if marker(filenames):
            found.append(dirpath)
    return found


def main() -> int:
    errors: list[str] = []

    def error(rule: str, path: str, message: str) -> None:
        errors.append("%s  %s: %s" % (rule, os.path.relpath(path, ROOT), message))

    trees = {
        "modules": lambda files: any(f.endswith(".tf") for f in files),
        "frontend/modules": lambda files: "ui-metadata.json" in files,
    }

    # ── L1: where modules live ───────────────────────────────────────────────
    # A wrapper must be *exactly* two deep: the catalog lists `<provider>/` and reads each entry's
    # ui-metadata.json. A Terraform module need only *start* with `<provider>/<id>` — below that
    # it may keep submodules its parent sources by relative path, as `gcp/iam` does.
    exact_depth = {"frontend/modules": True, "modules": False}
    located: dict[str, list[tuple[str, str, str]]] = {}
    for tree, marker in trees.items():
        base = os.path.join(ROOT, tree)
        located[tree] = []
        for directory in _module_dirs(base, marker):
            parts = os.path.relpath(directory, base).split(os.sep)
            depth_ok = len(parts) == 2 if exact_depth[tree] else len(parts) >= 2
            if not depth_ok or parts[0] not in PROVIDERS:
                error(
                    "L1",
                    directory,
                    "not under %s/<provider>/<id> (provider one of %s), so the platform will "
                    "never find it" % (tree, ", ".join(PROVIDERS)),
                )
                continue
            located[tree].append((parts[0], parts[1], directory))

    # ── L2, L3: wrappers point at real children of their own cloud ───────────
    for provider, _module_id, directory in located["frontend/modules"]:
        for path, text in _tf_files(directory):
            for match in CHILD_SOURCE.finditer(_strip_comments(text)):
                child = match.group("path").rstrip("/")
                child_parts = child.split("/")
                if not os.path.isdir(os.path.join(ROOT, child)):
                    error("L2", path, "sources %s, which does not exist in this tree" % child)
                # `modules/<provider>/<id>[/<submodule>…]` — a wrapper may reach a submodule, as
                # `gcp/iam` does; what matters is the cloud segment.
                elif len(child_parts) < 3 or child_parts[1] != provider:
                    error(
                        "L3",
                        path,
                        "is a %s wrapper sourcing %s — a child module of another cloud"
                        % (provider, child),
                    )

    # ── L4: a module declares only its own cloud's providers ─────────────────
    for tree in trees:
        for provider, _module_id, directory in located[tree]:
            foreign = {
                name for cloud, names in CLOUD_PROVIDERS.items() if cloud != provider for name in names
            }
            for path, text in _tf_files(directory):
                for match in REQUIRED_PROVIDER.finditer(_strip_comments(text)):
                    if match.group("name") in foreign:
                        error(
                            "L4",
                            path,
                            "is filed under %s but requires hashicorp/%s — another cloud's provider"
                            % (provider, match.group("name")),
                        )

    counted = sum(len(entries) for entries in located.values())
    for line in errors:
        print("ERROR  " + line)
    print(
        "\nChecked %d module director%s: %d error(s)"
        % (counted, "y" if counted == 1 else "ies", len(errors))
    )
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
