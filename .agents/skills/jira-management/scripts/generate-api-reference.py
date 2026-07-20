#!/usr/bin/env python3
"""Regenerate references/api-reference.md for the jira-management skill.

Parses the official Jira Cloud platform REST API v3 OpenAPI spec and emits the
full method catalog (Resource Group Index + one table per resource group).

Usage:
    python generate-api-reference.py --spec /path/to/swagger-v3.v3.json
    python generate-api-reference.py --download          # fetch the live spec
    python generate-api-reference.py --spec ... --out /custom/path.md

Requires Python 3.7+, stdlib only. After regenerating, update the Spec Snapshot
table in references/schema-structure.md and bump the skill version per
"Keeping This Skill Current" in that file.
"""
import argparse
import collections
import datetime
import json
import os
import re
import sys
import urllib.request

SPEC_URL = "https://developer.atlassian.com/cloud/jira/platform/swagger-v3.v3.json"
METHODS = ["get", "post", "put", "delete", "patch", "head", "options"]
MORDER = {"GET": 0, "POST": 1, "PUT": 2, "DELETE": 3, "PATCH": 4, "HEAD": 5, "OPTIONS": 6}
INTERNAL_TAG = "Internal (untagged)"


def load_spec(args):
    if args.spec:
        with open(args.spec, encoding="utf-8") as f:
            return json.load(f)
    if args.download:
        print("Downloading %s ..." % SPEC_URL)
        with urllib.request.urlopen(SPEC_URL) as r:
            return json.load(r)
    sys.exit("Provide --spec <file> or --download")


def collect(spec):
    tag_desc = {t["name"]: (t.get("description") or "").strip() for t in spec.get("tags", [])}
    groups, totals, exp_total = collections.OrderedDict(), collections.Counter(), 0
    for path, ops in spec["paths"].items():
        for m in METHODS:
            if m not in ops:
                continue
            op = ops[m]
            tag = (op.get("tags") or [INTERNAL_TAG])[0]
            if path.startswith("/rest/internal/"):
                tag = INTERNAL_TAG
            exp = bool(op.get("x-experimental"))
            exp_total += exp
            totals[m.upper()] += 1
            groups.setdefault(tag, []).append({
                "m": m.upper(), "p": path,
                "id": op.get("operationId", ""),
                "s": (op.get("summary") or "").strip(),
                "exp": exp, "dep": bool(op.get("deprecated")),
            })
    return groups, totals, exp_total, tag_desc


def anchor(t):
    return re.sub(r"[^\w\- ]", "", t.lower()).replace(" ", "-")


def render(spec, groups, totals, exp_total, tag_desc):
    order = sorted(groups.keys(), key=str.lower)
    total = sum(totals.values())
    today = datetime.date.today().isoformat()
    L = [
        "# Jira Cloud Platform REST API v3 — Full Method Reference",
        "",
        "| Field | Value |",
        "| --- | --- |",
        "| Skill | `jira-management` |",
        "| Source | Official Atlassian OpenAPI 3.0.1 spec (`swagger-v3.v3.json`) for The Jira Cloud platform REST API |",
        "| Spec snapshot | `%s` |" % spec["info"].get("version", ""),
        "| Generated | %s (`scripts/generate-api-reference.py`) |" % today,
        "| Base URL | `https://your-domain.atlassian.net` |",
        "| Operations | **%d** total — %d GET, %d POST, %d PUT, %d DELETE |" % (
            total, totals["GET"], totals["POST"], totals["PUT"], totals["DELETE"]),
        "| Experimental | %d operations flagged `x-experimental` |" % exp_total,
        "",
        "This catalog lists **every operation** exposed by the Jira Cloud platform REST API v3, grouped by resource. It documents the full capability of the `jira-management` skill at the **user tier**. Which of these methods an agent may actually invoke in a given repo is governed by the **project-tier scope** (`jira.allowed_methods` / `jira.allowed_operations`) — see [SKILL.md](../SKILL.md#capability--scoping-model). Regenerate this file from a fresh spec download per [schema-structure.md](schema-structure.md#keeping-this-skill-current).",
        "",
        "Legend: 🧪 = experimental (may change without notice, excluded from Atlassian's deprecation policy) · ⚠️ = deprecated. Operations under `/rest/atlassian-connect/` and `/rest/forge/` are for Connect/Forge apps and are not callable with basic auth; the internal endpoint is listed for completeness only and must not be used.",
        "",
        "## Resource Group Index",
        "",
        "| Resource group | GET | POST | PUT | DELETE | Total |",
        "| --- | ---: | ---: | ---: | ---: | ---: |",
    ]
    for tag in order:
        c = collections.Counter(e["m"] for e in groups[tag])
        L.append("| [%s](#%s) | %d | %d | %d | %d | %d |" % (
            tag, anchor(tag), c["GET"], c["POST"], c["PUT"], c["DELETE"], sum(c.values())))
    L += [
        "| **Total** | **%d** | **%d** | **%d** | **%d** | **%d** |" % (
            totals["GET"], totals["POST"], totals["PUT"], totals["DELETE"], total),
        "",
        "## Method Catalog",
        "",
    ]
    for tag in order:
        L.append("### %s" % tag)
        L.append("")
        d = tag_desc.get(tag, "").split("\n")[0].strip()
        if d:
            L += [d, ""]
        L += ["| Method | Path | Operation ID | Summary |", "| --- | --- | --- | --- |"]
        for e in sorted(groups[tag], key=lambda e: (e["p"], MORDER.get(e["m"], 9))):
            flags = (" 🧪" if e["exp"] else "") + (" ⚠️" if e["dep"] else "")
            L.append("| %s | `%s` | `%s` | %s%s |" % (
                e["m"], e["p"], e["id"], e["s"].replace("|", "\\|"), flags))
        L.append("")
    return "\n".join(L) + "\n"


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--spec", help="Path to a downloaded swagger-v3.v3.json")
    ap.add_argument("--download", action="store_true", help="Fetch the live spec from developer.atlassian.com")
    ap.add_argument("--out", help="Output path (default: ../references/api-reference.md relative to this script)")
    args = ap.parse_args()

    out = args.out or os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "references", "api-reference.md")
    spec = load_spec(args)
    groups, totals, exp_total, tag_desc = collect(spec)
    with open(out, "w", encoding="utf-8", newline="\n") as f:
        f.write(render(spec, groups, totals, exp_total, tag_desc))
    print("Wrote %s — %d operations (%s) in %d groups, %d experimental" % (
        os.path.normpath(out), sum(totals.values()),
        ", ".join("%d %s" % (totals[m], m) for m in ("GET", "POST", "PUT", "DELETE")),
        len(groups), exp_total))


if __name__ == "__main__":
    main()
