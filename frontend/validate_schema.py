#!/usr/bin/env python3
"""Validate every frontend/modules/*/ui-metadata.json against frontend/ui-metadata.schema.json.

The schema is published to GCS alongside the catalog and sets `additionalProperties: false`
throughout, but nothing used to check the catalog against it -- CI only ran `jq empty`,
which proves a file is well-formed JSON and nothing more. Schema drift was therefore
invisible until it reached a consumer.

This complements validate_metadata.py, which checks metadata against variables.tf /
main.tf but does not read the schema at all.

Usage:
    python3 frontend/validate_schema.py [--root REPO_ROOT] [--modules a,b,c]

Requires `jsonschema`. Exit status 1 if any file violates the schema.
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

try:
    from jsonschema import Draft7Validator
except ImportError:  # pragma: no cover - surfaced as a CI setup error
    sys.exit("validate_schema.py requires the 'jsonschema' package (pip install jsonschema).")


def _format_path(path) -> str:
    """Render a jsonschema error path as a JSON-Pointer-ish location."""
    if not path:
        return "<root>"
    return "".join(
        "[%d]" % part if isinstance(part, int) else ".%s" % part for part in path
    ).lstrip(".")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--root",
        default=str(Path(__file__).resolve().parent.parent),
        help="Repository root (defaults to the parent of frontend/).",
    )
    parser.add_argument(
        "--modules",
        help="Comma-separated module names to check (defaults to every module).",
    )
    args = parser.parse_args()

    root = Path(args.root).resolve()
    schema_path = root / "frontend" / "ui-metadata.schema.json"
    modules_dir = root / "frontend" / "modules"

    if not schema_path.is_file():
        print("ERROR: schema not found at %s" % schema_path)
        return 1

    schema = json.loads(schema_path.read_text())
    Draft7Validator.check_schema(schema)
    validator = Draft7Validator(schema)

    if args.modules:
        wanted = [name.strip() for name in args.modules.split(",") if name.strip()]
        metadata_files = [modules_dir / name / "ui-metadata.json" for name in wanted]
        missing = [str(p) for p in metadata_files if not p.is_file()]
        if missing:
            print("ERROR: no ui-metadata.json for: %s" % ", ".join(missing))
            return 1
    else:
        metadata_files = sorted(
            p
            for p in modules_dir.glob("*/ui-metadata.json")
            if ".terraform" not in p.parts
        )

    if not metadata_files:
        print("ERROR: no ui-metadata.json files found under %s" % modules_dir)
        return 1

    n_err = 0
    for metadata_file in metadata_files:
        try:
            document = json.loads(metadata_file.read_text())
        except json.JSONDecodeError as exc:
            print("%s:\n  ERROR [json] %s" % (metadata_file.relative_to(root), exc))
            n_err += 1
            continue

        errors = sorted(validator.iter_errors(document), key=lambda e: list(e.absolute_path))
        if not errors:
            continue
        print("%s:" % metadata_file.relative_to(root))
        for error in errors:
            print("  ERROR [schema] %s: %s" % (_format_path(error.absolute_path), error.message))
        print()
        n_err += len(errors)

    print(
        "Validated %d ui-metadata.json file(s) against %s: %d error(s)"
        % (len(metadata_files), schema_path.relative_to(root), n_err)
    )
    return 1 if n_err else 0


if __name__ == "__main__":
    sys.exit(main())
