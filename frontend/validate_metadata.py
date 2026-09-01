#!/usr/bin/env python3
"""Validate the frontend module catalog: ui-metadata.json against variables.tf / main.tf.

Enforces the rules in docs/MODULE_CONTRACT.md (R1-R9) and the metadata spec in
docs/UI_METADATA_GUIDE_NEW.md that can be checked statically:

  * ui-metadata.json parses, and `module` equals the directory name
  * `resource.variable` is declared in variables.tf as a map(object({...}))
  * every form control maps to an object attribute, a global, or is `ui_only` (R6)
  * every `each.value.X` in main.tf is a real attribute of that object
  * every metadata `globals` entry is declared in variables.tf
  * every `var.X` referenced by main.tf is declared in variables.tf
  * exactly one `module` block per catalog module (R7 - warning, legacy modules exist)
  * the remote `?ref=` pin is uniform across the whole catalog (R8)
  * if an `import` block is present, its module / target / field_map / id_template
    placeholders all resolve against real things

Usage:
    python3 frontend/validate_metadata.py [--root REPO_ROOT] [--modules a,b,c] [--strict]

Exit status 1 if any error-level finding is reported. Python 3 stdlib only.
"""

from __future__ import annotations

import argparse
import glob
import json
import os
import re
import subprocess
import sys

# --------------------------------------------------------------------------------------
# Minimal HCL scanning
#
# Deliberately not a full HCL parser, but it is careful about the things that break naive
# regex approaches:
#   * object attributes are separated by NEWLINES, not commas
#   * single-line blocks (`variable "x" { type = string }`) must not swallow the next block
#   * `count` / `for_each` inside a nested `dynamic` block are not top-level
# All of that falls out of real brace matching plus a comment/string mask.
# --------------------------------------------------------------------------------------

_HEREDOC_RE = re.compile(r"<<-?\s*([A-Za-z_][A-Za-z0-9_]*)")


# Data source identifiers implemented by the platform API's RESOURCE_HANDLERS
# (apps/api/services/gcp_client.py). Mirrored here so this repo's CI can reject a typo like
# "cloudsql.instance" that otherwise passes every check and fails at request time with
# "Unknown resource type". apps/api/tests/test_data_source_registry.py fails if the two lists drift.
KNOWN_DATA_SOURCES = {
    "artifactregistry.locations",
    "artifactregistry.repositories",
    "certificatemanager.certificateMaps",
    "certificatemanager.certificates",
    "certificatemanager.dnsAuthorizations",
    "cloudsql.databaseVersions",
    "cloudsql.flags",
    "cloudsql.instances",
    "cloudsql.sqlInstances",
    "cloudsql.tiers",
    "compute.additionalDisks",
    "compute.additional_disks",
    "compute.disks",
    "compute.globalAddresses",
    "compute.healthChecks",
    "compute.machineTypes",
    "compute.machine_types",
    "compute.managedInstanceGroups",
    "compute.networkEndpointGroups",
    "compute.networks",
    "compute.psa",
    "compute.regions",
    "compute.routers",
    "compute.subnets",
    "compute.subnetworks",
    "compute.unmanagedInstanceGroups",
    "compute.vpc",
    "compute.zones",
    "container.clusters",
    "dns.managedZones",
    "dns.managed_zones",
    "dns.peeringNetworks",
    "gke.clusters",
    "iam.customRoles",
    "iam.custom_roles",
    "iam.roles",
    "iam.sa",
    "iam.serviceAccounts",
    "iam.service_accounts",
    "kms.cryptoKeys",
    "secretmanager.secretVersions",
    "secretmanager.secrets",
    "servicenetworking.connections",
    "servicenetworking.psa",
    "storage.buckets",
    "subnet.subnetworks",
    "vpc.networks",
}


def code_mask(text: str) -> list:
    """Return a per-character mask: True where the char is real code.

    Comments, string literals (including their quotes) and heredoc bodies are False, so
    brace/paren matching never trips over `#`, `"{"` or `${...}`.
    """
    n = len(text)
    mask = [True] * n
    i = 0
    while i < n:
        c = text[i]
        if c == "#" or (c == "/" and text.startswith("//", i)):
            j = text.find("\n", i)
            j = n if j == -1 else j
            mask[i:j] = [False] * (j - i)
            i = j
        elif c == "/" and text.startswith("/*", i):
            j = text.find("*/", i + 2)
            j = n if j == -1 else j + 2
            mask[i:j] = [False] * (j - i)
            i = j
        elif c == "<" and text.startswith("<<", i):
            m = _HEREDOC_RE.match(text, i)
            if not m:
                i += 1
                continue
            tag = m.group(1)
            end_m = re.compile(r"^[ \t]*" + re.escape(tag) + r"[ \t]*$", re.M).search(text, m.end())
            j = end_m.end() if end_m else n
            mask[i:j] = [False] * (j - i)
            i = j
        elif c == '"':
            mask[i] = False
            i += 1
            while i < n:
                if text[i] == "\\":
                    mask[i] = False
                    if i + 1 < n:
                        mask[i + 1] = False
                    i += 2
                    continue
                mask[i] = False
                if text[i] == '"':
                    i += 1
                    break
                i += 1
        else:
            i += 1
    return mask


def strip_comments(text: str) -> str:
    """Blank out comments but keep string contents (so `"${each.value.x}"` still counts)."""
    n = len(text)
    out = list(text)
    i = 0
    while i < n:
        c = text[i]
        if c == "#" or (c == "/" and text.startswith("//", i)):
            j = text.find("\n", i)
            j = n if j == -1 else j
            for k in range(i, j):
                out[k] = " "
            i = j
        elif c == "/" and text.startswith("/*", i):
            j = text.find("*/", i + 2)
            j = n if j == -1 else j + 2
            for k in range(i, j):
                if out[k] != "\n":
                    out[k] = " "
            i = j
        elif c == '"':
            i += 1
            while i < n:
                if text[i] == "\\":
                    i += 2
                    continue
                if text[i] == '"':
                    i += 1
                    break
                i += 1
        else:
            i += 1
    return "".join(out)


class Block:
    __slots__ = ("type", "labels", "body", "body_start", "body_end")

    def __init__(self, btype, labels, body, body_start, body_end):
        self.type = btype
        self.labels = labels
        self.body = body
        self.body_start = body_start
        self.body_end = body_end

    def __repr__(self):  # pragma: no cover - debugging aid
        return "Block(%s, %s)" % (self.type, self.labels)


_HEADER_RE = re.compile(r"([A-Za-z_][A-Za-z0-9_-]*)((?:\s+\"[^\"]*\")*)\s*$")
_LABEL_RE = re.compile(r"\"([^\"]*)\"")


def top_level_blocks(text: str) -> list:
    """Return the top-level blocks of a .tf file via real brace matching."""
    mask = code_mask(text)
    blocks = []
    depth = 0
    open_idx = None
    for i, ch in enumerate(text):
        if not mask[i]:
            continue
        if ch == "{":
            if depth == 0:
                open_idx = i
            depth += 1
        elif ch == "}":
            if depth == 0:
                continue  # unbalanced; ignore
            depth -= 1
            if depth == 0 and open_idx is not None:
                header = text[:open_idx].rsplit("\n", 1)[-1]
                m = _HEADER_RE.search(header)
                if m:
                    labels = _LABEL_RE.findall(m.group(2) or "")
                    blocks.append(Block(m.group(1), labels, text[open_idx + 1 : i], open_idx + 1, i))
                open_idx = None
    return blocks


def flatten_top_level(body: str) -> str:
    """Collapse everything nested inside (), [] or {} so only depth-0 text remains.

    Newlines at depth 0 survive, which is what lets us split object attributes on
    newlines (and on depth-0 commas, which HCL also tolerates).
    """
    mask = code_mask(body)
    out = []
    depth = 0
    for i, ch in enumerate(body):
        if not mask[i]:
            out.append("\n" if (ch == "\n" and depth == 0) else " ")
            continue
        if ch in "([{":
            if depth == 0:
                out.append(ch)
            else:
                out.append(" ")
            depth += 1
        elif ch in ")]}":
            depth = max(0, depth - 1)
            out.append(ch if depth == 0 else " ")
        else:
            out.append(ch if depth == 0 else (" " if ch != "\n" else " "))
    return "".join(out)


_ASSIGN_RE = re.compile(r"^\s*([A-Za-z_][A-Za-z0-9_-]*)\s*=")


def top_level_assignments(body: str) -> list:
    """Names assigned at depth 0 of a block/object body, in order."""
    names = []
    for piece in re.split(r"[\n,]", flatten_top_level(body)):
        m = _ASSIGN_RE.match(piece)
        if m:
            names.append(m.group(1))
    return names


def top_level_assignment_expr(body: str, name: str):
    """Return the raw right-hand-side text of `name = ...` at depth 0, or None."""
    mask = code_mask(body)
    depth = 0
    i = 0
    n = len(body)
    pat = re.compile(r"\b" + re.escape(name) + r"\s*=(?!=)")
    while i < n:
        if mask[i]:
            if body[i] in "([{":
                depth += 1
            elif body[i] in ")]}":
                depth = max(0, depth - 1)
            elif depth == 0:
                m = pat.match(body, i)
                if m and (i == 0 or not re.match(r"[A-Za-z0-9_.]", body[i - 1])):
                    return _expr_from(body, m.end(), mask)
        i += 1
    return None


def _expr_from(text: str, start: int, mask: list) -> str:
    """Read an expression starting at `start`: to the first depth-0 newline."""
    depth = 0
    i = start
    n = len(text)
    while i < n:
        ch = text[i]
        if mask[i]:
            if ch in "([{":
                depth += 1
            elif ch in ")]}":
                if depth == 0:
                    break
                depth -= 1
            elif ch == "\n" and depth == 0:
                break
        i += 1
    return text[start:i].strip()


def matching_brace(text: str, open_idx: int, mask: list) -> int:
    depth = 0
    for i in range(open_idx, len(text)):
        if not mask[i]:
            continue
        if text[i] in "([{":
            depth += 1
        elif text[i] in ")]}":
            depth -= 1
            if depth == 0:
                return i
    return -1


# --------------------------------------------------------------------------------------
# variables.tf / main.tf models
# --------------------------------------------------------------------------------------

_MAP_OBJECT_RE = re.compile(r"^map\s*\(\s*object\s*\(\s*\{")
_OBJECT_RE = re.compile(r"^object\s*\(\s*\{")


class TerraformVariable:
    def __init__(self, name, type_expr):
        self.name = name
        self.type_expr = type_expr or ""
        self.is_map_object = bool(_MAP_OBJECT_RE.match(self.type_expr))
        self.attributes = []
        if self.is_map_object or _OBJECT_RE.match(self.type_expr):
            self.attributes = self._object_attributes(self.type_expr)

    @staticmethod
    def _object_attributes(type_expr: str) -> list:
        mask = code_mask(type_expr)
        brace = type_expr.find("{")
        while brace != -1 and not mask[brace]:
            brace = type_expr.find("{", brace + 1)
        if brace == -1:
            return []
        end = matching_brace(type_expr, brace, mask)
        if end == -1:
            end = len(type_expr)
        return top_level_assignments(type_expr[brace + 1 : end])


def parse_variables(path: str) -> dict:
    if not os.path.exists(path):
        return {}
    text = open(path, encoding="utf-8").read()
    variables = {}
    for block in top_level_blocks(text):
        if block.type != "variable" or not block.labels:
            continue
        name = block.labels[0]
        variables[name] = TerraformVariable(name, top_level_assignment_expr(block.body, "type"))
    return variables


_FOR_IN_RE = re.compile(r"\bfor\s+([A-Za-z_][A-Za-z0-9_]*)\s*(?:,\s*([A-Za-z_][A-Za-z0-9_]*)\s*)?in\s+")


def _resolve_locals(main_text: str) -> dict:
    locals_map = {}
    for block in top_level_blocks(main_text):
        if block.type != "locals":
            continue
        for name in top_level_assignments(block.body):
            expr = top_level_assignment_expr(block.body, name)
            if expr is not None:
                locals_map[name] = expr
    return locals_map


def each_value_is_primary(expr: str, resource_var: str, locals_map: dict):
    """Does this `for_each` expression iterate values of var.<resource_var> directly?

    Returns (is_primary, extra_attributes). True for `var.x`, for
    `{ for k, v in var.x : k => v if ... }`, for a local that is
    `{ for r in values(var.x) : "..." => r }`, and for `merge(v, { … })`, whose extra keys
    come back as extra_attributes. False when the comprehension descends into a nested list
    (cloud-sql databases, gke node pools) - there `each.value` is a different shape entirely
    and checking it against the primary object would be nonsense.
    """
    empty = set()
    if expr is None:
        return False, empty
    expr = expr.strip()
    m = re.match(r"^local\.([A-Za-z_][A-Za-z0-9_]*)$", expr)
    if m:
        expr = (locals_map.get(m.group(1)) or "").strip()
        if not expr:
            return False, empty
    if re.match(r"^var\.%s$" % re.escape(resource_var), expr):
        return True, empty

    matches = list(_FOR_IN_RE.finditer(expr))
    if not matches:
        return False, empty
    # The OUTERMOST comprehension is the one that decides what each.value looks like; an
    # inner `for` may appear inside the produced value (artifact-registry's merge).
    last = matches[0]
    key_var, val_var = last.group(1), last.group(2)
    loop_value_var = val_var or key_var
    coll = _expr_from(expr, last.end(), code_mask(expr))
    # the collection expression stops at ':' which _expr_from does not know about
    coll = coll.split(":")[0].strip()
    if not re.match(r"^(values\s*\(\s*)?var\.%s\s*\)?$" % re.escape(resource_var), coll):
        return False, empty
    after = expr[last.end() :]
    arrow = after.find("=>")
    if arrow == -1:
        return False, empty
    produced = _expr_from(after, arrow + 2, code_mask(after))
    produced = re.split(r"\bif\b", produced, maxsplit=1)[0].strip()
    if produced == loop_value_var:
        return True, empty
    # `merge(<loop var>, { extra = … })` widens the object rather than replacing it.
    m = re.match(r"^merge\s*\(\s*%s\s*," % re.escape(loop_value_var), produced)
    if m:
        mask = code_mask(produced)
        brace = produced.find("{", m.end())
        while brace != -1 and not mask[brace]:
            brace = produced.find("{", brace + 1)
        if brace != -1:
            end = matching_brace(produced, brace, mask)
            end = len(produced) if end == -1 else end
            return True, set(top_level_assignments(produced[brace + 1 : end]))
        return True, empty
    return False, empty


def _resolve_for_each(for_each, resource_var, locals_map, variables):
    """Work out which variable's object shape `each.value` has inside a block.

    Returns (variable_name, attribute_set), or (None, set()) when the iteration source
    cannot be resolved to a declared map(object) - e.g. a local that flattens a nested
    list, where each.value is a different shape and must not be checked.
    """
    if for_each is None:
        return None, set()
    is_primary, extra = each_value_is_primary(for_each, resource_var, locals_map)
    if is_primary:
        var = variables.get(resource_var)
        return resource_var, (set(var.attributes) if var else set()) | extra
    m = re.match(r"^var\.([A-Za-z_][A-Za-z0-9_]*)$", for_each.strip())
    if m:
        var = variables.get(m.group(1))
        if var is not None and var.is_map_object and var.attributes:
            return m.group(1), set(var.attributes)
    return None, set()


# --------------------------------------------------------------------------------------
# ui-metadata helpers
# --------------------------------------------------------------------------------------


def top_level_fields(meta: dict) -> list:
    """Form controls that must map to object attributes: section fields only.

    Section ids are not controls, and sub-fields under a repeatable/object field's
    `fields` describe the shape of that field's value, not separate attributes.
    """
    fields = []
    for section in meta.get("resource", {}).get("sections", []) or []:
        for field in section.get("fields", []) or []:
            if isinstance(field, dict):
                fields.append(field)
    return fields


def all_field_ids(meta: dict) -> set:
    """Every id anywhere in the metadata (globals, sections, nested, extras)."""
    ids = set()

    def walk(fields):
        for field in fields or []:
            if not isinstance(field, dict):
                continue
            if field.get("id"):
                ids.add(field["id"])
            walk(field.get("fields"))

    walk(meta.get("globals"))
    for section in meta.get("resource", {}).get("sections", []) or []:
        walk(section.get("fields"))
    for extra in meta.get("extras", []) or []:
        walk(extra.get("fields"))
    key_field = meta.get("resource", {}).get("key_field")
    if key_field:
        ids.add(key_field)
    return ids


# --------------------------------------------------------------------------------------
# Findings
# --------------------------------------------------------------------------------------


class Report:
    def __init__(self):
        self.entries = []  # (module, level, rule, message)

    def error(self, module, rule, message):
        self.entries.append((module, "error", rule, message))

    def note(self, module, rule, message):
        """Neither an error nor a warning: something true and worth seeing, needing no action."""
        self.entries.append((module, "note", rule, message))

    def warn(self, module, rule, message):
        self.entries.append((module, "warning", rule, message))

    def for_module(self, module):
        return [e for e in self.entries if e[0] == module]

    @property
    def errors(self):
        return [e for e in self.entries if e[1] == "error"]

    @property
    def warnings(self):
        return [e for e in self.entries if e[1] == "warning"]

    @property
    def notes(self):
        return [e for e in self.entries if e[1] == "note"]


# --------------------------------------------------------------------------------------
# Per-module validation
# --------------------------------------------------------------------------------------

_SOURCE_SUBPATH_RE = re.compile(r"//modules/([^?\"]+)\?ref=")
_REF_RE = re.compile(r"\?ref=([^\"&\s]+)")


def validate_module(root: str, name: str, report: Report) -> dict:
    """Validate one frontend/modules/<name>. Returns collected refs for the R8 check."""
    mod_dir = os.path.join(root, "frontend", "modules", name)
    meta_path = os.path.join(mod_dir, "ui-metadata.json")
    main_path = os.path.join(mod_dir, "main.tf")
    vars_path = os.path.join(mod_dir, "variables.tf")

    result = {"refs": set()}

    if not os.path.exists(meta_path):
        report.error(name, "metadata", "ui-metadata.json is missing")
        return result
    try:
        meta = json.load(open(meta_path, encoding="utf-8"))
    except json.JSONDecodeError as exc:
        report.error(name, "metadata", "ui-metadata.json is not valid JSON: %s" % exc)
        return result
    if not isinstance(meta, dict):
        report.error(name, "metadata", "ui-metadata.json must contain a JSON object")
        return result

    if meta.get("module") != name:
        report.error(
            name,
            "metadata",
            'module id %r does not match directory name %r' % (meta.get("module"), name),
        )

    main_text = strip_comments(open(main_path, encoding="utf-8").read()) if os.path.exists(main_path) else ""
    if not main_text:
        report.error(name, "main.tf", "main.tf is missing or empty")
    for ref in _REF_RE.findall(main_text):
        result["refs"].add(ref)

    variables = parse_variables(vars_path)
    if not variables:
        report.error(name, "variables.tf", "variables.tf is missing or declares no variables")

    resource = meta.get("resource") or {}
    resource_var = resource.get("variable")
    key_field = resource.get("key_field")

    # ---- resource.variable declared, and a map(object({...})) ----
    primary = None
    if not resource_var:
        report.error(name, "R6", "resource.variable is missing from ui-metadata.json")
    elif resource_var not in variables:
        report.error(
            name, "R6", "resource.variable %r is not declared in variables.tf" % resource_var
        )
    else:
        primary = variables[resource_var]
        if not primary.is_map_object:
            report.error(
                name,
                "R6",
                "variable %r must be map(object({...})); found type %s"
                % (resource_var, (primary.type_expr.splitlines() or ["<none>"])[0].strip() or "<none>"),
            )

    attrs = set(primary.attributes) if primary else set()
    global_ids = {g.get("id") for g in (meta.get("globals") or []) if isinstance(g, dict)}

    # ---- R6: every form control maps to an attribute, a global, or is ui_only ----
    if primary and primary.is_map_object:
        for field in top_level_fields(meta):
            fid = field.get("id")
            if not fid:
                report.error(name, "metadata", "a section field has no id")
                continue
            if field.get("ui_only") is True:
                continue
            if fid in attrs or fid in global_ids:
                continue
            # R5: key_field is legitimately the map key only in several modules.
            if fid == key_field:
                continue
            report.error(
                name,
                "R6",
                "form control %r is not an attribute of %s, not a global, and not ui_only"
                % (fid, resource_var),
            )

    # ---- each.value.X must be a real attribute ----
    if primary and primary.is_map_object and main_text:
        locals_map = _resolve_locals(main_text)
        module_labels = []
        multiple_blocks_note = []
        for block in top_level_blocks(main_text):
            if block.type not in ("module", "resource", "data"):
                continue
            if block.type == "module" and block.labels:
                module_labels.append(block.labels[0])
            # for_each / count only count at the TOP level of the block body, so a
            # `dynamic` block's own for_each is correctly ignored here.
            for_each = top_level_assignment_expr(block.body, "for_each")
            iterated, iterated_attrs = _resolve_for_each(
                for_each, resource_var, locals_map, variables
            )
            if iterated is None:
                if "each.value." in block.body:
                    multiple_blocks_note.append(
                        "%s %s" % (block.type, ".".join(block.labels) or "?")
                    )
                continue
            seen = set()
            for m in re.finditer(r"each\.value\.([A-Za-z_][A-Za-z0-9_]*)", block.body):
                a = m.group(1)
                if a in seen or a in iterated_attrs:
                    continue
                seen.add(a)
                report.error(
                    name,
                    "R6",
                    "main.tf (%s %s) reads each.value.%s, which is not an attribute of %s"
                    % (block.type, ".".join(block.labels) or "?", a, iterated),
                )
        for note in multiple_blocks_note:
            report.warn(
                name,
                "R7",
                "%s iterates something other than var.%s; its each.value references were not checked"
                % (note, resource_var),
            )
        result["module_labels"] = module_labels

    # ---- globals declared in variables.tf ----
    for gid in sorted(i for i in global_ids if i):
        if gid not in variables:
            report.error(
                name, "metadata", "globals entry %r is not declared in variables.tf" % gid
            )

    # ---- extras variables declared (advisory) ----
    for extra in meta.get("extras", []) or []:
        evar = extra.get("variable")
        if evar and evar not in variables:
            report.warn(
                name, "metadata", "extras variable %r is not declared in variables.tf" % evar
            )

    # ---- main.tf references only declared vars ----
    if main_text and variables:
        for ref in sorted(set(re.findall(r"\bvar\.([A-Za-z_][A-Za-z0-9_]*)", main_text))):
            if ref not in variables:
                report.error(
                    name, "main.tf", "main.tf references var.%s, which is not declared in variables.tf" % ref
                )

    # ---- R7: exactly one module block (warning; legacy multi-block modules exist) ----
    module_blocks = [b for b in top_level_blocks(main_text) if b.type == "module"] if main_text else []
    labels = [b.labels[0] if b.labels else "?" for b in module_blocks]
    if len(module_blocks) > 1:
        report.warn(
            name,
            "R7",
            "main.tf declares %d module blocks (%s); R7 wants exactly one"
            % (len(module_blocks), ", ".join(labels)),
        )

    # ---- satellites (R4): advisory, since the block is new and opt-in ----
    # driven_by may name a form control, an object attribute, or an extras variable.
    known_ids = (
        all_field_ids(meta)
        | attrs
        | {e.get("variable") for e in (meta.get("extras") or []) if isinstance(e, dict)}
    )
    for sat in meta.get("satellites", []) or []:
        if not isinstance(sat, dict):
            report.warn(name, "R4", "satellites entries must be objects")
            continue
        if not sat.get("address"):
            report.warn(name, "R4", "a satellites entry has no address")
        driven_by = sat.get("driven_by")
        if driven_by and driven_by not in known_ids:
            report.warn(
                name,
                "R4",
                "satellite %s is driven_by %r, which is not a field id in this module's metadata"
                % (sat.get("address"), driven_by),
            )

    # ---- data sources ----
    check_data_sources(name, meta, report)

    # ---- provides ----
    check_provides(name, meta, report)

    # ---- import block ----
    imp = meta.get("import")
    if isinstance(imp, dict):
        validate_import(root, name, meta, imp, main_text, module_blocks, labels, report)

    return result


def check_data_sources(name, meta, report):
    """Every data_source.resource must be an identifier the API actually implements."""

    def walk(node):
        if isinstance(node, dict):
            ds = node.get("data_source")
            if isinstance(ds, dict) and isinstance(ds.get("resource"), str):
                if ds["resource"] not in KNOWN_DATA_SOURCES:
                    report.error(
                        name,
                        "data_source",
                        "data_source.resource %r is not implemented by the API; it will fail at "
                        "request time with \"Unknown resource type\"" % ds["resource"],
                    )
            for value in node.values():
                walk(value)
        elif isinstance(node, list):
            for value in node:
                walk(value)

    walk(meta)


def check_provides(name, meta, report):
    """A `provides` entry must name a real data source and a real field of this module.

    `provides` is how a module says "a resource of mine can be the value of someone else's field" --
    vpc-network provides `compute.networks`, which is what `subnet.network` needs. The platform uses
    it to offer a resource being created in the same request as a value for a field that would
    otherwise list only what already exists in the cloud. A typo in either half fails silently: the
    field just never offers the new resource, which looks like the feature not working.
    """
    entries = meta.get("provides")
    if entries is None:
        return

    resource = meta.get("resource") or {}
    field_ids = {f.get("id") for f in (meta.get("globals") or []) if isinstance(f, dict)}
    for section in resource.get("sections") or []:
        if isinstance(section, dict):
            field_ids |= {
                f.get("id") for f in (section.get("fields") or []) if isinstance(f, dict)
            }
    # The key field is a value a consumer can use even when it is not itself a declared field --
    # several modules carry the resource name only as `key_field`.
    field_ids.add(resource.get("key_field"))

    for entry in entries:
        if not isinstance(entry, dict):
            continue
        data_source = entry.get("data_source")
        if data_source not in KNOWN_DATA_SOURCES:
            report.error(
                name,
                "provides",
                "provides.data_source %r is not implemented by the API, so no field will ever "
                "match it" % data_source,
            )
        value_field = entry.get("value_field")
        if value_field not in field_ids:
            report.error(
                name,
                "provides",
                "provides.value_field %r is not a field id or the key_field of this module"
                % value_field,
            )

    if meta.get("deprecated"):
        report.warn(
            name,
            "provides",
            "a deprecated module declares provides; new resources should not be steered towards it",
        )


def validate_import(root, name, meta, imp, main_text, module_blocks, labels, report):
    if len(module_blocks) != 1:
        report.error(
            name,
            "R7",
            "import block present but main.tf declares %d module blocks (%s); multi-block modules are not importable"
            % (len(module_blocks), ", ".join(labels)),
        )

    resource = meta.get("resource") or {}
    resource_var = resource.get("variable")
    key_field = resource.get("key_field")
    known_ids = all_field_ids(meta)

    # import.module must be a real module label
    imp_module = imp.get("module") or resource_var
    target_block = None
    if imp_module not in labels:
        report.error(
            name,
            "import",
            "import.module %r does not match any module block in main.tf (found: %s)"
            % (imp_module, ", ".join(labels) or "none"),
        )
    else:
        target_block = module_blocks[labels.index(imp_module)]

    # Every declared target must name a resource in the remote module it wraps. A composite module
    # declares several (`targets`); a single-target module declares one (`target`). Both are checked
    # the same way, because an unverified address is the one mistake that adopts the wrong resource.
    declared = imp.get("targets")
    if declared:
        if not isinstance(declared, list) or not declared:
            report.error(name, "import", "import.targets must be a non-empty array")
            declared = []
        entries = []
        for idx, entry in enumerate(declared or []):
            if not isinstance(entry, dict):
                report.error(name, "import", "import.targets[%d] must be an object" % idx)
                continue
            for key in ("id", "target", "id_template"):
                if not entry.get(key):
                    report.error(
                        name, "import", "import.targets[%d] is missing %s" % (idx, key)
                    )
            entries.append(entry)
        ids = [e.get("id") for e in entries if e.get("id")]
        if len(ids) != len(set(ids)):
            report.error(name, "import", "import.targets ids must be unique: %s" % ids)
        if entries and not any(e.get("required", True) for e in entries):
            report.error(
                name,
                "import",
                "at least one import.targets entry must be required, or an import could succeed "
                "having adopted nothing",
            )
        if imp.get("target"):
            report.error(
                name, "import", "declare either import.target or import.targets, not both"
            )
    else:
        if not imp.get("target"):
            report.error(name, "import", "import.target (or import.targets) is required")
        if not imp.get("id_template"):
            report.error(name, "import", "import.id_template is required")
        entries = [{"id": "primary", "target": imp.get("target"),
                    "id_template": imp.get("id_template"),
                    "field_map": imp.get("field_map")}]

    remote_resources = None
    for entry in entries:
        target = entry.get("target")
        if not target:
            continue
        label = entry.get("id") or "primary"
        if "." not in target:
            report.error(
                name, "import", "target %r (%s) must be '<type>.<name>'" % (target, label)
            )
            continue
        if target.startswith("module."):
            report.error(
                name, "import",
                "target %r (%s) must not include the module.… prefix" % (target, label),
            )
            continue
        if target_block is None:
            continue
        if remote_resources is None:
            source = top_level_assignment_expr(target_block.body, "source") or ""
            m = _SOURCE_SUBPATH_RE.search(source)
            if not m:
                report.warn(
                    name,
                    "import",
                    "could not derive the remote module subpath from source %s; targets unverified"
                    % source,
                )
                remote_resources = set()
            else:
                subpath = m.group(1)
                remote_dir = os.path.join(root, "modules", subpath)
                if not os.path.isdir(remote_dir):
                    report.error(
                        name,
                        "import",
                        "remote module directory modules/%s does not exist, so targets cannot be "
                        "verified" % subpath,
                    )
                    remote_resources = set()
                else:
                    remote_resources = set()
                    for fname in sorted(os.listdir(remote_dir)):
                        if not fname.endswith(".tf"):
                            continue
                        text = open(os.path.join(remote_dir, fname), encoding="utf-8").read()
                        for block in top_level_blocks(text):
                            if block.type == "resource" and len(block.labels) >= 2:
                                remote_resources.add(".".join(block.labels[:2]))
                    remote_resources.add("__subpath__:" + subpath)
        if remote_resources and target not in remote_resources:
            subpath = next(
                (r.split(":", 1)[1] for r in remote_resources if r.startswith("__subpath__:")), "?"
            )
            report.error(
                name,
                "import",
                "target %r (%s) is not declared in modules/%s" % (target, label, subpath),
            )

    # every target's id_template placeholders must be identity fields
    for entry in entries:
        for ph in sorted(set(re.findall(r"\{([^{}]+)\}", entry.get("id_template") or ""))):
            if ph not in (imp.get("identity_fields") or []):
                report.error(
                    name,
                    "import",
                    "target %s id_template placeholder {%s} is not in identity_fields"
                    % (entry.get("id"), ph),
                )

    # field_map values must be real field ids
    field_map = imp.get("field_map") or {}
    if isinstance(field_map, dict):
        for attr, fid in sorted(field_map.items()):
            if fid not in known_ids:
                report.error(
                    name,
                    "import",
                    "import.field_map[%r] = %r is not a field id in this module's metadata"
                    % (attr, fid),
                )

    # id_template placeholders must be listed in identity_fields
    identity = imp.get("identity_fields") or []
    if not isinstance(identity, list):
        report.error(name, "import", "import.identity_fields must be an array")
        identity = []
    template = imp.get("id_template") or ""
    if not template:
        # Only a single-target block needs a spec-level template; a `targets` block carries one per
        # entry, already checked above.
        if not imp.get("targets"):
            report.error(name, "import", "import.id_template is required")
    for fid in identity:
        if fid not in known_ids:
            report.warn(
                name, "import", "identity_fields entry %r is not a field id in this module's metadata" % fid
            )
    if key_field and identity and key_field not in identity:
        report.warn(
            name,
            "import",
            "identity_fields does not include resource.key_field %r" % key_field,
        )

    check_key_preserving_for_each(name, main_text, module_blocks, imp_module, resource_var, report)
    check_target_provider(root, name, main_text, module_blocks, imp_module, imp, report)


def check_key_preserving_for_each(name, main_text, module_blocks, imp_module, resource_var, report):
    """R10: the module block's for_each must keep the tfvars map key.

    An import address is `module.<block>["<tfvars key>"]`. That is only true when the block iterates
    the map itself, or a local that re-emits the same keys. `cloud-dns-record` used to iterate
    `values(var.cloud_dns_record)` re-keyed by "name|type", which discarded the map key and made the
    address unreachable from metadata — an import block built from the key targeted nothing.
    """
    block = next((b for b in module_blocks if b.labels and b.labels[0] == imp_module), None)
    if block is None:
        return
    expr = top_level_assignment_expr(block.body, "for_each")
    if expr is None:
        report.error(name, "R10", "module %r has no for_each; import needs an indexed address" % imp_module)
        return
    expr = expr.strip()
    if expr == "var.%s" % resource_var:
        return
    locals_map = _resolve_locals(main_text)
    # A local is acceptable only if it re-emits the same keys: `for k, v in var.x : k => ...`
    referenced = re.match(r"^local\.([A-Za-z_][A-Za-z0-9_]*)$", expr)
    if referenced:
        body = locals_map.get(referenced.group(1), "")
        if re.search(
            r"for\s+([A-Za-z_]\w*)\s*,\s*[A-Za-z_]\w*\s+in\s+var\.%s\s*:\s*\1\s*=>" % re.escape(resource_var),
            body,
        ):
            return
        if "values(" in body:
            report.error(
                name,
                "R10",
                "module %r iterates local.%s which re-keys via values(var.%s), discarding the tfvars "
                "map key — module.%s[\"<key>\"] is then not the real address"
                % (imp_module, referenced.group(1), resource_var, imp_module),
            )
            return
    report.warn(
        name,
        "R10",
        "module %r iterates %r; import assumes the tfvars map key is the module instance key, "
        "which could not be confirmed" % (imp_module, expr),
    )


def check_target_provider(root, name, main_text, module_blocks, imp_module, imp, report):
    """Derive the provider the target resource is declared against.

    `cloud-run`'s service is `provider = google-beta`. An import block that omits the provider
    resolves against the GA provider instance instead — a different client, silently. This is a fact
    in the repo, so it is derived rather than declared: declaring facts that can be derived is how
    four separate silent-drift defects got into this catalog.
    """
    block = next((b for b in module_blocks if b.labels and b.labels[0] == imp_module), None)
    if block is None:
        return
    src = top_level_assignment_expr(block.body, "source") or ""
    m = re.search(r"//modules/([^?\"']+)\?ref", src)
    if not m:
        return
    target = imp.get("target") or ""
    if "." not in target:
        return
    rtype, _, rname = target.partition(".")
    remote = os.path.join(root, "modules", m.group(1))
    for tf in sorted(glob.glob(os.path.join(remote, "*.tf"))):
        text = strip_comments(open(tf, encoding="utf-8").read())
        blocks = [
            b for b in top_level_blocks(text)
            if b.type == "resource" and len(b.labels) == 2 and b.labels == [rtype, rname]
        ]
        for b in blocks:
            provider = top_level_assignment_expr(b.body, "provider")
            if provider and provider.strip() != "google":
                # Informational, not a problem. Verified against Terraform v1.15.8: an import block
                # targeting `module.<label>["key"].<resource>` resolves the provider from that
                # resource's own configuration inside the module, so the beta provider is used
                # without the import block restating it — a probe against a nonexistent
                # google-beta cluster reached the API and returned 404, not a provider error.
                # It would matter only for a target declared in the wrapper itself, which import
                # never targets.
                report.note(
                    name,
                    "import",
                    "target %s uses provider %s; resolved from the module's own configuration, so "
                    "the generated import block needs no provider argument"
                    % (target, provider.strip()),
                )
            return


# --------------------------------------------------------------------------------------
# Catalog-wide
# --------------------------------------------------------------------------------------


def collect_catalog_refs(root: str, modules: list) -> dict:
    """Every distinct ?ref= pin in every .tf of every wrapper module -> where it appears."""
    refs = {}
    base = os.path.join(root, "frontend", "modules")
    for name in modules:
        mod_dir = os.path.join(base, name)
        for dirpath, dirnames, filenames in os.walk(mod_dir):
            dirnames[:] = [d for d in dirnames if d != ".terraform"]
            for fname in sorted(filenames):
                if not fname.endswith(".tf"):
                    continue
                text = open(os.path.join(dirpath, fname), encoding="utf-8").read()
                for ref in _REF_RE.findall(strip_comments(text)):
                    refs.setdefault(ref, set()).add(name)
    return refs


#: Where the wrappers' ?ref= pins are resolved from. Matches the source= URL in every wrapper.
REMOTE_URL = "https://github.com/Sela-Cloud/public-terraform-modules"


def check_refs_exist(refs, report):
    """A pinned ref that was never tagged breaks everything that runs `terraform init`.

    Uniformity is not enough. Bumping every wrapper to `?ref=v0.5.9` and not tagging it leaves a
    catalog that passes every other check here and fails at `terraform init` with
    `invalid ref: "v0.5.9"` -- for exported code *and* for every deploy, because the worker copies
    these same wrappers and inits them. It is a repository-wide outage produced by a missing git tag,
    so it belongs in CI rather than in a request log.

    A network failure is reported as a warning, not an error: this must not turn an offline run into
    a red build.
    """
    for ref in sorted(refs):
        try:
            result = subprocess.run(
                ["git", "ls-remote", "--tags", "--heads", REMOTE_URL, ref, "refs/tags/" + ref],
                capture_output=True,
                text=True,
                timeout=30,
            )
        except (OSError, subprocess.SubprocessError) as exc:
            report.warn("<catalog>", "R8", "could not verify ref %r exists: %s" % (ref, exc))
            continue
        if result.returncode != 0:
            report.warn(
                "<catalog>",
                "R8",
                "could not verify ref %r exists: git ls-remote failed (%s)"
                % (ref, (result.stderr or "").strip()[:120]),
            )
            continue
        if not result.stdout.strip():
            report.error(
                "<catalog>",
                "R8",
                "wrappers pin ?ref=%s but no such tag or branch exists on %s -- every "
                "`terraform init` will fail with 'invalid ref: \"%s\"'. Tag the release and push "
                "the tag." % (ref, REMOTE_URL, ref),
            )


def main(argv=None):
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    default_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    parser.add_argument("--root", default=default_root, help="repository root (default: %(default)s)")
    parser.add_argument("--modules", help="comma-separated subset of module names to check")
    parser.add_argument(
        "--strict", action="store_true", help="treat warnings as errors (exit 1 on any finding)"
    )
    args = parser.parse_args(argv)

    root = os.path.abspath(args.root)
    base = os.path.join(root, "frontend", "modules")
    if not os.path.isdir(base):
        print("error: %s is not a directory (wrong --root?)" % base, file=sys.stderr)
        return 2

    modules = sorted(d for d in os.listdir(base) if os.path.isdir(os.path.join(base, d)))
    if args.modules:
        wanted = [m.strip() for m in args.modules.split(",") if m.strip()]
        missing = [m for m in wanted if m not in modules]
        if missing:
            print("error: unknown module(s): %s" % ", ".join(missing), file=sys.stderr)
            return 2
        modules = wanted

    report = Report()
    for name in modules:
        validate_module(root, name, report)

    # R8: uniform remote ref across the whole catalog
    refs = collect_catalog_refs(root, modules)
    if len(refs) > 1:
        detail = "; ".join(
            "%s in %s" % (ref, ", ".join(sorted(mods))) for ref, mods in sorted(refs.items())
        )
        report.error("<catalog>", "R8", "remote ?ref= pins are not uniform: %s" % detail)

    # R8b: every pinned ref must actually exist on the remote
    check_refs_exist(refs, report)

    # ---- output ----
    module_order = modules + ["<catalog>"]
    for name in module_order:
        entries = report.for_module(name)
        if not entries:
            continue
        print("%s:" % name)
        for _, level, rule, message in entries:
            print("  %-7s [%s] %s" % (level.upper(), rule, message))
        print()

    n_err = len(report.errors)
    n_warn = len(report.warnings)
    print(
        "Checked %d module(s): %d error(s), %d warning(s)%s"
        % (len(modules), n_err, n_warn, "" if len(refs) != 1 else "; remote ref pinned at %s" % next(iter(refs)))
    )
    if n_err or (args.strict and n_warn):
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
